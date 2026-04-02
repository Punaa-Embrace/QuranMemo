import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/surah_model.dart';

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
  bool _isRecording = false;
  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initCamera();

    /// 🔒 LOCK ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();

    final camera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
    );

    await _controller!.initialize();
    setState(() {});
  }

  Future<void> _startRecording() async {
    await _controller!.startVideoRecording();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _seconds++);
    });

    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    final file = await _controller!.stopVideoRecording();

    _timer?.cancel();
    _seconds = 0;

    setState(() => _isRecording = false);

    print("Video disimpan: ${file.path}");
  }

  /// 🔒 AUTO CANCEL KALAU KELUAR
  Future<bool> _onWillPop() async {
    if (_isRecording) {
      await _controller!.stopVideoRecording();
    }
    return true;
  }

  @override
  void dispose() {
    _controller?.dispose();
    _timer?.cancel();

    /// BALIKIN ORIENTATION
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);

    super.dispose();
  }

  String get _timerText {
    final min = (_seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (_seconds % 60).toString().padLeft(2, '0');
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

            /// CAMERA
            CameraPreview(_controller!),

            /// GRADIENT OVERLAY
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

            /// INFO CARD
            Positioned(
              top: 60,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.surah.namaLatin,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Ayat ${widget.ayatStart} - ${widget.ayatEnd}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),

            /// TIMER
            if (_isRecording)
              Positioned(
                top: 140,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    _timerText,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            /// BUTTON RECORD
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _isRecording
                      ? _stopRecording
                      : _startRecording,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: _isRecording ? 30 : 60,
                        height: _isRecording ? 30 : 60,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(
                              _isRecording ? 8 : 30),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            /// TEXT INFO
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: const Center(
                child: Text(
                  "Tekan untuk mulai rekam",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}