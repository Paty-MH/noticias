import 'package:flutter_bloc/flutter_bloc.dart';
import 'news_event.dart';
import 'news_state.dart';
import '../services/api_service.dart';
import '../utils/bookmark_storage.dart';
import '../helpers/constants.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final ApiService api;
  int _page = 1;

  NewsBloc(this.api) : super(NewsInitial()) {
    on<FetchInitialPosts>(_fetchInitial);
    on<FetchMorePosts>(_fetchMore);
    on<ToggleBookmark>(_toggleBookmark);
    on<SearchPosts>(_search);
    on<FetchCategories>(_fetchCategories);
    on<FetchPostsByCategory>(_fetchByCategory);
  }

  // ================= POSTS =================

  Future<void> _fetchInitial(
    FetchInitialPosts event,
    Emitter<NewsState> emit,
  ) async {
    emit(NewsLoading());
    try {
      _page = 1;
      final posts = await api.fetchPosts(page: _page);
      final bookmarks = await BookmarkStorage.getBookmarkedIds();

      emit(
        NewsLoaded(
          posts: posts,
          bookmarks: bookmarks,
          hasMore: posts.length == Constants.perPage,
        ),
      );
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }

  Future<void> _fetchMore(FetchMorePosts event, Emitter<NewsState> emit) async {
    if (state is! NewsLoaded) return;
    final current = state as NewsLoaded;

    if (!current.hasMore) return;

    _page++;
    final more = await api.fetchPosts(page: _page);

    emit(
      NewsLoaded(
        posts: [...current.posts, ...more],
        bookmarks: current.bookmarks,
        hasMore: more.length == Constants.perPage,
      ),
    );
  }

  // ================= BOOKMARK =================

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

  // ================= SEARCH =================

  Future<void> _search(SearchPosts event, Emitter<NewsState> emit) async {
    emit(NewsLoading());
    try {
      final results = await api.searchPosts(event.query);
      final bookmarks = await BookmarkStorage.getBookmarkedIds();

      emit(SearchLoaded(results: results, bookmarks: bookmarks));
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }

  // ================= CATEGORIES =================
  // 🚨 NO emitimos NewsLoading aquí para no romper Home

  Future<void> _fetchCategories(
    FetchCategories event,
    Emitter<NewsState> emit,
  ) async {
    try {
      final cats = await api.fetchCategories();
      emit(CategoriesLoaded(cats));
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }

  Future<void> _fetchByCategory(
    FetchPostsByCategory event,
    Emitter<NewsState> emit,
  ) async {
    emit(NewsLoading());
    try {
      final posts = await api.fetchPostsByCategory(event.categoryId);
      final bookmarks = await BookmarkStorage.getBookmarkedIds();

      emit(NewsLoaded(posts: posts, bookmarks: bookmarks, hasMore: false));
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }
}
