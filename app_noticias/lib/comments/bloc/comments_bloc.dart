import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/comment_model.dart';
import '../services/comments_service.dart';
import 'comments_event.dart';
import 'comments_state.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final CommentsService service;
  StreamSubscription<List<Comment>>? _sub;

  CommentsBloc(this.service) : super(CommentsLoading()) {
    on<LoadComments>(_onLoad);
    on<AddComment>(_onAdd);
    on<ToggleLikeComment>(_onToggleLike);
    on<CommentsUpdated>(_onUpdated);
  }

  void _onLoad(LoadComments event, Emitter<CommentsState> emit) async {
    await _sub?.cancel();

    // ✅ Evita loading infinito
    emit(const CommentsLoaded([]));

    _sub = service
        .streamComments(event.postId)
        .listen(
          (comments) {
            add(CommentsUpdated(comments));
          },
          onError: (error) {
            emit(CommentsError(error.toString()));
          },
        );
  }

  Future<void> _onAdd(AddComment event, Emitter<CommentsState> emit) async {
    await service.addComment(
      postId: event.postId,
      content: event.content,
      userName: event.userName,
      userId: event.userId,
    );
  }

  Future<void> _onToggleLike(
    ToggleLikeComment event,
    Emitter<CommentsState> emit,
  ) async {
    await service.toggleLike(comment: event.comment, userId: event.userId);
  }

  void _onUpdated(CommentsUpdated event, Emitter<CommentsState> emit) {
    emit(CommentsLoaded(event.comments));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
