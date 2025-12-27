import 'dart:math' as math;
import 'package:flutter/material.dart';
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
  bool showSuccess = false;

  int dailyGoal = 0;
  int points = 0;

  // 🔽 backend driven
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
    _loadUserStatus();
  }

  Future<void> _loadUserStatus() async {
    setState(() => isLoading = true);

    try {
      final status = await _userStatsService.getUserStatus();

      setState(() {
        dailyStatics =
        List<Map<String, dynamic>>.from(status["daily_statics"] ?? []);
        points = _parseInt(status["points"]);

        // ✅ agreed changes
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

  int get amountAnswered {
    return dailyStatics.fold(0, (sum, e) {
      return sum + _parseInt(e["count"]);
    });
  }

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

    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      dailyGoal = value;
      showSuccess = true;
      disableSelect = false;
    });
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

          _TodayActivity(
            amount: amountAnswered,
            correct: stat("correct")["count"],
            skipped: stat("skipped")["count"],
            wrong: stat("wrong")["count"],
            percentCorrect: stat("correct")["percent"],
          ),

          const SizedBox(height: 24),

          _CheckProgressButton(onTap: () {}),

          const SizedBox(height: 32),

          _PointsSection(
            points: points,
            lastUpdate: lastUpdate,
          ),

          if (pastCategoriesCount > 0 && categoriesCount > 0) ...[
            const SizedBox(height: 32),
            Column(
              children: [
                const Text(
                  'Vergangene Kategorien',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text('$pastCategoriesCount von $categoriesCount'),
                const SizedBox(height: 6),
                Text(
                  '${pastCategoriesPercent.toStringAsFixed(0)} %',
                  style: const TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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

/* ================= DAILY GOAL (UNTOUCHED) ================= */

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
          const Text(
            'Tägliches Ziel setzen',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          DropdownButton<int>(
            value: value == 0 ? null : value,
            hint: const Text('Ziel auswählen'),
            isExpanded: true,
            onChanged: disabled ? null : (v) => onChanged(v!),
            items: const [
              DropdownMenuItem(value: 10, child: Text('10 Fragen')),
              DropdownMenuItem(value: 20, child: Text('20 Fragen')),
              DropdownMenuItem(value: 30, child: Text('30 Fragen')),
              DropdownMenuItem(value: 40, child: Text('40 Fragen')),
            ],
          ),
          const Divider(),
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

    final category = lastQuiz!["lastCategory"];
    final name = category["name"] ?? "";
    final answered = lastQuiz!["answeredQuestions"] ?? 0;
    final total = lastQuiz!["totalQuestions"] ?? 0;

    return Column(
      children: [
        const Text(
          'Letztes Quiz',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(name),
        const SizedBox(height: 6),
        Text(
          '$answered / $total',
          style: const TextStyle(
            color: Colors.purple,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/* ================= TODAY ACTIVITY (UNTOUCHED) ================= */

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
        const SizedBox(height: 20),
        SizedBox(
          width: 220,
          height: 160,
          child: CustomPaint(
            painter: _OpenCirclePainter(percentCorrect, gapDegrees: 50),
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
                  const SizedBox(height: 8),
                  Text('Richtig $correct',
                      style: const TextStyle(color: Colors.green)),
                  Text('Übersprungen $skipped'),
                  Text('Falsch $wrong',
                      style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/* ================= PAINTER ================= */

class _OpenCirclePainter extends CustomPainter {
  final double percent;
  final double gapDegrees;

  _OpenCirclePainter(this.percent, {this.gapDegrees = 50});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 10.0;

    final bg = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fg = Paint()
      ..color = Colors.purple
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final padding = stroke / 2 + 10;
    final diameter = math.min(size.width, size.height) - padding * 2;

    final rect = Rect.fromLTWH(
      (size.width - diameter) / 2,
      (size.height - diameter) / 2,
      diameter,
      diameter,
    );

    final gap = gapDegrees * math.pi / 180.0;
    final totalSweep = 2 * math.pi - gap;
    final startAngle = math.pi / 2 + gap / 2;

    final p = (percent / 100.0).clamp(0.0, 1.0);

    canvas.drawArc(rect, startAngle, totalSweep, false, bg);
    canvas.drawArc(rect, startAngle, totalSweep * p, false, fg);
  }

  @override
  bool shouldRepaint(covariant _OpenCirclePainter oldDelegate) {
    return oldDelegate.percent != percent ||
        oldDelegate.gapDegrees != gapDegrees;
  }
}

/* ================= BUTTON ================= */

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

/* ================= POINTS ================= */

class _PointsSection extends StatelessWidget {
  final int points;
  final String? lastUpdate;

  const _PointsSection({
    required this.points,
    required this.lastUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Punkte',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (lastUpdate != null) ...[
          const SizedBox(height: 6),
          Text(
            'Letztes Update: $lastUpdate',
            style: const TextStyle(color: Colors.black54),
          ),
        ],
        const SizedBox(height: 20),
        CircleAvatar(
          radius: 60,
          backgroundColor: const Color(0xFFF2ECFF),
          child: Text(
            '$points',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
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
    if (timeInApp == null || timeInApp!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      'Du bist in Mathe App $timeInApp',
      style: const TextStyle(
        color: Colors.purple,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
