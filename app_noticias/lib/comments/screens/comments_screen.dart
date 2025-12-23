import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/comments_bloc.dart';
import '../bloc/comments_event.dart';
import '../bloc/comments_state.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;

  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CommentsBloc>().add(LoadComments(widget.postId));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comentarios')),
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
                      child: Text('Sé el primero en comentar'),
                    );
                  }

                  return ListView.builder(
                    itemCount: state.comments.length,
                    itemBuilder: (_, i) {
                      final c = state.comments[i];
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(c.userName),
                        subtitle: Text(c.content),
                        trailing: Text(
                          '${c.createdAt.hour}:${c.createdAt.minute.toString().padLeft(2, '0')}',
                        ),
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),

          // Input comentario
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un comentario...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.trim().isEmpty) return;

                    context.read<CommentsBloc>().add(
                      AddComment(
                        postId: widget.postId,
                        content: _controller.text.trim(),
                      ),
                    );

                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
