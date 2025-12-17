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
  bool _hasRequestedMore = false;

  @override
  void initState() {
    super.initState();

    // 🔥 Cargar noticias al entrar
    context.read<NewsBloc>().add(const FetchInitialPosts());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;

    // 🔥 Cuando falten 250px para el final
    if (current >= max - 250 && !_hasRequestedMore) {
      _hasRequestedMore = true;
      context.read<NewsBloc>().add(const FetchMorePosts());
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // ─────────────────────────────
      // 📰 APP BAR
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

      body: BlocConsumer<NewsBloc, NewsState>(
        listener: (context, state) {
          // 🔄 Permitir nueva carga cuando llegan más posts
          if (state is NewsLoaded) {
            _hasRequestedMore = false;
          }
        },
        builder: (context, state) {
          // ⏳ Loading inicial
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

          // 🚫 Sin posts
          if (state is NewsEmpty) {
            return const _EmptyState(
              icon: Icons.article_outlined,
              title: 'Sin noticias',
              subtitle: 'No hay contenido disponible por ahora',
            );
          }

          // ✅ Noticias cargadas
          if (state is NewsLoaded) {
            return RefreshIndicator(
              color: theme.primaryColor,
              onRefresh: () async {
                context.read<NewsBloc>().add(const FetchInitialPosts());
              },
              child: ListView.builder(
                controller: _scrollController,
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
