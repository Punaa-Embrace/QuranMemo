import 'package:flutter/material.dart';
import 'riwayat_detail_page.dart';
import '../theme/app_theme.dart';
import '../components/custom_header.dart';
import '../services/santri_service.dart';
import '../services/quran_database.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({Key? key}) : super(key: key);

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List<dynamic> _riwayat = [];
  List<dynamic> _filteredRiwayat = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedFilter = 'Semua';

  final List<String> _filters = [
    'Semua',
    'Dikirim',
    'Feedback',
    'Revisi',
    'Selesai',
  ];

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await SantriService.getSetoran();

      if (response['success'] == true) {
        final List<dynamic> fetchedData = response['data'] ?? [];
        
        for (var i = 0; i < fetchedData.length; i++) {
          final item = fetchedData[i] as Map<String, dynamic>;
          final suratNo = int.tryParse(item['surat']?.toString() ?? '1') ?? 1;
          final surahInfo = await QuranDatabase.getSurahById(suratNo);
          if (surahInfo != null) {
            item['nama_surat'] = surahInfo.namaLatin;
          }
        }

        setState(() {
          _riwayat = fetchedData;
          _filteredRiwayat = _riwayat;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Gagal memuat riwayat';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  void _filterRiwayat(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'Semua') {
        _filteredRiwayat = _riwayat;
      } else {
        _filteredRiwayat = _riwayat.where((item) {
          final status = item['status']?.toString().toLowerCase() ?? '';
          return status == filter.toLowerCase();
        }).toList();
      }
    });
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'selesai':
        return 'Selesai';
      case 'revisi':
        return 'Revisi';
      case 'feedback':
        return 'Feedback';
      case 'dikirim':
        return 'Dikirim';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'selesai':
        return Colors.green;
      case 'revisi':
        return Colors.red;
      case 'feedback':
        return Colors.blue;
      case 'dikirim':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getAyatDisplay(Map<String, dynamic> setoran, String ayat) {
    if (ayat.contains('-')) return ayat;
    final start = setoran['ayat_start'] ?? ayat;
    final end = setoran['ayat_end'] ?? ayat;
    if (start != end) return '$start - $end';
    return ayat;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: "Riwayat Setoran",
              imagePath: "assets/images/self.jpg",
              showSearch: true,
              hintText: "Cari riwayat...",
              showAvatar: true,
            ),
            _buildFilterChips(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                  ? _buildErrorWidget()
                  : _filteredRiwayat.isEmpty
                  ? _buildEmptyWidget()
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: _filteredRiwayat.map((item) {
                        return _buildRiwayatItem(item);
                      }).toList(),
                    ),
            ),
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
              onPressed: _loadRiwayat,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Belum ada riwayat setoran',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Mulai setoran hafalan sekarang',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                backgroundColor: Colors.white,
                selectedColor: AppTheme.primaryColor.withOpacity(0.1),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
                  width: 1.5,
                ),
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                onSelected: (_) => _filterRiwayat(filter),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRiwayatItem(Map<String, dynamic> setoran) {
    final surat = setoran['nama_surat'] ?? setoran['surat']?.toString() ?? '-';
    final ayat = setoran['ayat']?.toString() ?? '-';
    final status = setoran['status'] ?? 'dikirim';
    final feedback = setoran['feedback_tulisan'];
    final ayatDisplay = _getAyatDisplay(setoran, ayat);

    String dateStr = '';
    if (setoran['created_at'] != null) {
      try {
        final date = DateTime.parse(setoran['created_at']);
        dateStr = '${date.day}/${date.month}/${date.year}';
      } catch (_) {}
    }

    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);
    
    IconData statusIcon = Icons.access_time;
    if (status == 'selesai') statusIcon = Icons.check_circle_outline;
    if (status == 'revisi') statusIcon = Icons.replay;
    if (status == 'feedback') statusIcon = Icons.rate_review_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => RiwayatDetailPage(setoran: setoran),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(statusIcon, color: statusColor, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Surah $surat',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Ayat $ayatDisplay',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                if ((feedback != null && feedback.toString().trim().isNotEmpty) || dateStr.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFF0F0F0)),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (feedback != null && feedback.toString().trim().isNotEmpty)
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.format_quote_rounded, size: 14, color: Colors.grey[500]),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  feedback,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        const Spacer(),
                      if (dateStr.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(left: (feedback != null && feedback.toString().trim().isNotEmpty) ? 12.0 : 0),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, size: 12, color: Colors.grey[400]),
                              const SizedBox(width: 4),
                              Text(
                                dateStr,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
