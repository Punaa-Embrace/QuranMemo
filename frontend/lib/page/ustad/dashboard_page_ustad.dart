import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../components/app_layout.dart';

class DashboardPageUstad extends StatelessWidget {
  DashboardPageUstad({super.key});

  final int pendingReview = 7;
  final int newToday = 5;
  final int completedToday = 9;

  final int totalSantri = 25;
  final int activeSantri = 18;

  final String gregorianDate = "Friday, 3 July 2026";
  final String hijriDate = "7 Muharram 1448 H";

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: "Dashboard Ustadz",
      imagePath: "assets/images/self.jpg",
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(1),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        
          /// =========================
          /// HEADER CONTEXT (clean, no workload text)
          /// =========================
          _header(),

          const SizedBox(height: 16),

          /// =========================
          /// DAFTAR SANTRI CARD (NEW)
          /// =========================
          _santriCard(),

          const SizedBox(height: 16),

          /// =========================
          /// CALENDAR HIJRI
          /// =========================
          _hijriCard(),

          const SizedBox(height: 20),

          /// =========================
          /// ACTION CENTER
          /// =========================
          const Text(
            "Utama",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          _actionCard(
            "Review Setoran",
            "Periksa video hafalan santri",
            Icons.play_circle_fill,
            Colors.blue,
            pendingReview,
          ),

          const SizedBox(height: 10),

          _actionCard(
            "Setoran Baru",
            "Masuk hari ini",
            Icons.fiber_new,
            Colors.orange,
            newToday,
          ),

          const SizedBox(height: 20),

          /// =========================
          /// ACTIVITY FEED
          /// =========================
          const Text(
            "Aktivitas Terbaru",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          _activityItem("Ahmad Fauzan mengirim setoran"),
          _activityItem("Rizky selesai direview"),
          _activityItem("Aisyah menunggu feedback"),
        ],
      ),
    ));
  }

  /// =========================
  /// HEADER (CLEAN MOBILE SAFE)
  /// =========================
  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Assalamu'alaikum",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            gregorianDate,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),

          Text(
            hijriDate,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$value",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(title,
              style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  /// =========================
  /// SANTRI CARD (NEW FEATURE)
  /// =========================
  Widget _santriCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.groups, color: AppTheme.primaryColor),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Daftar Santri",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "$activeSantri aktif hari ini",
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          const Icon(Icons.arrow_forward_ios, size: 14),
        ],
      ),
    );
  }

  /// =========================
  /// HIJRI CARD (CLEAN)
  /// =========================
  Widget _hijriCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, color: AppTheme.primaryColor),

          const SizedBox(width: 12),

          const Expanded(
            child: Text(
              "Kalender Hijriyah",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          Text(
            hijriDate.split(" ")[0] + " " + hijriDate.split(" ")[1],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// ACTION CARD
  /// =========================
  Widget _actionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    int value,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
          ),

          Text(
            "$value",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// ACTIVITY ITEM
  /// =========================
  Widget _activityItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}