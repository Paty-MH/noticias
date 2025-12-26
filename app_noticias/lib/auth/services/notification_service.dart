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

  // 🔔 MÉTODO BASE CON ANIMACIÓN
  static void _show(
    BuildContext context,
    String message, {
    required Color background,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
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
      animation: CurvedAnimation(
        parent: AnimationController(
          vsync: Scaffold.of(context),
          duration: const Duration(milliseconds: 500),
        ),
        curve: Curves.easeOut,
      ),
    );

    // Método para mostrar con animación Slide + Fade
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        content: AnimatedSlide(
          offset: const Offset(0, -1),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 400),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
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
          ),
        ),
      ),
    );
  }
}
