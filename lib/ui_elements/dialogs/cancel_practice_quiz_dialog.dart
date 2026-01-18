import 'package:flutter/material.dart';

class CancelPracticeQuizDialog extends StatelessWidget {
  final VoidCallback onLeave;
  final VoidCallback onStay;

  const CancelPracticeQuizDialog({
    super.key,
    required this.onLeave,
    required this.onStay,
  });

  // ДОБАВЬТЕ ЭТОТ МЕТОД
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => CancelPracticeQuizDialog(
            onLeave: () {
              // Возвращаем true = пользователь хочет уйти
            },
            onStay: () {
              // Ничего не делаем, диалог уже закрыт
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 32, 12, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Bist du sicher\ndass du diese Seite verlassen \nwillst?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Du wirst verlieren und dein Fortschritt wird verloren gehen 😢. 2 Punkte',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC9C9C9),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(true); // <-- ИЗМЕНИТЕ
                            onLeave();
                          },
                          child: const Text(
                            'Verlassen',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7A24E4),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(false); // <-- ИЗМЕНИТЕ
                            onStay();
                          },
                          child: const Text(
                            'Bleibe',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // X button
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, size: 22),
              color: Colors.black54,
              onPressed: () {
                Navigator.of(context).pop(false);
                onStay();
              },
            ),
          ),
        ],
      ),
    );
  }
}
