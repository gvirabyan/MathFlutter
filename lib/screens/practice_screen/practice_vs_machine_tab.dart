import 'package:flutter/material.dart';
import 'package:untitled2/app_start.dart';
import 'package:untitled2/screens/practice_screen/practice_quiz_question_screen.dart';

class PracticeVsMachineTab extends StatelessWidget {
  const PracticeVsMachineTab({super.key});

  void _startQuiz(BuildContext context, int count) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeQuizQuestionScreen(totalQuestions: count),
      ),
    );

    if (result != null && result is Map && result['action'] == 'go_to_status') {
      if (context.mounted) {
        final mainScreen = MainScreen.of(context);
        // Индекс 0 — это "Aktivität", subIndex 0 — "Mein Status"
        mainScreen?.setMainIndex(0, subIndex: 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 6),
      children: [
        _item(
          context,
          title: '10 Fragen',
          score: '+10, +5, -2',
          count: 10,
        ),
        _divider(),
        _item(
          context,
          title: '20 Fragen',
          score: '+20, +10, -4',
          count: 20,
        ),
        _divider(),
        _item(
          context,
          title: '30 Fragen',
          score: '+30, +15, -6',
          count: 30,
        ),
        _divider(),
      ],
    );
  }

  Widget _item(
      BuildContext context, {
        required String title,
        required String score,
        required int count,
      }) {
    return InkWell(
      onTap: () => _startQuiz(context, count),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            /// LEFT
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            /// RIGHT
            Text(
              score,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7C3AED), // фиолетовый как на скрине
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 20,
      endIndent: 20,
    );
  }
}
