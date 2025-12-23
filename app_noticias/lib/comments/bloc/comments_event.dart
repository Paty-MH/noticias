abstract class CommentsEvent {}

// Cargar comentarios de una noticia
class LoadComments extends CommentsEvent {
  final String postId;

  LoadComments(this.postId);
}

// Agregar comentario
class AddComment extends CommentsEvent {
  final String postId;
  final String content;

  AddComment({required this.postId, required this.content});
}
