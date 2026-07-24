import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/ustad_service.dart';
import '../../services/quran_database.dart';

class BeriTugasSheet extends StatefulWidget {
  final List<Map<String, dynamic>> daftarSantri;
  final VoidCallback onSuccess;

  const BeriTugasSheet({
    super.key,
    required this.daftarSantri,
    required this.onSuccess,
  });

  @override
  State<BeriTugasSheet> createState() => _BeriTugasSheetState();
}

class _BeriTugasSheetState extends State<BeriTugasSheet> {
  Map<String, dynamic>? selectedSantri;
  String? selectedSurah;
  final TextEditingController ayatController = TextEditingController();
  bool _isSubmitting = false;

  // Hardcode 114 surah names for now
  final List<String> surahList = [
    'Al-Fatihah', 'Al-Baqarah', 'Ali Imran', 'An-Nisa', 'Al-Maidah',
    'Al-Anam', 'Al-Araf', 'Al-Anfal', 'At-Tawbah', 'Yunus',
    'Hud', 'Yusuf', 'Ar-Rad', 'Ibrahim', 'Al-Hijr',
    'An-Nahl', 'Al-Isra', 'Al-Kahf', 'Maryam', 'Ta-Ha',
    'Al-Anbiya', 'Al-Hajj', 'Al-Muminun', 'An-Nur', 'Al-Furqan',
    'Ash-Shuara', 'An-Naml', 'Al-Qasas', 'Al-Ankabut', 'Ar-Rum',
    'Luqman', 'As-Sajdah', 'Al-Ahzab', 'Saba', 'Fatir',
    'Ya-Sin', 'As-Saffat', 'Sad', 'Az-Zumar', 'Ghafir',
    'Fussilat', 'Ash-Shura', 'Az-Zukhruf', 'Ad-Dukhan', 'Al-Jathiyah',
    'Al-Ahqaf', 'Muhammad', 'Al-Fath', 'Al-Hujurat', 'Qaf',
    'Adh-Dhariyat', 'At-Tur', 'An-Najm', 'Al-Qamar', 'Ar-Rahman',
    'Al-Waqiah', 'Al-Hadid', 'Al-Mujadila', 'Al-Hashr', 'Al-Mumtahanah',
    'As-Saf', 'Al-Jumuah', 'Al-Munafiqun', 'At-Taghabun', 'At-Talaq',
    'At-Tahrim', 'Al-Mulk', 'Al-Qalam', 'Al-Haqqah', 'Al-Maarij',
    'Nuh', 'Al-Jinn', 'Al-Muzzammil', 'Al-Muddaththir', 'Al-Qiyamah',
    'Al-Insan', 'Al-Mursalat', 'An-Naba', 'An-Naziat', 'Abasa',
    'At-Takwir', 'Al-Infitar', 'Al-Mutaffifin', 'Al-Inshiqaq', 'Al-Buruj',
    'At-Tariq', 'Al-Ala', 'Al-Ghashiyah', 'Al-Fajr', 'Al-Balad',
    'Ash-Shams', 'Al-Layl', 'Ad-Duha', 'Ash-Sharh', 'At-Tin',
    'Al-Alaq', 'Al-Qadr', 'Al-Bayyinah', 'Az-Zalzalah', 'Al-Adiyat',
    'Al-Qariah', 'At-Takathur', 'Al-Asr', 'Al-Humazah', 'Al-Fil',
    'Quraysh', 'Al-Maun', 'Al-Kawthar', 'Al-Kafirun', 'An-Nasr',
    'Al-Masad', 'Al-Ikhlas', 'Al-Falaq', 'An-Nas',
  ];

  Future<void> _submit() async {
    if (selectedSantri == null) {
      _showError('Pilih santri terlebih dahulu');
      return;
    }
    if (selectedSurah == null) {
      _showError('Pilih surah terlebih dahulu');
      return;
    }
    if (ayatController.text.isEmpty || int.tryParse(ayatController.text) == null) {
      _showError('Masukkan nomor ayat yang valid');
      return;
    }

    final inputAyat = int.parse(ayatController.text);
    final suratNumber = surahList.indexOf(selectedSurah!) + 1;

    // Validasi maksimal ayat dari database
    final surahInfo = await QuranDatabase.getSurahById(suratNumber);
    if (surahInfo != null && inputAyat > surahInfo.jumlahAyat) {
      _showError('Surah $selectedSurah hanya memiliki ${surahInfo.jumlahAyat} ayat');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final res = await UstadService.createTugas(
        santriId: selectedSantri!['id'].toString(),
        surat: suratNumber.toString(),
        ayat: inputAyat,
      );

      if (res['success'] == true) {
        if (mounted) Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tugas berhasil dikirim ke ${selectedSantri!['nama']}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Tampilkan pesan dari server (misal: ayat sudah selesai)
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Tidak Bisa', style: TextStyle(fontSize: 16)),
                ],
              ),
              content: Text(res['message'] ?? 'Gagal memberi tugas'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Mengerti'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),

            // Judul
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.assignment_add, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Beri Tugas Hafalan',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Pilih santri, surah, dan ayat target',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Pilih Santri
            const Text('Pilih Santri', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Map<String, dynamic>>(
                  isExpanded: true,
                  hint: const Text('Pilih santri binaan...'),
                  value: selectedSantri,
                  items: widget.daftarSantri.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(s['nama'] ?? 'Santri'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => selectedSantri = val),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Pilih Surah
            const Text('Pilih Surah', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Pilih surah...'),
                  value: selectedSurah,
                  items: surahList.map((s) {
                    return DropdownMenuItem(value: s, child: Text(s));
                  }).toList(),
                  onChanged: (val) => setState(() => selectedSurah = val),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Nomor Ayat
            const Text('Sampai Ayat ke-', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: ayatController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Contoh: 10',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.format_list_numbered),
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Kirim Tugas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
