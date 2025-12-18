import 'package:flutter_bloc/flutter_bloc.dart';

import 'news_event.dart';
import 'news_state.dart';
import '../services/api_service.dart';
import '../utils/bookmark_storage.dart';
import '../helpers/constants.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final ApiService api;

  int _page = 1;
  bool _isFetchingMore = false;

  NewsBloc(this.api) : super(const NewsInitial()) {
    on<FetchInitialPosts>(_fetchInitial);
    on<FetchMorePosts>(_fetchMore);
    on<ToggleBookmark>(_toggleBookmark);
    on<SearchPosts>(_search);
    on<FetchCategories>(_fetchCategories);
    on<FetchPostsByCategory>(_fetchByCategory);
  }

  // ─────────────────────────────
  // 📰 HOME / POSTS
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
      final bookmarks = await BookmarkStorage.getBookmarkedIds();

      if (posts.isEmpty) {
        emit(const NewsEmpty());
        return;
      }

      emit(
        NewsLoaded(
          posts: posts,
          bookmarks: bookmarks,
          hasMore: posts.length == Constants.perPage,
        ),
      );
    } catch (e) {
      emit(const NewsError('No se pudieron cargar las noticias'));
    }
  }

  Future<void> _fetchMore(FetchMorePosts event, Emitter<NewsState> emit) async {
    if (_isFetchingMore) return;
    if (state is! NewsLoaded) return;

    final current = state as NewsLoaded;

    // 🚫 Ya no hay más noticias
    if (!current.hasMore) return;

    _isFetchingMore = true;

    try {
      final nextPage = _page + 1;
      final more = await api.fetchPosts(page: nextPage);

      // 🚫 API ya no devuelve más datos
      if (more.isEmpty) {
        emit(
          NewsLoaded(
            posts: current.posts,
            bookmarks: current.bookmarks,
            hasMore: false,
          ),
        );
        return;
      }

      // ✅ Avanzar página SOLO si hubo resultados
      _page = nextPage;

      emit(
        NewsLoaded(
          posts: [...current.posts, ...more],
          bookmarks: current.bookmarks,
          hasMore: more.length == Constants.perPage,
        ),
      );
    } catch (_) {
      emit(current); // mantener estado anterior
    } finally {
      _isFetchingMore = false;
    }
  }

  // ─────────────────────────────
  // 🔖 BOOKMARKS
  // ─────────────────────────────

  Future<void> _toggleBookmark(
    ToggleBookmark event,
    Emitter<NewsState> emit,
  ) async {
    final bookmarks = await BookmarkStorage.getBookmarkedIds();

    if (bookmarks.contains(event.post.id)) {
      bookmarks.remove(event.post.id);
    } else {
      bookmarks.add(event.post.id);
    }

    await BookmarkStorage.saveBookmarkedIds(bookmarks);

    if (state is NewsLoaded) {
      final s = state as NewsLoaded;
      emit(
        NewsLoaded(posts: s.posts, bookmarks: bookmarks, hasMore: s.hasMore),
      );
    }

    if (state is SearchLoaded) {
      final s = state as SearchLoaded;
      emit(SearchLoaded(results: s.results, bookmarks: bookmarks));
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

      final filtered = categories
          .where(
            (cat) =>
                cat['count'] != null &&
                cat['count'] > 0 &&
                cat['name'] != 'Uncategorized',
          )
          .toList();

      filtered.sort((a, b) => b['count'].compareTo(a['count']));

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
      final bookmarks = await BookmarkStorage.getBookmarkedIds();

      if (posts.isEmpty) {
        emit(const NewsEmpty());
        return;
      }

      emit(
        NewsLoaded(
          posts: posts,
          bookmarks: bookmarks,
          hasMore: false, // 🚫 sin infinite scroll
        ),
      );
    } catch (_) {
      emit(const NewsError('Error al cargar la categoría'));
    }
  }
}
