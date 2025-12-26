import 'package:flutter/material.dart';
import 'quiz_question_screen.dart';

class PracticeVsPlayerTab extends StatefulWidget {
  const PracticeVsPlayerTab({super.key});

  @override
  State<PracticeVsPlayerTab> createState() => _PracticeVsPlayerTabState();
}

class _PracticeVsPlayerTabState extends State<PracticeVsPlayerTab> {
  bool started = false;

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
    return started ? _selectionList(context) : _startIntro();
  }

  // ================= INTRO SCREEN =================

  Widget _startIntro() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 80),

          const Text(
            'Du kannst mit jemandem üben, der\n'
                'eine ähnliche Bewertung hat',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Anzahl der Fragen: 10–30',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 48),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                setState(() => started = true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Start',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SELECTION LIST (COPY OF MACHINE) =================

  Widget _selectionList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              score,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7C3AED),
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
