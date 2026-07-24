import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '../../theme/app_theme.dart';
import '../../services/ustad_service.dart';
import '../../services/api_service.dart';

class DetailSetoranPageUstad extends StatefulWidget {
  final Map<String, dynamic> data;
  const DetailSetoranPageUstad({super.key, required this.data});

  @override
  State<DetailSetoranPageUstad> createState() => _DetailSetoranPageUstadState();
}

class _DetailSetoranPageUstadState extends State<DetailSetoranPageUstad> {
  // ── Video ──
  VideoPlayerController? _videoController;
  bool _videoLoading = true;
  bool _videoError = false;

  // ── Feedback tulisan ──
  final TextEditingController feedbackController = TextEditingController();

  // ── Voice Note Recording (baru) ──
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();   // player untuk rekaman baru
  bool _isRecording = false;
  bool _isPlayingVN = false;
  String? _vnPath;
  Duration _recordDuration = Duration.zero;
  Duration _playPosition = Duration.zero;
  Duration _playTotal = Duration.zero;
  Timer? _recordTimer;

  // ── Voice Note Server (sudah tersimpan) ──
  final AudioPlayer _serverVnPlayer = AudioPlayer();
  String? _serverVnUrl;       // URL VN dari server
  bool _isPlayingServerVN = false;
  Duration _serverVnPosition = Duration.zero;
  Duration _serverVnTotal = Duration.zero;

  // ── Submit ──
  bool _submitting = false;
  String status = 'Pending';

  // ── Roadmap ──
  List<dynamic> _roadmap = [];
  bool _isLoadingDetail = true;

  String get storageUrl =>
      ApiService.baseUrl.replaceFirst('/api', '/storage');

