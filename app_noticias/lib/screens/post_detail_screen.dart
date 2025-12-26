import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';

import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';
import '../models/post_model.dart';

// 💬 COMMENTS
import '../comments/bloc/comments_bloc.dart';
import '../comments/bloc/comments_event.dart';
import '../comments/bloc/comments_state.dart';
import '../comments/models/comment_model.dart';
import '../comments/services/comments_service.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CommentsBloc(CommentsService())
            ..add(LoadComments(post.id.toString())),
      child: _PostDetailView(post: post),
    );
  }
}

class _PostDetailView extends StatelessWidget {
  final Post post;

  const _PostDetailView({required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
        title: const Text('Newsnap'),
        actions: [
          BlocBuilder<NewsBloc, NewsState>(
            buildWhen: (_, state) => state is NewsLoaded,
            builder: (context, state) {
              if (state is! NewsLoaded) return const SizedBox();

              final isBookmarked = state.bookmarks.contains(post.id);

              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.purpleAccent,
                ),
                onPressed: () =>
                    context.read<NewsBloc>().add(ToggleBookmark(post)),
              );
            },
          ),
        ],
      ),

      body: CustomScrollView(
        slivers: [
          // 📰 IMAGEN + TITULO
          SliverToBoxAdapter(
            child: Stack(
              children: [
                if (post.featuredImage != null)
                  Image.network(
                    post.featuredImage!,
                    height: 280,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                Container(
                  height: 280,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.9),
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
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 📰 CONTENIDO
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF121212),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Html(
                data: post.content,
                style: {
                  "body": Style(
                    color: Colors.white,
                    fontSize: FontSize(16),
                    lineHeight: LineHeight(1.6),
                  ),
                  "p": Style(color: Colors.white),
                  "h1": Style(color: Colors.purpleAccent),
                  "h2": Style(color: Colors.purpleAccent),
                },
              ),
            ),
          ),

          // 💬 COMENTARIOS
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Comentarios',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  BlocBuilder<CommentsBloc, CommentsState>(
                    builder: (context, state) {
                      if (state is CommentsLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.purpleAccent,
                          ),
                        );
                      }

                      if (state is CommentsLoaded) {
                        if (state.comments.isEmpty) {
                          return const Text(
                            'Sé el primero en comentar 😊',
                            style: TextStyle(color: Colors.grey),
                          );
                        }

                        return Column(
                          children: state.comments.map((Comment c) {
                            return Card(
                              color: const Color(0xFF1E1E1E),
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.person,
                                  color: Colors.purpleAccent,
                                ),
                                title: Text(
                                  c.userName,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  c.content,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                trailing: Text(
                                  DateFormat('dd/MM HH:mm').format(c.createdAt),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }

                      if (state is CommentsError) {
                        return Text(
                          state.message,
                          style: const TextStyle(color: Colors.redAccent),
                        );
                      }

                      return const SizedBox();
                    },
                  ),

                  const SizedBox(height: 16),
                  _AddCommentInput(postId: post.id.toString()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 💬 INPUT COMENTARIO
class _AddCommentInput extends StatefulWidget {
  final String postId;
  const _AddCommentInput({required this.postId});

  @override
  State<_AddCommentInput> createState() => _AddCommentInputState();
}

class _AddCommentInputState extends State<_AddCommentInput> {
  final TextEditingController ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: ctrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Escribe un comentario...',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send, color: Colors.purpleAccent),
          onPressed: () {
            if (ctrl.text.trim().isEmpty) return;

            final authState = context.read<AuthBloc>().state;
            String userName = 'Usuario';
            String userId = '1';

            if (authState is AuthAuthenticated) {
              userName = authState.user.name;
              userId = authState.user.id;
            }

            context.read<CommentsBloc>().add(
              AddComment(
                postId: widget.postId,
                content: ctrl.text.trim(),
                userName: userName,
                userId: userId,
              ),
            );

            ctrl.clear();
          },
        ),
      ],
    );
  }
}
