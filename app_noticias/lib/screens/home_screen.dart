import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';
import '../components/post_card.dart';
import 'post_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();

    // 🔥 Cargar noticias al entrar
    context.read<NewsBloc>().add(const FetchInitialPosts());

    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 300) {
      context.read<NewsBloc>().add(const FetchMorePosts());
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Noticias')),
      body: BlocBuilder<NewsBloc, NewsState>(
        builder: (context, state) {
          // ⏳ Initial / Loading
          if (state is NewsInitial || state is NewsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ Error
          if (state is NewsError) {
            return Center(
              child: Text(state.message, textAlign: TextAlign.center),
            );
          }

          // ✅ Loaded
          if (state is NewsLoaded) {
            if (state.posts.isEmpty) {
              return const Center(
                child: Text(
                  'No hay noticias disponibles',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NewsBloc>().add(const FetchInitialPosts());
              },
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(12),
                itemCount: state.posts.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // 🔄 Loader al final (paginación)
                  if (index == state.posts.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  final post = state.posts[index];
                  final isBookmarked = state.bookmarks.contains(post.id);

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
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      ),
                      onPressed: () {
                        context.read<NewsBloc>().add(ToggleBookmark(post));
                      },
                    ),
                  );
                },
              ),
            );
          }

          // 🧼 Fallback
          return const SizedBox();
        },
      ),
    );
  }
}
