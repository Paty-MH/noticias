import 'package:flutter_bloc/flutter_bloc.dart';
import 'comments_event.dart';
import 'comments_state.dart';
import '../models/comment_model.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final List<Comment> _comments = [];

  CommentsBloc() : super(CommentsInitial()) {
    on<LoadComments>(_onLoadComments);
    on<AddComment>(_onAddComment);
  }

  void _onLoadComments(LoadComments event, Emitter<CommentsState> emit) async {
    emit(CommentsLoading());

    await Future.delayed(const Duration(milliseconds: 600));

    final postComments = _comments
        .where((c) => c.postId == event.postId)
        .toList();

    emit(CommentsLoaded(postComments));
  }

  void _onAddComment(AddComment event, Emitter<CommentsState> emit) async {
    if (state is! CommentsLoaded) return;

    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: event.postId,
      userId: '1',
      userName: 'Usuario',
      content: event.content,
      createdAt: DateTime.now(),
    );

    _comments.add(newComment);

    emit(
      CommentsLoaded(_comments.where((c) => c.postId == event.postId).toList()),
    );
  }
}
