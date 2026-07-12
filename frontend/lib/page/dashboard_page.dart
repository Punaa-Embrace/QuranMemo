import 'package:flutter/material.dart';
import 'package:quranmemo/page/rekam_setoran_page.dart';
import '../../theme/app_theme.dart';
import '../../components/custom_header.dart';
import '../../services/santri_service.dart';
import '../../services/quran_database.dart';
import '../../models/surah_model.dart';

class SantriPage extends StatefulWidget {
  const SantriPage({Key? key}) : super(key: key);

  @override
  State<SantriPage> createState() => _SantriPageState();
}

class _SantriPageState extends State<SantriPage> {
  Map<String, dynamic> _progress = {};
  List<dynamic> _setoranTerakhir = [];
  bool _isLoading = true;
  int _ayatTerakhir = 0;
  int _suratTerakhir = 1;
  String _namaSurat = 'Al-Fatihah';
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  
  Map<String, dynamic> _tugasAktif = {};
  List<DateTime> _setoranDates = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final progress = await SantriService.getProgress();
      final setoran = await SantriService.getSetoran();

      setState(() {
        _progress = progress['data'] ?? {};
        _setoranTerakhir = setoran['data'] ?? [];

        final ayatTerakhir = _progress['ayat_terakhir'];
        if (ayatTerakhir != null) {
          _suratTerakhir = ayatTerakhir['surat'] ?? 1;
          _ayatTerakhir = ayatTerakhir['ayat'] ?? 0;
        }

        _setoranDates = _setoranTerakhir.map((item) {
          try {
            return DateTime.parse(item['created_at'] ?? DateTime.now().toIso8601String());
          } catch (_) {
            return DateTime.now();
          }
        }).toList();

        _tugasAktif = {
          'deadline': DateTime.now().add(const Duration(days: 3)),
          'surat': _suratTerakhir,
          'ayat': _ayatTerakhir,
          'target': _ayatTerakhir + 5,
        };

        _isLoading = false;
      });

      //  Ambil nama surat dari SQLite
      final surahInfo = await QuranDatabase.getSurahById(_suratTerakhir);
      if (surahInfo != null) {
        setState(() {
          _namaSurat = surahInfo.namaLatin;
        });
      }

    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: "QuranMemo",
              imagePath: "assets/images/self.jpg",
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTugasCard(),
                            const SizedBox(height: 16),
                            _buildProgressCard(),
                            const SizedBox(height: 16),
                            _buildSetoranTerakhir(),
                            const SizedBox(height: 16),
                            _buildCalendar(),
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

