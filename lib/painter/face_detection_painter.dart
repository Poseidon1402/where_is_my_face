import 'package:flutter/material.dart';

import '../models/face_detection_result.dart';

class FaceDetectionPainter extends CustomPainter {
  final List<FaceDetectionResult> faces;
  final Size imageSize;
  final Size screenSize;

  FaceDetectionPainter({
    required this.faces,
    required this.imageSize,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // compute scale ratio
    final scaleX = screenSize.width / imageSize.width;
    final scaleY = (screenSize.height - 120) / imageSize.height;

    for (final face in faces) {
      final scaledBox = Rect.fromLTWH(
        screenSize.width - (face.boundingBox.left + face.boundingBox.width) * scaleX, // flip x to prevent inversion issue
        face.boundingBox.top * scaleY,
        face.boundingBox.width * scaleX,
        face.boundingBox.height * scaleY,
      );

      // Draw the rectangle
      canvas.drawRect(scaledBox, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}