import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/surah_model.dart';
import '../services/quran_database.dart';

class QuranService {
  // ============================================================================
  // Konstanta
  // ============================================================================
  static const String _baseUrl = 'https://equran.id/api/v2';
  
  // ============================================================================
  // Variabel Private
  // ============================================================================
  static final Map<int, SurahDetail> _cacheSurah = {};
  
  // ============================================================================
  // Daftar Qari
  // ============================================================================
  static const List<Map<String, String>> daftarQari = [
    {'key': '01', 'name': 'Abdullah Al-Juhany', 'audio': '01'},
    {'key': '02', 'name': 'Abdul Muhsin Al-Qasim', 'audio': '02'},
    {'key': '03', 'name': 'Abdurrahman As-Sudais', 'audio': '03'},
    {'key': '04', 'name': 'Ibrahim Al-Dossari', 'audio': '04'},
    {'key': '05', 'name': 'Misyari Rasyid Al-Afasy', 'audio': '05'},
    {'key': '06', 'name': 'Yasser Al-Dosari', 'audio': '06'},
  ];
  
  // ============================================================================
  // Operasi Surah
  // ============================================================================
  static Future<List<Surah>> getDaftarSurat({bool forceRefresh = false}) async {
    // Cek cache offline
    if (!forceRefresh) {
      final localData = await _ambilDariDatabase();
      if (localData != null) return localData;
    }
    
    // Ambil dari API
    try {
      final dataApi = await _ambilDariApi();
      await _simpanKeDatabase(dataApi);
      return dataApi;
    } catch (e) {
      // Fallback ke database
      final fallbackData = await _ambilDariDatabase();
      if (fallbackData != null) return fallbackData;
      throw Exception('Gagal mengambil data surat: $e');
    }
  }
  
  static Future<List<Surah>?> _ambilDariDatabase() async {
    try {
      final data = await QuranDatabase.getAllSurah();
      if (data.isNotEmpty) return data;
    } catch (e) {
      // Skip jika gagal
    }
    return null;
  }
  
  static Future<List<Surah>> _ambilDariApi() async {
    final response = await http.get(Uri.parse('$_baseUrl/surat'));
    
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat daftar surat');
    }
    
    final jsonData = json.decode(response.body);
    return SurahResponse.fromJson(jsonData).data;
  }
  
  static Future<void> _simpanKeDatabase(List<Surah> suratList) async {
    for (var surah in suratList) {
      await QuranDatabase.insertSurah(surah);
    }
  }
  
  // ============================================================================
  // Operasi Detail Surah
  // ============================================================================
  static Future<SurahDetail> getDetailSurat(int nomor, {bool forceRefresh = false}) async {
    // Cek cache memory
    if (!forceRefresh && _cacheSurah.containsKey(nomor)) {
      return _cacheSurah[nomor]!;
    }
    
    // Cek cache offline
    if (!forceRefresh) {
      final detailOffline = await _ambilDetailDariDatabase(nomor);
      if (detailOffline != null) {
        _cacheSurah[nomor] = detailOffline;
        return detailOffline;
      }
    }
    
    // Ambil dari API
    try {
      final detailApi = await _ambilDetailDariApi(nomor);
      await _simpanDetailKeDatabase(detailApi);
      _cacheSurah[nomor] = detailApi;
      return detailApi;
    } catch (e) {
      // Fallback ke database
      final fallbackDetail = await _ambilDetailDariDatabase(nomor);
      if (fallbackDetail != null) {
        _cacheSurah[nomor] = fallbackDetail;
        return fallbackDetail;
      }
      throw Exception('Gagal mengambil detail surat $nomor: $e');
    }
  }
  
  static Future<SurahDetail?> _ambilDetailDariDatabase(int nomor) async {
    try {
      final surahInfo = await QuranDatabase.getSurahById(nomor);
      final ayatList = await QuranDatabase.getAyatBySurah(nomor);
      
      if (surahInfo != null && ayatList.isNotEmpty && ayatList.length == surahInfo.jumlahAyat) {
        return SurahDetail(
          nomor: surahInfo.nomor,
          nama: surahInfo.nama,
          namaLatin: surahInfo.namaLatin,
          jumlahAyat: surahInfo.jumlahAyat,
          tempatTurun: surahInfo.tempatTurun,
          arti: surahInfo.arti,
          deskripsi: surahInfo.deskripsi,
          audioFull: surahInfo.audioFull,
          ayat: ayatList,
        );
      }
    } catch (e) {
      // Skip jika gagal
    }
    return null;
  }
  
  static Future<SurahDetail> _ambilDetailDariApi(int nomor) async {
    final response = await http.get(Uri.parse('$_baseUrl/surat/$nomor'));
    
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat detail surat');
    }
    
    final data = jsonDecode(response.body);
    return SurahDetail.fromJson(data["data"]);
  }
  
  static Future<void> _simpanDetailKeDatabase(SurahDetail detail) async {
    final surahInfo = Surah(
      nomor: detail.nomor,
      nama: detail.nama,
      namaLatin: detail.namaLatin,
      jumlahAyat: detail.jumlahAyat,
      tempatTurun: detail.tempatTurun,
      arti: detail.arti,
      deskripsi: detail.deskripsi,
      audioFull: detail.audioFull,
    );
    
    await QuranDatabase.insertSurah(surahInfo);
    await QuranDatabase.insertAyat(detail.nomor, detail.ayat);
  }
  
  // ============================================================================
  // Operasi Tafsir
  // ============================================================================
  static Future<Map<String, dynamic>> getTafsirSurat(int nomor) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/tafsir/$nomor'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal memuat tafsir');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }
  
  // ============================================================================
  // Utility Methods
  // ============================================================================
  static Future<void> refreshAllData() async {
    _cacheSurah.clear();
    await QuranDatabase.resetAllData();
    await getDaftarSurat(forceRefresh: true);
  }
  
  static Future<List<Surah>> refreshDaftarSurat() async {
    return await getDaftarSurat(forceRefresh: true);
  }
  
  static Future<SurahDetail> refreshDetailSurat(int nomor) async {
    _cacheSurah.remove(nomor);
    await QuranDatabase.deleteAyatBySurah(nomor);
    return await getDetailSurat(nomor, forceRefresh: true);
  }
  
  static Future<bool> isOfflineAvailable(int surahId) async {
    try {
      final surahInfo = await QuranDatabase.getSurahById(surahId);
      final ayatList = await QuranDatabase.getAyatBySurah(surahId);
      return surahInfo != null && ayatList.length == surahInfo.jumlahAyat;
    } catch (e) {
      return false;
    }
  }
  
  static void clearMemoryCache() {
    _cacheSurah.clear();
  }
  
  static String getNamaQari(String key) {
    final qari = daftarQari.firstWhere(
      (q) => q['key'] == key,
      orElse: () => {'name': 'Misyari Rasyid Al-Afasy'},
    );
    return qari['name']!;
  }
}