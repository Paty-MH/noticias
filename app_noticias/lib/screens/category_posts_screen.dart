import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';
import '../components/post_card.dart';
import 'post_detail_screen.dart';

class CategoryPostsScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryPostsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryPostsScreen> createState() => _CategoryPostsScreenState();
}

class _CategoryPostsScreenState extends State<CategoryPostsScreen> {
  @override
  void initState() {
    super.initState();

    // ✅ Cargar posts de la categoría al entrar
    context.read<NewsBloc>().add(FetchPostsByCategory(widget.categoryId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName), centerTitle: true),

      body: BlocBuilder<NewsBloc, NewsState>(
        buildWhen: (_, state) =>
            state is NewsLoading ||
            state is NewsLoaded ||
            state is NewsEmpty ||
            state is NewsError,

        builder: (context, state) {
          // ⏳ Loading
          if (state is NewsLoading) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 3),
            );
          }

          // ❌ Error
          if (state is NewsError) {
            return _EmptyState(
              icon: Icons.error_outline,
              title: 'Error',
              subtitle: state.message,
            );
          }

          // 🚫 Sin posts
          if (state is NewsEmpty) {
            return const _EmptyState(
              icon: Icons.newspaper_outlined,
              title: 'Sin noticias',
              subtitle: 'No hay noticias en esta categoría',
            );
          }

          // ✅ Posts cargados
          if (state is NewsLoaded) {
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
              itemCount: state.posts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final post = state.posts[index];
                final isBookmarked = state.bookmarks.contains(post.id);

                return PostCard(
                  post: post,
                  isBookmarked: isBookmarked,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailScreen(post: post),
                      ),
                    );
                  },
                  onBookmark: () {
                    context.read<NewsBloc>().add(ToggleBookmark(post));
                  },
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

// ─────────────────────────────
// 📭 EMPTY STATE
// ─────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