  @override
  void initState() {
    super.initState();
    status = widget.data['status_label'] ?? widget.data['status'] ?? 'Pending';
    feedbackController.text = widget.data['feedback_tulisan'] ?? '';

    // Set URL voice note dari widget.data langsung (tidak perlu tunggu API)
    final vnPath = widget.data['feedback_vn_path'];
    if (vnPath != null && vnPath.toString().isNotEmpty) {
      _serverVnUrl = '$storageUrl/$vnPath';
    }

    _initVideo();
    _fetchDetail();

    // Listen audioplayer state (rekaman baru)
    _audioPlayer.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _isPlayingVN = s == PlayerState.playing);
    });
    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _playPosition = p);
    });
    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _playTotal = d);
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() {
        _isPlayingVN = false;
        _playPosition = Duration.zero;
      });
    });

    // Listen server VN player
    _serverVnPlayer.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _isPlayingServerVN = s == PlayerState.playing);
    });
    _serverVnPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _serverVnPosition = p);
    });
    _serverVnPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _serverVnTotal = d);
    });
    _serverVnPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() {
        _isPlayingServerVN = false;
        _serverVnPosition = Duration.zero;
      });
    });
  }

  Future<void> _fetchDetail() async {
    try {
      final res = await UstadService.detailSetoran(int.parse(widget.data['id'].toString()));
      if (res['success'] == true) {
        if (mounted) {
          final data = res['data'];
          setState(() {
            _roadmap = res['roadmap'] ?? [];
            _isLoadingDetail = false;
            // Feedback tulisan
            if (data != null && data['feedback_tulisan'] != null && feedbackController.text.isEmpty) {
              feedbackController.text = data['feedback_tulisan'];
            }
            // Voice note dari server
            if (data != null && data['feedback_vn_path'] != null && data['feedback_vn_path'].toString().isNotEmpty) {
              _serverVnUrl = '$storageUrl/${data['feedback_vn_path']}';
            }
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingDetail = false);
    }
  }

  Future<void> _initVideo() async {
    final videoPath = widget.data['video_path'];
    if (videoPath == null || videoPath.toString().isEmpty) {
      setState(() { _videoLoading = false; _videoError = true; });
      return;
    }
    
    final setoranId = widget.data['id'];
    final token = await ApiService.getToken();
    final url = '${ApiService.baseUrl}/ustad/setoran/$setoranId/stream';
    
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: {
          'ngrok-skip-browser-warning': 'true',
          'Authorization': 'Bearer $token',
        },
      );
      await _videoController!.initialize();
      _videoController!.addListener(() { if (mounted) setState(() {}); });
      setState(() => _videoLoading = false);
    } catch (_) {
      setState(() { _videoLoading = false; _videoError = true; });
    }
  }

  // ─── RECORDING ───────────────────────────────────────────
  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izin mikrofon ditolak'), backgroundColor: Colors.red),
      );
      return;
    }

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/vn_feedback_${DateTime.now().millisecondsSinceEpoch}.ogg';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.opus, bitRate: 128000),
      path: path,
    );

    _recordDuration = Duration.zero;
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recordDuration += const Duration(seconds: 1));
    });

    setState(() { _isRecording = true; _vnPath = null; });
  }

  Future<void> _stopRecording() async {
    _recordTimer?.cancel();
    final path = await _recorder.stop();
    setState(() {
      _isRecording = false;
      _vnPath = path;
    });
  }

  // ─── PLAYBACK VN ─────────────────────────────────────────
  Future<void> _togglePlayVN() async {
    if (_vnPath == null) return;
    if (_isPlayingVN) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(DeviceFileSource(_vnPath!));
    }
  }

  void _deleteVN() async {
    await _audioPlayer.stop();
    if (_vnPath != null) {
      try { File(_vnPath!).deleteSync(); } catch (_) {}
    }
    setState(() {
      _vnPath = null;
      _isPlayingVN = false;
      _playPosition = Duration.zero;
      _playTotal = Duration.zero;
      _recordDuration = Duration.zero;
    });
  }

  // ─── SUBMIT ──────────────────────────────────────────────
  Future<void> _submit(String newStatus) async {
    if (widget.data['id'] == null) return;
    setState(() => _submitting = true);
    final String setoranId = widget.data['id'].toString();
    try {
      // 1. Upload voice note (opsional)
      if (_vnPath != null) {
        final vnRes = await UstadService.uploadVoiceNote(setoranId, File(_vnPath!));
        if (vnRes['success'] != true) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Gagal upload voice note: ${vnRes['message'] ?? 'Error'}'),
            backgroundColor: Colors.orange,
          ));
          // Lanjut meski VN gagal agar feedback dan status tetap tersimpan
        }
      }

      // 2. Simpan catatan tulisan (opsional)
      if (feedbackController.text.trim().isNotEmpty) {
        await UstadService.giveFeedback(setoranId, feedbackController.text.trim());
      }

      // 3. Update status (wajib)
      final res = await UstadService.updateStatus(setoranId, newStatus);
      if (!mounted) return;
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(newStatus == 'selesai' ? 'Hafalan: Dah Benar!' : 'Hafalan perlu Revisi'),
          backgroundColor: newStatus == 'selesai' ? Colors.green : Colors.orange,
        ));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(res['message'] ?? 'Gagal update status'), backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _recorder.dispose();
    _audioPlayer.dispose();
    _serverVnPlayer.dispose();
    _videoController?.dispose();
    feedbackController.dispose();
    super.dispose();
  }

  // ─── HELPERS ─────────────────────────────────────────────
  String _fmtDur(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'selesai': return Colors.green;
      case 'revisi':  return Colors.orange;
      case 'dikirim': return Colors.blue;
      case 'tugas':   return Colors.purple;
      default:        return Colors.grey.shade600;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'selesai': return 'Dah Benar';
      case 'revisi':  return 'Revisi';
      case 'dikirim': return 'Menunggu Review';
      case 'tugas':   return 'Belum Disetor';
      default:        return s;
    }
  }

  // ─── BUILD ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final nama  = widget.data['nama']  ?? '-';
    final surah = widget.data['surah'] ?? '-';

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Detail Setoran',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info Santri ─────────────────────────────
            _card(child: Row(children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.12),
                child: const Icon(Icons.person, color: AppTheme.primaryColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  const SizedBox(height: 4),
                  Text('Surah: $surah', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusColor(status).withOpacity(0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_statusLabel(status),
                    style: TextStyle(color: _statusColor(status),
                        fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ])),

            const SizedBox(height: 14),

            // ── Video Setoran ────────────────────────────
            _card(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(Icons.videocam, 'Video Setoran'),
                const SizedBox(height: 12),
                _buildVideoPlayer(),
              ],
            )),

            const SizedBox(height: 14),

            // ── Feedback Tulisan ─────────────────────────
            _card(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(Icons.edit_note, 'Catatan Tulisan'),
                const SizedBox(height: 10),
                TextField(
                  controller: feedbackController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Tulis catatan evaluasi untuk santri...',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            )),

            const SizedBox(height: 14),

            // ── Voice Note Feedback ──────────────────────
            _card(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(Icons.mic, 'Voice Note Feedback'),
                const SizedBox(height: 14),
                // Player VN yang sudah tersimpan di server
                if (_serverVnUrl != null) ...[
                  _buildServerVNPlayer(),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text('Kirim Voice Note Baru:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey.shade700)),
                  const SizedBox(height: 10),
                ],
                _buildVNWidget(),
              ],
            )),

            const SizedBox(height: 14),

            // ── Roadmap Revisi ───────────────────────────
            if (_roadmap.isNotEmpty) _card(child: _buildRoadmap()),

            const SizedBox(height: 20),

            // ── Tombol Aksi ──────────────────────────────
            if (status != 'selesai') ...[
              Row(children: [
                Expanded(child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _submitting ? null : () => _submit('selesai'),
                  icon: _submitting
                      ? const SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text('Dah Benar',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _submitting ? null : () => _submit('revisi'),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text('Revisi',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )),
              ]),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Setoran ini sudah selesai',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ]),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Server Voice Note Player ──────────────────────────────
  Widget _buildServerVNPlayer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.volume_up, color: Colors.teal, size: 16),
            const SizedBox(width: 6),
            Text('Voice Note Tersimpan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade700, fontSize: 13)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            // Tombol Play/Pause
            GestureDetector(
              onTap: () async {
                if (_isPlayingServerVN) {
                  await _serverVnPlayer.pause();
                } else {
                  await _serverVnPlayer.play(UrlSource(_serverVnUrl!));
                }
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
                child: Icon(_isPlayingServerVN ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 24),
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
                    value: _serverVnTotal.inSeconds > 0
                        ? _serverVnPosition.inSeconds.toDouble().clamp(0, _serverVnTotal.inSeconds.toDouble())
                        : 0,
                    max: _serverVnTotal.inSeconds > 0 ? _serverVnTotal.inSeconds.toDouble() : 1,
                    activeColor: Colors.teal,
                    inactiveColor: Colors.teal.shade100,
                    onChanged: (v) async {
                      await _serverVnPlayer.seek(Duration(seconds: v.toInt()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmtDur(_serverVnPosition), style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      Text(_fmtDur(_serverVnTotal), style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            )),
          ]),
        ],
      ),
    );
  }

  // ── Voice Note Widget ─────────────────────────────────────
  Widget _buildVNWidget() {
    // Sedang merekam
    if (_isRecording) {
      return Column(children: [
        // Animasi merekam
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(children: [
            const Icon(Icons.fiber_manual_record, color: Colors.red, size: 36),
            const SizedBox(height: 8),
            Text('Merekam... ${_fmtDur(_recordDuration)}',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Ketuk stop saat selesai',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _stopRecording,
            icon: const Icon(Icons.stop, color: Colors.white),
            label: const Text('Stop Rekaman',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ]);
    }

    // Ada hasil rekaman — tampilkan player
    if (_vnPath != null) {
      return Column(children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
          ),
          child: Column(children: [
            Row(children: [
              // Tombol Play/Pause
              GestureDetector(
                onTap: _togglePlayVN,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlayingVN ? Icons.pause : Icons.play_arrow,
                    color: Colors.white, size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Progress bar + durasi
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    ),
                    child: Slider(
                      value: _playTotal.inSeconds > 0
                          ? _playPosition.inSeconds.toDouble().clamp(0, _playTotal.inSeconds.toDouble())
                          : 0,
                      max: _playTotal.inSeconds > 0 ? _playTotal.inSeconds.toDouble() : 1,
                      activeColor: AppTheme.primaryColor,
                      inactiveColor: Colors.grey.shade300,
                      onChanged: (v) async {
                        await _audioPlayer.seek(Duration(seconds: v.toInt()));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_fmtDur(_playPosition),
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        Text(_fmtDur(_playTotal),
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ],
              )),
              // Tombol hapus
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Hapus rekaman',
                onPressed: _deleteVN,
              ),
            ]),
          ]),
        ),
        const SizedBox(height: 10),
        Text('Voice note siap dikirim',
            style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
      ]);
    }

    // Belum ada rekaman — tampilkan tombol mulai rekam
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _startRecording,
        icon: const Icon(Icons.mic, color: Colors.white),
        label: const Text('Mulai Rekam Voice Note',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }

  // ── Video Player ──────────────────────────────────────────
  Widget _buildVideoPlayer() {
    final videoPath = widget.data['video_path'];
    if (videoPath == null || videoPath.toString().isEmpty) {
      return _videoPlaceholder(Icons.videocam_off, 'Santri belum mengirim video setoran');
    }
    if (_videoLoading) {
      return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
    }
    if (_videoError || _videoController == null) {
      return _videoPlaceholder(Icons.error_outline, 'Video tidak dapat dimuat');
    }
    return Column(children: [
      GestureDetector(
        onTap: () => setState(() {
          _videoController!.value.isPlaying
              ? _videoController!.pause()
              : _videoController!.play();
        }),
        child: Stack(alignment: Alignment.center, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _videoController!.value.isPlaying ? 0.0 : 1.0,
            child: Container(
              decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
              padding: const EdgeInsets.all(14),
              child: Icon(
                _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                size: 40, color: Colors.white,
              ),
            ),
          ),
          Positioned(
            bottom: 8, right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
              child: Text(
                '${_fmtDur(_videoController!.value.position)} / ${_fmtDur(_videoController!.value.duration)}',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 8),
      VideoProgressIndicator(
        _videoController!, allowScrubbing: true,
        colors: VideoProgressColors(
          playedColor: AppTheme.primaryColor,
          backgroundColor: Colors.grey.shade300,
          bufferedColor: Colors.grey.shade400,
        ),
      ),
    ]);
  }

  Widget _videoPlaceholder(IconData icon, String msg) {
    return Container(
      height: 180,
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
      child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 48, color: Colors.grey.shade400),
        const SizedBox(height: 8),
        Text(msg, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
      ])),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(children: [
      Icon(icon, color: AppTheme.primaryColor, size: 20),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
    ]);
  }

  Widget _buildRoadmap() {
    if (_isLoadingDetail) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(Icons.map, 'Roadmap Riwayat Revisi'),
        const SizedBox(height: 12),
        ...List.generate(_roadmap.length, (index) {
          final item = _roadmap[index];
          final st = item['status'] ?? 'pending';
          final tgl = item['created_at'] != null ? item['created_at'].toString().split('T')[0] : '';
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: _statusColor(st).withOpacity(0.2),
                  child: Text('${index + 1}', style: TextStyle(color: _statusColor(st), fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Upaya ${index + 1} - $tgl', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      if (item['feedback_tulisan'] != null) ...[
                        const SizedBox(height: 4),
                        Text('"${item['feedback_tulisan']}"', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade600, fontSize: 12)),
                      ]
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(st).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_statusLabel(st), style: TextStyle(color: _statusColor(st), fontSize: 11, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}