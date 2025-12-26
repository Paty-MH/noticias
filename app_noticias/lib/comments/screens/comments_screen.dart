import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/comments_bloc.dart';
import '../bloc/comments_event.dart';
import '../bloc/comments_state.dart';
import '../services/comments_service.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';

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
                      child: Text('Sé el primero en comentar 😊'),
                    );
                  }
                  return ListView.builder(
                    reverse: true,
                    itemCount: state.comments.length,
                    itemBuilder: (_, i) {
                      final c = state.comments[i];
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(c.userName),
                        subtitle: Text(c.content),
                        trailing: Text(
                          '${c.createdAt.hour.toString().padLeft(2, '0')}:${c.createdAt.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 12),
                        ),
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
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un comentario...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;

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
                        content: text,
                        userName: userName,
                        userId: userId,
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
