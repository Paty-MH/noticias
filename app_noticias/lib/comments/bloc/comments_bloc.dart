import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/comment_model.dart';
import '../services/comments_service.dart';
import 'comments_event.dart';
import 'comments_state.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final CommentsService service;
  StreamSubscription<List<Comment>>? _commentsSub;

  CommentsBloc(this.service) : super(CommentsLoading()) {
    on<LoadComments>(_onLoadComments);
    on<AddComment>(_onAddComment);
    on<_CommentsUpdated>(_onCommentsUpdated);
  }

  // 🔹 Cargar comentarios en tiempo real
  void _onLoadComments(LoadComments event, Emitter<CommentsState> emit) async {
    emit(CommentsLoading());

    await _commentsSub?.cancel();
    _commentsSub = service
        .streamComments(event.postId)
        .listen(
          (comments) {
            add(_CommentsUpdated(comments));
          },
          onError: (error) {
            emit(CommentsError('Error al cargar comentarios: $error'));
          },
        );
  }

  // 🔹 Agregar comentario
  Future<void> _onAddComment(
    AddComment event,
    Emitter<CommentsState> emit,
  ) async {
    try {
      await service.addComment(
        postId: event.postId,
        content: event.content,
        userName: event.userName,
        userId: event.userId,
      );
      // No necesitamos recargar; el stream actualizará automáticamente
    } catch (e) {
      emit(CommentsError('No se pudo enviar el comentario: $e'));
    }
  }

  // 🔹 Actualizar comentarios desde el stream
  void _onCommentsUpdated(_CommentsUpdated event, Emitter<CommentsState> emit) {
    emit(CommentsLoaded(event.comments));
  }

  @override
  Future<void> close() {
    _commentsSub?.cancel();
    return super.close();
  }
}

/// Evento privado para actualizar comentarios desde el stream
class _CommentsUpdated extends CommentsEvent {
  final List<Comment> comments;
  _CommentsUpdated(this.comments);

  @override
  List<Object?> get props => [comments];
}
