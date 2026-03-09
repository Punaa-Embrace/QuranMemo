import 'package:flutter/material.dart';
import '../services/quran_service.dart';
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

    final detail = await QuranService.getDetailSurat(_selectedSurah!.nomor);

    setState(() {
      _maxAyat = detail.jumlahAyat;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPilihSurah(),
                      const SizedBox(height: 20),
                      _buildRentangAyat(),
                      const SizedBox(height: 20),
                      _buildMetodeSetoran(),
                      const SizedBox(height: 30),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const Text(
            "Setor Hafalan",
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPilihSurah() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pilih Surah",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Surah>(
              value: _selectedSurah,
              isExpanded: true,
              items: _surahList.map((surah) {
                return DropdownMenuItem(
                  value: surah,
                  child: Text("${surah.namaLatin} (${surah.jumlahAyat} ayat)"),
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
        ),
      ],
    );
  }

  Widget _buildRentangAyat() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Rentang Ayat",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  controller: _ayatStart,
                  decoration: InputDecoration(
                    hintText: "Dari ayat (1 - $_maxAyat)",
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  controller: _ayatEnd,
                  decoration: InputDecoration(
                    hintText: "Sampai ayat (1 - $_maxAyat)",
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetodeSetoran() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Metode Setoran",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 25),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppTheme.primaryColor, width: 2),
          ),
          child: const Column(
            children: [
              Icon(Icons.videocam, color: AppTheme.primaryColor, size: 30),
              SizedBox(height: 5),
              Text("Rekaman Video"),
            ],
          ),
        ),
      ],
    );
  }

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

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RekamSetoranPage()),
          );
        },
        child: const Text(
          "Mulai Rekam Setoran",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
