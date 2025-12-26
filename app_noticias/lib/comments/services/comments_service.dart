import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

class CommentsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Comment>> streamComments(String postId) {
    return _db
        .collection('comments')
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList(),
        );
  }

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
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
