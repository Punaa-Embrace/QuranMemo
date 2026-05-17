import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/quran_service.dart';
import '../services/audio_service.dart';
import '../models/surah_model.dart';

class DetailSuratPage extends StatefulWidget {
  final int nomorSurat;
  const DetailSuratPage({Key? key, required this.nomorSurat}) : super(key: key);

  @override
  State<DetailSuratPage> createState() => _DetailSuratPageState();
}

class _DetailSuratPageState extends State<DetailSuratPage> {
  SurahDetail? _surahDetail;
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedQari = '05';
  bool _showTranslation = true;
  bool _showLatin = true;

  @override
  void initState() {
    super.initState();
    AudioService.init();
    AudioService.addListener(_onAudioStateChanged);
    AudioService.setOnAyatComplete(_onAyatComplete);
    _loadDetailSurat();
  }

  void _onAudioStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onAyatComplete(int completedAyat) {
    if (_surahDetail == null) return;
    
    final nextAyat = completedAyat + 1;
    if (nextAyat <= _surahDetail!.ayat.length) {
      _playAyat(nextAyat);
    }
  }

  @override
  void dispose() {
    AudioService.removeListener(_onAudioStateChanged);
    AudioService.stop();
    super.dispose();
  }

  Future<void> _loadDetailSurat() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final detail = await QuranService.getDetailSurat(widget.nomorSurat);
      setState(() {
        _surahDetail = detail;
        _isLoading = false;
      });
    } catch (e) {
      String userMessage = e.toString();
      if (userMessage.contains('Tidak dapat mengambil') ||
          userMessage.contains('butuh koneksi internet')) {
        userMessage = 'Butuh koneksi internet untuk pertama kali membuka surat ini';
      }
      setState(() {
        _errorMessage = userMessage;
        _isLoading = false;
      });
    }
  }

  Future<void> _playAyat(int nomorAyat) async {
    if (_surahDetail == null) return;
    if (nomorAyat < 1 || nomorAyat > _surahDetail!.ayat.length) return;

    final ayat = _surahDetail!.ayat[nomorAyat - 1];
    final url = ayat.audio[_selectedQari];
    
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Audio tidak tersedia untuk qari ini'),
          backgroundColor: AppTheme.primaryColor,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      await AudioService.playAyat(
        url: url,
        surahId: widget.nomorSurat,
        ayat: nomorAyat,
        qari: _selectedQari,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memutar audio: $e')),
      );
    }
  }

  Future<void> _stopAudio() async {
    await AudioService.stop();
  }

  Future<void> _playFullSurah() async {
    if (_surahDetail == null) return;
    
    final url = _surahDetail!.audioFull[_selectedQari];
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio penuh tidak tersedia untuk qari ini')),
      );
      return;
    }

    try {
      await AudioService.playFullSurah(
        url: url,
        surahId: widget.nomorSurat,
        qari: _selectedQari,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memutar audio: $e')),
      );
    }
  }

  String _cleanHtmlDescription(String htmlText) {
    String clean = htmlText.replaceAll('<i>', '');
    clean = clean.replaceAll('</i>', '');
    clean = clean.replaceAll('<br>', '\n');
    clean = clean.replaceAll('<br/>', '\n');
    clean = clean.replaceAll('<br />', '\n');
    clean = clean.replaceAll(RegExp(r'<[^>]*>'), '');
    return clean;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _isLoading
          ? _buildLoading()
          : _errorMessage.isNotEmpty
          ? _buildErrorWidget()
          : _buildDetailContent(),
      bottomNavigationBar: _buildBottomAudioBar(),
    );
  }

  Widget? _buildBottomAudioBar() {
    if (_surahDetail == null) return null;
    
    final hasAudio = AudioService.isPlayingFull ||
        AudioService.currentAyat != null ||
        AudioService.currentPosition > Duration.zero;
    
    if (!hasAudio) return null;

    final title = _surahDetail!.namaLatin;
    final currentLabel = AudioService.isPlayingFull
        ? 'Full'
        : (AudioService.currentAyat != null ? AudioService.currentAyat.toString() : '-');

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$title : $currentLabel',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        QuranService.getNamaQari(_selectedQari),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: () {
                    if (_surahDetail == null) return;
                    int current = AudioService.currentAyat ?? 1;
                    int prev = current - 1;
                    if (prev >= 1) {
                      _playAyat(prev);
                    }
                  },
                ),
                IconButton(
                  iconSize: 36,
                  icon: AudioService.isPlaying
                      ? const Icon(Icons.pause_circle_filled, color: AppTheme.primaryColor)
                      : const Icon(Icons.play_circle_fill, color: AppTheme.primaryColor),
                  onPressed: () async {
                    if (AudioService.isPlaying) {
                      await AudioService.pause();
                    } else {
                      if (AudioService.isPlayingFull) {
                        await AudioService.resume();
                      } else if (AudioService.currentAyat != null) {
                        await AudioService.resume();
                      }
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () {
                    if (_surahDetail == null) return;
                    int current = AudioService.currentAyat ?? 0;
                    int next = current + 1;
                    if (next <= _surahDetail!.ayat.length) {
                      _playAyat(next);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _stopAudio,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AudioService.formatDuration(AudioService.currentPosition),
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      AudioService.formatDuration(AudioService.totalDuration),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: AudioService.totalDuration.inMilliseconds > 0
                        ? AudioService.currentPosition.inMilliseconds /
                              AudioService.totalDuration.inMilliseconds
                        : 0,
                    minHeight: 6,
                    backgroundColor: Colors.grey[200],
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
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
          Text("Memuat surat...", style: TextStyle(color: Colors.grey[600])),
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
              "Gagal memuat detail surat",
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
              onPressed: _loadDetailSurat,
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

  Widget _buildDetailContent() {
    if (_surahDetail == null) return const SizedBox();

    final bool isMakkiyah = _surahDetail!.tempatTurun.toLowerCase() == 'mekah';
    final Color tempatWarna = isMakkiyah ? Colors.purple : Colors.blue;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: AppTheme.primaryColor,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 46, bottom: 10),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _surahDetail!.namaLatin,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(_surahDetail!.arti, style: const TextStyle(fontSize: 14)),
              ],
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    _surahDetail!.nama,
                    style: const TextStyle(
                      fontSize: 60,
                      color: Colors.white24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: 1),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.audiotrack, color: Colors.white),
              onPressed: _showQariSelector,
            ),
            IconButton(
              icon: AudioService.isLoading && AudioService.isPlayingFull
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      AudioService.isPlaying && AudioService.isPlayingFull
                          ? Icons.stop
                          : Icons.play_circle_fill,
                      color: Colors.white,
                    ),
              onPressed: () async {
                if (AudioService.isPlaying && AudioService.isPlayingFull) {
                  await AudioService.stop();
                } else {
                  await _playFullSurah();
                }
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.settings, color: Colors.white),
              onSelected: (value) {
                setState(() {
                  if (value == 'translation') {
                    _showTranslation = !_showTranslation;
                  } else if (value == 'latin') {
                    _showLatin = !_showLatin;
                  }
                });
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'translation',
                  child: Row(
                    children: [
                      Icon(
                        _showTranslation
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      const Text('Tampilkan Terjemahan'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'latin',
                  child: Row(
                    children: [
                      Icon(
                        _showLatin
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      const Text('Tampilkan Latin'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  "Nomor",
                  _surahDetail!.nomor.toString(),
                  Icons.format_list_numbered,
                ),
                _buildInfoItem(
                  "Ayat",
                  "${_surahDetail!.jumlahAyat}",
                  Icons.menu_book,
                ),
                _buildInfoItem(
                  "Turun",
                  _surahDetail!.tempatTurun,
                  Icons.location_on,
                  warna: tempatWarna,
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Deskripsi",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _cleanHtmlDescription(_surahDetail!.deskripsi),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final ayat = _surahDetail!.ayat[index];
              return _buildAyatItem(ayat, index + 1);
            }, childCount: _surahDetail!.ayat.length),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon, {
    Color? warna,
  }) {
    return Column(
      children: [
        Icon(icon, color: warna ?? AppTheme.primaryColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildAyatItem(Ayat ayat, int nomor) {
    final bool isPlayingThisAyat = AudioService.isPlaying &&
        AudioService.currentAyat == nomor &&
        !AudioService.isPlayingFull;
    
    final bool isLoadingThisAyat = AudioService.isLoading &&
        AudioService.currentAyat == nomor &&
        !AudioService.isPlayingFull;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      color: isPlayingThisAyat ? const Color(0xFFE8F5E9) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isPlayingThisAyat ? AppTheme.primaryColor : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isPlayingThisAyat
                        ? AppTheme.primaryColor
                        : AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      nomor.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isPlayingThisAyat
                            ? Colors.white
                            : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: isLoadingThisAyat
                      ? const Padding(
                          padding: EdgeInsets.all(8),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            isPlayingThisAyat ? Icons.stop : Icons.play_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () async {
                            if (isPlayingThisAyat) {
                              await AudioService.stop();
                            } else {
                              await _playAyat(nomor);
                            }
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                            width: 36,
                            height: 36,
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              ayat.teksArab,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 24,
                height: 1.8,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_showLatin && ayat.teksLatin.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                ayat.teksLatin,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (_showTranslation && ayat.teksIndonesia.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPlayingThisAyat
                      ? const Color(0xFFE8F5E9)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  ayat.teksIndonesia,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showQariSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Pilih Qari",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...QuranService.daftarQari.map((qari) {
                return RadioListTile<String>(
                  title: Text(qari['name']!),
                  value: qari['key']!,
                  groupValue: _selectedQari,
                  activeColor: AppTheme.primaryColor,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() {
                      _selectedQari = value!;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}