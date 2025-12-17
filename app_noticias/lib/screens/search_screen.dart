import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';
import '../components/post_card.dart';
import 'post_detail_screen.dart';

/// 🔥 Categorías detectables (palabras clave)
const Map<String, int> categoryMap = {
  'futbol': 5,
  'deportes': 5,
  'tecnologia': 3,
  'salud': 7,
  'politica': 2,
};

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _hasSearched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 🧼 LIMPIAR BUSCADOR
  void _clearSearch() {
    _controller.clear();
    setState(() => _hasSearched = false);
    context.read<NewsBloc>().add(const FetchInitialPosts());
  }

  // 🔍 BUSCAR DESDE 2 LETRAS + COINCIDENCIA PARCIAL
  void _search(String value) {
    final query = value.trim().toLowerCase();

    // ⛔ Menos de 2 letras → no buscar
    if (query.length < 2) {
      setState(() => _hasSearched = false);
      return;
    }

    setState(() => _hasSearched = true);

    // 🔥 Detectar categoría por coincidencia parcial
    final matchedCategory = categoryMap.entries.firstWhere(
      (entry) => entry.key.contains(query),
      orElse: () => const MapEntry('', -1),
    );

    if (matchedCategory.value != -1) {
      context.read<NewsBloc>().add(FetchPostsByCategory(matchedCategory.value));
      return;
    }

    // 🔎 Búsqueda normal (texto parcial)
    context.read<NewsBloc>().add(SearchPosts(query));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ───────────── HEADER ─────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor,
                    theme.primaryColor.withOpacity(0.85),
                  ],
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Buscar noticias',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🔎 BUSCADOR
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      onChanged: _search, // 🔥 BÚSQUEDA EN TIEMPO REAL
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Buscar noticias.....',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: _clearSearch,
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ),

                  // 🔥 CHIPS DE CATEGORÍAS
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: categoryMap.keys.take(5).map((cat) {
                      return ActionChip(
                        backgroundColor: Colors.white.withOpacity(0.25),
                        label: Text(
                          cat,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          _controller.text = cat;
                          _search(cat);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // ───────────── RESULTADOS ─────────────
            Expanded(
              child: BlocBuilder<NewsBloc, NewsState>(
                buildWhen: (_, state) =>
                    state is NewsLoading ||
                    state is NewsLoaded ||
                    state is SearchLoaded ||
                    state is NewsError ||
                    state is NewsEmpty,
                builder: (_, state) {
                  if (state is NewsLoading && _hasSearched) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 3),
                    );
                  }

                  if (state is NewsError) {
                    return _EmptyState(
                      icon: Icons.error_outline,
                      title: 'Error',
                      subtitle: state.message,
                    );
                  }

                  if (state is SearchLoaded || state is NewsLoaded) {
                    final posts = state is SearchLoaded
                        ? state.results
                        : (state as NewsLoaded).posts;

                    final bookmarks = state is SearchLoaded
                        ? state.bookmarks
                        : (state as NewsLoaded).bookmarks;

                    if (posts.isEmpty) {
                      return const _EmptyState(
                        icon: Icons.search_off,
                        title: 'Sin resultados',
                        subtitle: 'Prueba con otra palabra',
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: posts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final post = posts[i];
                        final bookmarked = bookmarks.contains(post.id);

                        return PostCard(
                          post: post,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PostDetailScreen(post: post),
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              bookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: bookmarked
                                  ? theme.primaryColor
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              context.read<NewsBloc>().add(
                                ToggleBookmark(post),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }

                  return const _EmptyState(
                    icon: Icons.search,
                    title: 'Busca noticias',
                    subtitle: 'Escribe al menos 2 letras',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────── EMPTY STATE ─────────────
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
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
