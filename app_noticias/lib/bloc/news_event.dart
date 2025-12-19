import 'package:equatable/equatable.dart';
import '../models/post_model.dart';

/// ─────────────────────────────
/// BASE EVENT
/// ─────────────────────────────
abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object?> get props => [];
}

/// ─────────────────────────────
/// 📰 HOME / POSTS
/// ─────────────────────────────

/// Carga inicial de noticias
class FetchInitialPosts extends NewsEvent {
  const FetchInitialPosts();
}

/// Carga más noticias (infinite scroll)
class FetchMorePosts extends NewsEvent {
  const FetchMorePosts();
}

/// ─────────────────────────────
/// 🔖 BOOKMARKS
/// ─────────────────────────────
///
/// 👉 Se envía el Post COMPLETO
/// 👉 El BLoC decide cómo guardarlo

class ToggleBookmark extends NewsEvent {
  final Post post;

  const ToggleBookmark(this.post);

  /// 🔥 Equatable solo con ID (rendimiento + estabilidad)
  @override
  List<Object?> get props => [post.id];
}

/// ─────────────────────────────
/// 🔍 SEARCH
/// ─────────────────────────────

class SearchPosts extends NewsEvent {
  final String query;

  const SearchPosts(this.query);

  @override
  List<Object?> get props => [query];
}

/// ─────────────────────────────
/// 📂 CATEGORIES
/// ─────────────────────────────

class FetchCategories extends NewsEvent {
  const FetchCategories();
}

class FetchPostsByCategory extends NewsEvent {
  final int categoryId;

  const FetchPostsByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
