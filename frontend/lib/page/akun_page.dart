import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../components/custom_header.dart';
import 'main_page.dart';
import '../components/edit_profile_page.dart';     
import '../components/ganti_password_page.dart';    
import '../components/tentang_page.dart';  
import '../components/bantuan_page.dart';          
class AkunPage extends StatelessWidget {
  const AkunPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: "Akun Saya",
              showAvatar: false,
              showBackButton: true,
              onBackPressed: () {
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileCard(context),  // Kirim context
                    const SizedBox(height: 10),
                    _buildMenuCard(context),
                    const SizedBox(height: 20),
                    _buildLogoutButton(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// PROFILE CARD
  /// =========================
  Widget _buildProfileCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          /// AVATAR
          CircleAvatar(
            radius: 35,
            backgroundImage: Constants.getUserImage(),
          ),
          const SizedBox(width: 15),
          /// INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Constants.userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Santri",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  Constants.userEmail,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          /// EDIT BUTTON - Navigasi ke Edit Profile
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.edit, color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// MENU CARD
  /// =========================
  Widget _buildMenuCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _menuItem(Icons.lock, "Ganti Kata Sandi", context, onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GantiPasswordPage(),
              ),
            );
          }),
          _menuItem(Icons.history, "Riwayat Setoran", context, onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const MainPage(initialIndex: 4),
              ),
              (route) => false,
            );
          }),
          _menuItem(Icons.info, "Tentang Aplikasi", context, onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TentangAplikasiPage(),
              ),
            );
          }),
          _menuItem(Icons.help, "Bantuan", context, onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BantuanPage(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, BuildContext context, {VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryColor),
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  /// =========================
  /// LOGOUT BUTTON
  /// =========================
  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text(
          "Keluar",
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Konfirmasi Keluar"),
          content: const Text("Yakin ingin keluar?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text("Keluar"),
            ),
          ],
        );
      },
    );
  }
}