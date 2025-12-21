import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';
import '../components/post_card.dart';
import '../models/post_model.dart';
import 'post_detail_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        centerTitle: true,
        title: const Text(
          'Guardados',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: BlocBuilder<NewsBloc, NewsState>(
        buildWhen: (_, state) =>
            state is NewsLoaded ||
            state is NewsLoading ||
            state is NewsInitial ||
            state is NewsError,
        builder: (context, state) {
          // ⏳ Loading
          if (state is NewsLoading || state is NewsInitial) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 3),
            );
          }

          // ❌ Error
          if (state is NewsError) {
            return _EmptyState(
              icon: Icons.error_outline,
              title: 'Algo salió mal',
              subtitle: state.message,
            );
          }

          // ✅ Bookmarks
          if (state is NewsLoaded) {
            final List<Post> bookmarkedPosts = state.bookmarkedPosts;

            if (bookmarkedPosts.isEmpty) {
              return const _EmptyState(
                icon: Icons.bookmark_outline,
                title: 'Sin guardados',
                subtitle:
                    'Guarda noticias para leerlas después, incluso sin conexión.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 32),
              physics: const BouncingScrollPhysics(),
              itemCount: bookmarkedPosts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final post = bookmarkedPosts[index];

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: PostCard(
                    post: post,
                    isBookmarked: true,
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
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─────────────────────────────
// 📭 EMPTY STATE (MEJORADO)
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withOpacity(0.12),
              ),
              child: Icon(icon, size: 42, color: colors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
