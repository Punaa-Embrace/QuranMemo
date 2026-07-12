import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
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

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
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
    super.dispose();
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
    final surat = widget.setoran['surat']?.toString() ?? '-';
    final ayat = widget.setoran['ayat']?.toString() ?? '-';
    final status = widget.setoran['status']?.toString() ?? 'dikirim';
    final feedback = widget.setoran['feedback_tulisan'];
    final videoPath = widget.setoran['video_path'];
    final voicePath = widget.setoran['feedback_vn_path'];
    final createdAt = widget.setoran['created_at'];
    final ayatDisplay = _getAyatDisplay(ayat);

    String statusText = 'Dikirim';
    Color statusColor = Colors.orange;
    if (status == 'selesai') {
      statusText = 'Selesai';
      statusColor = Colors.green;
    } else if (status == 'revisi') {
      statusText = 'Revisi';
      statusColor = Colors.red;
    } else if (status == 'feedback') {
      statusText = 'Feedback';
      statusColor = Colors.blue;
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
                              backgroundColor: Colors.grey[200],
                              child: const Icon(Icons.person, color: Colors.grey),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                status == 'selesai' ? 'Hafalan Selesai' : 'Menunggu Review',
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w500,
                                ),
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
                    child: ListTile(
                      leading: Icon(Icons.mic, color: AppTheme.primaryColor),
                      title: const Text('Voice Note Feedback'),
                      subtitle: Text(voicePath.split('/').last),
                      trailing: Icon(Icons.play_arrow, color: AppTheme.primaryColor),
                      onTap: () {
                        // TODO: Play voice note
                      },
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