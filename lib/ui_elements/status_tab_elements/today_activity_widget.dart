import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:untitled2/app_colors.dart';

import '../../app_start.dart';

class TodayActivity extends StatelessWidget {
  final int amount;
  final int correct;
  final int skipped;
  final int wrong;
  final double percentCorrect;

  const TodayActivity({
    required this.amount,
    required this.correct,
    required this.skipped,
    required this.wrong,
    required this.percentCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Heutige Aktivität',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: 200,
          height: 160,
          child: CustomPaint(
            painter: MultiColorOpenCirclePainter(
              correct: correct,
              skipped: skipped,
              wrong: wrong,
              total: amount,
              gapDegrees: 75, // Угол разрыва внизу
              strokeWidth: 10,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$amount',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Text.rich(
                    TextSpan(
                      text: 'Richtig ',
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: '$correct',
                          style: const TextStyle(
                            color: AppColors.greenCorrect,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text.rich(
                    TextSpan(
                      text: 'Übersprungen ',
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: '$skipped',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      text: 'Falsch ',
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: '$wrong',
                          style: const TextStyle(
                            color: AppColors.redWrong,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _CheckProgressButton(
          onTap: () {
            MainScreen.of(context)?.setMainIndex(0, subIndex: 3);
          },
        ),
      ],
    );
  }
}

class _CheckProgressButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CheckProgressButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: const Text(
        'Fortschritt Prüfen',
        style: TextStyle(
          color: AppColors.primaryPurple,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}


class MultiColorOpenCirclePainter extends CustomPainter {
  final int correct;
  final int skipped;
  final int wrong;
  final int total;
  final double gapDegrees;
  final double strokeWidth;

  MultiColorOpenCirclePainter({
    required this.correct,
    required this.skipped,
    required this.wrong,
    required this.total,
    required this.gapDegrees,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final double gapRad = gapDegrees * math.pi / 180;
    final double availableSweep = 2 * math.pi - gapRad;

    // Начальная точка — слева от разрыва внизу
    double startAngle = math.pi / 2 + gapRad / 2;

    void drawSegment(int count, Color color) {
      if (count <= 0) return;

      final sweepAngle = availableSweep * (count / total);
      final paint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }

    // Рисуем последовательно: Зеленый -> Серый -> Красный
    drawSegment(correct, AppColors.greenCorrect);
    drawSegment(skipped, Colors.grey.shade400);
    drawSegment(wrong, AppColors.redWrong);
  }

  @override
  bool shouldRepaint(covariant MultiColorOpenCirclePainter old) =>
      old.correct != correct || old.wrong != wrong || old.skipped != skipped;
}