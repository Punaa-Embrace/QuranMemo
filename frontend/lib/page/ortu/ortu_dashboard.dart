// lib/page/ortu/dashboard_ortu.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../surah_page.dart';
import '../../components/custom_header.dart';
import 'donasi_page.dart';
import 'riwayat_donasi.dart';

class DashboardOrtu extends StatelessWidget {
  const DashboardOrtu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    // Data anak (static untuk frontend)
    final Map<String, dynamic> anak = {
      'name': 'Ahmad Santri',
      'kelas': 'Kelas 5',
      'totalJuz': 15,
      'targetJuz': 30,
      'lastSetoran': '20 April 2026',
      'nilaiRata': 85,
    };
    
    final progress = (anak['totalJuz'] / anak['targetJuz']) * 100;

    final List<Map<String, dynamic>> riwayatSetoran = [
      {
        'tanggal': '20 April 2026',
        'surah': 'Al-Fatihah',
        'ayat': '1-7',
        'nilai': 90,
        'catatan': 'Lancar, tajwid baik',
      },
      {
        'tanggal': '18 April 2026',
        'surah': 'An-Naba',
        'ayat': '1-15',
        'nilai': 85,
        'catatan': 'Perbaiki mad thabi\'i',
      },
      {
        'tanggal': '15 April 2026',
        'surah': 'Abasa',
        'ayat': '1-10',
        'nilai': 88,
        'catatan': 'Bagus, lanjutkan',
      },
    ];

    // 🔥 DATA MENU GRID
    final List<Map<String, dynamic>> menuGrid = [
      {'icon': Icons.book, 'label': 'Baca Quran', 'color': Colors.green, 'page': const SurahPage()},
      {'icon': Icons.assessment, 'label': 'Laporan', 'color': Colors.orange, 'page': null},
      {'icon': Icons.message, 'label': 'Pesan', 'color': Colors.blue, 'page': null},
      {'icon': Icons.volunteer_activism, 'label': 'Donasi', 'color': Colors.purple, 'page': const DonasiPage()},
      {'icon': Icons.history, 'label': 'Riwayat Donasi', 'color': Colors.teal, 'page': const RiwayatDonasiPage()},
      {'icon': Icons.help, 'label': 'Bantuan', 'color': Colors.brown, 'page': null},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5E2D1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// ===== CUSTOM HEADER DENGAN isParent: true =====
              CustomHeader(
                title: "QuranMemo",
                imagePath: "assets/images/self.jpg",
                showAvatar: true,
                showSearch: false,
                showBackButton: false,
                isParent: true,
              ),

              const SizedBox(height: 20),

              /// ===== CARD PROFIL ANAK =====
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.child_care,
                            color: AppTheme.primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Profil Anak",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(anak['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(anak['kelas'], style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                "Rata-rata: ${anak['nilaiRata']}",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text("Progress Hafalan", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        minHeight: 10,
                        backgroundColor: Colors.grey[200],
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${anak['totalJuz']} Juz", style: TextStyle(fontSize: 12, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                        Text("Target: ${anak['targetJuz']} Juz", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 18, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Text("Setoran Terakhir: ${anak['lastSetoran']}", style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// ===== RIWAYAT SETORAN =====
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.history, color: AppTheme.primaryColor, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Text("Riwayat Setoran", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 24),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: riwayatSetoran.length,
                      itemBuilder: (context, index) {
                        final item = riwayatSetoran[index];
                        return _buildRiwayatCard(item);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// ===== MENU GRID =====
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.grid_view, color: AppTheme.primaryColor, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Text("Menu", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 24),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemCount: menuGrid.length,
                      itemBuilder: (context, index) {
                        final menu = menuGrid[index];
                        return _buildGridMenu(
                          icon: menu['icon'],
                          label: menu['label'],
                          color: menu['color'],
                          onTap: () {
                            if (menu['page'] != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => menu['page']),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Fitur ${menu['label']} sedang dalam pengembangan')),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiwayatCard(Map<String, dynamic> item) {
    Color nilaiColor = item['nilai'] >= 85 
        ? Colors.green 
        : (item['nilai'] >= 70 ? Colors.orange : Colors.red);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                item['nilai'].toString(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: nilaiColor),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${item['surah']} (${item['ayat']})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(item['tanggal'], style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                if (item['catatan'] != null) ...[
                  const SizedBox(height: 4),
                  Text(item['catatan'], style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: nilaiColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text("${item['nilai']}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: nilaiColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildGridMenu({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}