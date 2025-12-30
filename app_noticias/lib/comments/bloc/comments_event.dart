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

class ToggleLikeComment extends CommentsEvent {
  final Comment comment;
  final String userId;

  const ToggleLikeComment({required this.comment, required this.userId});

  @override
  List<Object?> get props => [comment, userId];
}

class CommentsUpdated extends CommentsEvent {
  final List<Comment> comments;
  const CommentsUpdated(this.comments);

  @override
  List<Object?> get props => [comments];
}

class DeleteComment extends CommentsEvent {
  final String commentId;
  const DeleteComment(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

class EditComment extends CommentsEvent {
  final String commentId;
  final String newContent;
  const EditComment({required this.commentId, required this.newContent});

  @override
  List<Object?> get props => [commentId, newContent];
}
