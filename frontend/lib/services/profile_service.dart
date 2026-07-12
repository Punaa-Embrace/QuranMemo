import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class ProfileService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future<Map<String, dynamic>> updateProfile({
    required String nama,
    required String email,
  }) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.put(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'nama': nama, 'email': email}),
      );

      final String body = response.body.trim();
      if (body.isEmpty || body.startsWith('<!DOCTYPE') || body.startsWith('<html')) {
        return {'success': false, 'message': 'Terjadi kesalahan server'};
      }

      final data = jsonDecode(body);

      if (response.statusCode == 200 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('nama', nama);
        await prefs.setString('email', email);
        return data;
      }

      return {'success': false, 'message': data['message'] ?? 'Gagal update profile'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal koneksi: $e'};
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final token = await AuthService.getToken();

      final response = await http.put(
        Uri.parse('$baseUrl/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        }),
      );

      final String body = response.body.trim();
      if (body.isEmpty || body.startsWith('<!DOCTYPE') || body.startsWith('<html')) {
        return {'success': false, 'message': 'Terjadi kesalahan server'};
      }

      return jsonDecode(body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal koneksi: $e'};
    }
  }
}