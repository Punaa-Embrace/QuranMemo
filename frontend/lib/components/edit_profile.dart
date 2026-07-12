import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/profile_service.dart';

class EditProfilePage extends StatefulWidget {
  final String nama;
  final String email;
  final VoidCallback onSuccess;

  const EditProfilePage({
    Key? key,
    required this.nama,
    required this.email,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _namaController;
  late TextEditingController _emailController;
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.nama);
    _emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final nama = _namaController.text.trim();
    final email = _emailController.text.trim();

    if (nama.isEmpty || email.isEmpty) {
      setState(() => _error = 'Nama dan email harus diisi');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    final result = await ProfileService.updateProfile(nama: nama, email: email);

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (mounted) {
        widget.onSuccess();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(' Profile berhasil diupdate'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      setState(() => _error = result['message'] ?? 'Gagal update profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Edit Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_error.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_error, style: const TextStyle(color: Colors.red)),
            ),
          TextField(
            controller: _namaController,
            decoration: const InputDecoration(
              labelText: 'Nama',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Simpan'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}