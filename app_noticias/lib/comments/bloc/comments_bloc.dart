import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/comments_service.dart';
import 'comments_event.dart';
import 'comments_state.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final CommentsService service;
  StreamSubscription? _sub;

  CommentsBloc(this.service) : super(CommentsLoading()) {
    on<LoadComments>(_onLoad);
    on<AddComment>(_onAdd);
  }

  void _onLoad(LoadComments event, Emitter<CommentsState> emit) async {
    emit(CommentsLoading());
    await _sub?.cancel();

    _sub = service
        .streamComments(event.postId)
        .listen(
          (comments) => emit(CommentsLoaded(comments)),
          onError: (_) =>
              emit(const CommentsError('Error al cargar comentarios')),
        );
  }

  Future<void> _onAdd(AddComment event, Emitter<CommentsState> emit) async {
    try {
      await service.addComment(
        postId: event.postId,
        content: event.content,
        userName: event.userName,
        userId: event.userId,
      );
      // El stream actualiza automáticamente los comentarios
    } catch (_) {
      emit(const CommentsError('No se pudo enviar el comentario'));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
