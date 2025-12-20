import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/user_stats_service.dart';

class ProgressTab extends StatefulWidget {
  const ProgressTab({super.key});

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
  final UserStatsService _userStatsService = UserStatsService();

  bool isLoading = true;
  String unitOfTime = 'week'; // week | month
  DateTime currentDate = DateTime.now();

  String startDay = '';
  String endDay = '';

  Map<String, dynamic> userProgress = {};
  List<String> days = [];

  int amountLargest = 0;
  int topValueOfAmount = 0;

  @override
  void initState() {
    super.initState();
    _updateProgress();
  }

  /* ================= DATE HELPERS ================= */

  DateTime _startOfWeek(DateTime d) =>
      d.subtract(Duration(days: d.weekday - 1));

  DateTime _endOfWeek(DateTime d) =>
      _startOfWeek(d).add(const Duration(days: 6));

  DateTime _startOfMonth(DateTime d) =>
      DateTime(d.year, d.month, 1);

  DateTime _endOfMonth(DateTime d) =>
      DateTime(d.year, d.month + 1, 0);

  String _fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  /* ================= LOAD DATA ================= */

  Future<void> _updateProgress() async {
    setState(() {
      isLoading = true;
      userProgress = {};
      amountLargest = 0;
      topValueOfAmount = 0;
    });

    final start = unitOfTime == 'week'
        ? _startOfWeek(currentDate)
        : _startOfMonth(currentDate);

    final end = unitOfTime == 'week'
        ? _endOfWeek(currentDate)
        : _endOfMonth(currentDate);

    startDay = _fmt(start);
    endDay = _fmt(end);

    final sendingEnd =
    _fmt(end.add(const Duration(days: 1)));

    final data =
    await _userStatsService.getProgressByDays(startDay, sendingEnd);

    userProgress = data;

    days = [];
    DateTime d = start;
    while (!d.isAfter(end)) {
      days.add(_fmt(d));
      d = d.add(const Duration(days: 1));
    }

    setState(() => isLoading = false);
  }

  /* ================= CALCULATIONS ================= */

  int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  int getCountByStatus(String status) {
    int total = 0;
    for (final day in userProgress.values) {
      total += _parseInt(day[status]);
    }
    return total;
  }

  double getAnsweredPercent(String day, String status) {
    if (!userProgress.containsKey(day) ||
        userProgress[day][status] == null) {
      return 0;
    }

    int amount = 0;
    for (final v in userProgress[day].values) {
      amount += _parseInt(v);
    }

    if (amountLargest < amount) {
      amountLargest = amount;
    }

    topValueOfAmount =
        amountLargest + 5 - (amountLargest % 5);

    return (_parseInt(userProgress[day][status]) * 35) /
        (topValueOfAmount == 0 ? 1 : topValueOfAmount);
  }

  int scaleNumber(int i) =>
      topValueOfAmount -
          ((topValueOfAmount * (i - 1)) ~/ 5);

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _weekMonthSwitch(),
          const SizedBox(height: 24),
          _diagram(),
          const SizedBox(height: 24),
          _infoBlock(),
          const SizedBox(height: 24),
          _navButtons(),
        ],
      ),
    );
  }

  /* ================= TOP SWITCH ================= */

  Widget _weekMonthSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _switchItem('Woche', unitOfTime == 'week', () {
          unitOfTime = 'week';
          currentDate = DateTime.now();
          _updateProgress();
        }),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('/', style: TextStyle(fontSize: 18)),
        ),
        _switchItem('Monat', unitOfTime == 'month', () {
          unitOfTime = 'month';
          currentDate = DateTime.now();
          _updateProgress();
        }),
      ],
    );
  }

  Widget _switchItem(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.purple,
          decoration:
          active ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
    );
  }

  /* ================= DIAGRAM ================= */

  Widget _diagram() {
    return SizedBox(
      height: 320,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _yScale(),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                _barsDiagram(),
                _xScale(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _yScale() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (i) {
        return Text(
          scaleNumber(i + 1).toString(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        );
      }),
    );
  }

  Widget _barsDiagram() {
    final gap = unitOfTime == 'week' ? 10.0 : 3.0;

    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: days.map((day) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: gap / 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _bar(day, 'wrong', Colors.red),
                  _bar(day, 'skipped', Colors.grey),
                  _bar(day, 'correct', Colors.green),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _bar(String day, String status, Color color) {
    final h = getAnsweredPercent(day, status);
    if (h == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: h,
      margin: const EdgeInsets.only(bottom: 1),
      color: color,
    );
  }

  Widget _xScale() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(startDay, style: const TextStyle(fontSize: 12)),
          Text(endDay, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  /* ================= INFO BLOCK ================= */

  Widget _infoBlock() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _legendItem('Richtig', Colors.green,
            getCountByStatus('correct')),
        _legendItem('Übersprungen', Colors.grey,
            getCountByStatus('skipped')),
        _legendItem('Falsch', Colors.red,
            getCountByStatus('wrong')),
      ],
    );
  }

  Widget _legendItem(String label, Color color, int value) {
    return Column(
      children: [
        Row(
          children: [
            Container(width: 12, height: 12, color: color),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /* ================= NAV BUTTON ================= */

  Widget _navButtons() {
    return TextButton(
      onPressed: () {
        currentDate =
            DateTime(currentDate.year, currentDate.month - 1, 1);
        _updateProgress();
      },
      child: const Text(
        'Zurück Monat',
        style: TextStyle(
          fontSize: 18,
          color: Colors.purple,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
