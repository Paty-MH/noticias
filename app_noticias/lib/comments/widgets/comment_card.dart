import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/comment_model.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;
  final VoidCallback? onLike;
  final bool isLiked;

  const CommentCard({
    super.key,
    required this.comment,
    this.onLike,
    this.isLiked = false,
  });

  @override
  Widget build(BuildContext context) {
    final date = comment.createdAt ?? DateTime.now();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🧑 AVATAR
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.purpleAccent,
            child: Text(
              comment.userName[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 💬 BURBUJA
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 👤 NOMBRE
                  Text(
                    comment.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // 📝 TEXTO
                  Text(
                    comment.content,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ❤️ FECHA + LIKE
                  Row(
                    children: [
                      Text(
                        DateFormat('dd MMM · HH:mm').format(date),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),

                      const Spacer(),

                      InkWell(
                        onTap: onLike,
                        borderRadius: BorderRadius.circular(20),
                        child: Row(
                          children: [
                            Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 16,
                              color: isLiked ? Colors.pinkAccent : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              comment.likesCount.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
