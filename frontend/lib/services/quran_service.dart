import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/surah_model.dart';

class QuranService {

  static Map<int, SurahDetail> _surahCache = {};

  static const String baseUrl = 'https://equran.id/api/v2';
  
  // GET semua surat
  static Future<List<Surah>> getDaftarSurat() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/surat'));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final surahResponse = SurahResponse.fromJson(jsonData);
        return surahResponse.data;
      } else {
        throw Exception('Gagal memuat daftar surat (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }
  
  // GET detail surat berdasarkan nomor
  static Future<SurahDetail> getDetailSurat(int nomor) async {
    // cek cache dulu
    if (_surahCache.containsKey(nomor)) {
      return _surahCache[nomor]!;
    }

    final response = await http.get(
      Uri.parse("https://equran.id/api/v2/surat/$nomor"),
    );

    final data = jsonDecode(response.body);

    final surah = SurahDetail.fromJson(data["data"]);

    // simpan ke cache
    _surahCache[nomor] = surah;

    return surah;
  }
  
  // GET tafsir surat (opsional)
  static Future<Map<String, dynamic>> getTafsirSurat(int nomor) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tafsir/$nomor'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal memuat tafsir');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }
  
  // Daftar qari yang tersedia
  static const List<Map<String, String>> qariList = [
    {'key': '01', 'name': 'Abdullah Al-Juhany', 'audio': '01'},
    {'key': '02', 'name': 'Abdul Muhsin Al-Qasim', 'audio': '02'},
    {'key': '03', 'name': 'Abdurrahman As-Sudais', 'audio': '03'},
    {'key': '04', 'name': 'Ibrahim Al-Dossari', 'audio': '04'},
    {'key': '05', 'name': 'Misyari Rasyid Al-Afasy', 'audio': '05'},
    {'key': '06', 'name': 'Yasser Al-Dosari', 'audio': '06'},
  ];

  // Mendapatkan nama qari berdasarkan key
  static String getNamaQari(String key) {
    final qari = qariList.firstWhere(
      (q) => q['key'] == key,
      orElse: () => {'name': 'Misyari Rasyid Al-Afasy'},
    );
    return qari['name']!;
  }
}