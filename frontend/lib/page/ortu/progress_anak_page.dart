import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/orangtua_service.dart';

class ProgressAnakPage extends StatefulWidget {
  final String santriId;
  final String nama;

  const ProgressAnakPage({
    Key? key,
    required this.santriId,
    required this.nama,
  }) : super(key: key);

  @override
  State<ProgressAnakPage> createState() => _ProgressAnakPageState();
}

class _ProgressAnakPageState extends State<ProgressAnakPage> {
  Map<String, dynamic> _progress = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await OrangtuaService.getProgressAnak(widget.santriId);

      setState(() {
        if (response['success'] == true) {
          _progress = response['data'] ?? {};
        } else {
          _errorMessage = response['message'] ?? 'Gagal memuat progress';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Progress ${widget.nama}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildProgressCard(),
                      const SizedBox(height: 16),
                      _buildStatsCard(),
                      const SizedBox(height: 16),
                      _buildAyatTerakhirCard(),
                      const SizedBox(height: 16),
                      _buildLeaderboardCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProgress,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final totalAyat = _progress['total_ayat_selesai'] ?? 0;
    final target = _progress['total_ayat_target'] ?? 6236;
    final progressPercent = target > 0 ? (totalAyat / target * 100) : 0;
    final juz = (totalAyat / 6236 * 30).round();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: progressPercent / 100,
                    strokeWidth: 8,
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
                        fontSize: 24,
                      ),
                    ),
                    const Text(
                      'Juz',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${progressPercent.toStringAsFixed(1)}% selesai',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final totalSetoran = _progress['total_setoran'] ?? 0;
    final setoranSelesai = _progress['setoran_selesai'] ?? 0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Total Setoran',
              totalSetoran.toString(),
              Icons.history,
              Colors.orange,
            ),
            _buildStatItem(
              'Setoran Selesai',
              setoranSelesai.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAyatTerakhirCard() {
    final ayatTerakhir = _progress['ayat_terakhir'];
    final surat = ayatTerakhir != null ? ayatTerakhir['surat'] ?? '-' : '-';
    final ayat = ayatTerakhir != null ? ayatTerakhir['ayat'] ?? '-' : '-';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.menu_book, color: AppTheme.primaryColor),
        ),
        title: const Text('Ayat Terakhir'),
        subtitle: Text('Surah $surat - Ayat $ayat'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildLeaderboardCard() {
    final nilai = _progress['leaderboard'] ?? 0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.emoji_events, color: Colors.amber),
        ),
        title: const Text('Leaderboard'),
        subtitle: Text('$nilai poin'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          // Navigasi ke leaderboard
        },
      ),
    );
  }
}