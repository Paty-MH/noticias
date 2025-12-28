import 'package:equatable/equatable.dart';
import '../models/comment_model.dart';

abstract class CommentsState extends Equatable {
  const CommentsState();

  @override
  List<Object?> get props => [];
}

class CommentsLoading extends CommentsState {}

class CommentsLoaded extends CommentsState {
  final List<Comment> comments;
  const CommentsLoaded(this.comments);

  @override
  List<Object?> get props => [comments];
}

class CommentsError extends CommentsState {
  final String message;
  const CommentsError(this.message);

  @override
  List<Object?> get props => [message];
}
