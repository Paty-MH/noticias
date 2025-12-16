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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // ─────────────────────────────
      // 📰 APP BAR SUAVE
      // ─────────────────────────────
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: Colors.black,
        title: Text(
          post.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          BlocBuilder<NewsBloc, NewsState>(
            buildWhen: (previous, current) {
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
                  color: isBookmarked ? theme.primaryColor : Colors.black54,
                ),
                onPressed: () {
                  context.read<NewsBloc>().add(ToggleBookmark(post));
                },
              );
            },
          ),
        ],
      ),

      // ─────────────────────────────
      // 📄 CONTENIDO
      // ─────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 Imagen destacada
            if (post.featuredImage != null)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(post.featuredImage!, fit: BoxFit.cover),
                ),
              ),

            const SizedBox(height: 20),

            // 📄 Contenido HTML
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Html(
                data: post.content,
                style: {
                  "body": Style(
                    margin: Margins.zero,
                    fontSize: FontSize(16),
                    lineHeight: LineHeight(1.6),
                    color: Colors.grey.shade800,
                  ),
                  "p": Style(margin: Margins.only(bottom: 12)),
                  "h1": Style(fontSize: FontSize(22)),
                  "h2": Style(fontSize: FontSize(20)),
                  "h3": Style(fontSize: FontSize(18)),
                  "a": Style(
                    color: theme.primaryColor,
                    textDecoration: TextDecoration.none,
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
