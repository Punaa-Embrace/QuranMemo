import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_service.dart';

class UstadService {
  static Future<Map<String, dynamic>> getSantriBinaan() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/ustad/santri'),
      headers: await ApiService.getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createTugas({
    required String santriId,
    required String surat,
    required int ayat,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/ustad/tugas'),
      headers: await ApiService.getHeaders(),
      body: jsonEncode({
        'santri_id': santriId,
        'surat': surat,
        'ayat': ayat,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getSetoran() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/ustad/setoran'),
      headers: await ApiService.getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> detailSetoran(int id) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/ustad/setoran/$id'),
      headers: await ApiService.getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> giveFeedback(String id, String feedback) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/ustad/setoran/$id/feedback'),
      headers: await ApiService.getHeaders(),
      body: jsonEncode({'feedback_tulisan': feedback}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateStatus(String id, String status) async {
    final response = await http.put(
      Uri.parse('${ApiService.baseUrl}/ustad/setoran/$id/status'),
      headers: await ApiService.getHeaders(),
      body: jsonEncode({'status': status}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> uploadVoiceNote(String id, File file) async {
    final token = await ApiService.getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiService.baseUrl}/ustad/setoran/$id/voice-note'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.files.add(await http.MultipartFile.fromPath(
      'voice_note',
      file.path,
      contentType: MediaType('audio', 'ogg'),
    ));
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return {'success': false, 'message': 'Server error (${response.statusCode})'};
    }
  }
}
