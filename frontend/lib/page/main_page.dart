import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'setoran_page.dart';
import 'surah_page.dart';
import 'riwayat_page.dart';
import 'akun_page.dart';
import '../theme/app_theme.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    SetoranPage(),
    SuratPage(),
    RiwayatPage(),
    AkunPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          backgroundColor: Colors.white,
          elevation: 0,
          height: 70, // Tinggi navbar
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppTheme.primaryColor.withOpacity(0.1),
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: [
            // Beranda
            NavigationDestination(
              icon: _buildNavIcon(Icons.home, false, 0),
              selectedIcon: _buildNavIcon(Icons.home, true, 0),
              label: "Beranda",
            ),
            // Setoran
            NavigationDestination(
              icon: _buildNavIcon(Icons.upload, false, 1),
              selectedIcon: _buildNavIcon(Icons.upload, true, 1),
              label: "Setoran",
            ),
            // SURAT - DIPERBESAR DAN DI ATAS
            NavigationDestination(
              icon: _buildNavIcon(Icons.menu_book, false, 2, isSurat: true),
              selectedIcon: _buildNavIcon(Icons.menu_book, true, 2, isSurat: true),
              label: "Surat",
            ),
            // Riwayat
            NavigationDestination(
              icon: _buildNavIcon(Icons.history, false, 3),
              selectedIcon: _buildNavIcon(Icons.history, true, 3),
              label: "Riwayat",
            ),
            // Akun
            NavigationDestination(
              icon: _buildNavIcon(Icons.person, false, 4),
              selectedIcon: _buildNavIcon(Icons.person, true, 4),
              label: "Akun",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, bool isSelected, int index, {bool isSurat = false}) {
    if (isSurat) {
      // SURAT: Lebih besar dan posisi di atas
      return Container(
        margin: const EdgeInsets.only(bottom: 10), // Geser ke atas dengan margin bottom
        child: Container(
          width: 60,
          height: 80, 
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.primaryColor 
                : AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected 
                  ? Colors.white 
                  : AppTheme.primaryColor,
              width: isSelected ? 3 : 1.5,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.5),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ] : null,
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : AppTheme.primaryColor,
            size: 32,
          ),
        ),
      );
    }
    
    // ICON BIASA: Posisi normal di tengah
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8), // Biar tengah
      child: Icon(
        icon,
        color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
        size: 24,
      ),
    );
  }
}