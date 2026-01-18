import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/screens/topics_screen/learning_quiz_question_screen.dart';
import 'package:untitled2/services/auth_service.dart';

import '../../app_colors.dart';
import '../../services/user_stats_service.dart';
import '../../ui_elements/gauge_circle.dart';
import '../../ui_elements/loading_overlay.dart';
import '../../ui_elements/status_tab_elements/daily_goal_widget.dart';
import '../../ui_elements/status_tab_elements/point_section_widget.dart';
import '../../ui_elements/status_tab_elements/today_activity_widget.dart';

class StatusTab extends StatefulWidget {
  final Function(int)? onGoalUpdated;

  const StatusTab({super.key, this.onGoalUpdated});

  @override
  State<StatusTab> createState() => _StatusTabState();
}

class _StatusTabState extends State<StatusTab> {
  final UserStatsService _userStatsService = UserStatsService();

  bool isLoading = true;
  bool disableSelect = false;

  int dailyGoal = 0;
  int points = 0;

  Map<String, dynamic>? lastQuiz;
  String? lastUpdate;
  String? timeInApp;

  int pastCategoriesCount = 0;
  int categoriesCount = 0;
  double pastCategoriesPercent = 0;

  List<Map<String, dynamic>> dailyStatics = [];

  @override
  void initState() {
    super.initState();
    _loadDailyGoalFromStorage();
    _loadUserStatus();
  }

  Future<void> _loadUserStatus() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final status = await _userStatsService.getUserStatus();

      if (!mounted) return;
      setState(() {
        dailyStatics = List<Map<String, dynamic>>.from(
          status["daily_statics"] ?? [],
        );
        points = _parseInt(status["points"]);

        lastQuiz = status["last_quiz"];
        lastUpdate = status["last_update"]?.toString();
        timeInApp = status["time_in_app"]?.toString();

        pastCategoriesCount = _parseInt(status["past_categories_count"]);
        categoriesCount = _parseInt(status["categories_count"]);
        pastCategoriesPercent =
            (status["past_categories_percent"] ?? 0).toDouble();
      });
    } catch (e) {
      debugPrint("Error loading user status: $e");
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  int get amountAnswered =>
      dailyStatics.fold(0, (s, e) => s + _parseInt(e["count"]));

  Map<String, dynamic> stat(String key) {
    final item = dailyStatics.firstWhere(
      (e) => e["status"] == key,
      orElse: () => {"count": 0},
    );

    final count = _parseInt(item["count"]);
    final percent = amountAnswered == 0 ? 0.0 : (count * 100) / amountAnswered;

    return {"count": count, "percent": percent};
  }

  void setGoal(int value) async {
    setState(() => disableSelect = true);

    try {
      final res = await AuthService.updateUser({'everyday_goal': value});

      if (res['status'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('daily_goal', value);

        setState(() => dailyGoal = value);
        if (widget.onGoalUpdated != null) {
          widget.onGoalUpdated!(value);
        }
      }
    } finally {
      if (mounted) setState(() => disableSelect = false);
    }
  }

  Future<void> _loadDailyGoalFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      dailyGoal = prefs.getInt('daily_goal') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingOverlay();
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),

          DailyGoal(
            value: dailyGoal,
            disabled: disableSelect,
            onChanged: setGoal,
          ),

          const SizedBox(height: 24),

          _LastQuiz(
            lastQuiz: lastQuiz,
            onTap: _goLastQuiz, // Передаем метод
          ),
          const SizedBox(height: 40),

          if (dailyStatics.isNotEmpty)
            TodayActivity(
              amount: amountAnswered,
              correct: stat("correct")["count"],
              skipped: stat("skipped")["count"],
              wrong: stat("wrong")["count"],
              percentCorrect: stat("correct")["percent"],
            ),

          const SizedBox(height: 20),

          PointsSection(points: points, lastUpdate: lastUpdate),

          if (pastCategoriesCount > 0 && categoriesCount > 0) ...[
            const SizedBox(height: 54),
            // Заголовок оставляем снаружи
            const Text(
              'Vergangene Kategorien',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16), // Отступ до круга

            Center(
              child: GaugeCircle(
                percent: pastCategoriesPercent,
                color: AppColors.primaryPurple,
                size: 200,
                // Можно настроить нужный размер
                strokeWidth: 10,
                // Верхний текст: проценты
                top: Text(
                  '${pastCategoriesPercent.toStringAsFixed(0)} %',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                // Средний текст: дробь
                middle: Text(
                  '$pastCategoriesCount of $categoriesCount',
                  style: const TextStyle(
                    fontSize: 36,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Нижний текст (если нужен доп. текст, иначе можно оставить пустым)
                bottom: const Text(
                  'Beantwortete \nKategorien',
                  style: TextStyle(fontSize: 12, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],

          _FooterText(timeInApp: timeInApp),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _goLastQuiz() {
    if (lastQuiz != null && lastQuiz!["lastCategory"] != null) {
      // Извлекаем ID категории
      final categoryId = _parseInt(lastQuiz!["lastCategory"]["id"]);

      // Извлекаем имя категории (чтобы оно отображалось в заголовке экрана)
      final String categoryName = lastQuiz!["lastCategory"]["name"] ?? 'Quiz';

      // Извлекаем общее количество вопросов (чтобы кружочки сверху были правильного размера)
      final int totalQuestions = _parseInt(lastQuiz!["totalQuestions"]);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => LearningQuizQuestionScreen(
                categoryId: categoryId,
                categoryName: categoryName,
                totalQuestions: totalQuestions,
                learningMode: true,
                // В Vue версии это обычно режим обучения
                awardPoints: true,
                saveResult: true,
              ),
        ),
      );
    }
  }
}

class _LastQuiz extends StatelessWidget {
  final Map<String, dynamic>? lastQuiz;

  // Добавляем колбэк для клика
  final VoidCallback onTap;

  const _LastQuiz({required this.lastQuiz, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (lastQuiz == null || lastQuiz!["lastCategory"] == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap, // Вызываем функцию при нажатии
      behavior: HitTestBehavior.opaque, // Чтобы кликалась вся область
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const Text(
              'Letztes Quiz',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    lastQuiz!["lastCategory"]["name"] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    '${lastQuiz!["answeredQuestions"]} / ${lastQuiz!["totalQuestions"]}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterText extends StatelessWidget {
  final String? timeInApp;

  const _FooterText({required this.timeInApp});

  @override
  Widget build(BuildContext context) {
    if (timeInApp == null || timeInApp!.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 42.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(fontSize: 14, height: 1.4),
          children: [
            const TextSpan(
              text: 'Du bist in Mathe App ',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: timeInApp,
              style: const TextStyle(
                color: AppColors.primaryPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
