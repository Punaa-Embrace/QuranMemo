import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/custom_header.dart';

class BantuanPage extends StatelessWidget {
  const BantuanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: "Pusat Bantuan",
              showAvatar: false,
              showBackButton: true,
              onBackPressed: () {
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  /// Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.support_agent,
                          size: 50,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Ada yang bisa kami bantu?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Temukan jawaban dari pertanyaan Anda',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  /// FAQ Title
                  const Text(
                    'Pertanyaan Umum',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  /// FAQ Items
                  _buildFaqItem(
                    'Cara melakukan setoran hafalan?',
                    '1. Buka menu "Setoran" di navbar bawah\n2. Pilih surat dan ayat yang akan disetor\n3. Rekam hafalan Anda dengan klik tombol mikrofon\n4. Klik "Kirim Setoran" untuk mengirim ke pengajar',
                  ),
                  _buildFaqItem(
                    'Bagaimana cara melihat riwayat setoran?',
                    'Anda bisa melihat riwayat setoran dengan:\n• Klik menu "Riwayat" di navbar bawah\n• Di sana akan tampil semua riwayat setoran Anda\n• Klik item untuk melihat detail',
                  ),
                  _buildFaqItem(
                    'Apa yang harus dilakukan jika setoran ditolak?',
                    'Jika setoran ditolak:\n1. Buka menu "Riwayat"\n2. Cari setoran yang ditolak\n3. Lihat catatan dari pengajar\n4. Perbaiki hafalan sesuai catatan\n5. Kirim ulang setoran',
                  ),
                  _buildFaqItem(
                    'Bagaimana cara menghubungi pengajar?',
                    'Anda bisa menghubungi pengajar melalui:\n• Fitur chat yang tersedia di profil pengajar\n• WhatsApp sesuai nomor yang terdaftar\n• Datang langsung ke pondok',
                  ),
                  _buildFaqItem(
                    'Apakah bisa mengulang hafalan?',
                    'Ya, Anda bisa mengulang hafalan kapan saja melalui menu "Surat" di navbar bawah, lalu pilih surat dan ayat yang ingin diulang.',
                  ),
                  _buildFaqItem(
                    'Bagaimana cara mendapatkan poin?',
                    'Poin didapatkan dari:\n• Setoran hafalan yang disetujui\n• Bermain game di menu "Permainan"\n• Keaktifan harian',
                  ),
                  _buildFaqItem(
                    'Kontak dukungan',
                    'Jika masih ada pertanyaan, silakan hubungi:\nEmail: support@quranmemo.com\nWhatsApp: 0812-3456-7890\nSenin-Jumat: 08.00-16.00',
                  ),
                  
                  const SizedBox(height: 20),
                  
                  /// Contact Button
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Masih butuh bantuan?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Fitur chat akan segera hadir'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.chat),
                            label: const Text('Hubungi Kami'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.help_outline,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.5,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}