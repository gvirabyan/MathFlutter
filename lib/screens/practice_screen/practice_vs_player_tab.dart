import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/screens/practice_screen/practice_quiz_question_screen.dart';
import 'package:untitled2/screens/practice_screen/practice_vs_machine_tab.dart';
import 'package:untitled2/services/auth_service.dart';

import '../../app_colors.dart';
import '../../app_start.dart';
import '../../ui_elements/dialogs/no_player_dialog.dart';
import '../../ui_elements/loading_overlay.dart';
import '../../ui_elements/player_searching_loading.dart';
import '../../ui_elements/primary_button.dart';

class PracticeVsPlayerTab extends StatefulWidget {
  const PracticeVsPlayerTab({super.key});

  @override
  State<PracticeVsPlayerTab> createState() => _PracticeVsPlayerTabState();
}

class _PracticeVsPlayerTabState extends State<PracticeVsPlayerTab> {
  bool started = false;
  bool loading = false;
  bool rivalAvailable = true;
  bool showResults = false;
  bool resultsAlreadyShown = false;
  int lastMyPoints = 0;
  int lastRivalPoints = 0;
  String lastRivalName = '';
  String myUserName = 'Ich';

  // ✅ NEW: Флаг для начальной загрузки
  bool isInitializing = true;

  // стартовый таймер (4..1)
  bool startCountdownRunning = false;
  int startCountdown = 4;
  Timer? startTimer;

  int? selectedQuestionsCount;

  // ========================= ENTRY =========================

  @override
  void initState() {
    super.initState();
    _loadSavedResults(); // ✅ Загружаем сохраненные результаты
  }

  @override
  void dispose() {
    startTimer?.cancel();
    super.dispose();
  }

  // ✅ FIXED: Загрузка сохраненных результатов с немедленным отображением
  Future<void> _loadSavedResults() async {
    final prefs = await SharedPreferences.getInstance();

    // Fetch real user name
    final userRes = await AuthService.getUser();
    if (userRes['status'] == 'success') {
      myUserName = userRes['user']['username'] ?? 'Ich';
    }

    final resultsJson = prefs.getString('practice_vs_player_results');
    resultsAlreadyShown = prefs.getBool('results_already_shown') ?? false;

    if (resultsJson != null && !resultsAlreadyShown) {
      try {
        final results = json.decode(resultsJson) as Map<String, dynamic>;

        // ✅ CRITICAL: Обновляем состояние ДО завершения initState
        if (mounted) {
          setState(() {
            lastMyPoints = results['myPoints'] ?? 0;
            lastRivalPoints = results['rivalPoints'] ?? 0;
            lastRivalName = results['rivalName'] ?? 'Gegner';
            selectedQuestionsCount = results['totalQuestions'] ?? 10;
            showResults = true;
            isInitializing = false; // ✅ Завершили инициализацию
          });
        }

        // 👇 отмечаем, что уже показали
        await prefs.setBool('results_already_shown', true);
      } catch (e) {
        debugPrint('Error loading results: $e');
        if (mounted) {
          setState(() {
            isInitializing = false;
          });
        }
      }
    } else {
      // ✅ Нет сохраненных результатов - просто завершаем инициализацию
      if (mounted) {
        setState(() {
          isInitializing = false;
        });
      }
    }
  }


  // ✅ NEW: Сохранение результатов
  Future<void> _saveResults() async {
    final prefs = await SharedPreferences.getInstance();
    final resultsJson = json.encode({
      'myPoints': lastMyPoints,
      'rivalPoints': lastRivalPoints,
      'rivalName': lastRivalName,
      'totalQuestions': selectedQuestionsCount,
    });
    await prefs.setString('practice_vs_player_results', resultsJson);
    await prefs.setBool('results_already_shown', false);
  }

