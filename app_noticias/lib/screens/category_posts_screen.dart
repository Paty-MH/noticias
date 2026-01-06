import 'dart:ui';
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
    context.read<NewsBloc>().add(
          FetchPostsByCategory(widget.categoryId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // 🔥 APPBAR CON BLUR
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.black.withOpacity(0.6),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      ),

      // 🎨 FONDO
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black,
              Color(0xFF1A0033),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: BlocBuilder<NewsBloc, NewsState>(
          buildWhen: (_, state) =>
              state is NewsLoading ||
              state is NewsLoaded ||
              state is NewsEmpty ||
              state is NewsError,
          builder: (context, state) {
            // ⏳ LOADING
            if (state is NewsLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.purpleAccent,
                ),
              );
            }

            // ❌ ERROR
            if (state is NewsError) {
              return _EmptyState(
                icon: Icons.error_outline,
                title: 'Ocurrió un error',
                subtitle: state.message,
              );
            }

            // 🚫 VACÍO
            if (state is NewsEmpty) {
              return const _EmptyState(
                icon: Icons.newspaper_outlined,
                title: 'Sin noticias',
                subtitle: 'No hay noticias en esta categoría',
              );
            }

            // ✅ POSTS
            if (state is NewsLoaded) {
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 28),
                itemCount: state.posts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final post = state.posts[index];
                  final isBookmarked = state.bookmarks.contains(post.id);

                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 300 + index * 40),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: PostCard(
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
                    ),
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
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
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.purpleAccent.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.purpleAccent),
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
