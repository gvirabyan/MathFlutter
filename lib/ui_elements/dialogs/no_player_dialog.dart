import 'package:flutter/material.dart';
import 'package:untitled2/app_colors.dart';

class NoPlayersDialog extends StatelessWidget {
  final VoidCallback onPracticePressed;
  final VoidCallback onRetryPressed;

  const NoPlayersDialog({
    super.key,
    required this.onPracticePressed,
    required this.onRetryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        children: [
          // Кнопка закрытия
          Positioned(
            right: 2,
            top: 2,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.close,
                color: Colors.black54,
                size: 22,
              ),
              splashRadius: 20,
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Kein Spieler ist verfügbar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      height: 1.3,
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      TextSpan(text: 'Sorry, aktuell ist kein Spieler verfügbar '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Text('🤷‍♀️', style: TextStyle(fontSize: 18)),
                      ),
                      TextSpan(text: 'Probiere später noch einmal.'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Кнопка "Gehe zum Üben"
                _DialogButton(
                  text: 'Gehe zum Üben',
                  onPressed: onPracticePressed,
                ),

                const SizedBox(height: 24),

                // Кнопка "Erneut versuchen"
                _DialogButton(
                  text: 'Erneut versuchen',
                  onPressed: onRetryPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Вспомогательный виджет для кнопок, чтобы не дублировать код
class _DialogButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _DialogButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}