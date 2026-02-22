import 'package:flutter/material.dart';

import '../app_colors.dart';

class TopicProgressItemWidget extends StatelessWidget {
  final String title;
  final int done;
  final int total;
  final VoidCallback? onTap;
  final VoidCallback? onGenerate;
  final VoidCallback? onReview;

  bool get isAdmin => true;

  const TopicProgressItemWidget({
    super.key,
    required this.title,
    required this.done,
    required this.total,
    this.onTap,
    this.onGenerate,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
        ),
        child: Column(
          children: [
            // Основная строка (Заголовок и Прогресс)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '$done/$total',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ],
            ),

            // Секция для админа
            if (isAdmin) ...[
              const SizedBox(height: 12), // Отступ между текстом и кнопками
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _AdminButton(
                    label: 'Generate',
                    onPressed: () {
                      onGenerate?.call();
                    },
                  ),
                  _AdminButton(
                    label: 'Review',
                    onPressed: () {
                      onReview?.call();
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Вспомогательный мини-виджет для кнопок, чтобы не дублировать код
class _AdminButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _AdminButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryPurple,
        side: const BorderSide(color: AppColors.primaryPurple),
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }
}
