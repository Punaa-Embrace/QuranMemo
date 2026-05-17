import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/surah_model.dart';
import '../services/quran_database.dart';

class QuranService {

  static Map<int, SurahDetail> _surahCache = {};

  static const String baseUrl = 'https://equran.id/api/v2';
  
  // ==================== GET SEMUA SURAT (DENGAN OFFLINE SUPPORT) ====================
  static Future<List<Surah>> getDaftarSurat({bool forceRefresh = false}) async {
    // 🔥 PRIORITAS 1: Ambil dari DATABASE (kalau tidak force refresh)
    if (!forceRefresh) {
      try {
        final localData = await QuranDatabase.getAllSurah();
        if (localData.isNotEmpty) {
          print("📱 [Offline] Mengambil ${localData.length} surat dari database");
          return localData;
        }
      } catch (e) {
        print("⚠️ Gagal baca database: $e");
      }
    }
    
    // 🔥 PRIORITAS 2: Ambil dari API (online)
    try {
      print("🌐 [Online] Mengambil daftar surat dari API");
      final response = await http.get(Uri.parse('$baseUrl/surat'));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final surahResponse = SurahResponse.fromJson(jsonData);
        final suratList = surahResponse.data;
        
        // 🔥 SIMPAN KE DATABASE untuk offline
        for (var surah in suratList) {
          await QuranDatabase.insertSurah(surah);
        }
        print("💾 Menyimpan ${suratList.length} surat ke database");
        
        return suratList;
      } else {
        throw Exception('Gagal memuat daftar surat (Status: ${response.statusCode})');
      }
    } catch (e) {
      // 🔥 PRIORITAS 3: FALLBACK - coba lagi ke database (kalau API gagal)
      print("⚠️ API gagal, fallback ke database");
      try {
        final localData = await QuranDatabase.getAllSurah();
        if (localData.isNotEmpty) {
          print("📱 [Fallback] Mengambil ${localData.length} surat dari database");
          return localData;
        }
      } catch (dbError) {
        print("❌ Database juga gagal: $dbError");
      }
      
      throw Exception('Tidak dapat mengambil data surat: $e');
    }
  }
  
  // ==================== GET DETAIL SURAT (DENGAN OFFLINE SUPPORT) ====================
  static Future<SurahDetail> getDetailSurat(int nomor, {bool forceRefresh = false}) async {
    // 🔥 PRIORITAS 1: Cek MEMORY CACHE dulu (paling cepat)
    if (_surahCache.containsKey(nomor) && !forceRefresh) {
      print("📱 [Memory Cache] Mengambil detail surat $nomor dari cache");
      return _surahCache[nomor]!;
    }
    
    // 🔥 PRIORITAS 2: Ambil dari DATABASE (kalau tidak force refresh)
    if (!forceRefresh) {
      try {
        // Ambil info surah dari database
        final surahInfo = await QuranDatabase.getSurahById(nomor);
        // Ambil daftar ayat dari database
        final ayatList = await QuranDatabase.getAyatBySurah(nomor);
        
        // Cek apakah data lengkap (jumlah ayat sesuai)
        if (surahInfo != null && ayatList.isNotEmpty) {
          // Validasi jumlah ayat
          if (ayatList.length == surahInfo.jumlahAyat) {
            print("📱 [Offline] Mengambil detail surat $nomor dari database (${ayatList.length} ayat)");
            
            // Buat objek SurahDetail dari data database
            final surahDetail = SurahDetail(
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
            
            // Simpan ke memory cache
            _surahCache[nomor] = surahDetail;
            return surahDetail;
          } else {
            print("⚠️ Data ayat tidak lengkap: expected ${surahInfo.jumlahAyat}, got ${ayatList.length}");
            print("🔄 Akan menghapus data tidak lengkap dan mengambil ulang dari API jika online");
            // Hapus data yang tidak lengkap
            await QuranDatabase.deleteAyatBySurah(nomor);
          }
        } else if (surahInfo != null && ayatList.isEmpty) {
          print("⚠️ Data ayat KOSONG untuk surah $nomor, perlu ambil dari API");
        }
      } catch (e) {
        print("⚠️ Gagal baca detail surat dari database: $e");
      }
    }
    
    // 🔥 PRIORITAS 3: Ambil dari API (online)
    try {
      print("🌐 [Online] Mengambil detail surat $nomor dari API");
      final response = await http.get(
        Uri.parse("https://equran.id/api/v2/surat/$nomor"),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Gagal memuat detail surat (Status: ${response.statusCode})');
      }
      
      final data = jsonDecode(response.body);
      final surah = SurahDetail.fromJson(data["data"]);
      
      print("📊 API mengembalikan ${surah.ayat.length} ayat untuk surah $nomor");
      
      // 🔥 SIMPAN KE DATABASE untuk offline
      // Simpan info surah
      final surahInfo = Surah(
        nomor: surah.nomor,
        nama: surah.nama,
        namaLatin: surah.namaLatin,
        jumlahAyat: surah.jumlahAyat,
        tempatTurun: surah.tempatTurun,
        arti: surah.arti,
        deskripsi: surah.deskripsi,
        audioFull: surah.audioFull,
      );
      await QuranDatabase.insertSurah(surahInfo);
      
      // Simpan daftar ayat (SEMUA AYAT)
      await QuranDatabase.insertAyat(surah.nomor, surah.ayat);
      print("💾 BERHASIL menyimpan ${surah.ayat.length} ayat untuk surah $nomor ke database");
      
      // Simpan ke memory cache
      _surahCache[nomor] = surah;
      
      return surah;
      
    } catch (e) {
      // 🔥 PRIORITAS 4: FALLBACK TERAKHIR - coba database lagi (kalau API gagal)
      print("⚠️ API gagal, fallback terakhir ke database untuk surah $nomor");
      try {
        final surahInfo = await QuranDatabase.getSurahById(nomor);
        final ayatList = await QuranDatabase.getAyatBySurah(nomor);
        
        if (surahInfo != null && ayatList.isNotEmpty) {
          print("📱 [Fallback] Mengambil detail surat $nomor dari database (${ayatList.length} ayat)");
          
          final surahDetail = SurahDetail(
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
          
          _surahCache[nomor] = surahDetail;
          return surahDetail;
        }
      } catch (dbError) {
        print("❌ Database juga gagal: $dbError");
      }
      
      throw Exception('Tidak dapat mengambil detail surat $nomor: $e');
    }
  }
  
  // ==================== GET TAFSIR SURAT (TETAP ONLINE) ====================
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
  
  // ==================== METHOD TAMBAHAN ====================
  
  /// Refresh semua data (hapus cache dan ambil dari API)
  static Future<void> refreshAllData() async {
    print("🔄 Refresh semua data...");
    _surahCache.clear();
    await QuranDatabase.resetAllData();
    await getDaftarSurat(forceRefresh: true);
    print("✅ Refresh selesai");
  }
  
  /// Hanya refresh daftar surat
  static Future<List<Surah>> refreshDaftarSurat() async {
    print("🔄 Refresh daftar surat...");
    return await getDaftarSurat(forceRefresh: true);
  }
  
  /// Refresh detail surat tertentu
  static Future<SurahDetail> refreshDetailSurat(int nomor) async {
    print("🔄 Refresh detail surat $nomor...");
    // Hapus dari cache dulu
    _surahCache.remove(nomor);
    // Hapus dari database (biar di-recreate)
    await QuranDatabase.deleteAyatBySurah(nomor);
    return await getDetailSurat(nomor, forceRefresh: true);
  }
  
  /// Cek apakah data offline tersedia untuk surat tertentu
  static Future<bool> isOfflineAvailable(int surahId) async {
    try {
      final surahInfo = await QuranDatabase.getSurahById(surahId);
      final ayatList = await QuranDatabase.getAyatBySurah(surahId);
      return surahInfo != null && ayatList.length == surahInfo.jumlahAyat;
    } catch (e) {
      return false;
    }
  }
  
  /// Hapus cache memory (tidak hapus database)
  static void clearMemoryCache() {
    _surahCache.clear();
    print("🗑️ Memory cache dibersihkan");
  }
  
  // ==================== DATA QARI (TIDAK BERUBAH) ====================
  
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