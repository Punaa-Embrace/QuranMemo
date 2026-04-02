import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'custom_header.dart';

class TentangAplikasiPage extends StatelessWidget {
  const TentangAplikasiPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: "Tentang Aplikasi",
              showAvatar: false,
              showBackButton: true,
              onBackPressed: () {
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          /// Logo
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Icon(
                              Icons.menu_book_rounded,
                              size: 60,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          /// Nama Aplikasi
                          const Text(
                            'QuranMemo',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          /// Versi
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Versi 1.0.0',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          /// Deskripsi
                          const Text(
                            'Aplikasi untuk memudahkan santri dalam setoran hafalan Al-Qur\'an',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 30),
                          
                          /// Divider
                          Divider(color: Colors.grey[300], thickness: 1),
                          const SizedBox(height: 20),
                          
                          /// Informasi Developer
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Informasi Developer',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          _buildInfoRow(Icons.person_outline, 'Developer', 'PBL IF-4MB–05'),
                          _buildInfoRow(Icons.email_outlined, 'Email', 'Syaapuna@gmail.com'),
                          _buildInfoRow(Icons.location_on_outlined, 'Alamat', 'Politeknik Negeri Batam'),
                          
                          const SizedBox(height: 20),
                          Divider(color: Colors.grey[300]),
                          const SizedBox(height: 20),
                          
                          /// Hak Cipta
                          const Text(
                            '© 2026 QuranMemo. All rights reserved.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}