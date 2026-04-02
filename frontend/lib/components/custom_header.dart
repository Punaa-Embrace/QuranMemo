import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../page/akun_page.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final String? imagePath;

  /// SEARCH CONFIG
  final bool showAvatar;
  final bool showSearch;
  final String hintText;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  
  /// BACK BUTTON CONFIG
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CustomHeader({
    super.key,
    required this.title,
    this.imagePath,
    this.showSearch = false,
    this.hintText = "Cari...",
    this.controller,
    this.onChanged,
    this.showAvatar = true,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            /// HEADER
            Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  /// BACK BUTTON (jika ditampilkan)
                  if (showBackButton) ...[
                    GestureDetector(
                      onTap: onBackPressed ?? () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  
                  /// LOGO + TEXT
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  /// AVATAR WITH NAVIGATION
                  if (showAvatar)
                    GestureDetector(
                      onTap: () {
                        // Navigasi ke AkunPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AkunPage(),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        backgroundImage: imagePath != null
                            ? AssetImage(imagePath!)
                            : null,
                        child: imagePath == null
                            ? const Icon(Icons.person, color: Colors.grey)
                            : null,
                      ),
                    ),
                ],
              ),
            ),

            /// SEARCH BAR (FLOATING)
            if (showSearch)
              Positioned(
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
                    decoration: InputDecoration(
                      hintText: hintText,
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: AppTheme.primaryColor),
                      suffixIcon:
                          controller != null && controller!.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                controller!.clear();
                                if (onChanged != null) onChanged!("");
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),
          ],
        ),

        /// SPACING BAWAH BIAR GA KETIMPA LIST
        SizedBox(height: showSearch ? 70 : 10),
      ],
    );
  }
}