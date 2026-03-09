import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class RekamSetoranPage extends StatefulWidget {
  const RekamSetoranPage({super.key});

  @override
  State<RekamSetoranPage> createState() => _RekamSetoranPageState();
}

class _RekamSetoranPageState extends State<RekamSetoranPage> {

  CameraController? _controller;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
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

    if (!_controller!.value.isInitialized) return;

    await _controller!.startVideoRecording();

    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {

    final file = await _controller!.stopVideoRecording();

    setState(() {
      _isRecording = false;
    });

    print("Video disimpan: ${file.path}");
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [

          CameraPreview(_controller!),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                onPressed: _isRecording
                    ? _stopRecording
                    : _startRecording,
                child: Icon(
                  _isRecording
                      ? Icons.stop
                      : Icons.videocam,
                ),
              ),
            ),
          )

        ],
      ),
    );
  }
}