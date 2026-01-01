import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untitled2/app_colors.dart';
import 'package:untitled2/services/auth_service.dart';

import '../../services/user_stats_service.dart';



class ProgressTab extends StatefulWidget {
  const ProgressTab({super.key});

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
  final UserStatsService _userStatsService = UserStatsService();

  int? selectedIndex;


  bool isLoading = true;
  String? selectedDay;

  /// week | month
  String unitOfTime = 'week';
  DateTime currentDate = DateTime.now();

  /// registration date (from backend)
  DateTime? registeredAt;

  String startDay = '';
  String endDay = '';

  Map<String, dynamic> userProgress = {};
  List<String> days = [];

  int amountLargest = 0;
  int topValueOfAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadRegistrationDate();
    _updateProgress();
  }

  /* ================= DATE HELPERS ================= */

  DateTime _startOfWeek(DateTime d) =>
      d.subtract(Duration(days: d.weekday - 1));

  DateTime _endOfWeek(DateTime d) =>
      _startOfWeek(d).add(const Duration(days: 6));

  DateTime _startOfMonth(DateTime d) => DateTime(d.year, d.month, 1);

  DateTime _endOfMonth(DateTime d) => DateTime(d.year, d.month + 1, 0);

  String _fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  bool _isSameWeek(DateTime a, DateTime b) {
    final sa = _startOfWeek(a);
    final sb = _startOfWeek(b);
    return sa.year == sb.year && sa.month == sb.month && sa.day == sb.day;
  }

  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  /* ================= PERIOD CHECKS ================= */

  bool get isAtCurrentPeriod {
    final now = DateTime.now();

    if (unitOfTime == 'week') {
      return _isSameWeek(currentDate, now);
    }

    return _isSameMonth(currentDate, now);
  }

  bool get isAtFirstPeriod {
    if (registeredAt == null) return false;

    if (unitOfTime == 'week') {
      return _isSameWeek(currentDate, registeredAt!);
    }

    return _isSameMonth(currentDate, registeredAt!);
  }

  /* ================= LOAD USER ================= */

  Future<void> _loadRegistrationDate() async {
    final res = await AuthService.getUser();

    if (res['status'] == 'success' && res['user']['createdAt'] != null) {
      registeredAt = DateTime.parse(res['user']['createdAt']);
      setState(() {});
    }
  }

  /* ================= LOAD DATA ================= */

  Future<void> _updateProgress() async {
    setState(() {
      isLoading = true;
      userProgress = {};
      amountLargest = 0;
      topValueOfAmount = 0;
    });

    final start =
        unitOfTime == 'week'
            ? _startOfWeek(currentDate)
            : _startOfMonth(currentDate);

    final end =
        unitOfTime == 'week'
            ? _endOfWeek(currentDate)
            : _endOfMonth(currentDate);

    startDay = _fmt(start);
    endDay = _fmt(end);

    /// Vue logic: end + 1 day
    final sendingEnd = _fmt(end.add(const Duration(days: 1)));

    final data = await _userStatsService.getProgressByDays(
      startDay,
      sendingEnd,
    );

    userProgress = data;

    days = [];
    DateTime d = start;
    while (!d.isAfter(end)) {
      days.add(_fmt(d));
      d = d.add(const Duration(days: 1));
    }

    _prepareScaleValues();
    setState(() => isLoading = false);
  }

  void _prepareScaleValues() {
    amountLargest = 0;

    for (final day in days) {
      final data = userProgress[day];
      if (data == null) continue;

      int amount = 0;
      for (final v in data.values) {
        amount += _parseInt(v);
      }

      if (amount > amountLargest) {
        amountLargest = amount;
      }
    }

    /// Vue logic: max + (5 - max % 5)
    topValueOfAmount =
        amountLargest == 0 ? 0 : amountLargest + 5 - (amountLargest % 5);
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
        userProgress[day][status] == null ||
        topValueOfAmount == 0) {
      return 0;
    }

    /// EXACT Vue logic: (value * 35) / topValue
    return (_parseInt(userProgress[day][status]) * 35) / topValueOfAmount;
  }

  int scaleNumber(int i) =>
      topValueOfAmount - ((topValueOfAmount * (i - 1)) ~/ 5);

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
          if (selectedDay != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('dd-MM-yyyy').format(DateTime.parse(selectedDay!)),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _miniStat(
                          'Richtig',
                          AppColors.greenCorrect,
                          userProgress[selectedDay!]?['correct'],
                        ),
                        _miniStat(
                          'Übersprungen',
                          Colors.grey,
                          userProgress[selectedDay!]?['skipped'],
                        ),
                        _miniStat(
                          'Falsch',
                          AppColors.redWrong,
                          userProgress[selectedDay!]?['wrong'],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
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
        _periodSwitchItem('Woche', unitOfTime == 'week', () {
          unitOfTime = 'week';
          currentDate = DateTime.now();
          _updateProgress();
        }),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '/',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _periodSwitchItem('Monat', unitOfTime == 'month', () {
          unitOfTime = 'month';
          currentDate = DateTime.now();
          _updateProgress();
        }),
      ],
    );
  }

  Widget _periodSwitchItem(
      String text,
      bool active,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: active ? 40 : 0,
            decoration: BoxDecoration(
              color: AppColors.primaryPurple,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }


  /* ================= DIAGRAM ================= */

  Widget _diagram() {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxBarHeight = screenHeight * 0.35;

    const double yScaleWidth = 40;
    const double axisThickness = 3;
    const double xScaleHeight = 24;

    return SizedBox(
      height: maxBarHeight + xScaleHeight + 16,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ================= CONTENT =================
          Padding(
            padding: const EdgeInsets.only(left: yScaleWidth + 8),
            child: Column(
              children: [
                SizedBox(
                  height: maxBarHeight,
                  child: _barsDiagram(maxBarHeight),
                ),
                const SizedBox(height: 8),
                _xScale(),
              ],
            ),
          ),

          // ================= Y SCALE =================
          Positioned(
            left: 0,
            top: 0,
            height: maxBarHeight,
            child: _yScale(maxBarHeight, yScaleWidth),
          ),

          // ================= Y AXIS =================
          Positioned(
            left: yScaleWidth,
            top: 0,
            height: maxBarHeight,
            child: Container(
              width: axisThickness,
              color: Colors.black,
            ),
          ),

          // ================= X AXIS =================
          Positioned(
            left: yScaleWidth,
            right: 0,
            top: maxBarHeight,
            child: Container(
              height: axisThickness,
              color: Colors.black,
            ),
          ),

          // ================= TOOLTIP =================
          if (selectedIndex != null) _buildTooltip(maxBarHeight),
        ],
      ),
    );
  }


  Widget _buildTooltip(double maxBarHeight) {
    final day = days[selectedIndex!];
    final data = userProgress[day] ?? {};


    return Positioned(
      bottom: 60, // Высота над датами
      left:
          48 +
          (selectedIndex! *
              (MediaQuery.of(context).size.width - 48 - 48) /
              days.length),
      child: FractionalTranslation(
        translation: const Offset(-0.3, 0),
        // Немного центрируем относительно бара
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1),
            ],
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _tooltipPoint(AppColors.greenCorrect, _parseInt(data['correct'])),
                  const SizedBox(width: 8),
                  _tooltipPoint(Colors.grey, _parseInt(data['skipped'])),
                  const SizedBox(width: 8),
                  _tooltipPoint(AppColors.redWrong, _parseInt(data['wrong'])),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd.MM.yyyy').format(DateTime.parse(day)),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tooltipPoint(Color color, int value) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$value',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _yScale(double height, double width) {
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(6, (i) {
          final value = topValueOfAmount - (topValueOfAmount * i ~/ 5);
          return Text(
            "$value ",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          );
        }),
      ),
    );
  }

  Widget _barsDiagram(double maxBarHeight) {
    final gap = unitOfTime == 'week' ? 12.0 : 2.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(days.length, (index) {
        final day = days[index];
        return Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                // Если нажали на тот же — закрываем, иначе открываем новый
                selectedIndex = (selectedIndex == index) ? null : index;
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: gap / 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _bar(day, 'correct', AppColors.greenCorrect, maxBarHeight),
                  _bar(day, 'skipped', Colors.grey, maxBarHeight),
                  _bar(day, 'wrong', AppColors.redWrong, maxBarHeight),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _xScale() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Добавляем оформление датам, чтобы они не "висели" в воздухе
          _dateLabel(startDay),
          _dateLabel(endDay),
        ],
      ),
    );
  }

  Widget _dateLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _bar(String day, String status, Color color, double maxBarHeight) {
    final hPercent = getAnsweredPercent(day, status);
    if (hPercent == 0) return const SizedBox.shrink();

    final h = (hPercent / 35) * maxBarHeight;

    return Container(
      width: double.infinity,
      height: h,
      margin: const EdgeInsets.only(bottom: 1),
      color: color,
    );
  }

  /* ================= INFO BLOCK ================= */

  Widget _infoBlock() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _legendItem('Richtig', AppColors.greenCorrect, getCountByStatus('correct')),
        _legendItem('Übersprungen', Colors.grey, getCountByStatus('skipped')),
        _legendItem('Falsch',AppColors.redWrong, getCountByStatus('wrong')),
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
            color: color,
          ),
        ),
      ],
    );
  }

  /* ================= NAV ================= */

  Widget _navButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (isAtFirstPeriod && registeredAt != null)
          Text(
            'Du hast dich registriert am '
            '${DateFormat('yyyy-MM-dd').format(registeredAt!)}',
            style: const TextStyle(fontSize: 14, color: Colors.black),
          )
        else
          TextButton(
            onPressed: () {
              if (unitOfTime == 'week') {
                currentDate = currentDate.subtract(const Duration(days: 7));
              } else {
                currentDate = DateTime(
                  currentDate.year,
                  currentDate.month - 1,
                  1,
                );
              }
              _updateProgress();
            },
            child: Text(
              'Zurück ${unitOfTime == 'week' ? 'Woche' : 'Monat'}',
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.primaryPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (!isAtCurrentPeriod)
          TextButton(
            onPressed: () {
              if (unitOfTime == 'week') {
                currentDate = currentDate.add(const Duration(days: 7));
              } else {
                currentDate = DateTime(
                  currentDate.year,
                  currentDate.month + 1,
                  1,
                );
              }
              _updateProgress();
            },
            child: Text(
              'Nächste ${unitOfTime == 'week' ? 'Woche' : 'Monat'}',
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.primaryPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _miniStat(String label, Color color, dynamic value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: color)),
        Text(
          "${_parseInt(value)}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
