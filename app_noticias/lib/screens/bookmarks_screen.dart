import 'dart:ui';
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
    return Scaffold(
      body: Stack(
        children: [
          // 🌌 FONDO GRADIENT PRO
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A0033),
                  Color(0xFF090014),
                  Colors.black,
                ],
              ),
            ),
          ),

          // ✨ GLOW DECORATIVO
          Positioned(
            top: -120,
            right: -120,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purpleAccent.withOpacity(0.22),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 🧠 APPBAR CUSTOM
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.bookmark_rounded,
                        color: Colors.purpleAccent,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'GUARDADOS',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // 📦 CONTENIDO
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(36)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(36),
                          ),
                        ),
                        child: BlocBuilder<NewsBloc, NewsState>(
                          buildWhen: (_, state) =>
                              state is NewsLoaded ||
                              state is NewsLoading ||
                              state is NewsInitial ||
                              state is NewsError,
                          builder: (context, state) {
                            // ⏳ LOADING
                            if (state is NewsLoading || state is NewsInitial) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.purpleAccent,
                                  strokeWidth: 3,
                                ),
                              );
                            }

                            // ❌ ERROR
                            if (state is NewsError) {
                              return _EmptyState(
                                icon: Icons.error_outline,
                                title: 'Algo salió mal',
                                subtitle: state.message,
                              );
                            }

                            // ✅ BOOKMARKS
                            if (state is NewsLoaded) {
                              final List<Post> bookmarkedPosts =
                                  state.bookmarkedPosts;

                              if (bookmarkedPosts.isEmpty) {
                                return const _EmptyState(
                                  icon: Icons.bookmark_outline,
                                  title: 'Sin guardados',
                                  subtitle:
                                      'Guarda noticias para leerlas después.',
                                );
                              }

                              return ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  20,
                                  16,
                                  36,
                                ),
                                physics: const BouncingScrollPhysics(),
                                itemCount: bookmarkedPosts.length,
                                itemBuilder: (context, index) {
                                  final post = bookmarkedPosts[index];

                                  return TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0, end: 1),
                                    duration: Duration(
                                      milliseconds: 350 + index * 70,
                                    ),
                                    curve: Curves.easeOut,
                                    builder: (context, value, child) {
                                      return Opacity(
                                        opacity: value,
                                        child: Transform.translate(
                                          offset: Offset(
                                            0,
                                            30 * (1 - value),
                                          ),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: PostCard(
                                        post: post,
                                        isBookmarked: true,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  PostDetailScreen(post: post),
                                            ),
                                          );
                                        },
                                        onBookmark: () {
                                          context
                                              .read<NewsBloc>()
                                              .add(ToggleBookmark(post));
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────
// 📭 EMPTY STATE PRO
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
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.purpleAccent.withOpacity(0.35),
                    Colors.purpleAccent.withOpacity(0.15),
                  ],
                ),
              ),
              child: Icon(icon, size: 44, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
