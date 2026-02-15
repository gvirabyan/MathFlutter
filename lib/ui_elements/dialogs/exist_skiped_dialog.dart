import 'package:flutter/material.dart';

class ExistSkipedDialog extends StatelessWidget {
  final int skippedCount;
  final VoidCallback onLeave;
  final VoidCallback onShowSkipped;
  final VoidCallback onDismiss;


  const ExistSkipedDialog({
    super.key,
    required this.skippedCount,
    required this.onLeave,
    required this.onShowSkipped,
    required this.onDismiss,

  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), // Скругление как на фото
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 8),
      // Отступ от краев экрана
      backgroundColor: Colors.white,
      child: Stack(
        children: [
          // Иконка крестика в углу
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed: () { Navigator.of(context).pop();
                        onDismiss();},
              icon: const Icon(Icons.close, color: Color(0xFF4D4D4D), size: 30),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Заголовок
                Text(
                  'Bist du sicher\ndass du diese Seite verlassen\nwillst?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800, // Жирный шрифт
                    color: Colors.black.withOpacity(0.8),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                // Описание
                Text(
                  'Du hast den Großteil des Themas bestanden, aber du hast $skippedCount Fragen übersprungen. Du kannst sie noch einmal überprüfen oder sie vorerst lassen.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF232323),
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                // Кнопки
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: onLeave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFBCBCBC),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            // Убираем стандартные отступы Flutter
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'Vorerst\nverlassen',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: onShowSkipped,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B2CFE),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            // Убираем стандартные отступы Flutter
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'Übersprungene\nFragen zeigen',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.1,
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
        ],
      ),
    );
  }
}
