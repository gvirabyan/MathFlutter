import 'dart:math' as math;
import 'package:flutter/material.dart';

class OpenCircleGauge extends StatelessWidget {
  final double percent;
  final double size;
  final double strokeWidth;
  final Color color;
  final Widget child;

  const OpenCircleGauge({
    super.key,
    required this.percent,
    required this.child,
    this.size = 160,
    this.strokeWidth = 10,
    this.color = Colors.purple,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _OpenCirclePainter(
          percent: percent,
          color: color,
          strokeWidth: strokeWidth,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _OpenCirclePainter extends CustomPainter {
  final double percent;
  final Color color;
  final double strokeWidth;

  _OpenCirclePainter({
    required this.percent,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2 - strokeWidth;
    final center = Offset(size.width / 2, size.height / 2);

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);

    const gapDegrees = 50.0;
    final gap = gapDegrees * math.pi / 180;
    final sweep = (2 * math.pi - gap) * (percent / 100);
    final start = math.pi / 2 + gap / 2;

    canvas.drawArc(rect, start, sweep, false, paint);
  }

  @override
  bool shouldRepaint(covariant _OpenCirclePainter old) =>
      old.percent != percent ||
          old.color != color ||
          old.strokeWidth != strokeWidth;
}
