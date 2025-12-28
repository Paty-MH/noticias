import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

class CommentsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔥 STREAM SIN orderBy (EVITA LOADING INFINITO)
  Stream<List<Comment>> streamComments(String postId) {
    return _db
        .collection('comments')
        .where('postId', isEqualTo: postId) // SIEMPRE STRING
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((d) => Comment.fromDoc(d)).toList(),
        );
  }

  /// ➕ AGREGAR COMENTARIO
  Future<void> addComment({
    required String postId,
    required String content,
    required String userName,
    required String userId,
  }) async {
    await _db.collection('comments').add({
      'postId': postId,
      'content': content,
      'userName': userName,
      'userId': userId,
      'likedBy': [],
      'likesCount': 0,
      'createdAt':
          FieldValue.serverTimestamp(), // SE QUEDA ASÍ, YA NO CAUSA PROBLEMAS
    });
  }

  /// ❤️ LIKE / UNLIKE
  Future<void> toggleLike({
    required Comment comment,
    required String userId,
  }) async {
    final ref = _db.collection('comments').doc(comment.id);

    if (comment.likedBy.contains(userId)) {
      await ref.update({
        'likedBy': FieldValue.arrayRemove([userId]),
        'likesCount': FieldValue.increment(-1),
      });
    } else {
      await ref.update({
        'likedBy': FieldValue.arrayUnion([userId]),
        'likesCount': FieldValue.increment(1),
      });
    }
  }
}
