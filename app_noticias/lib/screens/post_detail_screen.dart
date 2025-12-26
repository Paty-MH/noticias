import 'package:cloud_firestore/cloud_firestore.dart';
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
      /// ✅ CommentsBloc SOLO vive aquí
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
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<NewsBloc, NewsState>(
            buildWhen: (_, state) => state is NewsLoaded,
            builder: (context, state) {
              if (state is! NewsLoaded) return const SizedBox();

              final isBookmarked = state.bookmarks.contains(post.id);

              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
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
          // ───────── HEADER ─────────
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

          // ───────── CONTENIDO ─────────
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -20, 0),
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Html(data: post.content),
            ),
          ),

          // ───────── COMENTARIOS ─────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Comentarios',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  BlocBuilder<CommentsBloc, CommentsState>(
                    builder: (context, state) {
                      if (state is CommentsLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is CommentsLoaded) {
                        if (state.comments.isEmpty) {
                          return const Text('Sé el primero en comentar 😊');
                        }

                        return Column(
                          children: state.comments.map((Comment c) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(c.userName),
                                subtitle: Text(c.content),
                                trailing: Text(
                                  DateFormat(
                                    'dd/MM/yyyy HH:mm',
                                  ).format(c.createdAt),
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }

                      if (state is CommentsError) {
                        return Text(state.message);
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

// ───────── INPUT COMENTARIO ─────────
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
            decoration: const InputDecoration(
              hintText: 'Escribe un comentario...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () {
            if (ctrl.text.trim().isEmpty) return;

            // Obtener info del usuario desde AuthBloc
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
