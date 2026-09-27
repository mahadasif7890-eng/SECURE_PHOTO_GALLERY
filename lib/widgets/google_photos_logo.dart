import 'dart:math';
import 'package:flutter/material.dart';

class GooglePhotosLogo extends StatelessWidget {
  final double size;

  const GooglePhotosLogo({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GooglePhotosLogoPainter(),
      ),
    );
  }
}

class _GooglePhotosLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final petalRadius = radius * 0.52;

    final paintRed = Paint()..color = const Color(0xFFEA4335)..style = PaintingStyle.fill;
    final paintYellow = Paint()..color = const Color(0xFFFBBC05)..style = PaintingStyle.fill;
    final paintGreen = Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.fill;
    final paintBlue = Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.fill;

    // Draw 4 rounded pinwheel petals
    // Top petal (Red)
    _drawPetal(canvas, center, petalRadius, 0, paintRed);
    // Right petal (Yellow)
    _drawPetal(canvas, center, petalRadius, pi / 2, paintYellow);
    // Bottom petal (Green)
    _drawPetal(canvas, center, petalRadius, pi, paintGreen);
    // Left petal (Blue)
    _drawPetal(canvas, center, petalRadius, 3 * pi / 2, paintBlue);
  }

  void _drawPetal(Canvas canvas, Offset center, double radius, double angle, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final path = Path();
    // A semicircle / pinwheel blade starting from center outwards
    final rect = Rect.fromCircle(center: Offset(0, -radius), radius: radius);
    path.arcTo(rect, 0, pi, false);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
