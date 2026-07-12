import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'setoran_page.dart';
import 'surah_page.dart';
import 'riwayat_page.dart';
import 'permainan_page.dart';
import '../theme/app_theme.dart';

class MainPage extends StatefulWidget {
  final int initialIndex;
  
  const MainPage({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _selectedIndex;

  final List<Widget> _pages = const [
    SantriPage(),
    SetoranPage(),
    SuratPage(),
    PermainanPage(),
    RiwayatPage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 75,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  label: "Beranda",
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.upload,
                  label: "Setoran",
                  index: 1,
                ),
                _buildCenterNavItem(
                  icon: Icons.menu_book,
                  label: "Surat",
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.emoji_events,
                  label: "Permainan",
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.history,
                  label: "Riwayat",
                  index: 4,
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey[500],
              size: isSelected ? 28 : 24,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppTheme.primaryColor : Colors.grey[500],
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 28,
              width: 28,
              child: OverflowBox(
                minHeight: 65,
                maxHeight: 65,
                minWidth: 65,
                maxWidth: 65,
                alignment: Alignment.bottomCenter,
                child: Transform.translate(
                  offset: const Offset(0, -12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      "assets/images/QuranNoText.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppTheme.primaryColor : Colors.grey[500],
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}