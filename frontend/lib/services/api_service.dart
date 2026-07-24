import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ApiService {
  // ============================================
  // BASE URL - SUPPORT MULTI ENVIRONMENT
  // ============================================

  // IP KOMPUTER (DARI IPCONFIG)
  static const String _ipAddress = '10.207.74.190'; 
  static const String _port = '8000';
  
  // MODE: 'local' | 'wifi' | 'ngrok'
  static const String _mode = 'ngrok'; 

  static String get baseUrl {
    switch (_mode) {
      case 'local':
        // Untuk Web/Desktop/Emulator (localhost)
        return 'http://localhost:$_port/api';
      
      case 'wifi':
        // Untuk HP Fisik (WiFi sama)
        return 'http://$_ipAddress:$_port/api';
      
      case 'ngrok':
        // Untuk akses dari mana aja (internet)
        return 'https://bacterium-olympics-surpass.ngrok-free.dev/api';
      
      default:
        return 'http://localhost:$_port/api';
    }
  }

  // BASE URL UNTUK EMULATOR ANDROID (10.0.2.2)
  static String get baseUrlEmulator {
    return 'http://10.0.2.2:$_port/api';
  }

  // BASE URL UNTUK IP MANUAL (bisa diganti kapan aja)
  static String get baseUrlManual {
    return 'http://$_ipAddress:$_port/api';
  }

  // ============================================
  // GET BASE URL (OTOMATIS DETECT PLATFORM)
  // ============================================
  
  static String get baseU {
    if (Platform.isAndroid) {
      // Cek apakah di emulator (bisa detect via properties)
      // Default pake IP WiFi
      return 'http://$_ipAddress:$_port/api';
    } else if (Platform.isIOS) {
      return 'http://$_ipAddress:$_port/api';
    } else {
      // Windows, Mac, atau Web
      return 'http://localhost:$_port/api';
    }
  }

  // ============================================
  // LOGIN
  // ============================================

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    return jsonDecode(response.body);
  }

  // ============================================
  // GET TOKEN
  // ============================================

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ============================================
  // SET TOKEN
  // ============================================

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // ============================================
  // GET HEADERS
  // ============================================

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ============================================
  // LOGOUT
  // ============================================

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
  }

  // ============================================
  // DONASI
  // ============================================

  static Future<Map<String, dynamic>> createDonasi(int nominal) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orangtua/donasi'),
      headers: await getHeaders(),
      body: jsonEncode({'nominal': nominal}),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getRiwayatDonasi() async {
    final response = await http.get(
      Uri.parse('$baseUrl/orangtua/donasi/riwayat'),
      headers: await getHeaders(),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getStatusDonasi(String orderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orangtua/donasi/status/$orderId'),
      headers: await getHeaders(),
    );

    return jsonDecode(response.body);
  }
}