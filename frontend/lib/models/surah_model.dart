class SurahResponse {
  final int code;
  final String message;
  final List<Surah> data;

  SurahResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory SurahResponse.fromJson(Map<String, dynamic> json) {
    return SurahResponse(
      code: json['code'] ?? 0, // Tambah null check
      message: json['message'] ?? '',
      data: (json['data'] as List? ?? []) // Tambah null check
          .map((item) => Surah.fromJson(item))
          .toList(),
    );
  }
}

class Surah {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;
  final String tempatTurun;
  final String arti;
  final String deskripsi;
  final Map<String, String> audioFull;

  Surah({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.deskripsi,
    required this.audioFull,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      nomor: json['nomor'] ?? 0,
      nama: json['nama'] ?? '',
      namaLatin: json['namaLatin'] ?? '',
      jumlahAyat: json['jumlahAyat'] ?? 0,
      tempatTurun: json['tempatTurun'] ?? '',
      arti: json['arti'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      audioFull: Map<String, String>.from(json['audioFull'] ?? {}),
    );
  }
}

class SurahDetail extends Surah {
  final List<Ayat> ayat;

  SurahDetail({
    required super.nomor,
    required super.nama,
    required super.namaLatin,
    required super.jumlahAyat,
    required super.tempatTurun,
    required super.arti,
    required super.deskripsi,
    required super.audioFull,
    required this.ayat,
  });

  factory SurahDetail.fromJson(Map<String, dynamic> json) {
    return SurahDetail(
      nomor: json['nomor'] ?? 0,
      nama: json['nama'] ?? '',
      namaLatin: json['namaLatin'] ?? '',
      jumlahAyat: json['jumlahAyat'] ?? 0,
      tempatTurun: json['tempatTurun'] ?? '',
      arti: json['arti'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      audioFull: Map<String, String>.from(json['audioFull'] ?? {}),
      ayat: (json['ayat'] as List? ?? [])
          .map((item) => Ayat.fromJson(item))
          .toList(),
    );
  }
}

class Ayat {
  final int nomor;
  final String teksArab;
  final String teksLatin;
  final String teksIndonesia;
  final Map<String, String> audio;

  Ayat({
    required this.nomor,
    required this.teksArab,
    required this.teksLatin,
    required this.teksIndonesia,
    required this.audio,
  });

  factory Ayat.fromJson(Map<String, dynamic> json) {
    return Ayat(
      nomor: json['nomor'] ?? 0,
      teksArab: json['teksArab'] ?? '',
      teksLatin: json['teksLatin'] ?? '',
      teksIndonesia: json['teksIndonesia'] ?? '',
      audio: Map<String, String>.from(json['audio'] ?? {}),
    );
  }
}