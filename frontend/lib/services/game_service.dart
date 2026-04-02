import 'dart:math';
import 'quran_service.dart';
import '../models/surah_model.dart';

class GameService {
  static final Random _random = Random();
  static List<GameQuestion> _cachedQuestions = [];
  
  /// ========================
  /// GENERATE SOAL
  /// ========================
  static Future<List<GameQuestion>> generateTebakSurahSoal({
  required int jumlahSoal,
  bool forceRefresh = false,
  }) async {
    try {
      // 1. Ambil daftar semua surat
      final daftarSurat = await QuranService.getDaftarSurat();
      
      if (daftarSurat.isEmpty) throw Exception('Data surat kosong');
      
      // 2. Acak dan ambil sejumlah surat
      final List<Surah> suratTerpilih = List.from(daftarSurat);
      suratTerpilih.shuffle(_random);
      final suratUntukSoal = suratTerpilih.take(jumlahSoal).toList();
      
      List<GameQuestion> soalList = [];
      
      // 3. Buat soal untuk setiap surat
      for (var surat in suratUntukSoal) {
        // Ambil detail surat (untuk dapat ayat)
        final detailSurat = await QuranService.getDetailSurat(surat.nomor);
        
        if (detailSurat.ayat.isEmpty) continue;
        
        // Ambil ayat pertama
        final ayatContoh = detailSurat.ayat[0];
        
        // Buat pilihan jawaban (1 benar + 3 salah dari surat lain)
        List<String> pilihan = [surat.namaLatin];
        
        // Ambil surat lain untuk pengecoh
        final suratLain = daftarSurat
            .where((s) => s.nomor != surat.nomor)
            .toList();
        suratLain.shuffle(_random);
        
        for (int i = 0; i < 3 && i < suratLain.length; i++) {
          pilihan.add(suratLain[i].namaLatin);
        }
        pilihan.shuffle(_random);
        
        // Audio URL (ambil qari default '05' = Misyari)
        final audioUrl = ayatContoh.audio['05'] ?? '';
        
        soalList.add(GameQuestion(
          id: 'tebak_${surat.nomor}',
          type: 'tebak_surah',
          pertanyaan: ayatContoh.teksArab,
          terjemahan: ayatContoh.teksIndonesia,
          jawabanBenar: surat.namaLatin,
          pilihan: pilihan,
          surahReferensi: surat.namaLatin,
          nomorAyat: ayatContoh.nomor,
          audioUrl: audioUrl,
        ));
      }
      
      return soalList;
      
    } catch (e) {
      throw Exception('Gagal generate soal: $e');
    }
  }
  
  /// ========================
  /// GENERATE SOAL SAMBUNG AYAT
  /// ========================
  static Future<List<GameQuestion>> generateSambungAyatSoal({
  required int jumlahSoal,
  bool forceRefresh = false,
  }) async {
    try {
      // 1. Ambil daftar semua surat
      final daftarSurat = await QuranService.getDaftarSurat();
      
      if (daftarSurat.isEmpty) throw Exception('Data surat kosong');
      
      // 2. Filter surat yang punya minimal 2 ayat
      List<Surah> suratValid = [];
      for (var surat in daftarSurat) {
        if (surat.jumlahAyat >= 2) {
          suratValid.add(surat);
        }
      }
      
      // 3. Acak dan ambil sejumlah surat
      suratValid.shuffle(_random);
      final suratUntukSoal = suratValid.take(jumlahSoal).toList();
      
      List<GameQuestion> soalList = [];
      
      // 4. Buat soal untuk setiap surat
      for (var surat in suratUntukSoal) {
        final detailSurat = await QuranService.getDetailSurat(surat.nomor);
        
        if (detailSurat.ayat.length < 2) continue;
        
        // Ambil ayat ke-1 dan ke-2
        final ayatPertama = detailSurat.ayat[0];
        final ayatKedua = detailSurat.ayat[1];
        
        // Buat pilihan (1 benar + 3 ayat random dari surat lain)
        List<String> pilihan = [ayatKedua.teksArab];
        
        // Ambil ayat random dari surat lain untuk pengecoh
        final suratLain = daftarSurat
            .where((s) => s.nomor != surat.nomor)
            .toList();
        suratLain.shuffle(_random);
        
        int pengecohDiambil = 0;
        for (var suratPengecoh in suratLain) {
          if (pengecohDiambil >= 3) break;
          
          final detailPengecoh = await QuranService.getDetailSurat(suratPengecoh.nomor);
          if (detailPengecoh.ayat.isNotEmpty) {
            pilihan.add(detailPengecoh.ayat[0].teksArab);
            pengecohDiambil++;
          }
        }
        
        // Jika kurang pengecoh, tambah dari surat yang sama tapi ayat beda
        while (pilihan.length < 4 && detailSurat.ayat.length > 2) {
          pilihan.add(detailSurat.ayat[_random.nextInt(detailSurat.ayat.length)].teksArab);
        }
        
        pilihan.shuffle(_random);
        
        final audioUrl = ayatPertama.audio['05'] ?? '';
        
        soalList.add(GameQuestion(
          id: 'sambung_${surat.nomor}',
          type: 'sambung_ayat',
          pertanyaan: ayatPertama.teksArab,
          terjemahan: ayatPertama.teksIndonesia,
          jawabanBenar: ayatKedua.teksArab,
          pilihan: pilihan,
          surahReferensi: surat.namaLatin,
          nomorAyat: 1,
          audioUrl: audioUrl,
        ));
      }
      
      return soalList;
      
    } catch (e) {
      throw Exception('Gagal generate soal: $e');
    }
  }
  
  /// ========================
  /// RESET CACHE
  /// ========================
  static void resetCache() {
    _cachedQuestions.clear();
  }
}

/// Model soal game
class GameQuestion {
  final String id;
  final String type;
  final String pertanyaan;
  final String terjemahan;
  final String jawabanBenar;
  final List<String> pilihan;
  final String surahReferensi;
  final int nomorAyat;
  final String audioUrl;
  
  GameQuestion({
    required this.id,
    required this.type,
    required this.pertanyaan,
    required this.terjemahan,
    required this.jawabanBenar,
    required this.pilihan,
    required this.surahReferensi,
    required this.nomorAyat,
    required this.audioUrl,
  });
}