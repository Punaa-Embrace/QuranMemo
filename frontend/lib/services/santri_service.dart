import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class SantriService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // ============================================
  // GET PROGRESS
  // ============================================
  static Future<Map<String, dynamic>> getProgress() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/santri/progress'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }

  // ============================================
  // GET SETORAN (RIWAYAT)
  // ============================================
  static Future<Map<String, dynamic>> getSetoran() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/santri/setoran'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }

  // ============================================
  // UPLOAD SETORAN VIDEO
  // ============================================
  static Future<Map<String, dynamic>> uploadSetoran({
    required String videoPath,
    required String surat,
    required int ayat,
  }) async {
    try {
      final token = await AuthService.getToken();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/santri/setoran'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['surat'] = surat;
      request.fields['ayat'] = ayat.toString();

      var videoFile = await http.MultipartFile.fromPath('video', videoPath);
      request.files.add(videoFile);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      return {
        'statusCode': response.statusCode,
        'data': jsonDecode(responseBody),
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'error': e.toString(),
      };
    }
  }

  // ============================================
  // UPDATE AYAT TERAKHIR
  // ============================================
  static Future<Map<String, dynamic>> updateAyatTerakhir({
    required String surat,
    required int ayat,
  }) async {
    final token = await AuthService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/santri/ayat-terakhir'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'surat': surat,
        'ayat': ayat,
      }),
    );
    return jsonDecode(response.body);
  }
}