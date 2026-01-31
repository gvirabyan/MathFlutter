import 'dart:math';
import 'package:flutter/material.dart';

class CountdownPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color inactiveColor;

  CountdownPainter({
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    final strokeWidth = 8.0;

    // Настройки кисти
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // Закругленные края

    // Угол разрыва снизу (примерно 90 градусов или 1.5 * pi радианов общая длина)
    const double startAngle = 0.75 * pi;
    const double totalAngle = 1.5 * pi;

    // 1. Рисуем фоновую (неактивную) дугу
    paint.color = inactiveColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalAngle,
      false,
      paint,
    );

    // 2. Рисуем активную дугу (прогресс)
    paint.color = activeColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalAngle * progress, // Заполнение слева направо
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CountdownPainter oldDelegate) =>
      oldDelegate.progress != progress;
}