  Widget _buildTugasCard() {
    final nextAyat = _ayatTerakhir + 1;
    final targetAyat = _tugasAktif['target'] ?? nextAyat + 4;
    final deadline = _tugasAktif['deadline'] as DateTime?;
    final daysLeft = deadline != null ? deadline.difference(DateTime.now()).inDays : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            const Color(0xFF26B760), // Lighter, more vibrant green
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.35),
            blurRadius: 24,
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.assignment, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tugas Hafalan Aktif',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (deadline != null)
                      Text(
                        daysLeft <= 0
                            ? 'Deadline hari ini!'
                            : 'Sisa $daysLeft hari',
                        style: TextStyle(
                          color: daysLeft <= 1 ? Colors.red : Colors.white70,
                          fontSize: 12,
                          fontWeight: daysLeft <= 1 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: daysLeft <= 1 ? Colors.red : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  deadline != null ? '${deadline.day}/${deadline.month}' : '-',
                  style: TextStyle(
                    color: daysLeft <= 1 ? Colors.white : Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip('Surah $_namaSurat', Colors.white.withOpacity(0.2)),
              const SizedBox(width: 8),
              _buildInfoChip('Ayat $nextAyat → $targetAyat', Colors.white.withOpacity(0.2)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RekamSetoranPage(
                      surah: Surah(
                        nomor: _suratTerakhir ?? 1,
                        nama: '',
                        namaLatin: _namaSurat,
                        jumlahAyat: 100,
                        tempatTurun: '',
                        arti: '',
                        deskripsi: '',
                        audioFull: {},
                      ),
                      ayatStart: nextAyat,
                      ayatEnd: targetAyat,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.mic, size: 20),
                  SizedBox(width: 8),
                  Text('Rekam Setoran', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }

  Widget _buildProgressCard() {
    final totalAyat = _progress['total_ayat_selesai'] ?? 0;
    final target = _progress['total_ayat_target'] ?? 6236;
    final progressPercent = target > 0 ? (totalAyat / target * 100) : 0;
    final juz = (totalAyat / 6236 * 30).round();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: progressPercent / 100,
                    strokeWidth: 6,
                    color: AppTheme.primaryColor,
                    backgroundColor: Colors.grey[200],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$juz',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Text(
                      'Juz',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progress Hafalan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${progressPercent.toStringAsFixed(1)}% selesai',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressPercent / 100,
                      minHeight: 6,
                      backgroundColor: Colors.grey[200],
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildSetoranTerakhir() {
    if (_setoranTerakhir.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: const Row(
          children: [
            Icon(Icons.history, color: Colors.grey),
            SizedBox(width: 12),
            Text('Belum ada riwayat setoran'),
          ],
        ),
      );
    }

    final last = _setoranTerakhir[0];
    final surat = last['surat'] ?? '-';
    final ayat = last['ayat'] ?? '-';
    final status = last['status'] ?? 'dikirim';

    String statusText = 'Dikirim';
    Color statusColor = Colors.orange;
    if (status == 'selesai') {
      statusText = 'Selesai';
      statusColor = Colors.green;
    } else if (status == 'revisi') {
      statusText = 'Perbaiki';
      statusColor = Colors.red;
    } else if (status == 'feedback') {
      statusText = 'Feedback';
      statusColor = Colors.blue;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.history, color: AppTheme.primaryColor),
        ),
        title: Text(
          'Surah $surat - Ayat $ayat',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                statusText,
                style: TextStyle(color: statusColor, fontSize: 11),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {},
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_getMonthName(_selectedMonth)} $_selectedYear',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 24),
                      onPressed: () {
                        setState(() {
                          if (_selectedMonth == 1) {
                            _selectedMonth = 12;
                            _selectedYear--;
                          } else {
                            _selectedMonth--;
                          }
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 24),
                      onPressed: () {
                        setState(() {
                          if (_selectedMonth == 12) {
                            _selectedMonth = 1;
                            _selectedYear++;
                          } else {
                            _selectedMonth++;
                          }
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCalendarGrid(),
          ],
        ),
      );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = _getDaysInMonth(_selectedMonth, _selectedYear);
    final firstDayOfWeek = _getFirstDayOfWeek(_selectedMonth, _selectedYear);

    List<Widget> dayWidgets = [];

    const weekdays = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];
    for (var day in weekdays) {
      dayWidgets.add(
        Container(
          alignment: Alignment.center,
          child: Text(
            day,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    for (int i = 0; i < firstDayOfWeek; i++) {
      dayWidgets.add(const SizedBox());
    }

    final today = DateTime.now();
    final deadline = _tugasAktif['deadline'] as DateTime?;

    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(_selectedYear, _selectedMonth, i);
      final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
      
      final hasSetoran = _setoranDates.any((d) => 
        d.year == date.year && d.month == date.month && d.day == date.day
      );
      
      final isDeadline = deadline != null && 
        deadline.year == date.year && 
        deadline.month == date.month && 
        deadline.day == date.day;

      Color? bgColor;
      if (isToday) {
        bgColor = AppTheme.primaryColor;
      } else if (isDeadline) {
        bgColor = Colors.red;
      } else if (hasSetoran) {
        bgColor = Colors.green.withOpacity(0.3);
      }

      Color textColor = Colors.black87;
      if (isToday) textColor = Colors.white;
      else if (isDeadline) textColor = Colors.white;
      else if (hasSetoran) textColor = AppTheme.primaryColor;

      dayWidgets.add(
        Container(
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bgColor,
                ),
              ),
              Text(
                i.toString(),
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: textColor,
                  fontSize: 13,
                ),
              ),
              if (isDeadline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              if (hasSetoran && !isToday && !isDeadline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: dayWidgets,
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }

  int _getDaysInMonth(int month, int year) {
    return DateTime(year, month + 1, 0).day;
  }

  int _getFirstDayOfWeek(int month, int year) {
    return DateTime(year, month, 1).weekday % 7;
  }
}