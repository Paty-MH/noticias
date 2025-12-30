import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/comments_bloc.dart';
import '../bloc/comments_event.dart';
import '../bloc/comments_state.dart';
import '../services/comments_service.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../models/comment_model.dart';

class CommentsScreen extends StatelessWidget {
  final String postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CommentsBloc(CommentsService())..add(LoadComments(postId)),
      child: _CommentsView(postId: postId),
    );
  }
}

class _CommentsView extends StatefulWidget {
  final String postId;
  const _CommentsView({required this.postId});

  @override
  State<_CommentsView> createState() => _CommentsViewState();
}

class _CommentsViewState extends State<_CommentsView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState is AuthAuthenticated
        ? authState.user.id
        : 'anon';

    return Scaffold(
      appBar: AppBar(title: const Text('Comentarios'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<CommentsBloc, CommentsState>(
              builder: (context, state) {
                if (state is CommentsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is CommentsLoaded) {
                  if (state.comments.isEmpty) {
                    return const Center(
                      child: Text('Sé el primero en comentar 💬'),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    reverse: true,
                    itemCount: state.comments.length,
                    itemBuilder: (_, i) {
                      final comment = state.comments[i];
                      return _CommentCard(
                        comment: comment,
                        currentUserId: currentUserId,
                      );
                    },
                  );
                }
                if (state is CommentsError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox();
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Escribe un comentario...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      final text = _controller.text.trim();
                      if (text.isEmpty) return;

                      String userName = 'Usuario';
                      String userId = '1';

                      if (authState is AuthAuthenticated) {
                        userName = authState.user.name;
                        userId = authState.user.id;
                      }

                      context.read<CommentsBloc>().add(
                        AddComment(
                          postId: widget.postId,
                          content: text,
                          userName: userName,
                          userId: userId,
                        ),
                      );

                      _controller.clear();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// CARD DE COMENTARIO CON EDITAR Y ELIMINAR
class _CommentCard extends StatefulWidget {
  final Comment comment;
  final String currentUserId;
  const _CommentCard({required this.comment, required this.currentUserId});

  @override
  State<_CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<_CommentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  bool liked = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.8,
      upperBound: 1.2,
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    liked = widget.comment.likedBy.contains(widget.currentUserId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onLike() {
    setState(() => liked = !liked);
    _controller.forward(from: 0.8);
    context.read<CommentsBloc>().add(
      ToggleLikeComment(comment: widget.comment, userId: widget.currentUserId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.comment;
    final isAuthor = widget.currentUserId == c.userId;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                c.userName.isNotEmpty ? c.userName[0].toUpperCase() : '?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(c.content),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('dd MMM · HH:mm').format(c.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _onLike,
              child: ScaleTransition(
                scale: _scale,
                child: Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  color: liked ? Colors.red : Colors.grey,
                ),
              ),
            ),
            if (isAuthor) ...[
              IconButton(
                icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                onPressed: () async {
                  final controller = TextEditingController(text: c.content);
                  final result = await showDialog<String>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Editar comentario'),
                      content: TextField(
                        controller: controller,
                        maxLines: null,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, controller.text),
                          child: const Text('Guardar'),
                        ),
                      ],
                    ),
                  );

                  if (result != null && result.trim().isNotEmpty) {
                    context.read<CommentsBloc>().add(
                      EditComment(commentId: c.id, newContent: result.trim()),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Eliminar comentario'),
                      content: const Text(
                        '¿Estás seguro de eliminar este comentario?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<CommentsBloc>().add(
                              DeleteComment(c.id),
                            );
                            Navigator.pop(context);
                          },
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
