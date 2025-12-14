import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';

import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';
import '../models/post_model.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          BlocBuilder<NewsBloc, NewsState>(
            buildWhen: (previous, current) {
              // 🔑 solo reconstruir si cambia bookmarks
              if (previous is NewsLoaded && current is NewsLoaded) {
                return previous.bookmarks != current.bookmarks;
              }
              if (previous is SearchLoaded && current is SearchLoaded) {
                return previous.bookmarks != current.bookmarks;
              }
              return false;
            },
            builder: (context, state) {
              final bookmarks = state is NewsLoaded
                  ? state.bookmarks
                  : state is SearchLoaded
                  ? state.bookmarks
                  : const <int>[];

              final isBookmarked = bookmarks.contains(post.id);

              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                ),
                onPressed: () {
                  context.read<NewsBloc>().add(ToggleBookmark(post));
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.featuredImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(post.featuredImage!),
              ),
            const SizedBox(height: 16),
            Html(data: post.content),
          ],
        ),
      ),
    );
  }
}
