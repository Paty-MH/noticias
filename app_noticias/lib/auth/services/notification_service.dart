import 'package:flutter/material.dart';

class NotificationService {
  // ❌ Mostrar error
  static void error(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.redAccent, Icons.error);
  }

  // ✅ Mostrar éxito
  static void success(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.greenAccent, Icons.check_circle);
  }

  // ℹ️ Mostrar info
  static void info(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.blueAccent, Icons.info);
  }

  // 🔧 Función interna para mostrar Snackbar
  static void _showSnackBar(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );

    // Mostrar Snackbar
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
