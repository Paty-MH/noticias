import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../providers/news_provider.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;
  const PostDetailScreen({required this.post, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<NewsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
        actions: [
          IconButton(
            icon: Icon(
              prov.isBookmarked(post.id)
                  ? Icons.bookmark
                  : Icons.bookmark_border,
            ),
            onPressed: () => prov.toggleBookmark(post),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (post.featuredImage != null)
              Image.network(post.featuredImage!, fit: BoxFit.cover),
            const SizedBox(height: 12),
            Html(data: post.content),
          ],
        ),
      ),
    );
  }
}
