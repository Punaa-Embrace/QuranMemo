import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'page/auth/onboarding_page.dart';
import 'page/main_page.dart';
import 'page/ustad/main_page_ustad.dart';
import 'page/ortu/ortu_dashboard.dart';
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

  // Cek apakah user sudah login sebelumnya
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final role = prefs.getString('role');

  Widget initialScreen = const OnboardingPage();

  if (token != null && token.isNotEmpty && role != null) {
    if (role == 'santri') {
      initialScreen = const MainPage();
    } else if (role == 'ustad') {
      initialScreen = const MainPageUstad();
    } else if (role == 'orangtua') {
      initialScreen = const DashboardOrtu();
    }
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({Key? key, required this.initialScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuranMemo',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: initialScreen,
    );
  }
}