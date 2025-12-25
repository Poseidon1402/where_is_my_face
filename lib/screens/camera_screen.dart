import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import '../models/face_detection_result.dart';
import '../painter/face_detection_painter.dart';
import '../services/face_detector_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isProcessing = false; // Used to detect if the camera is processing a frame
  bool _isCameraInitialized = false;
  final _faceDetectorService = FaceDetectorService();
  List<FaceDetectionResult> _detectedFaces = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  /// Camera initialization
  /// Initialize the camera using available cameras.
  /// Then set the camera controller to the first camera found.
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(cameras.last, ResolutionPreset.high);

    _controller!.initialize().then((_) async {
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });

      await _faceDetectorService.initialize();

      // Process each camera frame
      _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
        _processFrame();
      });
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetectorService.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
        backgroundColor: Colors.black,
      ),
      body: _isCameraInitialized
          ? Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_controller!),
                CustomPaint(
                  painter: FaceDetectionPainter(
                    faces: _detectedFaces,
                    imageSize: Size(
                      _controller!.value.previewSize!.height,
                      _controller!.value.previewSize!.width,
                    ),
                    screenSize: MediaQuery.sizeOf(context),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: extract,
        child: const Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> extract() async {
    // TODO: Extract faces
  }

  Future<void> _processFrame() async {
    if (!_isCameraInitialized || _isProcessing) return;

    _isProcessing = true;

    final picture = await _controller!.takePicture();
    final bytes = await picture.readAsBytes();

    final faces = await _faceDetectorService.detectFromBytes(bytes);

    if (mounted) {
      setState(() => _detectedFaces = faces);
    }

    _isProcessing = false;
  }

}
