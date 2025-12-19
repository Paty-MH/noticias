import 'package:equatable/equatable.dart';
import '../models/post_model.dart';

/// ─────────────────────────────
/// BASE STATE
/// ─────────────────────────────
abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object?> get props => [];
}

/// ─────────────────────────────
/// ⏳ INITIAL / LOADING
/// ─────────────────────────────

class NewsInitial extends NewsState {
  const NewsInitial();
}

class NewsLoading extends NewsState {
  const NewsLoading();
}

/// ─────────────────────────────
/// 📰 HOME / POSTS
/// ─────────────────────────────
///
/// ✔ Estado inmutable
/// ✔ Bookmarks desacoplados
/// ✔ Soporta infinite scroll

class NewsLoaded extends NewsState {
  final List<Post> posts;
  final List<int> bookmarks;
  final List<Post> bookmarkedPosts;
  final bool hasMore;
  final bool isFetchingMore;

  NewsLoaded({
    required List<Post> posts,
    required List<int> bookmarks,
    required List<Post> bookmarkedPosts,
    required this.hasMore,
    this.isFetchingMore = false,
  }) : posts = List.unmodifiable(posts),
       bookmarks = List.unmodifiable(bookmarks),
       bookmarkedPosts = List.unmodifiable(bookmarkedPosts);

  /// 🔁 helper para actualizar estado sin mutar
  NewsLoaded copyWith({
    List<Post>? posts,
    List<int>? bookmarks,
    List<Post>? bookmarkedPosts,
    bool? hasMore,
    bool? isFetchingMore,
  }) {
    return NewsLoaded(
      posts: posts ?? this.posts,
      bookmarks: bookmarks ?? this.bookmarks,
      bookmarkedPosts: bookmarkedPosts ?? this.bookmarkedPosts,
      hasMore: hasMore ?? this.hasMore,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }

  @override
  List<Object?> get props => [
    posts.map((p) => p.id).toList(),
    bookmarks,
    bookmarkedPosts.map((p) => p.id).toList(),
    hasMore,
    isFetchingMore,
  ];
}

/// ─────────────────────────────
/// 📂 CATEGORIES
/// ─────────────────────────────

class CategoriesLoaded extends NewsState {
  final List<Map<String, dynamic>> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

/// ─────────────────────────────
/// 🔍 SEARCH
/// ─────────────────────────────

class SearchLoading extends NewsState {
  const SearchLoading();
}

class SearchEmpty extends NewsState {
  const SearchEmpty();
}

class SearchLoaded extends NewsState {
  final List<Post> results;
  final List<int> bookmarks;

  const SearchLoaded({required this.results, required this.bookmarks});

  @override
  List<Object?> get props => [results.map((p) => p.id).toList(), bookmarks];
}

/// ─────────────────────────────
/// 📭 EMPTY / ❌ ERROR
/// ─────────────────────────────

class NewsEmpty extends NewsState {
  const NewsEmpty();
}

class NewsError extends NewsState {
  final String message;

  const NewsError(this.message);

  @override
  List<Object?> get props => [message];
}
