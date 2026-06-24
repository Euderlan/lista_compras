import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Handler para mensagens em background (deve ser top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Não precisa fazer nada — a notificação já aparece automaticamente na barra
}

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();
  static final _supabase = Supabase.instance.client;

  static const _channel = AndroidNotificationChannel(
    'estoque_channel',
    'Avisos de Estoque',
    description: 'Notificações sobre produtos acabando',
    importance: Importance.high,
  );

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

    // Inicializa notificações locais (necessário para o canal existir)
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

    // Quando o app está em FOREGROUND (aberto), o Android por padrão
    // não mostra a notificação na barra — precisamos exibir via local notification.
    // O iOS já mostra automaticamente.
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      final android = message.notification?.android;

      // Exibe na barra de notificação mesmo com o app aberto
      if (notification != null && android != null) {
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
              // Não abre diálogo — apenas mostra na barra
              fullScreenIntent: false,
            ),
          ),
        );
      }
      // iOS já exibe automaticamente na barra quando configurado corretamente
    });

    // Configura apresentação das notificações no iOS com app aberto
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,  // mostra banner
      badge: true,
      sound: true,
    );
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