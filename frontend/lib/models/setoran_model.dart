import 'package:flutter/material.dart';

class SetoranModel {
  final String surah;
  final String ayat;
  final String status;
  final Color statusColor;
  final String date;
  final String? catatan;
  final int? kelancaran;
  final int? tajwid;
  final String? catatanUstad;
  final String? ustadName;

  SetoranModel({
    required this.surah,
    required this.ayat,
    required this.status,
    required this.statusColor,
    required this.date,
    this.catatan,
    this.kelancaran,
    this.tajwid,
    this.catatanUstad,
    this.ustadName,
  });

  // Factory method untuk dummy data
  static List<SetoranModel> dummyData() {
    return [
      SetoranModel(
        surah: "Surah Al-Baqarah",
        ayat: "QS.2 : Al-Baqarah (1-5)",
        status: "Disetujui",
        statusColor: Colors.green,
        date: "20 Feb 2026",
        kelancaran: 90,
        tajwid: 85,
        catatanUstad: "Hafalan kamu bagus, pertahankan!",
        ustadName: "Ust. Ahmad",
      ),
      SetoranModel(
        surah: "Surah An-Nisa'",
        ayat: "QS.4 : An-Nisa' (20-25)",
        status: "Disetujui",
        statusColor: Colors.green,
        date: "15 Feb 2026",
        kelancaran: 95,
        tajwid: 90,
        catatanUstad: "Sangat baik, lancar dan tajwid tepat",
        ustadName: "Ust. Ahmad",
      ),
      SetoranModel(
        surah: "Surah Ali Imran",
        ayat: "QS.3 : Ali Imran (50-55)",
        status: "Pending",
        statusColor: Colors.orange,
        date: "10 Feb 2026",
        catatan: "Menunggu koreksi ustad",
        ustadName: "Ust. Ahmad",
      ),
      SetoranModel(
        surah: "Surah Al-Baqarah",
        ayat: "QS.2 : Al-Baqarah (255-260)",
        status: "Ditolak",
        statusColor: Colors.red,
        date: "05 Feb 2026",
        catatan: "Ayat kursi perlu diulang",
        kelancaran: 50,
        tajwid: 45,
        catatanUstad: "Mohon ulangi setoran, masih banyak kesalahan makhraj",
        ustadName: "Ust. Ahmad",
      ),
    ];
  }

  // Helper method untuk mendapatkan icon status
  IconData getStatusIcon() {
    switch (status) {
      case "Disetujui":
        return Icons.check_circle;
      case "Perbaikan":
        return Icons.warning;
      case "Ditolak":
        return Icons.cancel;
      case "Pending":
        return Icons.hourglass_empty;
      default:
        return Icons.help;
    }
  }
}

class UserModel {
  final String name;
  final String email;
  final String imageUrl;
  final String status;
  final int totalJuz;
  final int targetJuz;
  final double progress;

  UserModel({
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.status,
    required this.totalJuz,
    required this.targetJuz,
    required this.progress,
  });

  // Factory method untuk dummy data user
  static UserModel dummyUser() {
    return UserModel(
      name: "Putra Santri",
      email: "putra@example.com",
      imageUrl: "https://i.pravatar.cc/150?img=3",
      status: "Santri Aktif",
      totalJuz: 12,
      targetJuz: 30,
      progress: 0.4,
    );
  }
}

class UstadModel {
  final String name;
  final String role;
  final String imageUrl;

  UstadModel({
    required this.name,
    required this.role,
    required this.imageUrl,
  });

  static UstadModel dummyUstad() {
    return UstadModel(
      name: "Ust. Ahmad",
      role: "Pembimbing Tahfidz",
      imageUrl: "https://i.pravatar.cc/150?img=8",
    );
  }
}

class TugasModel {
  final String title;
  final String surah;
  final DateTime deadline;
  final bool isCompleted;

  TugasModel({
    required this.title,
    required this.surah,
    required this.deadline,
    required this.isCompleted,
  });

  static List<TugasModel> dummyTugas() {
    return [
      TugasModel(
        title: "Setor Hafalan Baru",
        surah: "Juz 5 - Surah Al-Ma'idah",
        deadline: DateTime(2026, 2, 21),
        isCompleted: false,
      ),
      TugasModel(
        title: "Murojaah",
        surah: "Juz 1 - Surah Al-Baqarah",
        deadline: DateTime(2026, 2, 22),
        isCompleted: false,
      ),
      TugasModel(
        title: "Perbaikan Setoran",
        surah: "Surah An-Nisa' ayat 10",
        deadline: DateTime(2026, 2, 20),
        isCompleted: true,
      ),
    ];
  }
}