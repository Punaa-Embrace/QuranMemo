import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/surah_model.dart';

class QuranDatabase {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'quran.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE surah(
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
        CREATE TABLE ayat(
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
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion == 1 && newVersion == 2) {
          print("🔄 Upgrade database: menghapus data ayat yang tidak lengkap");
          await db.delete('ayat');
        }
      },
    );
  }

  // ================= SURAH =================

  static Future<void> insertSurah(Surah surah) async {
    final database = await db;

    await database.insert('surah', {
      'nomor': surah.nomor,
      'nama': surah.nama,
      'namaLatin': surah.namaLatin,
      'jumlahAyat': surah.jumlahAyat,
      'tempatTurun': surah.tempatTurun,
      'arti': surah.arti,
      'deskripsi': surah.deskripsi,
      'audioFull': jsonEncode(surah.audioFull),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Surah>> getAllSurah() async {
    final database = await db;
    final result = await database.query('surah');

    return result.map((e) {
      return Surah(
        nomor: e['nomor'] as int,
        nama: e['nama'] as String,
        namaLatin: e['namaLatin'] as String,
        jumlahAyat: e['jumlahAyat'] as int,
        tempatTurun: e['tempatTurun'] as String,
        arti: e['arti'] as String,
        deskripsi: e['deskripsi'] as String,
        audioFull: Map<String, String>.from(
          jsonDecode(e['audioFull'] as String),
        ),
      );
    }).toList();
  }

  static Future<Surah?> getSurahById(int id) async {
    final database = await db;
    final result = await database.query(
      'surah',
      where: 'nomor = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;

    final e = result.first;

    return Surah(
      nomor: e['nomor'] as int,
      nama: e['nama'] as String,
      namaLatin: e['namaLatin'] as String,
      jumlahAyat: e['jumlahAyat'] as int,
      tempatTurun: e['tempatTurun'] as String,
      arti: e['arti'] as String,
      deskripsi: e['deskripsi'] as String,
      audioFull: Map<String, String>.from(jsonDecode(e['audioFull'] as String)),
    );
  }

  static Future<bool> isAyatLengkap(int surahId, int expectedJumlahAyat) async {
    final ayat = await getAyatBySurah(surahId);
    return ayat.length == expectedJumlahAyat;
  }

  static Future<void> deleteAyatBySurah(int surahId) async {
    final database = await db;
    await database.delete('ayat', where: 'surah_id = ?', whereArgs: [surahId]);
    print("🗑️ Menghapus ayat untuk surah $surahId");
  }

  // ================= AYAT =================

  static Future<void> insertAyat(int surahId, List<Ayat> ayatList) async {
    final database = await db;

    print("🔍 [DEBUG] Akan menyimpan ${ayatList.length} ayat untuk surah $surahId");
    if (ayatList.isNotEmpty) {
      print("🔍 [DEBUG] Ayat pertama: nomor=${ayatList.first.nomor}");
      print("🔍 [DEBUG] Ayat terakhir: nomor=${ayatList.last.nomor}");
    }

    await deleteAyatBySurah(surahId);

    final batch = database.batch();
    int insertedCount = 0;

    for (var ayat in ayatList) {
      batch.insert('ayat', {
        'surah_id': surahId,
        'nomor': ayat.nomor,
        'teksArab': ayat.teksArab,
        'teksLatin': ayat.teksLatin,
        'teksIndonesia': ayat.teksIndonesia,
        'audio': jsonEncode(ayat.audio),
      });
      insertedCount++;
    }

    await batch.commit(noResult: true);
    print("✅ BERHASIL menyimpan $insertedCount ayat untuk surah $surahId");

    // VERIFIKASI: cek langsung setelah insert
    final verify = await database.query(
      'ayat',
      where: 'surah_id = ?',
      whereArgs: [surahId],
    );
    print("🔍 [VERIFIKASI] Setelah insert, database berisi ${verify.length} ayat untuk surah $surahId");
  }

  static Future<List<Ayat>> getAyatBySurah(int surahId) async {
    final database = await db;

    final result = await database.query(
      'ayat',
      where: 'surah_id = ?',
      whereArgs: [surahId],
      orderBy: 'nomor ASC',
    );

    print("📖 Mengambil ${result.length} ayat untuk surah $surahId");

    List<Ayat> ayatList = [];

    for (var e in result) {
      try {
        final audioMap = Map<String, String>.from(jsonDecode(e['audio'] as String));
        
        ayatList.add(Ayat(
          nomor: e['nomor'] as int,
          teksArab: e['teksArab'] as String,
          teksLatin: e['teksLatin'] as String,
          teksIndonesia: e['teksIndonesia'] as String,
          audio: audioMap,
        ));
      } catch (err) {
        print("❌ Gagal decode audio untuk surah $surahId, ayat ${e['nomor']}: $err");
      }
    }

    print("📖 Total ayat yang berhasil di-decode: ${ayatList.length}");
    return ayatList;
  }

  static Future<void> resetAllData() async {
    final database = await db;
    await database.delete('ayat');
    await database.delete('surah');
    print("🗑️ Semua data dihapus");
  }

  // ================= DEBUG =================

  static Future<void> debugPrintAllSurah() async {
    final database = await db;
    final result = await database.query('surah');
    print("\n========== DAFTAR SURAT ==========");
    for (var row in result) {
      print("${row['nomor']}. ${row['namaLatin']} - ${row['jumlahAyat']} ayat");
    }
    print("==================================\n");
  }

  static Future<void> debugPrintAyat(int surahId) async {
    final database = await db;
    final result = await database.query(
      'ayat',
      where: 'surah_id = ?',
      whereArgs: [surahId],
    );
    print("\n========== AYAT SURAT $surahId ==========");
    for (var row in result) {
      print("Ayat ${row['nomor']}: ${row['teksArab']}");
    }
    print("========================================\n");
  }
}