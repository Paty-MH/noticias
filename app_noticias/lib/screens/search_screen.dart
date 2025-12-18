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

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  bool _hasSearched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String value) {
    final query = value.trim();

    if (query.length < 2) {
      setState(() => _hasSearched = false);
      return;
    }

    setState(() => _hasSearched = true);
    context.read<NewsBloc>().add(SearchPosts(query));
  }

  void _clear() {
    _controller.clear();
    setState(() => _hasSearched = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🖼 FONDO
          Positioned.fill(
            child: Image.asset('assets/images/news_bg.png', fit: BoxFit.cover),
          ),

          // OSCURECER FONDO
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),

          SafeArea(
            child: Column(
              children: [
                // 🔍 BUSCADOR
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

                // 📰 RESULTADOS
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
                        buildWhen: (_, state) =>
                            state is SearchLoading ||
                            state is SearchLoaded ||
                            state is SearchEmpty ||
                            state is NewsError,
                        builder: (context, state) {
                          // ⏳ Cargando
                          if (state is SearchLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          // ❌ Error
                          if (state is NewsError) {
                            return _SearchEmpty(
                              icon: Icons.error_outline,
                              title: 'Error',
                              subtitle: state.message,
                            );
                          }

                          // 🔍 NO ENCONTRADO
                          if (state is SearchEmpty) {
                            return const _SearchEmpty(
                              icon: Icons.search_off,
                              title: 'Noticia no encontrada',
                              subtitle:
                                  'Intenta con otras palabras o revisa la ortografía',
                            );
                          }

                          // ✅ RESULTADOS
                          if (state is SearchLoaded) {
                            return ListView.separated(
                              padding: const EdgeInsets.all(12),
                              itemCount: state.results.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, i) {
                                final post = state.results[i];
                                final bookmarked = state.bookmarks.contains(
                                  post.id,
                                );

                                return PostCard(
                                  post: post,
                                  isBookmarked: bookmarked,
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

// ───────── SEARCH BAR ─────────
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

// ───────── EMPTY SEARCH ─────────
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
