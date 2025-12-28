import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/comments_bloc.dart';
import '../bloc/comments_event.dart';
import '../models/comment_model.dart';
import '../widgets/floating_heart.dart';

import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';

class CommentLikeButton extends StatefulWidget {
  final Comment comment;

  const CommentLikeButton({super.key, required this.comment});

  @override
  State<CommentLikeButton> createState() => _CommentLikeButtonState();
}

class _CommentLikeButtonState extends State<CommentLikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scale = Tween<double>(
      begin: 1,
      end: 1.4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  void _animateHeart(BuildContext context) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) =>
          Positioned(bottom: 120, right: 50, child: const FloatingHeart()),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(milliseconds: 900), () {
      entry.remove();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : 'anon';

    final isLiked = widget.comment.likedBy.contains(userId);

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            _controller.forward().then((_) => _controller.reverse());
            _animateHeart(context);

            context.read<CommentsBloc>().add(
              ToggleLikeComment(comment: widget.comment, userId: userId),
            );
          },
          child: ScaleTransition(
            scale: _scale,
            child: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.pinkAccent : Colors.grey,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          widget.comment.likesCount.toString(),
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
