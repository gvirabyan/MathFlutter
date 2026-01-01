import 'package:flutter/material.dart';
import '../../services/user_stats_service.dart';
import '../../ui_elements/gauge_circle.dart';

class AnswersTab extends StatefulWidget {
  const AnswersTab({super.key});

  @override
  State<AnswersTab> createState() => _AnswersTabState();
}

class _AnswersTabState extends State<AnswersTab> {
  final UserStatsService _service = UserStatsService();

  bool isLoading = true;

  // ✅ как в Pinia: структура есть сразу
  Map<String, dynamic> answersStats = UserStatsService.defaultAnswersStats();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => isLoading = true);

    try {
      final res = await _service.getAnswersStats();
      debugPrint('✅ get-answers-stats parsed: $res');

      if (mounted) {
        setState(() {
          answersStats = Map<String, dynamic>.from(res);
        });
      }

    } catch (e, s) {
      debugPrint('❌ getAnswersStats error: $e');
      debugPrintStack(stackTrace: s);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }


  int _int(dynamic v) => int.tryParse(v?.toString() ?? '0') ?? 0;
  double _double(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0;

  Widget _gauge({
    required double percent,
    required int value,
    required String label,
    required Color color,
  }) {
    return GaugeCircle(
      percent: percent,
      color: color,
      size: 200,
      strokeWidth: 11,
      top: Text(
        '${percent.toInt()}%',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      middle: Text(
        value.toString(),
        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
      ),
      bottom: SizedBox(
        width: 160,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final totalPercent = _double(answersStats['answers_percent']);
    final totalCount = _int(answersStats['answers_count']);
    final totalQuestions = _int(answersStats['questions_count']);

    final correctPercent = _double(answersStats['correct_answers']?['percent']);
    final correctCount = _int(answersStats['correct_answers']?['count']);

    final wrongPercent = _double(answersStats['wrong_answers']?['percent']);
    final wrongCount = _int(answersStats['wrong_answers']?['count']);

    final skippedPercent = _double(answersStats['skipped_answers']?['percent']);
    final skippedCount = _int(answersStats['skipped_answers']?['count']);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Text(
            'Zusammenfassung',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          if (answersStats['last_update'] != null)
            Text(
              'Letztes Update:${answersStats['last_update']}',
              style: const TextStyle(color: Colors.black,fontSize: 12),
            ),
          const SizedBox(height: 32),

          _gauge(
            percent: totalPercent,
            value: totalCount,
            label: 'von $totalQuestions Beantwortete Fragen',
            color: const Color(0xFF8419FF),
          ),
          const SizedBox(height: 40),

          _gauge(
            percent: correctPercent,
            value: correctCount,
            label: 'Richtige Antworten',
            color: const Color(0xFF2EE56B),
          ),
          const SizedBox(height: 40),

          _gauge(
            percent: wrongPercent,
            value: wrongCount,
            label: 'Falsche Antworten',
            color: Colors.red,
          ),
          const SizedBox(height: 40),

          _gauge(
            percent: skippedPercent,
            value: skippedCount,
            label: 'Übersprungene Antworten',
            color: const Color(0xFF777481),
          ),
        ],
      ),
    );
  }
}
