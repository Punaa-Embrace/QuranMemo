import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/surah_model.dart';

class QuranDatabase {
  // ============================================================================
  // Konstanta
  // ============================================================================
  static const int _versiDB = 2;
  static const String _namaDB = 'quran.db';
  static const String _tabelSurah = 'surah';
  static const String _tabelAyat = 'ayat';
  
  // ============================================================================
  // Variabel Private
  // ============================================================================
  static Database? _database;
  
  // ============================================================================
  // Akses Database
  // ============================================================================
  static Future<Database> get db async {
    _database ??= await _initDB();
    return _database!;
  }
  
  // ============================================================================
  // Inisialisasi Database
  // ============================================================================
  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), _namaDB);
    
    return await openDatabase(
      path,
      version: _versiDB,
      onCreate: _buatTabel,
      onUpgrade: _upgradeDB,
    );
  }
  
  static Future<void> _buatTabel(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tabelSurah(
        nomor INTEGER PRIMARY KEY,
        nama TEXT,
        namaLatin TEXT,
        jumlahAyat INTEGER,
        tempatTurun TEXT,
        arti TEXT,
        deskripsi TEXT,
        audioFull TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE $_tabelAyat(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_id INTEGER,
        nomor INTEGER,
        teksArab TEXT,
        teksLatin TEXT,
        teksIndonesia TEXT,
        audio TEXT,
        UNIQUE(surah_id, nomor)
      )
    ''');
  }
  
  static Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion == 1 && newVersion == 2) {
      await db.delete(_tabelAyat);
    }
  }
  
  // ============================================================================
  // Operasi Surah
  // ============================================================================
  static Future<void> insertSurah(Surah surah) async {
    final db = await QuranDatabase.db;
    
    await db.insert(
      _tabelSurah,
      {
        'nomor': surah.nomor,
        'nama': surah.nama,
        'namaLatin': surah.namaLatin,
        'jumlahAyat': surah.jumlahAyat,
        'tempatTurun': surah.tempatTurun,
        'arti': surah.arti,
        'deskripsi': surah.deskripsi,
        'audioFull': jsonEncode(surah.audioFull),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  static Future<List<Surah>> getAllSurah() async {
    final db = await QuranDatabase.db;
    final hasil = await db.query(_tabelSurah);
    return hasil.map(_mapToSurah).toList();
  }
  
  static Future<Surah?> getSurahById(int id) async {
    final db = await QuranDatabase.db;
    final hasil = await db.query(
      _tabelSurah,
      where: 'nomor = ?',
      whereArgs: [id],
    );
    
    return hasil.isEmpty ? null : _mapToSurah(hasil.first);
  }
  
  static Surah _mapToSurah(Map<String, dynamic> map) {
    return Surah(
      nomor: map['nomor'] as int,
      nama: map['nama'] as String,
      namaLatin: map['namaLatin'] as String,
      jumlahAyat: map['jumlahAyat'] as int,
      tempatTurun: map['tempatTurun'] as String,
      arti: map['arti'] as String,
      deskripsi: map['deskripsi'] as String,
      audioFull: Map<String, String>.from(jsonDecode(map['audioFull'] as String)),
    );
  }
  
  // ============================================================================
  // Operasi Ayat
  // ============================================================================
  static Future<void> insertAyat(int surahId, List<Ayat> ayatList) async {
    if (ayatList.isEmpty) return;
    
    final db = await QuranDatabase.db;
    
    await _hapusAyatBySurah(db, surahId);
    
    final batch = db.batch();
    for (var ayat in ayatList) {
      batch.insert(_tabelAyat, _ayatToMap(surahId, ayat));
    }
    
    try {
      await batch.commit(noResult: true);
    } catch (e) {
      // Fallback: insert satu per satu
      for (var ayat in ayatList) {
        await db.insert(
          _tabelAyat,
          _ayatToMap(surahId, ayat),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }
  
  static Map<String, dynamic> _ayatToMap(int surahId, Ayat ayat) {
    return {
      'surah_id': surahId,
      'nomor': ayat.nomor,
      'teksArab': ayat.teksArab,
      'teksLatin': ayat.teksLatin,
      'teksIndonesia': ayat.teksIndonesia,
      'audio': jsonEncode(ayat.audio),
    };
  }
  
  static Future<List<Ayat>> getAyatBySurah(int surahId) async {
    final db = await QuranDatabase.db;
    
    final hasil = await db.query(
      _tabelAyat,
      where: 'surah_id = ?',
      whereArgs: [surahId],
      orderBy: 'nomor ASC',
    );
    
    final List<Ayat> ayatList = [];
    for (var item in hasil) {
      try {
        ayatList.add(Ayat(
          nomor: item['nomor'] as int,
          teksArab: item['teksArab'] as String,
          teksLatin: item['teksLatin'] as String,
          teksIndonesia: item['teksIndonesia'] as String,
          audio: Map<String, String>.from(jsonDecode(item['audio'] as String)),
        ));
      } catch (e) {
        // Skip jika gagal decode
      }
    }
    
    return ayatList;
  }
  
  static Future<void> _hapusAyatBySurah(Database db, int surahId) async {
    await db.delete(
      _tabelAyat,
      where: 'surah_id = ?',
      whereArgs: [surahId],
    );
  }
  
  static Future<void> deleteAyatBySurah(int surahId) async {
    final db = await QuranDatabase.db;
    await _hapusAyatBySurah(db, surahId);
  }
  
  // ============================================================================
  // Utility
  // ============================================================================
  static Future<bool> isAyatLengkap(int surahId, int expectedJumlahAyat) async {
    final ayat = await getAyatBySurah(surahId);
    return ayat.length == expectedJumlahAyat;
  }
  
  static Future<void> resetAllData() async {
    final db = await QuranDatabase.db;
    await db.delete(_tabelAyat);
    await db.delete(_tabelSurah);
  }
  
  // ============================================================================
  // Debug 
  // ============================================================================
  static Future<void> debugPrintAllSurah() async {
    final surahList = await getAllSurah();
    print('\n========== DATA SURAH ==========');
    for (var surah in surahList) {
      print('${surah.nomor}. ${surah.namaLatin} - ${surah.jumlahAyat} ayat');
    }
    print('================================\n');
  }
}