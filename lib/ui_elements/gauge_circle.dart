import 'dart:math';
import 'package:flutter/material.dart';

class GaugeCircle extends StatelessWidget {
  final double percent; // 0..100
  final Color color;

  /// размеры
  final double size; // общая ширина/высота
  final double strokeWidth;

  /// контент внутри
  final Widget? top;     // например "60%"
  final Widget? middle;  // например "123"
  final Widget? bottom;  // например описание

  final double spacingMiddleBottom;

  /// дуга: как в твоём Vue (1.5*pi)
  final double startAngle; // radians
  final double sweepAngle; // radians

  /// фон дуги (слабый)
  final double backgroundOpacity;

  const GaugeCircle({
    super.key,
    required this.percent,
    required this.color,
    this.size = 200,
    this.strokeWidth = 14,
    this.top,
    this.middle,
    this.bottom,
    this.startAngle = pi * 0.75,
    this.sweepAngle = pi * 1.5,
    this.backgroundOpacity = 0.2,
    this.spacingMiddleBottom = 6,
  });

  @override
  Widget build(BuildContext context) {
    final double safePercent = percent.isFinite ? percent.clamp(0, 100) : 0.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _GaugeCirclePainter(
              percent: safePercent,
              color: color,
              strokeWidth: strokeWidth,
              startAngle: startAngle,
              sweepAngle: sweepAngle,
              backgroundOpacity: backgroundOpacity,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (top != null) top!,
              if (top != null) const SizedBox(height: 2),
              if (middle != null) middle!,
              if (bottom != null) ...[
                SizedBox(height: spacingMiddleBottom),
                bottom!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugeCirclePainter extends CustomPainter {
  final double percent;
  final Color color;
  final double strokeWidth;
  final double startAngle;
  final double sweepAngle;
  final double backgroundOpacity;

  _GaugeCirclePainter({
    required this.percent,
    required this.color,
    required this.strokeWidth,
    required this.startAngle,
    required this.sweepAngle,
    required this.backgroundOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2 - strokeWidth;
    final center = Offset(size.width / 2, size.height / 2);

    final bgPaint = Paint()
      ..color = color.withOpacity(backgroundOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // background arc
    canvas.drawArc(rect, startAngle, sweepAngle, false, bgPaint);

    // foreground arc
    final sweep = sweepAngle * (percent / 100);
    canvas.drawArc(rect, startAngle, sweep, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugeCirclePainter oldDelegate) {
    return oldDelegate.percent != percent ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.startAngle != startAngle ||
        oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.backgroundOpacity != backgroundOpacity;
  }
}
