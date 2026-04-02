import 'package:flutter/material.dart';
import '../services/quran_service.dart';
import '../components/custom_header.dart';
import '../models/surah_model.dart';
import '../theme/app_theme.dart';
import 'rekam_setoran_page.dart';

class SetoranPage extends StatefulWidget {
  const SetoranPage({Key? key}) : super(key: key);

  @override
  State<SetoranPage> createState() => _SetoranPageState();
}

class _SetoranPageState extends State<SetoranPage> {
  List<Surah> _surahList = [];
  Surah? _selectedSurah;
  int _maxAyat = 0;

  final TextEditingController _ayatStart = TextEditingController();
  final TextEditingController _ayatEnd = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSurah();
  }

  Future<void> _loadSurah() async {
    final data = await QuranService.getDaftarSurat();

    setState(() {
      _surahList = data;
      _selectedSurah = data.first;
    });

    _loadDetailSurah();
  }

  Future<void> _loadDetailSurah() async {
    if (_selectedSurah == null) return;

    final detail =
        await QuranService.getDetailSurat(_selectedSurah!.nomor);

    setState(() {
      _maxAyat = detail.jumlahAyat;
    });
  }

  @override
  void dispose() {
    _ayatStart.dispose();
    _ayatEnd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: "QuranMemo",
              imagePath: "assets/images/self.jpg",
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// ===== SURAH =====
                      const Text("Surah",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildDropdownCard(),

                      const SizedBox(height: 16),

                      /// ===== AYAT =====
                      const Text("Ayat",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildAyatRange(),

                      const SizedBox(height: 16),

                      /// ===== INFO =====
                      _buildInfoCard(),

                      const SizedBox(height: 20),

                      /// ===== VIDEO =====
                      _buildVideoCard(),

                      const SizedBox(height: 20),

                      /// ===== BUTTON =====
                      _buildKirimButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// DROPDOWN SURAH
  /// =========================
  Widget _buildDropdownCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          )
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Surah>(
          value: _selectedSurah,
          isExpanded: true,
          hint: const Text("Pilih Surah"),
          items: _surahList.map((surah) {
            return DropdownMenuItem(
              value: surah,
              child: Text(
                "${surah.namaLatin} (${surah.jumlahAyat} ayat)",
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSurah = value;
            });

            _loadDetailSurah();
          },
        ),
      ),
    );
  }

  /// =========================
  /// RENTANG AYAT
  /// =========================
  Widget _buildAyatRange() {
    return Row(
      children: [

        /// DARI
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                )
              ],
            ),
            child: TextField(
              controller: _ayatStart,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final num = int.tryParse(value);
                if (num != null && num > _maxAyat) {
                  _ayatStart.text = _maxAyat.toString();
                  _ayatStart.selection = TextSelection.fromPosition(
                    TextPosition(offset: _ayatStart.text.length),
                  );
                }
              },
              decoration: InputDecoration(
                hintText: "Dari (1 - $_maxAyat)",
                border: InputBorder.none,
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        /// SAMPAI
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                )
              ],
            ),
            child: TextField(
              controller: _ayatEnd,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final num = int.tryParse(value);
                if (num != null && num > _maxAyat) {
                  _ayatEnd.text = _maxAyat.toString();
                  _ayatEnd.selection = TextSelection.fromPosition(
                    TextPosition(offset: _ayatEnd.text.length),
                  );
                }
              },
              decoration: InputDecoration(
                hintText: "Sampai (1 - $_maxAyat)",
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// =========================
  /// INFO CARD
  /// =========================
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Pilih Surah & rentang ayat yang akan disetor.\nRekam bacaan dengan jelas dan benar.",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// VIDEO CARD
  /// =========================
  Widget _buildVideoCard() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          )
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            "Rekam Video",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// BUTTON + VALIDASI
  /// =========================
  Widget _buildKirimButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () {
          if (_selectedSurah == null ||
              _ayatStart.text.isEmpty ||
              _ayatEnd.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Lengkapi data setoran terlebih dahulu"),
              ),
            );
            return;
          }

          final start = int.tryParse(_ayatStart.text) ?? 0;
          final end = int.tryParse(_ayatEnd.text) ?? 0;

          /// VALIDASI RANGE
          if (start < 1 || end < 1 || start > _maxAyat || end > _maxAyat) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Ayat harus antara 1 - $_maxAyat"),
              ),
            );
            return;
          }

          /// VALIDASI URUTAN
          if (start > end) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    "Ayat awal tidak boleh lebih besar dari ayat akhir"),
              ),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RekamSetoranPage(
                surah: _selectedSurah!,
                ayatStart: start,
                ayatEnd: end,
              ),
            ),
          );
        },
        child: const Text(
          "Kirim Setoran",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}