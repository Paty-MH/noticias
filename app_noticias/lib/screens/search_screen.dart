import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../components/post_card.dart';
import 'post_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List posts = [];
  bool loading = false;
  String? error;

  void doSearch(String q) async {
    if (q.trim().isEmpty) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final prov = Provider.of<NewsProvider>(context, listen: false);
      final res = await prov.search(q);
      setState(() {
        posts = res;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<NewsProvider>(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            onSubmitted: doSearch,
            decoration: InputDecoration(
              hintText: 'Search articles',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  setState(() {
                    posts = [];
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(child: Text('Error: $error'))
              : ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
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
        ),
      ],
    );
  }
}
