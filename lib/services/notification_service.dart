import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Handler para mensagens em background (deve ser top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Não precisa fazer nada aqui — a notificação já aparece automaticamente
}

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();
  static final _supabase = Supabase.instance.client;

  // Canal Android para notificações de estoque
  static const _channel = AndroidNotificationChannel(
    'estoque_channel',
    'Avisos de Estoque',
    description: 'Notificações sobre produtos acabando',
    importance: Importance.high,
  );

  // Inicializa tudo — chame no main() antes do runApp
  static Future<void> inicializar() async {
    // Solicita permissão
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Cria canal Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Inicializa notificações locais
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // Handler para mensagens em background
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handler para mensagens com app aberto
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }

  // Salva o token FCM do dispositivo no Supabase
  static Future<void> salvarToken() async {
    try {
      final usuario = _supabase.auth.currentUser;
      if (usuario == null) return;

      final token = await _messaging.getToken();
      if (token == null) return;

      await _supabase.from('device_tokens').upsert(
        {
          'usuario_id': usuario.id,
          'token': token,
          'atualizado_em': DateTime.now().toIso8601String(),
        },
        onConflict: 'usuario_id, token',
      );

      // Atualiza token quando ele muda
      _messaging.onTokenRefresh.listen((novoToken) async {
        await _supabase.from('device_tokens').upsert(
          {
            'usuario_id': usuario.id,
            'token': novoToken,
            'atualizado_em': DateTime.now().toIso8601String(),
          },
          onConflict: 'usuario_id, token',
        );
      });
    } catch (_) {}
  }

  // Remove o token ao fazer logout
  static Future<void> removerToken() async {
    try {
      final usuario = _supabase.auth.currentUser;
      if (usuario == null) return;

      final token = await _messaging.getToken();
      if (token == null) return;

      await _supabase
          .from('device_tokens')
          .delete()
          .eq('usuario_id', usuario.id)
          .eq('token', token);

      await _messaging.deleteToken();
    } catch (_) {}
  }
}