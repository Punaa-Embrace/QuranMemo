import 'package:flutter/material.dart';

import '../../components/custom_bottom_nav.dart';

import 'dashboard_page_ustad.dart';
import 'quran_page_ustad.dart';
import 'setoran_page_ustad.dart';

class MainPageUstad extends StatefulWidget {
  final int initialIndex;

  const MainPageUstad({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainPageUstad> createState() => _MainPageUstadState();
}

class _MainPageUstadState extends State<MainPageUstad> {
  late int _selectedIndex;

  final List<Widget> _pages = const [
    DashboardPageUstad(),
    QuranPageUstad(),
    SetoranPageUstad(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          NavItem(
            label: "Beranda",
            icon: Icons.home_rounded,
          ),
          NavItem(
            label: "Al-Qur'an",
            icon: Icons.menu_book_rounded,
          ),
          NavItem(
            label: "Setoran",
            icon: Icons.video_library_rounded,
          ),
        ],
      ),
    );
  }
}