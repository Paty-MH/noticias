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

  // 📅 Formatear fecha segura
  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat.yMMMd().format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(post.id),

      // 👉 Swipe derecha → izquierda
      direction: DismissDirection.endToStart,

      // 🔖 Toggle bookmark sin eliminar
      confirmDismiss: (_) async {
        onBookmark();
        return false;
      },

      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: isBookmarked ? Colors.grey : Colors.deepPurple,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isBookmarked ? Icons.bookmark_remove : Icons.bookmark,
          color: Colors.white,
          size: 28,
        ),
      ),

      child: Card(
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),

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
                      color: Colors.grey.shade300,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 100,
                      height: 70,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.broken_image),
                    ),
                  )
                : Container(
                    width: 100,
                    height: 70,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported),
                  ),
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

          // 🔖 BOTÓN BOOKMARK
          trailing: IconButton(
            onPressed: onBookmark,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                key: ValueKey(isBookmarked),
                color: isBookmarked ? Colors.deepPurple : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
