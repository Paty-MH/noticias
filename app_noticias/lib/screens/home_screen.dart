import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../components/post_card.dart';
import 'post_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<NewsProvider>(context, listen: false);
    provider.fetchInitialPosts();

    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 300) {
        provider.fetchMorePosts();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, prov, _) {
        if (prov.state == ViewState.loading) {
          return const Center(child: CircularProgressIndicator());
        } else if (prov.state == ViewState.error) {
          return Center(child: Text('Error: ${prov.errorMessage}'));
        } else {
          return RefreshIndicator(
            onRefresh: prov.fetchInitialPosts,
            child: ListView.builder(
              controller: _scroll,
              itemCount: prov.posts.length + (prov.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= prov.posts.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final post = prov.posts[index];
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
                      prov.isBookmarked(post.id)
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                    ),
                    onPressed: () => prov.toggleBookmark(post),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
