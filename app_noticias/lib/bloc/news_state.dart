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

class NewsLoaded extends NewsState {
  final List<Post> posts;
  final List<int> bookmarks;
  final bool hasMore;

  const NewsLoaded({
    required this.posts,
    required this.bookmarks,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [posts, bookmarks, hasMore];
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

/// 👉 Cuando NO hay resultados
class SearchEmpty extends NewsState {
  const SearchEmpty();
}

/// 👉 Resultados encontrados
class SearchLoaded extends NewsState {
  final List<Post> results;
  final List<int> bookmarks;

  const SearchLoaded({required this.results, required this.bookmarks});

  @override
  List<Object?> get props => [results, bookmarks];
}

/// ─────────────────────────────
/// 📭 EMPTY / ❌ ERROR
/// ─────────────────────────────

/// 👉 Home sin noticias
class NewsEmpty extends NewsState {
  const NewsEmpty();
}

class NewsError extends NewsState {
  final String message;

  const NewsError(this.message);

  @override
  List<Object?> get props => [message];
}
