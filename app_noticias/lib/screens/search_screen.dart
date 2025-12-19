import 'dart:async';
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

    _debounce = Timer(const Duration(milliseconds: 400), () {
      final query = value.trim();

      if (query.length < 2) {
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
          Positioned.fill(
            child: Image.asset('assets/images/news_bg.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),
          SafeArea(
            child: Column(
              children: [
                // 🔍 SEARCH BAR
                AnimatedPadding(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.only(
                    top: _hasSearched
                        ? 20
                        : MediaQuery.of(context).size.height * 0.30,
                    left: 20,
                    right: 20,
                  ),
                  child: _SearchBar(
                    controller: _controller,
                    onChanged: _search,
                    onClear: _clear,
                  ),
                ),

                // 📰 RESULTS
                if (_hasSearched)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: BlocBuilder<NewsBloc, NewsState>(
                        builder: (context, state) {
                          if (state is SearchLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
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
                              title: 'No encontrado',
                              subtitle: 'Intenta con otras palabras',
                            );
                          }

                          if (state is SearchLoaded) {
                            return ListView.separated(
                              padding: const EdgeInsets.all(12),
                              itemCount: state.results.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final post = state.results[index];
                                final isBookmarked = state.bookmarks.contains(
                                  post.id,
                                );

                                return PostCard(
                                  post: post,
                                  isBookmarked: isBookmarked,
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
                                    context.read<NewsBloc>().add(
                                      ToggleBookmark(post),
                                    );
                                  },
                                );
                              },
                            );
                          }

                          return const SizedBox();
                        },
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
// 🔍 SEARCH BAR
// ─────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(30),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Buscar noticias...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(icon: const Icon(Icons.close), onPressed: onClear)
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────
// 📭 EMPTY SEARCH
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
