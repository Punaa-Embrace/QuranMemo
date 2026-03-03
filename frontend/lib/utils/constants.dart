import 'package:flutter/material.dart';

class Constants {
  static const String userName = "Budi Syah Putra";
  static const String userEmail = "putra@example.com";
  
  // Gambar lokal
  static const String userImage = "assets/images/self.jpg";
  static const String ustadImage = "assets/images/ustad.jpg";
  
  static const List<String> surahList = [
    "Al-Baqarah",
    "Ali Imran",
    "An-Nisa'",
    "Al-Maidah",
  ];

  static const Map<String, String> surahMap = {
    "Al-Baqarah": "QS.2 : Al-Baqarah",
    "Ali Imran": "QS.3 : Ali Imran",
    "An-Nisa'": "QS.4 : An-Nisa'",
    "Al-Maidah": "QS.5 : Al-Maidah",
  };

  static ImageProvider getUserImage() {
    return const AssetImage(userImage);
  }

  static ImageProvider getUstadImage() {
    return const AssetImage(ustadImage);
  }
}