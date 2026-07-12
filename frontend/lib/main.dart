import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'page/auth/onboarding_page.dart';
import 'theme/app_theme.dart';
import 'services/fcm_service.dart';

// Global key untuk navigasi dari mana saja (misal: klik notifikasi)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp();

  // Inisialisasi FCM (push notification dari server)
  await FCMService.init();

  // Listen jika FCM token berubah
  FCMService.listenTokenRefresh();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuranMemo',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // Pasang navigator key di sini
      home: const OnboardingPage(),
    );
  }
}