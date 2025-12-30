import 'package:flutter/material.dart';

class NotificationService {
  static void success(BuildContext c, String m) =>
      _show(c, m, Colors.green, Icons.check_circle);

  static void error(BuildContext c, String m) =>
      _show(c, m, Colors.red, Icons.error);

  static void _show(BuildContext c, String m, Color color, IconData icon) {
    ScaffoldMessenger.of(c).hideCurrentSnackBar();
    ScaffoldMessenger.of(c).showSnackBar(
      SnackBar(
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(m, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
