import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';
import '../utils/bookmark_storage.dart';

enum ViewState { idle, loading, success, error }

class NewsProvider extends ChangeNotifier {
  final ApiService api = ApiService();

  List<Post> posts = [];
  int _page = 1;
  bool hasMore = true;
  ViewState state = ViewState.idle;
  String errorMessage = '';

  // bookmarks
  List<int> bookmarks = [];

  NewsProvider() {
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    bookmarks = await BookmarkStorage.getBookmarkedIds();
    notifyListeners();
  }

  bool isBookmarked(int id) => bookmarks.contains(id);

  Future<void> toggleBookmark(Post post) async {
    if (isBookmarked(post.id)) {
      bookmarks.remove(post.id);
    } else {
      bookmarks.add(post.id);
    }
    await BookmarkStorage.saveBookmarkedIds(bookmarks);
    notifyListeners();
  }

  Future<void> fetchInitialPosts() async {
    state = ViewState.loading;
    notifyListeners();
    try {
      _page = 1;
      final result = await api.fetchPosts(page: _page);
      posts = result;
      hasMore = result.length == 10;
      state = ViewState.success;
    } catch (e) {
      state = ViewState.error;
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> fetchMorePosts() async {
    if (!hasMore) return;
    _page++;
    try {
      final more = await api.fetchPosts(page: _page);
      posts.addAll(more);
      if (more.length < 10) hasMore = false;
      notifyListeners();
    } catch (_) {
      hasMore = false;
      notifyListeners();
    }
  }

  Future<List<Post>> search(String q) async {
    try {
      final res = await api.searchPosts(q);
      return res;
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    return api.fetchCategories();
  }

  Future<List<Post>> fetchByCategory(int id) async {
    return api.fetchPostsByCategory(id);
  }
}
