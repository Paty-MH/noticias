import 'package:equatable/equatable.dart';
import '../models/comment_model.dart';

abstract class CommentsEvent extends Equatable {
  const CommentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadComments extends CommentsEvent {
  final String postId;
  const LoadComments(this.postId);

  @override
  List<Object?> get props => [postId];
}

class AddComment extends CommentsEvent {
  final String postId;
  final String content;
  final String userName;
  final String userId;

  const AddComment({
    required this.postId,
    required this.content,
    required this.userName,
    required this.userId,
  });

  @override
  List<Object?> get props => [postId, content, userName, userId];
}

/// Evento privado para actualizar comentarios desde el stream
class _CommentsUpdated extends CommentsEvent {
  final List<Comment> comments;
  const _CommentsUpdated(this.comments);

  @override
  List<Object?> get props => [comments];
}
