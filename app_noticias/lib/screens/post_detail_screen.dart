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
import '../comments/widgets/comment_like_button.dart';

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

      // 🔝 APPBAR
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
        title: const Text('Newsnap'),
      ),

      body: CustomScrollView(
        slivers: [
          // 🖼️ IMAGEN
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
                },
              ),
            ),
          ),

          // 💬 COMENTARIOS
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: BlocBuilder<CommentsBloc, CommentsState>(
                builder: (context, state) {
                  if (state is! CommentsLoaded) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.purpleAccent,
                      ),
                    );
                  }

                  if (state.comments.isEmpty) {
                    return const Text(
                      'Sé el primero en comentar 😊',
                      style: TextStyle(color: Colors.grey),
                    );
                  }

                  return Column(
                    children: state.comments.map((Comment c) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 👤 AVATAR
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.purpleAccent,
                              child: Text(
                                c.userName.isNotEmpty
                                    ? c.userName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // 💬 BURBUJA
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.userName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      c.content,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // ❤️ LIKE + FECHA
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CommentLikeButton(comment: c),
                                        Text(
                                          DateFormat(
                                            'dd MMM · HH:mm',
                                          ).format(c.createdAt),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),

          // ✍️ INPUT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _AddCommentInput(postId: post.id.toString()),
            ),
          ),
        ],
      ),
    );
  }
}

// ✍️ INPUT
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
            String userId = 'anon';

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
