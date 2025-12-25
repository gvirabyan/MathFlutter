import 'package:flutter/material.dart';
import 'quiz_question_screen.dart';

class PracticeVsMachineTab extends StatelessWidget {
  const PracticeVsMachineTab({super.key});

  void _startQuiz(BuildContext context, int count) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizQuestionScreen(totalQuestions: count),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        Row(
          children: [
            _btn(context, 10),
            _btn(context, 20),
            _btn(context, 30),
          ],
        ),
      ],
    );
  }

  Widget _btn(BuildContext context, int count) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _startQuiz(context, count),
        child: Container(
          height: 80,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
