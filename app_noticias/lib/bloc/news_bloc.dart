import 'package:flutter_bloc/flutter_bloc.dart';

import 'news_event.dart';
import 'news_state.dart';
import '../services/api_service.dart';
import '../utils/bookmark_storage.dart';
import '../helpers/constants.dart';
import '../models/post_model.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final ApiService api;

  int _page = 1;
  bool _isFetchingMore = false;

  // 🔖 Bookmarks globales (persisten entre pantallas)
  final List<Post> _globalBookmarkedPosts = [];

  NewsBloc(this.api) : super(const NewsInitial()) {
    on<FetchInitialPosts>(_fetchInitial);
    on<FetchMorePosts>(_fetchMore);
    on<ToggleBookmark>(_toggleBookmark);
    on<SearchPosts>(_search);
    on<FetchCategories>(_fetchCategories);
    on<FetchPostsByCategory>(_fetchByCategory);
  }

  // ─────────────────────────────
  // 📰 FETCH INITIAL POSTS
  // ─────────────────────────────
  Future<void> _fetchInitial(
    FetchInitialPosts event,
    Emitter<NewsState> emit,
  ) async {
    emit(const NewsLoading());

    _page = 1;
    _isFetchingMore = false;

    try {
      final posts = await api.fetchPosts(page: _page);
      final bookmarkedIds = await BookmarkStorage.getBookmarkedIds();

      if (posts.isEmpty) {
        emit(const NewsEmpty());
        return;
      }

      // 🔖 sincronizar bookmarks sin borrar
      for (final post in posts) {
        if (bookmarkedIds.contains(post.id) &&
            !_globalBookmarkedPosts.any((p) => p.id == post.id)) {
          _globalBookmarkedPosts.add(post);
        }
      }

      emit(
        NewsLoaded(
          posts: posts,
          bookmarks: bookmarkedIds,
          bookmarkedPosts: List.from(_globalBookmarkedPosts),
          hasMore: posts.length >= Constants.perPage,
          isFetchingMore: false,
        ),
      );
    } catch (_) {
      emit(const NewsError('No se pudieron cargar las noticias'));
    }
  }

  // ─────────────────────────────
  // 🔄 FETCH MORE (FINITO)
  // ─────────────────────────────
  Future<void> _fetchMore(FetchMorePosts event, Emitter<NewsState> emit) async {
    if (_isFetchingMore || state is! NewsLoaded) return;

    final current = state as NewsLoaded;
    if (!current.hasMore) return;

    _isFetchingMore = true;
    emit(current.copyWith(isFetchingMore: true));

    try {
      // ⏳ UX: máximo 1 segundo
      await Future.delayed(const Duration(seconds: 1));

      final nextPage = _page + 1;
      final more = await api.fetchPosts(page: nextPage);

      _page = nextPage;

      // 🚫 No hay más noticias
      if (more.isEmpty) {
        emit(current.copyWith(hasMore: false, isFetchingMore: false));
        return;
      }

      for (final post in more) {
        if (current.bookmarks.contains(post.id) &&
            !_globalBookmarkedPosts.any((p) => p.id == post.id)) {
          _globalBookmarkedPosts.add(post);
        }
      }

      emit(
        current.copyWith(
          posts: [...current.posts, ...more],
          bookmarkedPosts: List.from(_globalBookmarkedPosts),
          hasMore: more.length >= Constants.perPage,
          isFetchingMore: false,
        ),
      );
    } catch (_) {
      emit(current.copyWith(isFetchingMore: false));
    } finally {
      _isFetchingMore = false;
    }
  }

  // ─────────────────────────────
  // 🔖 TOGGLE BOOKMARK (FUNCIONA EN TODAS LAS PANTALLAS)
  // ─────────────────────────────
  Future<void> _toggleBookmark(
    ToggleBookmark event,
    Emitter<NewsState> emit,
  ) async {
    final currentState = state;

    final ids = await BookmarkStorage.getBookmarkedIds();
    final exists = ids.contains(event.post.id);

    if (exists) {
      ids.remove(event.post.id);
      _globalBookmarkedPosts.removeWhere((p) => p.id == event.post.id);
    } else {
      ids.add(event.post.id);
      if (!_globalBookmarkedPosts.any((p) => p.id == event.post.id)) {
        _globalBookmarkedPosts.add(event.post);
      }
    }

    await BookmarkStorage.saveBookmarkedIds(ids);

    // 📰 HOME / CATEGORÍAS
    if (currentState is NewsLoaded) {
      emit(
        currentState.copyWith(
          bookmarks: ids,
          bookmarkedPosts: List.from(_globalBookmarkedPosts),
        ),
      );
    }

    // 🔍 BUSCADOR (🔥 CLAVE)
    if (currentState is SearchLoaded) {
      emit(SearchLoaded(results: currentState.results, bookmarks: ids));
    }
  }

  // ─────────────────────────────
  // 🔍 SEARCH
  // ─────────────────────────────
  Future<void> _search(SearchPosts event, Emitter<NewsState> emit) async {
    emit(const SearchLoading());

    try {
      final results = await api.searchPosts(event.query);
      final bookmarks = await BookmarkStorage.getBookmarkedIds();

      if (results.isEmpty) {
        emit(const SearchEmpty());
        return;
      }

      emit(SearchLoaded(results: results, bookmarks: bookmarks));
    } catch (_) {
      emit(const NewsError('Error al realizar la búsqueda'));
    }
  }

  // ─────────────────────────────
  // 📂 CATEGORIES
  // ─────────────────────────────
  Future<void> _fetchCategories(
    FetchCategories event,
    Emitter<NewsState> emit,
  ) async {
    try {
      final categories = await api.fetchCategories();

      final filtered =
          categories
              .where((c) => c['count'] > 0 && c['name'] != 'Uncategorized')
              .toList()
            ..sort((a, b) => b['count'].compareTo(a['count']));

      emit(CategoriesLoaded(filtered));
    } catch (_) {
      emit(const NewsError('Error al cargar categorías'));
    }
  }

  // ─────────────────────────────
  // 🏷 POSTS BY CATEGORY
  // ─────────────────────────────
  Future<void> _fetchByCategory(
    FetchPostsByCategory event,
    Emitter<NewsState> emit,
  ) async {
    emit(const NewsLoading());

    try {
      final posts = await api.fetchPostsByCategory(event.categoryId);
      final bookmarkedIds = await BookmarkStorage.getBookmarkedIds();

      if (posts.isEmpty) {
        emit(const NewsEmpty());
        return;
      }

      for (final post in posts) {
        if (bookmarkedIds.contains(post.id) &&
            !_globalBookmarkedPosts.any((p) => p.id == post.id)) {
          _globalBookmarkedPosts.add(post);
        }
      }

      emit(
        NewsLoaded(
          posts: posts,
          bookmarks: bookmarkedIds,
          bookmarkedPosts: List.from(_globalBookmarkedPosts),
          hasMore: false,
          isFetchingMore: false,
        ),
      );
    } catch (_) {
      emit(const NewsError('Error al cargar la categoría'));
    }
  }
}
