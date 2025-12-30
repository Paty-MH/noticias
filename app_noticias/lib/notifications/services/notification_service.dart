import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// 🔔 INICIALIZAR NOTIFICACIONES
  static Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('🔕 Firebase Messaging deshabilitado en Web');
      return;
    }

    final messaging = FirebaseMessaging.instance;

    /// 📱 Permisos
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    final token = await messaging.getToken();
    debugPrint('🔥 FCM Token: $token');

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('📩 Notificación: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('📲 App abierta desde notificación');
    });
  }

  /// 📌 OBTENER TÓPICOS DEL USUARIO
  Future<List<String>> getUserTopics() async {
    final prefs = await SharedPreferences.getInstance();

    final keys = prefs.getKeys();

    return keys
        .where((key) => key.startsWith('topic_'))
        .where((key) => prefs.getBool(key) == true)
        .map((key) => key.replaceFirst('topic_', ''))
        .toList();
  }

  /// ✅ SUSCRIBIRSE A TÓPICO
  Future<void> subscribeToTopic(String topic) async {
    final finalTopic = _buildTopic(topic);

    if (!kIsWeb) {
      await _messaging.subscribeToTopic(finalTopic);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('topic_$topic', true);

    debugPrint('✅ Suscrito a $finalTopic');
  }

  /// ❌ DESUSCRIBIRSE DE TÓPICO
  Future<void> unsubscribeFromTopic(String topic) async {
    final finalTopic = _buildTopic(topic);

    if (!kIsWeb) {
      await _messaging.unsubscribeFromTopic(finalTopic);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('topic_$topic', false);

    debugPrint('❌ Desuscrito de $finalTopic');
  }

  /// 🧠 TÓPICO ÚNICO (REGLA DEL PROFE)
  String _buildTopic(String topic) {
    return 'news_category_$topic';
  }
}
