import 'package:flutter/material.dart';
import 'package:quranmemo/page/auth/login_page.dart';
import '../../theme/app_theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingModel> _pages = [
    OnboardingModel(
      description:    
      "Aplikasi untuk mempermudah proses hafalan Quran bagi santri dan ustad/pembimbing.",
      imagePath: "assets/images/QuranMemo.png",
    ),
    OnboardingModel(
      description:
          "Setorkan hafalan Quran Anda langsung ke ustad/pembimbing dengan mudah.",
      imagePath: "assets/images/Setor.png",
    ),
    OnboardingModel(
      description:
          "Lihat riwayat setoran, nilai, dan catatan dari ustad untuk evaluasi.",
      imagePath: "assets/images/Riwayat-Hfl.png",
    ),
    OnboardingModel(
      description:
          "Akses Al-Quran lengkap dengan terjemahan dan audio dari 6 qari.",
      imagePath: "assets/images/Pelajari.png",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E2D1), 
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    _goToLoginPage();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Lewati",
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_pages[index]);
                },
              ),
            ),

            // Bottom Section
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildDotIndicator(index),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Button
                  if (_currentPage == _pages.length - 1)
                    _buildGetStartedButton()
                  else
                    _buildNextButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingModel page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 340,
            height: 340,
            padding: const EdgeInsets.all(20),
            child: Image.asset(
              page.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.image_not_supported,
                    size: 30,
                    color: AppTheme.primaryColor,
                  ),
                );
              },
            ),
          ),
          // Description
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              color: const Color.fromARGB(255, 27, 25, 25),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: _currentPage == index ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index 
            ? AppTheme.primaryColor 
            : AppTheme.primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Selanjutnya",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _goToLoginPage,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Mulai Aplikasi",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _goToLoginPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }
}

class OnboardingModel {
  final String description;
  final String imagePath;

  OnboardingModel({
    required this.description,
    required this.imagePath,
  });
}