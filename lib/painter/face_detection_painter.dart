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
    // Cyan stroke for the box
    final boxPaint = Paint()
      ..color = Colors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Background for confidence label
    final labelBgPaint = Paint()
      ..color = Colors.cyan
      ..style = PaintingStyle.fill;

    // Compute scale ratio
    final scaleX = screenSize.width / imageSize.width;
    final scaleY = (screenSize.height - 120) / imageSize.height;

    for (final face in faces) {
      final scaledBox = Rect.fromLTWH(
        screenSize.width - (face.boundingBox.left + face.boundingBox.width) * scaleX,
        face.boundingBox.top * scaleY,
        face.boundingBox.width * scaleX,
        face.boundingBox.height * scaleY,
      );

      // Draw the main rectangle
      canvas.drawRect(scaledBox, boxPaint);

      // Draw corner brackets (L-shaped corners)
      final cornerLength = 20.0;
      final cornerPaint = Paint()
        ..color = Colors.cyan
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;

      // Top-left corner
      canvas.drawLine(
        Offset(scaledBox.left, scaledBox.top + cornerLength),
        Offset(scaledBox.left, scaledBox.top),
        cornerPaint,
      );
      canvas.drawLine(
        Offset(scaledBox.left, scaledBox.top),
        Offset(scaledBox.left + cornerLength, scaledBox.top),
        cornerPaint,
      );

      // Top-right corner
      canvas.drawLine(
        Offset(scaledBox.right - cornerLength, scaledBox.top),
        Offset(scaledBox.right, scaledBox.top),
        cornerPaint,
      );
      canvas.drawLine(
        Offset(scaledBox.right, scaledBox.top),
        Offset(scaledBox.right, scaledBox.top + cornerLength),
        cornerPaint,
      );

      // Bottom-left corner
      canvas.drawLine(
        Offset(scaledBox.left, scaledBox.bottom - cornerLength),
        Offset(scaledBox.left, scaledBox.bottom),
        cornerPaint,
      );
      canvas.drawLine(
        Offset(scaledBox.left, scaledBox.bottom),
        Offset(scaledBox.left + cornerLength, scaledBox.bottom),
        cornerPaint,
      );

      // Bottom-right corner
      canvas.drawLine(
        Offset(scaledBox.right - cornerLength, scaledBox.bottom),
        Offset(scaledBox.right, scaledBox.bottom),
        cornerPaint,
      );
      canvas.drawLine(
        Offset(scaledBox.right, scaledBox.bottom),
        Offset(scaledBox.right, scaledBox.bottom - cornerLength),
        cornerPaint,
      );

      // Draw confidence label above the box
      final confidence = (face.score * 100).round();
      final confidenceText = 'CONFIDENCE:\n$confidence%';
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: confidenceText,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      
      // Draw background rectangle for the label
      final labelRect = Rect.fromLTWH(
        scaledBox.left,
        scaledBox.top - textPainter.height - 12,
        textPainter.width + 16,
        textPainter.height + 8,
      );
      
      canvas.drawRect(labelRect, labelBgPaint);
      
      // Draw the text
      textPainter.paint(
        canvas,
        Offset(labelRect.left + 8, labelRect.top + 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}