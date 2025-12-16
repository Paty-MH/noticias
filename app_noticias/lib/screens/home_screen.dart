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
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();

    // 🔥 Cargar noticias al entrar
    context.read<NewsBloc>().add(const FetchInitialPosts());
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 300) {
      context.read<NewsBloc>().add(const FetchMorePosts());
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // ─────────────────────────────
      // 📰 APP BAR SUAVE
      // ─────────────────────────────
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: Colors.black,
        title: const Text(
          'Noticias',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: BlocBuilder<NewsBloc, NewsState>(
        builder: (context, state) {
          // ⏳ Initial / Loading
          if (state is NewsInitial || state is NewsLoading) {
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

          // ✅ Loaded
          if (state is NewsLoaded) {
            if (state.posts.isEmpty) {
              return const _EmptyState(
                icon: Icons.article_outlined,
                title: 'Sin noticias',
                subtitle: 'No hay contenido disponible por ahora',
              );
            }

            return RefreshIndicator(
              color: theme.primaryColor,
              onRefresh: () async {
                context.read<NewsBloc>().add(const FetchInitialPosts());
              },
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
                itemCount: state.posts.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // 🔄 Loader paginación
                  if (index == state.posts.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  final post = state.posts[index];
                  final isBookmarked = state.bookmarks.contains(post.id);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PostCard(
                      post: post,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PostDetailScreen(post: post),
                          ),
                        );
                      },
                      trailing: IconButton(
                        icon: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: isBookmarked
                              ? theme.primaryColor
                              : Colors.grey,
                        ),
                        onPressed: () {
                          context.read<NewsBloc>().add(ToggleBookmark(post));
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          }

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
