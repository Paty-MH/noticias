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
      body: Stack(
        children: [
          // 🌌 FONDO PRO
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.4,
                colors: [
                  Color(0xFF7B2CFF),
                  Color(0xFF1A0033),
                  Colors.black,
                ],
              ),
            ),
          ),

          // ✨ GLOW
          Positioned(
            top: -140,
            left: -140,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purpleAccent.withOpacity(0.25),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 28),

                // 🧠 LOGO
                Column(
                  children: const [
                    Text(
                      'NEWSNAP',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Discover news intelligently',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.4,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // 🔍 SEARCH
                Expanded(
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutExpo,
                    alignment:
                        _hasSearched ? Alignment.topCenter : Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: _hasSearched ? 12 : 0,
                      ),
                      child: _ProSearchBar(
                        controller: _controller,
                        onChanged: _search,
                        onClear: _clear,
                      ),
                    ),
                  ),
                ),

                // 📦 RESULTADOS
                if (_hasSearched)
                  Expanded(
                    flex: 3,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 40 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: _ResultsPanel(),
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
// 🔍 SEARCH BAR PRO
// ─────────────────────────────
class _ProSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _ProSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(36),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.18),
                Colors.white.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: Colors.white24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Search news...',
              hintStyle: const TextStyle(color: Colors.white54),
              border: InputBorder.none,
              icon: const Icon(Icons.search, color: Colors.white),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: onClear,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────
// 📦 PANEL RESULTADOS
// ─────────────────────────────
class _ResultsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.65),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
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
                  title: 'Error',
                  subtitle: state.message,
                );
              }

              if (state is SearchEmpty) {
                return const _SearchEmpty(
                  icon: Icons.search_off,
                  title: 'No results',
                  subtitle: 'Try another keyword',
                );
              }

              if (state is SearchLoaded) {
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: state.results.length,
                  itemBuilder: (context, index) {
                    final post = state.results[index];
                    final isBookmarked = state.bookmarks.contains(post.id);

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 350 + index * 60),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 30 * (1 - value)),
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
