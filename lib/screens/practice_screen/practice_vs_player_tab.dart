import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:untitled2/screens/practice_screen/practice_quiz_question_screen.dart';

import '../../ui_elements/player_searching_loading.dart';

class PracticeVsPlayerTab extends StatefulWidget {
  const PracticeVsPlayerTab({super.key});

  @override
  State<PracticeVsPlayerTab> createState() => _PracticeVsPlayerTabState();
}

class _PracticeVsPlayerTabState extends State<PracticeVsPlayerTab> {
  bool started = false;
  bool loading = false;
  bool rivalAvailable = true;

  // стартовый таймер (4..1)
  bool startCountdownRunning = false;
  int startCountdown = 4;
  Timer? startTimer;

  int? selectedQuestionsCount;

  // ========================= ENTRY =========================

  @override
  void dispose() {
    startTimer?.cancel();
    super.dispose();
  }

  // ========================= UI =========================

  @override
  Widget build(BuildContext context) {
    if (!started) return _intro();

    if (loading) return LoadingView();

    if (startCountdownRunning) {
      return _startCountdownView();
    }

    return _selectionList();
  }

  Widget _intro() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Title
            const Text(
              'Du kannst mit jemandem üben, der\neine ähnliche Bewertung hat',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Anzahl der Fragen: 10–30',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 36,),

            // Start Button (yellow)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => setState(() => started = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107), // Yellow
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
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

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }


  Widget _selectionList() {
    return ListView(
      padding: const EdgeInsets.only(top: 8),
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
      onTap: () => _startVsPlayer(count),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7C3AED), // фиолетовый как на скрине
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Divider(indent: 20, endIndent: 20);

  Widget _startCountdownView() {
    final progress = startCountdown / 4;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: CircularProgressIndicator(value: progress),
          ),
          const SizedBox(height: 16),
          Text(
            '$startCountdown',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ========================= LOGIC =========================

  Future<void> _startVsPlayer(int count) async {
    selectedQuestionsCount = count;
    setState(() => loading = true);

    // 1️⃣ random delay 5–20s (как Vue)
    final delayMs = 5000 + Random().nextInt(15001);
    await Future.delayed(Duration(milliseconds: delayMs));

    // 2️⃣ check availability (Berlin time)
    rivalAvailable = _checkAvailabilityBerlin();

    if (!mounted) return;

    setState(() => loading = false);

    if (!rivalAvailable) {
      _showNoPlayersPopup();
      return;
    }

    // 3️⃣ start countdown 4..1
    _runStartCountdown();
  }

  void _runStartCountdown() {
    startTimer?.cancel();

    setState(() {
      startCountdownRunning = true;
      startCountdown = 4;
    });

    startTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;

      if (startCountdown <= 1) {
        t.cancel();
        setState(() => startCountdownRunning = false);

        _goToQuiz();
      } else {
        setState(() => startCountdown--);
      }
    });
  }

  void _goToQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeQuizQuestionScreen(
          totalQuestions: selectedQuestionsCount!,
          rival: 'fake_user',
        ),

      ),
    );
  }

  // ========================= HELPERS =========================

  bool _checkAvailabilityBerlin() {
    // Berlin ≈ UTC+1
    final berlin = DateTime.now().toUtc().add(const Duration(hours: 1));
    final hour = berlin.hour;

    bool chance(double p) => Random().nextDouble() >= p;

    if (hour >= 0 && hour < 6) return chance(0.9);
    if (hour >= 6 && hour < 8) return chance(0.75);
    if (hour >= 8 && hour < 13) return chance(0.4);
    if (hour >= 13 && hour < 19) return chance(0.2);
    if (hour >= 19 && hour < 21) return chance(0.6);
    if (hour >= 21 && hour <= 23) return chance(0.75);

    return true;
  }

  void _showNoPlayersPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Oops'),
          content: const Text(
            'Im Moment sind keine Spieler verfügbar.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Zurück'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _startVsPlayer(selectedQuestionsCount!);
              },
              child: const Text('Nochmal'),
            ),
          ],
        );
      },
    );
  }
}