  // ✅ NEW: Очистка сохраненных результатов
  Future<void> _clearResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('practice_vs_player_results');
  }

  // ========================= UI =========================

  @override
  Widget build(BuildContext context) {
    // ✅ CRITICAL: Показываем loading пока идет инициализация
    if (isInitializing) {
      return const Center(child: LoadingOverlay());
    }

    if (showResults) {
      return _resultsView();
    }

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
              'Du kannst mit jemandem \nüben, der eine ähnliche \nBewertung hat',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Anzahl der Fragen: 10–30',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),

            const SizedBox(height: 46),

            // Start Button (yellow)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Theme(
                data: Theme.of(context).copyWith(
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                child: SizedBox(
                  height: 55,
                  child: PrimaryButton(
                    text: 'Start',
                    enabled: true,
                    color: const Color(0xFFFFC107),
                    onPressed: () => setState(() => started = true),
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
        _item(context, title: '10 Fragen', score: '+10, +5, -2', count: 10),
        _divider(),
        _item(context, title: '20 Fragen', score: '+20, +10, -4', count: 20),
        _divider(),
        _item(context, title: '30 Fragen', score: '+30, +15, -6', count: 30),
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
    final delayMs = 5000 + Random().nextInt(7000);
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

  Future<void> _goToQuiz() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => PracticeQuizQuestionScreen(
          totalQuestions: selectedQuestionsCount!,
          rival: 'fake_user',
        ),
      ),
    );

    if (!mounted) return;

    if (result is Map<String, dynamic>) {
      setState(() {
        lastMyPoints = result['myPoints'] ?? 0;
        lastRivalPoints = result['rivalPoints'] ?? 0;
        lastRivalName = result['rivalName'] ?? 'Gegner';
        showResults = true;
      });

      // ✅ Сохраняем результаты в SharedPreferences
      await _saveResults();

      if (result['action'] == 'go_to_status') {
        final mainScreen = MainScreen.of(context);
        mainScreen?.setMainIndex(0, subIndex: 0);
      }
    } else if (result == 'go_to_status') {
      final mainScreen = MainScreen.of(context);
      mainScreen?.setMainIndex(0, subIndex: 0);
    }
  }

  Widget _resultsView() {
    int myDisplayPoints = lastMyPoints > lastRivalPoints ? 10 : -2;
    int rivalDisplayPoints = lastRivalPoints > lastMyPoints ? 10 : -2;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _resultCard(
            name: myUserName,
            correct: lastMyPoints,
            total: selectedQuestionsCount!,
            points: myDisplayPoints,
            isWinner: lastMyPoints >= lastRivalPoints,
          ),
          _resultCard(
            name: lastRivalName.isEmpty ? "Gegner" : lastRivalName,
            correct: lastRivalPoints,
            total: selectedQuestionsCount!,
            points: rivalDisplayPoints,
            isWinner: lastRivalPoints > lastMyPoints,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: PrimaryButton(
              fontSize: 18,
              text: 'Erneut probieren',
              color: const Color(0xFFFFC107),
              onPressed: () async {
                await _clearResults();

                setState(() {
                  showResults = false;
                });
              },
              enabled: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultCard({
    required String name,
    required int correct,
    required int total,
    required int points,
    required bool isWinner,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$name s Punkte",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$correct/$total Richtige Antworten",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),

            const Spacer(), // ← ПРИЖИМАЕТ К ПРАВОЙ СТЕНЕ

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${points > 0 ? '' : ''}$points Punkts",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryPurple,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isWinner ? "Gewonnen" : "Verloren",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
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
      barrierDismissible: true,
      builder: (ctx) => NoPlayersDialog(
        onPracticePressed: () {
          Navigator.of(ctx).pop(); // Закрываем диалог

          // Используем ваш статический метод, чтобы найти состояние MainScreen
          final mainScreen = MainScreen.of(context);

          if (mainScreen != null) {
            // Индекс 2 — это вкладка "Üben"
            // subIndex 0 — это "Spieler vs Maschine" (первый под-таб)
            mainScreen.setMainIndex(2, subIndex: 0);
          }
        },
        onRetryPressed: () {
          Navigator.of(ctx).pop(); // Закрываем диалог
          _startVsPlayer(selectedQuestionsCount!); // Вызываем вашу логику
        },
      ),
    );
  }}