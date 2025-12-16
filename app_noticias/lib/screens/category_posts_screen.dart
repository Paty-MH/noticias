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
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 🔐 Pedir posts SOLO una vez
    if (!_loaded) {
      context.read<NewsBloc>().add(
        FetchPostsByCategory(widget.categoryId), // ✅ CORRECTO
      );
      _loaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName), centerTitle: true),
      body: BlocBuilder<NewsBloc, NewsState>(
        // 🔑 Escuchar SOLO estados de posts
        buildWhen: (_, state) =>
            state is NewsLoading ||
            state is NewsLoaded ||
            state is NewsEmpty ||
            state is NewsError,

        builder: (context, state) {
          // ⏳ Loading SOLO de categoría
          if (state is NewsLoading) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 3),
            );
          }

          // ❌ Error
          if (state is NewsError) {
            return Center(
              child: Text(state.message, style: const TextStyle(fontSize: 16)),
            );
          }

          // 🚫 Sin posts
          if (state is NewsEmpty) {
            return const Center(
              child: Text(
                'No hay noticias en esta categoría',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // ✅ Posts cargados
          if (state is NewsLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.posts.length,
              itemBuilder: (_, i) {
                final post = state.posts[i];
                final bookmarked = state.bookmarks.contains(post.id);

                return PostCard(
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
                      bookmarked ? Icons.bookmark : Icons.bookmark_border,
                    ),
                    onPressed: () {
                      context.read<NewsBloc>().add(ToggleBookmark(post));
                    },
                  ),
                );
              },
            );
          }

          // 🧼 Fallback seguro
          return const SizedBox();
        },
      ),
    );
  }
}
