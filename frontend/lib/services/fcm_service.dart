import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../main.dart'; // Import navigatorKey
import '../page/main_page.dart';

// Handler untuk notifikasi saat app di-BACKGROUND / TERMINATED
// Harus top-level function (di luar class)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Notif diterima (background): ${message.notification?.title}');
}

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // ============================================
  // INISIALISASI FCM
  // ============================================
  static Future<void> init() async {
    // Setup channel untuk tampilkan notif saat app di foreground (Android)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'fcm_high_importance_channel',
      'Notifikasi QuranMemo',
      description: 'Notifikasi feedback dan pengingat hafalan',
      importance: Importance.high,
    );

    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Inisialisasi local notification untuk foreground
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    await _localNotif.initialize(
      const InitializationSettings(android: androidSettings),
    );

    // Minta izin notifikasi (Android 13+ & iOS)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Daftarkan background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle notif saat app FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Notif diterima (foreground): ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Handle notif saat user klik notif (app background → foreground)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('User klik notif: ${message.data}');
      _handleNotificationClick(message);
    });

    // Handle notif saat user klik notif dan app dalam keadaan TERMINATED (mati total)
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('User klik notif (terminated): ${initialMessage.data}');
      // Kasih delay sedikit supaya UI siap dulu sebelum pindah halaman
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleNotificationClick(initialMessage);
      });
    }
  }

  // ============================================
  // HANDLE DEEP LINK (Navigasi Halaman)
  // ============================================
  static void _handleNotificationClick(RemoteMessage message) {
    final type = message.data['type'];
    
    // Cek navigator key
    if (navigatorKey.currentState == null) return;

    if (type == 'setoran_baru') {
      // Ustad mendapat setoran baru, arahkan ke tab Setoran (Index 1)
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(
          builder: (_) => const MainPage(initialIndex: 1),
        ),
      );
    } else if (type == 'feedback' || type == 'status_selesai' || type == 'status_revisi' || type == 'voice_note') {
      // Santri mendapat update, arahkan ke tab Riwayat (Index 4)
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(
          builder: (_) => const MainPage(initialIndex: 4),
        ),
      );
    }
  }

  // ============================================
  // AMBIL & KIRIM FCM TOKEN KE BACKEND
  // ============================================
  static Future<void> sendTokenToServer() async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;

      debugPrint('FCM Token: $token');

      final authToken = await AuthService.getToken();
      if (authToken == null) return;

      await http.put(
        Uri.parse('$baseUrl/me/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'fcm_token': token}),
      );

      debugPrint('FCM token berhasil dikirim ke server');
    } catch (e) {
      debugPrint('Gagal kirim FCM token: $e');
    }
  }

  // ============================================
  // TAMPILKAN NOTIF LOKAL (saat app foreground)
  // ============================================
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotif.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'fcm_high_importance_channel',
          'Notifikasi QuranMemo',
          channelDescription: 'Notifikasi feedback dan pengingat hafalan',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
      ),
    );
  }

  // ============================================
  // REFRESH TOKEN (panggil saat token berubah)
  // ============================================
  static void listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM token diperbarui: $newToken');
      sendTokenToServer();
    });
  }
}
