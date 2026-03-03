import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildProgressCard(),
                      const SizedBox(height: 20),
                      _buildTugasHariIni(),
                      const SizedBox(height: 10),
                      _buildSetoranTerakhir(),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.menu_book, color: AppTheme.white),
                  const SizedBox(width: 10),
                  Text(
                    "QuranMemo",
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                backgroundImage: Constants.getUserImage(),
              )
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Assalamu'alaikum, Putra",
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Selasa, 03 Maret 2026",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
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
                    value: 0.4,
                    strokeWidth: 10,
                    color: AppTheme.primaryColor,
                    backgroundColor: Colors.grey[200],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      "12 / 30",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const Text("Juz"),
                    const Text("40%"),
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.mic),
                label: const Text("Setor Hafalan Sekarang"),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.all(14),
                ),
                onPressed: () {},
              ),
            )
          ],
        ),
      ),
    );
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
}