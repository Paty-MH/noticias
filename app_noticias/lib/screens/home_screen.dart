import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';
import '../components/post_card.dart';
import 'post_detail_screen.dart';

// 🔽 COMMENTS
import '../comments/bloc/comments_bloc.dart';
import '../comments/bloc/comments_event.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()..addListener(_onScroll);

    final bloc = context.read<NewsBloc>();
    if (bloc.state is! NewsLoaded) {
      bloc.add(const FetchInitialPosts());
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final state = context.read<NewsBloc>().state;

    if (state is NewsLoaded &&
        state.hasMore &&
        position.pixels >= position.maxScrollExtent - 200) {
      context.read<NewsBloc>().add(const FetchMorePosts());
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // 📰 APPBAR
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.flash_on_rounded, color: Colors.purpleAccent, size: 22),
            SizedBox(width: 6),
            Text(
              'Newsnap',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                letterSpacing: 0.6,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),

      // 📦 BODY
      body: BlocBuilder<NewsBloc, NewsState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildState(context, state),
          );
        },
      ),
    );
  }

  Widget _buildState(BuildContext context, NewsState state) {
    // ⏳ LOADING
    if (state is NewsLoading) {
      return const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: Colors.purpleAccent,
        ),
      );
    }

    // ❌ ERROR
    if (state is NewsError) {
      return _EmptyState(
        key: const ValueKey('error'),
        icon: Icons.error_outline,
        title: 'Ocurrió un error',
        subtitle: state.message,
      );
    }

    // 📭 VACÍO
    if (state is NewsEmpty) {
      return const _EmptyState(
        key: ValueKey('empty'),
        icon: Icons.newspaper_outlined,
        title: 'Sin noticias',
        subtitle: 'No hay noticias disponibles por ahora',
      );
    }

    // ✅ CARGADO
    if (state is NewsLoaded) {
      return RefreshIndicator(
        color: Colors.purpleAccent,
        backgroundColor: Colors.black,
        onRefresh: () async {
          context.read<NewsBloc>().add(const FetchInitialPosts());
        },
        child: ListView.separated(
          key: const ValueKey('list'),
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          itemCount: state.posts.length + (state.hasMore ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index < state.posts.length) {
              final post = state.posts[index];
              final isBookmarked = state.bookmarks.contains(post.id);

              return _AnimatedPostItem(
                index: index,
                child: PostCard(
                  post: post,
                  isBookmarked: isBookmarked,

                  // ✅ NAVEGACIÓN CORRECTA CON COMMENTS BLOC
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) =>
                              CommentsBloc()
                                ..add(LoadComments(post.id.toString())),
                          child: PostDetailScreen(post: post),
                        ),
                      ),
                    );
                  },

                  onBookmark: () {
                    context.read<NewsBloc>().add(ToggleBookmark(post));
                  },
                ),
              );
            }

            // ⏳ CARGANDO MÁS
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.purpleAccent,
                ),
              ),
            );
          },
        ),
      );
    }

    return const SizedBox();
  }
}

// ─────────────────────────────
// 🎞 ANIMACIÓN DE ITEM
// ─────────────────────────────
class _AnimatedPostItem extends StatelessWidget {
  final Widget child;
  final int index;

  const _AnimatedPostItem({required this.child, required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + index * 40),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────
// 📭 EMPTY / ERROR STATE
// ─────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    super.key,
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
            Icon(icon, size: 64, color: Colors.grey.shade600),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }
}
