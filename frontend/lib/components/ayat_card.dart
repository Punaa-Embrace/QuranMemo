import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AyatCard extends StatelessWidget {
  final String teksArab;
  final String terjemahan;

  const AyatCard({
    Key? key,
    required this.teksArab,
    required this.terjemahan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Hitung panjang teks untuk menentukan ukuran font
    int panjangTeks = teksArab.length;
    
    // Auto adjust font size berdasarkan panjang teks
    double fontSize;
    if (panjangTeks < 50) {
      fontSize = 28;  // Teks pendek -> font besar
    } else if (panjangTeks < 100) {
      fontSize = 24;  // Teks sedang -> font sedang
    } else if (panjangTeks < 150) {
      fontSize = 20;  // Teks panjang -> font kecil
    } else {
      fontSize = 18;  // Teks sangat panjang -> font sangat kecil
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Ayat Arab dengan auto font size
                Container(
                  width: double.infinity,
                  child: Text(
                    teksArab,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontFamily: 'me_quran',
                      color: Colors.white,
                      height: 1.5,
                    ),
                    softWrap: true,  // Wrap ke bawah
                  ),
                ),
                const SizedBox(height: 12),
                
                /// Terjemahan
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    terjemahan,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}