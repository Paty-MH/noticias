import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String content;
  final String userName;
  final String userId;
  final DateTime createdAt;
  final List<String> likedBy;

  Comment({
    required this.id,
    required this.postId,
    required this.content,
    required this.userName,
    required this.userId,
    required this.createdAt,
    required this.likedBy,
  });

  /// 👍 Likes calculados (NO se guardan en Firestore)
  int get likesCount => likedBy.length;

  factory Comment.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Comment(
      id: doc.id,
      postId: data['postId'] ?? '',
      content: data['content'] ?? '',
      userName: data['userName'] ?? 'Usuario',
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }
}
