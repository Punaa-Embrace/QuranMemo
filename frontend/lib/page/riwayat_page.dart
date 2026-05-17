import 'package:flutter/material.dart';
import 'riwayat_detail_page.dart';
import '../theme/app_theme.dart';
import '../components/custom_header.dart';
import '../models/setoran_model.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<SetoranModel> riwayatList = SetoranModel.dummyData();

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
              showAvatar: true, // Tampilkan avatar untuk ke akun
            ),
            _buildFilterChips(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: riwayatList.map((setoran) {
                  return _buildRiwayatItem(
                    setoran: setoran,
                    onTap: () {
                      _showDetailDialog(context, setoran);
                    },
                  );
                }).toList(),
              ),
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
          children: [
            _buildFilterChip("Semua", true),
            const SizedBox(width: 8),
            _buildFilterChip("Disetujui", false),
            const SizedBox(width: 8),
            _buildFilterChip("Perbaikan", false),
            const SizedBox(width: 8),
            _buildFilterChip("Ditolak", false),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Chip(
      label: Text(label),
      backgroundColor: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.white,
      side: isSelected
          ? BorderSide(color: AppTheme.primaryColor, width: 1.5)
          : BorderSide(color: Colors.grey[300]!),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildRiwayatItem({
    required SetoranModel setoran,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              /// ICON
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              /// TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      setoran.surah,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      setoran.date,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      setoran.ayat,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              /// STATUS
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: setoran.statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  setoran.status,
                  style: TextStyle(
                    color: setoran.statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailDialog(BuildContext context, SetoranModel setoran) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RiwayatDetailPage(setoran: setoran),
    );
  }
}