import 'package:equatable/equatable.dart';
import '../models/post_model.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object?> get props => [];
}

// ================= HOME POSTS =================

class FetchInitialPosts extends NewsEvent {
  const FetchInitialPosts();
}

class FetchMorePosts extends NewsEvent {
  const FetchMorePosts();
}

// ================= BOOKMARK =================

class ToggleBookmark extends NewsEvent {
  final Post post;

  const ToggleBookmark(this.post);

  @override
  List<Object?> get props => [post];
}

// ================= SEARCH =================

class SearchPosts extends NewsEvent {
  final String query;

  const SearchPosts(this.query);

  @override
  List<Object?> get props => [query];
}

// ================= CATEGORIES =================

class FetchCategories extends NewsEvent {
  const FetchCategories();
}

class FetchPostsByCategory extends NewsEvent {
  final int categoryId;

  const FetchPostsByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
