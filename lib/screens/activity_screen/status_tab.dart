import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/services/auth_service.dart';
import '../../services/user_stats_service.dart';

class StatusTab extends StatefulWidget {
  const StatusTab({super.key});

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
    setState(() => isLoading = true);

    try {
      final status = await _userStatsService.getUserStatus();

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
      }
    } finally {
      if (mounted) setState(() => disableSelect = false);
    }
  }

  Future<void> _loadDailyGoalFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    dailyGoal = prefs.getInt('daily_goal') ?? 0;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),

          _DailyGoal(
            value: dailyGoal,
            disabled: disableSelect,
            onChanged: setGoal,
          ),

          const SizedBox(height: 24),

          _LastQuiz(lastQuiz: lastQuiz),

          const SizedBox(height: 32),

          if (dailyStatics.isNotEmpty)
            _TodayActivity(
              amount: amountAnswered,
              correct: stat("correct")["count"],
              skipped: stat("skipped")["count"],
              wrong: stat("wrong")["count"],
              percentCorrect: stat("correct")["percent"],
            ),

          const SizedBox(height: 20),

          _PointsSection(points: points, lastUpdate: lastUpdate),

          if (pastCategoriesCount > 0 && categoriesCount > 0) ...[
            const SizedBox(height: 32),
            Text(
              'Vergangene Kategorien',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('$pastCategoriesCount von $categoriesCount'),
            Text(
              '${pastCategoriesPercent.toStringAsFixed(0)} %',
              style: const TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],

          const SizedBox(height: 40),

          _FooterText(timeInApp: timeInApp),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

/* ================= DAILY GOAL ================= */

class _DailyGoal extends StatelessWidget {
  final int value;
  final bool disabled;
  final ValueChanged<int> onChanged;

  const _DailyGoal({
    required this.value,
    required this.disabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tägliches Ziel setzen'),
          DropdownButton<int>(
            value: value == 0 ? null : value,
            isExpanded: true,
            onChanged: disabled ? null : (v) => onChanged(v!),
            items: const [
              DropdownMenuItem(value: 10, child: Text('10 Fragen')),
              DropdownMenuItem(value: 20, child: Text('20 Fragen')),
              DropdownMenuItem(value: 30, child: Text('30 Fragen')),
              DropdownMenuItem(value: 40, child: Text('40 Fragen')),
            ],
          ),
        ],
      ),
    );
  }
}

/* ================= LAST QUIZ ================= */

class _LastQuiz extends StatelessWidget {
  final Map<String, dynamic>? lastQuiz;

  const _LastQuiz({required this.lastQuiz});

  @override
  Widget build(BuildContext context) {
    if (lastQuiz == null || lastQuiz!["lastCategory"] == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const Text(
          'Letztes Quiz',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(lastQuiz!["lastCategory"]["name"] ?? ''),
        Text(
          '${lastQuiz!["answeredQuestions"]} / ${lastQuiz!["totalQuestions"]}',
          style: const TextStyle(color: Colors.purple),
        ),
      ],
    );
  }
}

/* ================= TODAY ACTIVITY ================= */

class _TodayActivity extends StatelessWidget {
  final int amount;
  final int correct;
  final int skipped;
  final int wrong;
  final double percentCorrect;

  const _TodayActivity({
    required this.amount,
    required this.correct,
    required this.skipped,
    required this.wrong,
    required this.percentCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Heutige Aktivität',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: 220,
          height: 160,
          child: CustomPaint(
            painter: _OpenCirclePainter(
              percent: percentCorrect,
              gapDegrees: 50,
              color: Colors.green,
              strokeWidth: 10,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$amount',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Richtig $correct',
                    style: const TextStyle(color: Colors.green),
                  ),
                  Text('Übersprungen $skipped'),
                  Text(
                    'Falsch $wrong',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _CheckProgressButton(
          onTap: () {
            DefaultTabController.of(context).animateTo(1);
          },
        ),
      ],
    );
  }
}

/* ================= POINTS (SECOND CIRCLE) ================= */

class _CheckProgressButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CheckProgressButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: const Text(
        'Fortschritt prüfen',
        style: TextStyle(
          color: Colors.purple,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _PointsSection extends StatelessWidget {
  final int points;
  final String? lastUpdate;

  const _PointsSection({required this.points, required this.lastUpdate});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Punkte',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (lastUpdate != null)
          Text(
            'Letztes Update: $lastUpdate',
            style: const TextStyle(color: Colors.black54),
          ),
        const SizedBox(height: 20),
        SizedBox(
          width: 190,
          height: 190,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(190, 190),
                painter: _OpenCirclePainter(
                  percent: 100,
                  gapDegrees: 0,
                  color: const Color(0xFFEDE7FF),
                  strokeWidth: 10,
                ),
              ),
              Text(
                '$points',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/* ================= FOOTER ================= */

class _FooterText extends StatelessWidget {
  final String? timeInApp;

  const _FooterText({required this.timeInApp});

  @override
  Widget build(BuildContext context) {
    if (timeInApp == null || timeInApp!.isEmpty) return const SizedBox.shrink();

    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(
            text: 'Du bist in Mathe App ',
            style: TextStyle(color: Colors.black),
          ),
          TextSpan(
            text: timeInApp,
            style: const TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= PAINTER ================= */

class _OpenCirclePainter extends CustomPainter {
  final double percent;
  final double gapDegrees;
  final Color color;
  final double strokeWidth;

  _OpenCirclePainter({
    required this.percent,
    required this.gapDegrees,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2 - strokeWidth;
    final center = Offset(size.width / 2, size.height / 2);

    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);

    final gap = gapDegrees * math.pi / 180;
    final sweep = (2 * math.pi - gap) * (percent / 100);
    final start = math.pi / 2 + gap / 2;

    canvas.drawArc(rect, start, sweep, false, paint);
  }

  @override
  bool shouldRepaint(covariant _OpenCirclePainter old) =>
      old.percent != percent ||
      old.gapDegrees != gapDegrees ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}
