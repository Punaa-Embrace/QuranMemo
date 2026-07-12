import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class OrangtuaService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // ============================================
  // GET DAFTAR ANAK
  // ============================================
  static Future<Map<String, dynamic>> getAnak() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/orangtua/anak'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal koneksi: $e',
      };
    }
  }

  // ============================================
  // GET PROGRESS ANAK
  // ============================================
  static Future<Map<String, dynamic>> getProgressAnak(String santriId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/orangtua/anak/$santriId/progress'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal koneksi: $e',
      };
    }
  }
}