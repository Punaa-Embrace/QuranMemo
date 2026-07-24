import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../page/akun_page.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final String? imagePath;
  final bool showAvatar;
  final bool showSearch;
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  
  // MENGATUR UKURAN
  final double searchTextSize;
  final double hintTextSize;

  const CustomHeader({
    super.key,
    required this.title,
    this.imagePath,
    this.showSearch = false,
    this.hintText = 'Cari...',
    this.controller,
    this.onChanged,
    this.showAvatar = true,
    this.showBackButton = false,
    this.onBackPressed,
    this.searchTextSize = 16,    
    this.hintTextSize = 14,       
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            _buildHeader(context),
            if (showSearch) _buildSearchBar(),
          ],
        ),
        SizedBox(height: showSearch ? 70 : 10),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          if (showBackButton) _buildBackButton(context),
          _buildLogo(),
          const Spacer(),
          if (showAvatar) _buildAvatar(context),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBackPressed ?? () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            "assets/images/QuranNoText.png",
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AkunPage()),
        );
      },
      child: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          String initial = '?';
          if (snapshot.hasData) {
            final nama = snapshot.data!.getString('nama') ?? '';
            if (nama.isNotEmpty) {
              initial = nama[0].toUpperCase();
            }
          }

          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      left: 24,
      right: 24,
      bottom: -65,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: searchTextSize,  //            fontWeight: FontWeight.normal,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: hintTextSize,   //              color: Colors.grey[400],
            ),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: AppTheme.primaryColor, size: 20),
            suffixIcon: _buildClearButton(),
          ),
        ),
      ),
    );
  }

  Widget? _buildClearButton() {
    if (controller == null || controller!.text.isEmpty) return null;
    
    return IconButton(
      icon: const Icon(Icons.clear, size: 18),
      onPressed: () {
        controller!.clear();
        if (onChanged != null) onChanged!('');
      },
    );
  }
}