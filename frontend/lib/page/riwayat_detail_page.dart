import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../services/santri_service.dart';
import '../services/auth_service.dart';

class RiwayatDetailPage extends StatefulWidget {
  final Map<String, dynamic> setoran;

  const RiwayatDetailPage({super.key, required this.setoran});

  @override
  State<RiwayatDetailPage> createState() => _RiwayatDetailPageState();
}

class _RiwayatDetailPageState extends State<RiwayatDetailPage> {
  VideoPlayerController? _videoController;
  bool _isVideoError = false;
  bool _isVideoLoading = true;

  // ── Voice Note Player ──
  final AudioPlayer _vnPlayer = AudioPlayer();
  bool _isPlayingVN = false;
  bool _isLoadingVN = false;
  Duration _vnPosition = Duration.zero;
  Duration _vnTotal = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();

    // Listen voice note player
    _vnPlayer.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _isPlayingVN = s == PlayerState.playing);
    });
    _vnPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _vnPosition = p);
    });
    _vnPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _vnTotal = d);
    });
    _vnPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() {
        _isPlayingVN = false;
        _vnPosition = Duration.zero;
      });
    });
  }

  Future<void> _playVoiceNote(String voicePath) async {
    if (_isPlayingVN) {
      await _vnPlayer.pause();
      return;
    }
    setState(() => _isLoadingVN = true);
    try {
      final storageUrl = ApiService.baseUrl.replaceFirst('/api', '/storage');
      final url = '$storageUrl/$voicePath';
      final token = await ApiService.getToken();

      // Download dulu dengan auth header (workaround ngrok/auth)
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      });

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/vn_playback_${DateTime.now().millisecondsSinceEpoch}.ogg');
        await file.writeAsBytes(response.bodyBytes);
        await _vnPlayer.play(DeviceFileSource(file.path));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memutar voice note: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoadingVN = false);
    }
  }

  Future<void> _initVideoPlayer() async {
    final setoranId = widget.setoran['id'];
    if (setoranId == null) {
      setState(() {
        _isVideoLoading = false;
        _isVideoError = true;
      });
      return;
    }

    // Gunakan streaming endpoint yang support Range Request
    final token = await AuthService.getToken();
    final streamUrl = '${SantriService.baseUrl}/santri/setoran/$setoranId/stream';

    debugPrint('Streaming video dari: $streamUrl');

    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(streamUrl),
      httpHeaders: {
        'Authorization': 'Bearer $token',
      },
    )..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoLoading = false;
          });
        }
      }).catchError((error) {
        debugPrint('Video Player Error: $error, URL: $streamUrl');
        if (mounted) {
          setState(() {
            _isVideoLoading = false;
            _isVideoError = true;
          });
        }
      });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _vnPlayer.dispose();
    super.dispose();
  }

  String _fmtDur(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  String _getAyatDisplay(String ayat) {
    if (ayat.contains('-')) return ayat;
    final start = widget.setoran['ayat_start']?.toString() ?? ayat;
    final end = widget.setoran['ayat_end']?.toString() ?? ayat;
    if (start != end) return '$start - $end';
    return ayat;
  }

  @override
  Widget build(BuildContext context) {
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

    // Coba ambil dari nama_surat, jika gagal, lookup dari list pakai angka
    String namaSuratDisplay = '-';
    if (widget.setoran['nama_surat'] != null) {
      namaSuratDisplay = widget.setoran['nama_surat'].toString();
    } else {
      final suratNoStr = widget.setoran['surat']?.toString() ?? '1';
      final suratNo = int.tryParse(suratNoStr) ?? 1;
      if (suratNo >= 1 && suratNo <= 114) {
        namaSuratDisplay = surahList[suratNo - 1];
      } else {
        namaSuratDisplay = suratNoStr;
      }
    }

    final surat = namaSuratDisplay;
    final ayat = widget.setoran['ayat']?.toString() ?? '-';
    final status = widget.setoran['status']?.toString() ?? 'dikirim';
    final feedback = widget.setoran['feedback_tulisan'];
    final videoPath = widget.setoran['video_path'];
    final voicePath = widget.setoran['feedback_vn_path'];
    final createdAt = widget.setoran['created_at'];
    final ayatDisplay = _getAyatDisplay(ayat);

    // Nama ustad dari relasi santriUstad.ustad
    final ustadData = widget.setoran['santri_ustad']?['ustad'];
    final namaUstad = ustadData?['nama'] ?? 'Ustad';

    String statusText = 'Dikirim';
    Color statusColor = Colors.orange;
    if (status == 'selesai') {
      statusText = 'Selesai';
      statusColor = Colors.green;
    } else if (status == 'revisi') {
      statusText = 'Revisi';
      statusColor = Colors.red;
    }

    String tanggal = 'Belum ada tanggal';
    if (createdAt != null && createdAt.toString().length > 10) {
      try {
        final DateTime date = DateTime.parse(createdAt.toString());
        tanggal =
            '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
      } catch (e) {
        tanggal = createdAt.toString();
      }
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5E2D1),
            border: Border(
              top: BorderSide(color: AppTheme.primaryColor, width: 3),
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 6,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: statusColor, width: 2),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.menu_book_rounded,
                      color: statusColor,
                      size: 30,
                    ),
                    title: Text(
                      'Surah $surat - Ayat $ayatDisplay',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    trailing: Chip(
                      label: Text(
                        statusText,
                        style: TextStyle(color: statusColor),
                      ),
                      backgroundColor: statusColor.withOpacity(0.1),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Card(
                  child: ListTile(
                    leading: Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                    title: const Text('Tanggal Setoran'),
                    subtitle: Text(tanggal),
                  ),
                ),

                const SizedBox(height: 10),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Evaluasi Ustad",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.green.shade100,
                              child: const Icon(Icons.person, color: Colors.green),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(namaUstad,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text(
                                    status == 'selesai' ? 'Hafalan Dinyatakan Selesai ✓' 
                                      : status == 'revisi' ? 'Perlu Diperbaiki'
                                      : 'Menunggu Review',
                                    style: TextStyle(color: statusColor, fontWeight: FontWeight.w500, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            if (status == 'selesai')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Selesai',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                if (feedback != null && feedback.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.message, color: AppTheme.primaryColor, size: 18),
                              const SizedBox(width: 8),
                              const Text(
                                'Catatan Ustad',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            feedback,
                            style: TextStyle(
                              color: Colors.grey[800],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (voicePath != null && voicePath.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.mic, color: AppTheme.primaryColor, size: 18),
                            const SizedBox(width: 8),
                            const Text('Voice Note dari Ustad',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ]),
                          const SizedBox(height: 12),
                          Row(children: [
                            // Tombol Play/Pause
                            GestureDetector(
                              onTap: _isLoadingVN ? null : () => _playVoiceNote(voicePath),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: _isLoadingVN
                                    ? const SizedBox(width: 26, height: 26,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : Icon(
                                        _isPlayingVN ? Icons.pause : Icons.play_arrow,
                                        color: Colors.white, size: 26,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(
                              children: [
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 3,
                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                  ),
                                  child: Slider(
                                    value: _vnTotal.inSeconds > 0
                                        ? _vnPosition.inSeconds.toDouble().clamp(0, _vnTotal.inSeconds.toDouble())
                                        : 0,
                                    max: _vnTotal.inSeconds > 0 ? _vnTotal.inSeconds.toDouble() : 1,
                                    activeColor: AppTheme.primaryColor,
                                    inactiveColor: Colors.grey.shade300,
                                    onChanged: (v) async {
                                      await _vnPlayer.seek(Duration(seconds: v.toInt()));
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_fmtDur(_vnPosition),
                                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                      Text(_fmtDur(_vnTotal),
                                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                          ]),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 10),

                if (widget.setoran['id'] != null)
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _isVideoError
                          ? SizedBox(
                              height: 150,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error_outline, color: Colors.red, size: 36),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Gagal memuat video',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : _videoController != null && _videoController!.value.isInitialized
                              ? AspectRatio(
                                  aspectRatio: _videoController!.value.aspectRatio,
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      VideoPlayer(_videoController!),
                                      _ControlsOverlay(controller: _videoController!),
                                      VideoProgressIndicator(
                                        _videoController!, 
                                        allowScrubbing: true,
                                        colors: VideoProgressColors(
                                          playedColor: AppTheme.primaryColor,
                                          bufferedColor: Colors.white24,
                                          backgroundColor: Colors.white12,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(
                                  height: 150,
                                  child: Center(
                                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                                  ),
                                ),
                    ),
                  )
                else
                  Card(
                    child: Container(
                      height: 150,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videocam_off, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Tidak ada video', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key? key, required this.controller}) : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.value.isPlaying ? controller.pause() : controller.play();
      },
      child: Stack(
        children: <Widget>[
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 50),
            reverseDuration: const Duration(milliseconds: 200),
            child: controller.value.isPlaying
                ? const SizedBox.shrink()
                : Container(
                    color: Colors.black26,
                    child: const Center(
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 60.0,
                        semanticLabel: 'Play',
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}