import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/quran_service.dart';
import '../models/surah_model.dart';
import '../components/custom_header.dart';
import 'surah_detail_page.dart';

class SuratPage extends StatefulWidget {
  const SuratPage({Key? key}) : super(key: key);

  @override
  State<SuratPage> createState() => _SuratPageState();
}

class _SuratPageState extends State<SuratPage> {
  List<Surah> _daftarSurat = [];
  List<Surah> _filteredSurat = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDaftarSurat();
    _searchController.addListener(_filterSurat);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDaftarSurat() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final surat = await QuranService.getDaftarSurat();
      setState(() {
        _daftarSurat = surat;
        _filteredSurat = surat;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterSurat() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSurat = _daftarSurat;
      } else {
        _filteredSurat = _daftarSurat.where((surah) {
          return surah.namaLatin.toLowerCase().contains(query) ||
              surah.arti.toLowerCase().contains(query) ||
              surah.nama.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
          top: true,
        child: Column(
          children: [
            CustomHeader(
              title: "QuranMemo",
              imagePath: "assets/images/self.jpg",
              showSearch: true,
              hintText: "Cari surat...",
              controller: _searchController,
              onChanged: (value) => _filterSurat(),
            ),
            Expanded(
              child: _isLoading
                  ? _buildLoading()
                  : _errorMessage.isNotEmpty
                  ? _buildErrorWidget()
                  : RefreshIndicator(
                      onRefresh: _loadDaftarSurat, // Panggil fungsi yang sama
                      color: AppTheme.primaryColor,
                      backgroundColor: Colors.white,
                      child: _buildSuratList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            "Memuat daftar surat...",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              "Gagal memuat data",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadDaftarSurat,
              icon: const Icon(Icons.refresh),
              label: const Text("Coba Lagi"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuratList() {
    if (_filteredSurat.isEmpty) {
      return ListView(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "Surat tidak ditemukan",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredSurat.length,
      itemBuilder: (context, index) {
        final surah = _filteredSurat[index];
        return _buildSuratCard(surah, index + 1);
      },
    );
  }

  Widget _buildSuratCard(Surah surah, int index) {
    // Warna berbeda untuk surat Makkiyah dan Madaniyah
    final bool isMakkiyah = surah.tempatTurun.toLowerCase() == 'mekah';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailSuratPage(nomorSurat: surah.nomor),
            ),
          );
        },
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: isMakkiyah
                ? Colors.purple.withOpacity(0.1)
                : Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              surah.nomor.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isMakkiyah ? Colors.purple : Colors.blue,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.namaLatin,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    surah.arti,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Nama Arab
            Text(
              surah.nama,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: 'Uthmani',
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isMakkiyah
                      ? Colors.purple.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  surah.tempatTurun,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMakkiyah ? Colors.purple : Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${surah.jumlahAyat} Ayat",
                  style: TextStyle(fontSize: 10, color: AppTheme.primaryColor),
                ),
              ),
            ],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}