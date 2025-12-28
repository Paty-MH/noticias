import 'dart:math';
import 'package:flutter/material.dart';

class FloatingHeart extends StatefulWidget {
  const FloatingHeart({super.key});

  @override
  State<FloatingHeart> createState() => _FloatingHeartState();
}

class _FloatingHeartState extends State<FloatingHeart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final double randomX = Random().nextDouble() * 30 - 15;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _animation = Tween<double>(
      begin: 0,
      end: -70,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Transform.translate(
          offset: Offset(randomX, _animation.value),
          child: const Icon(Icons.favorite, color: Colors.pinkAccent, size: 20),
        );
      },
    );
  }
}
