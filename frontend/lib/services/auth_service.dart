import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // ============================================
  // LOGIN
  // ============================================
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final String body = response.body.trim();

      if (body.isEmpty) {
        return {
          'success': false,
          'message': 'Server tidak merespon. Coba lagi nanti.',
        };
      }

      if (body.startsWith('<!DOCTYPE') || body.startsWith('<html')) {
        return {
          'success': false,
          'message': 'Terjadi kesalahan server. Silakan coba lagi nanti.',
        };
      }

      final data = jsonDecode(body);

      if (response.statusCode == 200 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['data']['token']);
        await prefs.setString('role', data['data']['user']['role']);
        await prefs.setString('nama', data['data']['user']['nama']);
        await prefs.setString('email', data['data']['user']['email']);
        await prefs.setString('user_id', data['data']['user']['id']);
        await prefs.setString('nim', data['data']['user']['nim'] ?? '');
        await prefs.setString('nik', data['data']['user']['nik'] ?? '');

        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // ============================================
  // LOGOUT
  // ============================================
  static Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      print('Error logout: $e');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('role');
      await prefs.remove('nama');
      await prefs.remove('email');
      await prefs.remove('user_id');
      await prefs.remove('nim');
      await prefs.remove('nik');
    }
  }

  // ============================================
  // GET TOKEN
  // ============================================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ============================================
  // GET ROLE
  // ============================================
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  // ============================================
  // GET NAMA
  // ============================================
  static Future<String?> getNama() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nama');
  }

  // ============================================
  // GET EMAIL
  // ============================================
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  // ============================================
  // GET NIM (UNTUK SANTRI)
  // ============================================
  static Future<String?> getNim() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nim');
  }

  // ============================================
  // GET NIK (UNTUK USTAD)
  // ============================================
  static Future<String?> getNik() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nik');
  }

  // ============================================
  // GET USER ID
  // ============================================
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // ============================================
  // CEK LOGIN STATUS
  // ============================================
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ============================================
  // GET HEADERS
  // ============================================
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}