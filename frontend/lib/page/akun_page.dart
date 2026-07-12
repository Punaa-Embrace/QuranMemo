import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/custom_header.dart';
import 'main_page.dart';
import '../components/tentang_page.dart';
import '../components/bantuan_page.dart';
import '../services/auth_service.dart';
import '../page/auth/onboarding_page.dart';
import '../components/edit_profile.dart';
import '../components/ganti_password.dart';

class AkunPage extends StatefulWidget {
  const AkunPage({Key? key}) : super(key: key);

  @override
  State<AkunPage> createState() => _AkunPageState();
}

class _AkunPageState extends State<AkunPage> {
  String _nama = '';
  String _email = '';
  String _role = '';
  String _nim = '';
  String _nik = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    _nama = await AuthService.getNama() ?? 'Pengguna';
    _email = await AuthService.getEmail() ?? '-';
    _role = await AuthService.getRole() ?? 'user';
    _nim = await AuthService.getNim() ?? '-';
    _nik = await AuthService.getNik() ?? '-';
    setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
        (route) => false,
      );
    }
  }

  void _showEditProfileSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EditProfilePage(
        nama: _nama,
        email: _email,
        onSuccess: _loadUserData,
      ),
    );
  }

  void _showChangePasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const GantiPasswordPage(),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor(_role);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: "Akun Saya",
              showAvatar: false,
              showBackButton: true,
              onBackPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildProfileCard(roleColor),
                          const SizedBox(height: 16),
                          _buildMenuCard(),
                          const SizedBox(height: 24),
                          _buildLogoutButton(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(Color roleColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _nama.isNotEmpty ? _nama[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nama,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  _email,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (_role == 'santri')
                  Text(
                    'NIM: $_nim',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                if (_role == 'ustad')
                  Text(
                    'NIK: $_nik',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getRoleLabel(_role),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: roleColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showEditProfileSheet,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.edit_outlined,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard() {
    final List<Map<String, dynamic>> items = [];

    // Menu dasar semua role
    items.add({
      'icon': Icons.lock_outline,
      'label': 'Ganti Kata Sandi',
      'onTap': _showChangePasswordSheet,
    });

    // Riwayat Setoran HANYA UNTUK SANTRI
    if (_role == 'santri') {
      items.add({
        'icon': Icons.history_outlined,
        'label': 'Riwayat Setoran',
        'onTap': () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainPage(initialIndex: 4)),
            (route) => false,
          );
        },
      });
    }

    // Menu untuk semua role
    items.addAll([
      {
        'icon': Icons.info_outline,
        'label': 'Tentang Aplikasi',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TentangAplikasiPage()),
          );
        },
      },
      {
        'icon': Icons.help_outline,
        'label': 'Bantuan',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BantuanPage()),
          );
        },
      },
    ]);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items.map((item) {
          return _buildMenuItem(
            icon: item['icon'] as IconData,
            label: item['label'] as String,
            onTap: item['onTap'] as VoidCallback,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        onPressed: _showLogoutDialog,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Keluar',
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'santri':
        return 'Santri';
      case 'ustad':
        return 'Ustad';
      case 'orangtua':
        return 'Orang Tua';
      default:
        return 'Santri';
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'santri':
        return Colors.green;
      case 'ustad':
        return Colors.green;
      case 'orangtua':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}