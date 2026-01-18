import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app_colors.dart';
import '../../ui_elements/primary_button.dart';

class CompleteOfLearningPage extends StatelessWidget {
  final int points;
  final int correctAnswers;
  final int totalQuestions;
  final VoidCallback onStartPractice;
  final VoidCallback onBottomIconTap; // ✅ Новый колбэк для нижней иконки

  const CompleteOfLearningPage({
    super.key,
    required this.points,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.onStartPractice,
    required this.onBottomIconTap, // ✅ Добавляем в конструктор
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Opacity(
                opacity: 0.3,
                child: SvgPicture.asset(
                  'assets/pics_for_buttons/points-bg.svg',
                  height: 150,
                ),
              ),
            ),
            const SizedBox(height: 56),
            // Логотип
            Center(
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  children: [
                    TextSpan(
                      text: 'Mathe',
                      style: TextStyle(color: AppColors.primaryPurple),
                    ),
                    TextSpan(
                      text: 'App',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 36),
            // Карточка с результатами
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF8FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Deine Punkte zu diesem Thema',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Text(
                          '$points Punkt',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$correctAnswers / $totalQuestions Richtige Antworten Fragen',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Кнопка
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Theme(
                data: Theme.of(context).copyWith(
                  textTheme: Theme.of(context).textTheme.copyWith(
                    labelLarge: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                child: PrimaryButton(
                  text: 'Üben beginnen',
                  color: AppColors.primaryPurple,
                  onPressed: onStartPractice,
                  enabled: true,
                ),
              ),
            ),
            const Spacer(),
            // ✅ Кликабельная нижняя SVG
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: GestureDetector(
                onTap: onBottomIconTap, // Вызов колбэка
                behavior: HitTestBehavior.opaque, // Делает всю область иконки чувствительной
                child: SvgPicture.asset(
                  'assets/pics_for_buttons/points-violet.svg',
                  height: 50,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}