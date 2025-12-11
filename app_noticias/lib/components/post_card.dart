import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post_model.dart';
import 'package:intl/intl.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final Widget? trailing;

  const PostCard({
    required this.post,
    required this.onTap,
    this.trailing,
    Key? key,
  }) : super(key: key);

  String formatDate(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      return DateFormat.yMMMd().format(d);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: post.featuredImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: post.featuredImage!,
                width: 100,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (c, s) =>
                    Container(width: 100, height: 70, color: Colors.grey[200]),
                errorWidget: (c, s, d) =>
                    Container(width: 100, height: 70, color: Colors.grey[200]),
              ),
            )
          : Container(width: 100, height: 70, color: Colors.grey[200]),
      title: Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(formatDate(post.date)),
      trailing: trailing,
    );
  }
}
