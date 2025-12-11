import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import 'post_detail_screen.dart';
import '../components/post_card.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Map<String, dynamic>> cats = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadCats();
  }

  Future<void> loadCats() async {
    try {
      final prov = Provider.of<NewsProvider>(context, listen: false);
      final res = await prov.getCategories();
      setState(() {
        cats = res;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  void openCategory(int id, String name) async {
    setState(() {
      loading = true;
    });
    try {
      final prov = Provider.of<NewsProvider>(context, listen: false);
      final posts = await prov.fetchByCategory(id);
      setState(() {
        loading = false;
      });

      showModalBottomSheet(
        context: context,
        builder: (ctx) => ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, i) {
            final post = posts[i];
            return PostCard(
              post: post,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(post: post),
                  ),
                );
              },
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
    } catch (e) {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text('Error: $error'));

    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: cats.map((c) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, // ✔ color de fondo correcto
            foregroundColor: Colors.black87, // ✔ color del texto/iconos
            padding: const EdgeInsets.all(18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          onPressed: () => openCategory(c['id'] as int, c['name'] as String),
          child: Text(
            (c['name'] ?? '').toString(),
            textAlign: TextAlign.center,
          ),
        );
      }).toList(),
    );
  }
}
