import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/news_bloc.dart';
import '../bloc/news_state.dart';
import '../bloc/news_event.dart';
import '../components/post_card.dart';
import '../models/post_model.dart';
import 'post_detail_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // ─────────────────────────────
      // 🔖 APP BAR SUAVE
      // ─────────────────────────────
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: Colors.black,
        title: const Text(
          'Guardados',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: BlocBuilder<NewsBloc, NewsState>(
        builder: (context, state) {
          // 🔄 Loading
          if (state is NewsInitial || state is NewsLoading) {
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

          // ✅ Posts cargados
          if (state is NewsLoaded) {
            final List<Post> bookmarkedPosts = state.posts
                .where((post) => state.bookmarks.contains(post.id))
                .toList();

            // 📭 Empty
            if (bookmarkedPosts.isEmpty) {
              return const _EmptyState(
                icon: Icons.bookmark_border,
                title: 'Sin guardados',
                subtitle: 'Aún no has guardado ninguna noticia',
              );
            }

            // 📋 Listado
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
              itemCount: bookmarkedPosts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final post = bookmarkedPosts[index];

                return PostCard(
                  post: post,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailScreen(post: post),
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.bookmark, color: theme.primaryColor),
                    onPressed: () {
                      context.read<NewsBloc>().add(ToggleBookmark(post));
                    },
                  ),
                );
              },
            );
          }

          // 🧼 Fallback
          return const SizedBox();
        },
      ),
    );
  }
}

// ─────────────────────────────
// 📭 ESTADO VACÍO / ERROR
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
