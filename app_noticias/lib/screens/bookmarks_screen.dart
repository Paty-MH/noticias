import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/news_bloc.dart';
import '../bloc/news_state.dart';
import '../bloc/news_event.dart';
import '../components/post_card.dart';
import '../models/post_model.dart';
import 'post_detail_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guardados')),
      body: BlocBuilder<NewsBloc, NewsState>(
        builder: (context, state) {
          // 🔄 Loading
          if (state is NewsInitial || state is NewsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ Error
          if (state is NewsError) {
            return Center(child: Text(state.message));
          }

          // ✅ Posts cargados
          if (state is NewsLoaded) {
            final List<Post> bookmarkedPosts = state.posts
                .where((post) => state.bookmarks.contains(post.id))
                .toList();

            // 📭 Empty
            if (bookmarkedPosts.isEmpty) {
              return const Center(
                child: Text(
                  'No tienes noticias guardadas',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            // 📋 Listado
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: bookmarkedPosts.length,
              itemBuilder: (context, index) {
                final post = bookmarkedPosts[index];

                return PostCard(
                  post: post,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailScreen(post: post),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.bookmark),
                    onPressed: () {
                      context.read<NewsBloc>().add(ToggleBookmark(post));
                    },
                  ),
                );
              },
            );
          }

          // 🧼 Fallback
          return const Center(child: Text('No hay datos disponibles'));
        },
      ),
    );
  }
}
