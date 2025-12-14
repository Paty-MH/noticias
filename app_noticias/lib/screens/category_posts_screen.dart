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

    // 🔐 pedir posts SOLO una vez
    if (!_loaded) {
      context.read<NewsBloc>().add(
        FetchPostsByCategory(widget.categoryId, widget.categoryName),
      );
      _loaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName), centerTitle: true),
      body: BlocBuilder<NewsBloc, NewsState>(
        builder: (context, state) {
          // 🔄 Loading seguro
          if (state is NewsInitial || state is NewsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ Error
          if (state is NewsError) {
            return Center(child: Text(state.message));
          }

          // ✅ Posts cargados
          if (state is NewsLoaded) {
            if (state.posts.isEmpty) {
              return const Center(
                child: Text(
                  'No hay noticias en esta categoría',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

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

          // 🧼 fallback
          return const Center(child: Text('No hay datos'));
        },
      ),
    );
  }
}
