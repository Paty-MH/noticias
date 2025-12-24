import 'package:flutter/material.dart';

class NotificationService {
  // ✅ ÉXITO
  static void success(BuildContext context, String message) {
    _show(context, message, background: Colors.green, icon: Icons.check_circle);
  }

  // ❌ ERROR
  static void error(BuildContext context, String message) {
    _show(context, message, background: Colors.red, icon: Icons.error);
  }

  // ℹ️ INFO
  static void info(BuildContext context, String message) {
    _show(context, message, background: Colors.blue, icon: Icons.info);
  }

  // ⚠️ WARNING
  static void warning(BuildContext context, String message) {
    _show(context, message, background: Colors.orange, icon: Icons.warning);
  }

  // 🔔 MÉTODO BASE
  static void _show(
    BuildContext context,
    String message, {
    required Color background,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: background,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
