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

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,

        actions: [
          BlocBuilder<NewsBloc, NewsState>(
            buildWhen: (_, state) => state is NewsLoaded,
            builder: (context, state) {
              if (state is! NewsLoaded) {
                return const SizedBox();
              }

              final isBookmarked = state.bookmarks.contains(post.id);

              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.white,
                ),
                onPressed: () {
                  context.read<NewsBloc>().add(ToggleBookmark(post));
                },
              );
            },
          ),
        ],
      ),

      body: CustomScrollView(
        slivers: [
          // ─────────────────────────────
          // 🖼 HEADER
          // ─────────────────────────────
          SliverToBoxAdapter(
            child: Stack(
              children: [
                if (post.featuredImage != null)
                  Image.network(
                    post.featuredImage!,
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),

                Container(
                  height: 260,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 20,
                  child: Text(
                    post.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─────────────────────────────
          // 📄 CONTENIDO
          // ─────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -20, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Html(
                data: post.content,
                style: {
                  "body": Style(
                    margin: Margins.zero,
                    fontSize: FontSize(16),
                    lineHeight: LineHeight(1.7),
                    color: Colors.grey.shade800,
                  ),
                  "p": Style(margin: Margins.only(bottom: 14)),
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
          ),
        ],
      ),
    );
  }
}
