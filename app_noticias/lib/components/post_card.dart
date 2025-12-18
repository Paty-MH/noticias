import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../models/post_model.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const PostCard({
    super.key,
    required this.post,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmark,
  });

  String formatDate(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      return DateFormat.yMMMd().format(d);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      // 🖼 IMAGEN
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: post.featuredImage != null
            ? CachedNetworkImage(
                imageUrl: post.featuredImage!,
                width: 100,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 100,
                  height: 70,
                  color: Colors.grey.shade200,
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 100,
                  height: 70,
                  color: Colors.grey.shade200,
                ),
              )
            : Container(width: 100, height: 70, color: Colors.grey.shade200),
      ),

      // 📰 TÍTULO
      title: Text(
        post.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),

      // 📅 FECHA
      subtitle: Text(
        formatDate(post.date),
        style: const TextStyle(fontSize: 12),
      ),

      // 🔖 BOOKMARK
      trailing: IconButton(
        icon: Icon(
          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          color: isBookmarked ? Colors.deepPurple : Colors.grey,
        ),
        onPressed: onBookmark,
      ),
    );
  }
}
