import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/profile_service.dart';

class GantiPasswordPage extends StatefulWidget {
  const GantiPasswordPage({Key? key}) : super(key: key);

  @override
  State<GantiPasswordPage> createState() =>
      _GantiPasswordPageState();
}

class _GantiPasswordPageState
    extends State<GantiPasswordPage> {
  final _oldPass = TextEditingController();
  final _newPass = TextEditingController();
  final _confirmPass = TextEditingController();

  bool _isLoading = false;
  String _error = '';
  bool _showOld = false;
  bool _showNew = false;
  bool _showConfirm = false;

  Future<void> _changePassword() async {
    if (_newPass.text != _confirmPass.text) {
      setState(() => _error = 'Password baru tidak cocok!');
      return;
    }
    if (_newPass.text.length < 6) {
      setState(() => _error = 'Password minimal 6 karakter!');
      return;
    }
    if (_oldPass.text == _newPass.text) {
      setState(() => _error = 'Password baru tidak boleh sama dengan password lama');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    final result = await ProfileService.changePassword(
      oldPassword: _oldPass.text.trim(),
      newPassword: _newPass.text.trim(),
      confirmPassword: _confirmPass.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (mounted) {
        setState(() => _error = ' Password berhasil diubah!');
        Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
      }
    } else {
      setState(() => _error = result['message'] ?? 'Gagal ubah password');
    }
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, size: 20),
          onPressed: onToggle,
        ),
      ),
    );
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
            'Ganti Kata Sandi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_error.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: _error.contains('berhasil')
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _error,
                style: TextStyle(
                  color: _error.contains('berhasil') ? Colors.green : Colors.red,
                ),
              ),
            ),
          _buildField(
            controller: _oldPass,
            label: 'Password Lama',
            isVisible: _showOld,
            onToggle: () => setState(() => _showOld = !_showOld),
          ),
          const SizedBox(height: 12),
          _buildField(
            controller: _newPass,
            label: 'Password Baru',
            isVisible: _showNew,
            onToggle: () => setState(() => _showNew = !_showNew),
          ),
          const SizedBox(height: 12),
          _buildField(
            controller: _confirmPass,
            label: 'Konfirmasi Password',
            isVisible: _showConfirm,
            onToggle: () => setState(() => _showConfirm = !_showConfirm),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _changePassword,
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
                  : const Text('Ubah Password'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}