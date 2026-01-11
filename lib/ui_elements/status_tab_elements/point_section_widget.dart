import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PointsSection extends StatelessWidget {
  final int points;
  final String? lastUpdate;

  const PointsSection({required this.points, required this.lastUpdate});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Punkte',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        if (lastUpdate != null)
          Text(
            'Letztes Update: $lastUpdate',
            style: const TextStyle(color: Colors.black, fontSize: 12),
          ),
        const SizedBox(height: 20),
        SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(220, 220),
                painter: OpenCirclePainter(
                  percent: 100,
                  gapDegrees: 0,
                  color: const Color(0xFFEDE7FF),
                  strokeWidth: 9,
                ),
              ),
              Text(
                '$points',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
class OpenCirclePainter extends CustomPainter {
  final double percent;
  final double gapDegrees;
  final Color color;
  final double strokeWidth;

  OpenCirclePainter({
    required this.percent,
    required this.gapDegrees,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2 - strokeWidth;
    final center = Offset(size.width / 2, size.height / 2);

    final paint =
    Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);

    final gap = gapDegrees * math.pi / 180;
    final sweep = (2 * math.pi - gap) * (percent / 100);
    final start = math.pi / 2 + gap / 2;

    canvas.drawArc(rect, start, sweep, false, paint);
  }

  @override
  bool shouldRepaint(covariant OpenCirclePainter old) =>
      old.percent != percent ||
          old.gapDegrees != gapDegrees ||
          old.color != color ||
          old.strokeWidth != strokeWidth;
}