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
    DashboardPage(),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: const Offset(0, -12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withOpacity(0.7),
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey[400]!,
                          Colors.grey[300]!,
                        ],
                      ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 6,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
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
    );
  }
}