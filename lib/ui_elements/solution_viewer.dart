import 'package:flutter/material.dart';
import '../ui_elements/math_content.dart';

class SolutionViewer extends StatelessWidget {
  final String solution;

  const SolutionViewer({super.key, required this.solution});

  static void show(BuildContext context, String solution) {
    showDialog(
      context: context,
      builder: (context) => SolutionViewer(solution: solution),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      // Контролируем отступы диалога от краев экрана
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Чтобы диалог подстраивался под контент
          children: [
            // ШАПКА (Фиксированная)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Erklärung',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // КОНТЕНТ (Скроллируемый)
            Flexible( // Важно: позволяет скроллу работать внутри Column диалога
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MathContent(
                      content: solution,
                      fontSize: 18,
                    ),
                    // Дополнительный отступ снизу, чтобы текст не прилипал
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}