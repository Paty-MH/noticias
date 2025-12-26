import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

class CommentsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream de comentarios en tiempo real
  Stream<List<Comment>> streamComments(String postId) {
    return _db
        .collection('comments')
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) {
                try {
                  return Comment.fromFirestore(doc);
                } catch (e) {
                  print('Documento inválido ignorado: ${doc.id}, error: $e');
                  return null;
                }
              })
              .whereType<Comment>()
              .toList(),
        );
  }

  /// Agregar comentario
  Future<void> addComment({
    required String postId,
    required String content,
    required String userName,
    required String userId,
  }) async {
    if (postId.isEmpty) throw Exception('postId no puede estar vacío');
    if (content.isEmpty) throw Exception('El comentario no puede estar vacío');

    await _db.collection('comments').add({
      'postId': postId,
      'content': content,
      'userName': userName,
      'userId': userId,
      'createdAt': Timestamp.now(),
    });
  }
}
