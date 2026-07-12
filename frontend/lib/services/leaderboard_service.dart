import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class LeaderboardService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future<Map<String, dynamic>> getLeaderboard() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/leaderboard'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getTop10() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/leaderboard/top'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> tambahPoin(int poin) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/santri/leaderboard'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'poin': poin}),
    );
    return jsonDecode(response.body);
  }
}