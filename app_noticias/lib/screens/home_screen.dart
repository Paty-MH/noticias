import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';
import '../components/post_card.dart';
import 'post_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // 🔥 Cargar noticias iniciales
    context.read<NewsBloc>().add(const FetchInitialPosts());

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // ⬇️ cuando llega al 80% del scroll
    if (currentScroll >= maxScroll * 0.8) {
      final bloc = context.read<NewsBloc>();
      final state = bloc.state;

      if (state is NewsLoaded && state.hasMore) {
        bloc.add(const FetchMorePosts());
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Noticias',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: BlocBuilder<NewsBloc, NewsState>(
        buildWhen: (_, state) =>
            state is NewsLoading ||
            state is NewsLoaded ||
            state is NewsEmpty ||
            state is NewsError,
        builder: (context, state) {
          // ⏳ Loading inicial
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

          // 📭 Sin noticias
          if (state is NewsEmpty) {
            return const _EmptyState(
              icon: Icons.newspaper_outlined,
              title: 'Sin noticias',
              subtitle: 'No hay noticias disponibles',
            );
          }

          // ✅ Noticias cargadas
          if (state is NewsLoaded) {
            return Column(
              children: [
                // ───────── LISTA ─────────
                Expanded(
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),

                    // 🔥 FIX CLAVE
                    itemCount: state.posts.length + (state.hasMore ? 1 : 0),

                    separatorBuilder: (_, __) => const SizedBox(height: 8),

                    itemBuilder: (context, index) {
                      // ───────── POSTS ─────────
                      if (index < state.posts.length) {
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
                      }

                      // ───────── LOADER (solo si hasMore) ─────────
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),

                // ───────── FOOTER FINAL ─────────
                if (!state.hasMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      '📰 Ya no hay más noticias',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
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
