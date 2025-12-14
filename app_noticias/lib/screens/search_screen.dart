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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 🔥 LIMPIAR BUSCADOR (sin romper Home)
  void _clearSearch() {
    _controller.clear();
    setState(() {});
  }

  // 🔍 BUSCAR
  void _doSearch(String q) {
    final query = q.trim();
    if (query.isEmpty) return;

    context.read<NewsBloc>().add(SearchPosts(query));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // ─────────────────────────────
        // 🔎 BUSCADOR
        // ─────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: _doSearch,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar noticias...',
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
        ),

        // ─────────────────────────────
        // 📃 RESULTADOS
        // ─────────────────────────────
        Expanded(
          child: BlocBuilder<NewsBloc, NewsState>(
            buildWhen: (_, state) =>
                state is NewsLoading ||
                state is SearchLoaded ||
                state is NewsError,

            builder: (_, state) {
              // ⏳ Loading SOLO para search
              if (state is NewsLoading) {
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 3),
                );
              }

              // ❌ Error
              if (state is NewsError) {
                return _EmptyState(
                  icon: Icons.error_outline,
                  title: 'Ocurrió un error',
                  subtitle: state.message,
                );
              }

              // ✅ Resultados
              if (state is SearchLoaded) {
                if (state.results.isEmpty) {
                  return const _EmptyState(
                    icon: Icons.search_off,
                    title: 'Sin resultados',
                    subtitle: 'Intenta con otra palabra',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: state.results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final post = state.results[i];
                    final bookmarked = state.bookmarks.contains(post.id);

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
                          bookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: bookmarked ? theme.primaryColor : Colors.grey,
                        ),
                        onPressed: () {
                          context.read<NewsBloc>().add(ToggleBookmark(post));
                        },
                      ),
                    );
                  },
                );
              }

              // 🔍 Estado inicial
              return const _EmptyState(
                icon: Icons.search,
                title: 'Busca una noticia',
                subtitle: 'Escribe una palabra clave arriba',
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────
// 📭 WIDGET DE ESTADO VACÍO
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
