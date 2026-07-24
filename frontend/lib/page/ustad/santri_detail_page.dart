import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'detail_setoran_page_ustad.dart';

class SantriDetailPage extends StatefulWidget {
  final Map<String, dynamic> santri;
  final List<Map<String, dynamic>> setoranList;

  const SantriDetailPage({
    super.key,
    required this.santri,
    required this.setoranList,
  });

  @override
  State<SantriDetailPage> createState() => _SantriDetailPageState();
}

class _SantriDetailPageState extends State<SantriDetailPage> {
  String _getInitials(String nama) {
    final parts = nama.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Colors.green;
      case 'revisi':
        return Colors.orange;
      case 'dikirim':
        return Colors.blue;
      case 'tugas':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Icons.check_circle_rounded;
      case 'revisi':
        return Icons.refresh_rounded;
      case 'dikirim':
        return Icons.send_rounded;
      case 'tugas':
        return Icons.assignment_rounded;
      default:
        return Icons.hourglass_empty_rounded;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return 'Selesai';
      case 'revisi':
        return 'Revisi';
      case 'dikirim':
        return 'Menunggu Review';
      case 'tugas':
        return 'Tugas';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nama = widget.santri['nama'] ?? 'Santri';
    final nim = widget.santri['nim'] ?? '-';
    final initials = _getInitials(nama.toString());
    final setoranList = widget.setoranList;

    final selesai = setoranList.where((s) => s['status'] == 'selesai').length;
    final menunggu = setoranList.where((s) => s['status'] == 'dikirim').length;
    final revisi = setoranList.where((s) => s['status'] == 'revisi').length;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Avatar
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        nama.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.badge_outlined, size: 13, color: Colors.white.withOpacity(0.8)),
                          const SizedBox(width: 4),
                          Text(
                            nim.toString(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  Row(
                    children: [
                      _buildStatCard(
                        label: 'Selesai',
                        count: selesai,
                        color: Colors.green,
                        icon: Icons.check_circle_rounded,
                      ),
                      const SizedBox(width: 10),
                      _buildStatCard(
                        label: 'Menunggu',
                        count: menunggu,
                        color: Colors.blue,
                        icon: Icons.hourglass_empty_rounded,
                      ),
                      const SizedBox(width: 10),
                      _buildStatCard(
                        label: 'Revisi',
                        count: revisi,
                        color: Colors.orange,
                        icon: Icons.refresh_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Setoran list header
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Riwayat Setoran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${setoranList.length} item',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Setoran list
          setoranList.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState())
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = setoranList[index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: _buildSetoranCard(item),
                      );
                    },
                    childCount: setoranList.length,
                  ),
                ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetoranCard(Map<String, dynamic> item) {
    final surat = item['surat'] ?? '-';
    final ayat = item['ayat'] ?? '-';
    final status = (item['status'] ?? 'dikirim').toString();
    final tanggal = item['created_at'] ?? item['tanggal'];

    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final statusLabel = _getStatusLabel(status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            // Build the item map that DetailSetoranPageUstad expects
            final detailData = {
              ...item,
              'nama': widget.santri['nama'] ?? 'Santri',
              'surah': '$surat $ayat',
              'status': statusLabel,
              'tanggal': tanggal?.toString() ?? 'Tidak diketahui',
            };
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailSetoranPageUstad(data: detailData),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Surah icon
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: AppTheme.primaryColor,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$surat',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Ayat $ayat',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      if (tanggal != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 12, color: Colors.grey.shade500),
                            const SizedBox(width: 3),
                            Text(
                              tanggal.toString().length > 10
                                  ? tanggal.toString().substring(0, 10)
                                  : tanggal.toString(),
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Status badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusBadge(statusLabel, statusColor, statusIcon),
                    const SizedBox(height: 8),
                    const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Belum ada setoran',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Santri ini belum memiliki riwayat setoran',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
