import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../components/post_card.dart';
import 'post_detail_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, prov, _) {
        if (prov.bookmarks.isEmpty) {
          return const Center(child: Text('No bookmarks yet'));
        }

        // Filtrar los posts que ya existen en cache
        final bookmarkedPosts = prov.posts
            .where((post) => prov.bookmarks.contains(post.id))
            .toList();

        if (bookmarkedPosts.isEmpty) {
          return const Center(child: Text("No bookmarks available locally"));
        }

        return ListView.builder(
          itemCount: bookmarkedPosts.length,
          itemBuilder: (context, i) {
            final post = bookmarkedPosts[i];

            return PostCard(
              post: post,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
              ),
              trailing: IconButton(
                icon: Icon(
                  prov.isBookmarked(post.id)
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                ),
                onPressed: () => prov.toggleBookmark(post),
              ),
            );
          },
        );
      },
    );
  }
}
