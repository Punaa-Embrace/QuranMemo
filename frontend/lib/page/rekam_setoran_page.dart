import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/surah_model.dart';
import '../services/santri_service.dart';

class RekamSetoranPage extends StatefulWidget {
  final Surah surah;
  final int ayatStart;
  final int ayatEnd;

  const RekamSetoranPage({
    super.key,
    required this.surah,
    required this.ayatStart,
    required this.ayatEnd,
  });

  @override
  State<RekamSetoranPage> createState() => _RekamSetoranPageState();
}

class _RekamSetoranPageState extends State<RekamSetoranPage> {
  CameraController? _controller;
  String? _videoPath;
  bool _isRecording = false;
  bool _isUploading = false;
  int _seconds = 0;
  Timer? _timer;
  bool _isLocked = false;
  String _errorMessage = '';

  static const int MAX_DURATION = 600; // 10 menit

  @override
  void initState() {
    super.initState();
    _initCamera();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();

      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.low, // Resolusi diturunkan ke low agar file lebih kecil tanpa butuh kompresi tambahan
      );

      await _controller!.initialize();
      setState(() {});
    } catch (e) {
      print('Camera error: $e');
    }
  }

  Future<void> _startRecording() async {
    try {
      await _controller!.startVideoRecording();

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _seconds++;

          if (_seconds >= MAX_DURATION) {
            timer.cancel();
            _timer = null;
            _stopRecording();
          }
        });
      });

      setState(() {
        _isRecording = true;
        _isLocked = true;
      });
    } catch (e) {
      print('Start recording error: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final XFile file = await _controller!.stopVideoRecording();

      if (_timer != null) {
        _timer!.cancel();
        _timer = null;
      }

      _seconds = 0;

      setState(() {
        _isRecording = false;
        _isLocked = false;
        _videoPath = file.path;
        _isUploading = true;
      });

      // LANGSUNG UPLOAD TANPA PREVIEW
      String finalVideoPath = await _compressVideo(file.path);
      await _uploadVideo(finalVideoPath);

    } catch (e) {
      print('Stop recording error: $e');
      setState(() {
        _isRecording = false;
        _isLocked = false;
        _errorMessage = 'Gagal menghentikan rekaman: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghentikan rekaman: $e')),
      );
    }
  }

  // Kompresi tidak diperlukan karena sudah pakai ResolutionPreset.low
  Future<String> _compressVideo(String rawVideoPath) async {
    return rawVideoPath;
  }


  Future<void> _uploadVideo(String videoPath) async {
    try {
      final result = await SantriService.uploadSetoran(
        videoPath: videoPath,
        surat: widget.surah.nomor.toString(),
        ayat: widget.ayatEnd,
      );

      setState(() => _isUploading = false);

      if (result['statusCode'] == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Setoran berhasil dikirim!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        String message = result['data']?['message'] ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim setoran: $message'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (_isRecording) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak bisa keluar saat rekaman!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }

    if (_isUploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tunggu upload selesai!'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    _controller?.dispose();
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  String get _timerText {
    final min = (_seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (_seconds % 60).toString().padLeft(2, '0');
    return "$min:$sec";
  }

  String get _remainingText {
    final remaining = MAX_DURATION - _seconds;
    final min = (remaining ~/ 60).toString().padLeft(2, '0');
    final sec = (remaining % 60).toString().padLeft(2, '0');
    return "$min:$sec";
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            // CAMERA
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.previewSize?.height ?? 100,
                  height: _controller!.value.previewSize?.width ?? 100,
                  child: CameraPreview(_controller!),
                ),
              ),
            ),

            // GRADIENT OVERLAY
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // BACK BUTTON
            Positioned(
              top: 50,
              left: 20,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: _isRecording ? Colors.grey : Colors.white,
                ),
                onPressed: _isRecording
                    ? null
                    : () {
                        Navigator.pop(context);
                      },
              ),
            ),

            // INFO CARD
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Setoran Hafalan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.surah.namaLatin} - Ayat ${widget.ayatStart} - ${widget.ayatEnd}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // TIMER
            if (_isRecording)
              Positioned(
                top: 180,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      _timerText,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sisa: $_remainingText',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 200,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: _seconds / MAX_DURATION,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _seconds > MAX_DURATION * 0.8
                                ? Colors.red
                                : Colors.green,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // UPLOADING LOADING
            if (_isUploading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Mengirim setoran...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

            // BUTTON RECORD
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _isUploading
                        ? null
                        : (_isRecording ? _stopRecording : _startRecording),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isRecording ? Colors.red : Colors.white,
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: _isRecording ? 30 : 60,
                          height: _isRecording ? 30 : 60,
                          decoration: BoxDecoration(
                            color: _isUploading ? Colors.grey : Colors.red,
                            borderRadius: BorderRadius.circular(
                                _isRecording ? 8 : 30),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    _isUploading
                        ? 'Mohon tunggu...'
                        : _isRecording
                            ? ' Rekaman berjalan... (10 menit max)'
                            : 'Tekan untuk mulai rekam',
                    style: TextStyle(
                      color: _isUploading
                          ? Colors.yellow
                          : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}