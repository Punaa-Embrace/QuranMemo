import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/custom_header.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,

      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: "QuranMemo",
              imagePath: "assets/images/self.jpg", // optional
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildProgressCard(),
                      const SizedBox(height: 18),
                      _buildTugasSection(),
                      const SizedBox(height: 12),
                      _buildCalendarCard(),
                      const SizedBox(height: 12),
                      _buildSetoranTerakhir(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const weekdays = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final wd = weekdays[(date.weekday - 1) % 7];
    final d = date.day.toString().padLeft(2, '0');
    final m = months[date.month - 1];
    final y = date.year;
    return '$wd, $d $m $y';
  }

  Widget _buildProgressCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      '12/30',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Juz',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progress Hafalan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '40% selesai',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.mic),
                      label: const Text('Setoran Hafal Sekarang'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTugasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.event_note, color: Colors.brown),
            SizedBox(width: 8),
            Text(
              'Tugas Hari ini',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _taskCard(
          'Juz 5 - Surah Al-Ma\'idah',
          'Batas: 30 Maret 2026',
          'Belum Setor',
        ),
        const SizedBox(height: 8),
        _taskCard(
          'Juz 5 - Surah Al-Ma\'idah',
          'Batas: 30 Maret 2026',
          'Belum Setor',
        ),
      ],
    );
  }

  Widget _taskCard(String title, String subtitle, String tag) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.menu_book, color: Colors.green),
        ),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.redAccent),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(tag, style: const TextStyle(color: Colors.orange)),
        ),
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.calendar_today, color: Colors.green),
                SizedBox(width: 8),
                Text('Kalender', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) => _dayBox(i)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayBox(int index) {
    // simplified sample: first 3 days checked, 4th check, 5th red, 6th warn, 7th empty
    final icons = [
      Icons.check_circle,
      Icons.check_circle,
      Icons.check_circle,
      Icons.check_circle,
      Icons.circle,
      Icons.error_outline,
      Icons.check_circle_outline,
    ];
    final colors = [
      Colors.green,
      Colors.green,
      Colors.green,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.grey,
    ];
    return Column(
      children: [
        Text(
          ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'][index],
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 6),
        Icon(icons[index], color: colors[index], size: 18),
      ],
    );
  }
}

Widget _buildTugasHariIni() {
  return Card(
    child: ListTile(
      leading: const Icon(Icons.assignment, color: Colors.green),
      title: const Text("Tugas Hari Ini"),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Juz 5 - Surah Al-Ma'idah"),
          Text(
            "Batas: 05 Maret 2026",
            style: TextStyle(color: Colors.red[400], fontSize: 12),
          ),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          "Belum Setor",
          style: TextStyle(color: Colors.orange, fontSize: 12),
        ),
      ),
    ),
  );
}

Widget _buildSetoranTerakhir() {
  return Card(
    child: ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.menu_book, color: Colors.green),
      ),
      title: const Text("Surah Al-Baqarah"),
      subtitle: const Text("Status: Perbaiki tajwid ayat 3"),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    ),
  );
}
