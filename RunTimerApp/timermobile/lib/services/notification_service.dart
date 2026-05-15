import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_strings.dart';

// ── Handler para mensajes en background (top-level, fuera de clase) ──
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase ya está inicializado por FlutterFire
  await NotificationService._mostrarNotificacionLocal(message);
}

class NotificationService {
  static final FirebaseMessaging          _messaging    = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotif = FlutterLocalNotificationsPlugin();
  static final FirebaseFirestore          _firestore    = FirebaseFirestore.instance;

  // Canal Android de alta prioridad
  static const AndroidNotificationChannel _canal = AndroidNotificationChannel(
    'runtimer_channel',
    'RunTimer Notificaciones',
    description:  'Recordatorios de competencias RunTimer',
    importance:   Importance.high,
    playSound:    true,
    enableVibration: true,
  );

  // ── INICIALIZAR (llamar en main.dart) ────────────
  static Future<void> inicializar() async {
    // 1. Registrar handler de background
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2. Crear canal Android
    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_canal);

    // 3. Inicializar plugin local
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestBadgePermission: true,
      requestAlertPermission: true,
      requestSoundPermission: true,
    );
    await _localNotif.initialize(
      const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
    );

    // 4. Pedir permisos
    await _pedirPermisos();

    // 5. Guardar/actualizar token FCM
    await _guardarToken();

    // 6. Escuchar cambios de token
    _messaging.onTokenRefresh.listen(_actualizarToken);

    // 7. Manejar notificaciones en foreground
    FirebaseMessaging.onMessage.listen((message) {
      _mostrarNotificacionLocal(message);
    });

    // 8. Configurar presentación en iOS foreground
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ── PEDIR PERMISOS ───────────────────────────────
  static Future<bool> _pedirPermisos() async {
    final settings = await _messaging.requestPermission(
      alert:         true,
      badge:         true,
      sound:         true,
      announcement:  false,
      carPlay:       false,
      criticalAlert: false,
      provisional:   false,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
           settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  // ── GUARDAR TOKEN EN FIRESTORE ───────────────────
  static Future<void> _guardarToken() async {
    try {
      final uid   = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      String? token;
      if (Platform.isIOS) {
        // En iOS primero obtener APNs token
        await _messaging.getAPNSToken();
      }
      token = await _messaging.getToken();
      if (token == null) return;

      await _firestore
          .collection(AppStrings.colUsers)
          .doc(uid)
          .update({'fcmToken': token});
    } catch (_) {
      // No bloquear el flujo si falla
    }
  }

  // ── ACTUALIZAR TOKEN CUANDO CAMBIA ───────────────
  static Future<void> _actualizarToken(String token) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await _firestore
          .collection(AppStrings.colUsers)
          .doc(uid)
          .update({'fcmToken': token});
    } catch (_) {}
  }

  // ── MOSTRAR NOTIFICACIÓN LOCAL ───────────────────
  static Future<void> _mostrarNotificacionLocal(
      RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotif.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _canal.id,
          _canal.name,
          channelDescription: _canal.description,
          importance:         Importance.high,
          priority:           Priority.high,
          icon:               '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ── OBTENER TOKEN ACTUAL (para debug) ────────────
  static Future<String?> getToken() => _messaging.getToken();
}
