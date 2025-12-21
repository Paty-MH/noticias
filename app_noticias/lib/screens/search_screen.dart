import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';
import '../components/post_card.dart';
import 'post_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  bool _hasSearched = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _search(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      final query = value.trim();
      if (query.isEmpty) {
        setState(() => _hasSearched = false);
        return;
      }
      setState(() => _hasSearched = true);
      context.read<NewsBloc>().add(SearchPosts(query));
    });
  }

  void _clear() {
    _controller.clear();
    setState(() => _hasSearched = false);
    context.read<NewsBloc>().add(const FetchInitialPosts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🖼 FONDO
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/news_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🌑 OVERLAY
          Container(color: Colors.black.withOpacity(0.6)),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),

                // 📰 HEADER NEWSNAP
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.flash_on_rounded,
                      color: Colors.purpleAccent,
                      size: 26,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Newsnap',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 🔍 SEARCH BAR
                Expanded(
                  child: AnimatedAlign(
                    alignment: _hasSearched
                        ? Alignment.topCenter
                        : Alignment.center,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutQuart,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: _hasSearched ? 16 : 0,
                      ),
                      child: _GlassSearchBar(
                        controller: _controller,
                        onChanged: _search,
                        onClear: _clear,
                      ),
                    ),
                  ),
                ),

                // 🔥 RESULTADOS
                if (_hasSearched)
                  Expanded(
                    flex: 2,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.75),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(32),
                              ),
                            ),
                            child: BlocBuilder<NewsBloc, NewsState>(
                              builder: (context, state) {
                                if (state is SearchLoading) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.purpleAccent,
                                    ),
                                  );
                                }

                                if (state is NewsError) {
                                  return _SearchEmpty(
                                    icon: Icons.error_outline,
                                    title: 'Ocurrió un error',
                                    subtitle: state.message,
                                  );
                                }

                                if (state is SearchEmpty) {
                                  return const _SearchEmpty(
                                    icon: Icons.search_off,
                                    title: 'Sin resultados',
                                    subtitle:
                                        'Intenta con otras palabras clave',
                                  );
                                }

                                if (state is SearchLoaded) {
                                  return ListView.separated(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: state.results.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final post = state.results[index];
                                      final isBookmarked = state.bookmarks
                                          .contains(post.id);

                                      return TweenAnimationBuilder<double>(
                                        tween: Tween(begin: 0, end: 1),
                                        duration: Duration(
                                          milliseconds: 300 + index * 60,
                                        ),
                                        curve: Curves.easeOut,
                                        builder: (context, value, child) {
                                          return Opacity(
                                            opacity: value,
                                            child: Transform.translate(
                                              offset: Offset(
                                                0,
                                                20 * (1 - value),
                                              ),
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
                                                builder: (_) =>
                                                    PostDetailScreen(
                                                      post: post,
                                                    ),
                                              ),
                                            );
                                          },
                                          onBookmark: () {
                                            context.read<NewsBloc>().add(
                                              ToggleBookmark(post),
                                            );
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
// 🔍 GLASS SEARCH BAR
// ─────────────────────────────
class _GlassSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _GlassSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white24),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Buscar en Newsnap...',
              hintStyle: const TextStyle(color: Colors.white70),
              icon: const Icon(Icons.search, color: Colors.white),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: onClear,
                    )
                  : null,
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────
// 📭 EMPTY STATE
// ─────────────────────────────
class _SearchEmpty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SearchEmpty({
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
            Icon(icon, size: 64, color: Colors.white70),
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
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
