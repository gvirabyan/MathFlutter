import 'package:flutter/material.dart';

import '../../app_colors.dart';
import '../../ui_elements/math_content.dart';
import '../../ui_elements/primary_button.dart';

class PracticeQuizQuestionView extends StatefulWidget {
  final bool submitted;
  final int currentIndex;
  final int total;
  final int myPoints;
  final int machinePoints;
  final String rivalLabel;
  final String title;
  final String question;
  final List<String> answers;
  final int? correctAnswerIndex;
  final int secondsLeft;
  final int? selectedIndex;
  final List<bool?> results;
  final void Function(int index)? onSelect;
  final VoidCallback? onSubmit;
  final VoidCallback? onNext;

  const PracticeQuizQuestionView({
    super.key,
    required this.submitted,
    required this.currentIndex,
    required this.total,
    required this.myPoints,
    required this.machinePoints,
    this.rivalLabel = 'Punkte der Mas...',
    required this.title,
    required this.question,
    required this.answers,
    this.correctAnswerIndex,
    required this.secondsLeft,
    required this.selectedIndex,
    required this.results,
    required this.onSelect,
    required this.onSubmit,
    required this.onNext,
  });

  @override
  State<PracticeQuizQuestionView> createState() =>
      _PracticeQuizQuestionViewState();
}

class _PracticeQuizQuestionViewState extends State<PracticeQuizQuestionView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Скроллим к текущему индексу при старте
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToIndex(widget.currentIndex),
    );
  }

  @override
  void didUpdateWidget(PracticeQuizQuestionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Скроллим автоматически, если индекс изменился (перешли к следующему вопросу)
    if (oldWidget.currentIndex != widget.currentIndex) {
      _scrollToIndex(widget.currentIndex);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToIndex(int index) {
    if (_scrollController.hasClients) {
      const double itemWidth = 64.0;
      const double spacing = 1.0;
      // Вычисляем смещение так, чтобы текущий кружок был по центру
      final double targetOffset =
          (index * (itemWidth + spacing)) -
          (_scrollController.position.viewportDimension / 2) +
          (itemWidth / 2);

      _scrollController.animateTo(
        targetOffset.clamp(0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: Text(
                "Spieler против Maschine",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 18),
                const SizedBox(width: 6),
                Text(
                  '0:${widget.secondsLeft.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 32),
          // Кружки
          SizedBox(
            height: 44,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: widget.total,
              separatorBuilder: (_, __) => const SizedBox(width: 1),
              itemBuilder: (context, i) {
                final bool? res =
                    (i < widget.results.length) ? widget.results[i] : null;
                final isCurrent = i == widget.currentIndex;

                Color borderColor = Colors.grey.shade300;
                Color backgroundColor = Colors.transparent;
                Color textColor = Colors.black38;

                if (isCurrent) {
                  backgroundColor = Colors.black;
                  borderColor = Colors.black;
                  textColor = Colors.white;
                } else if (res == true) {
                  borderColor = AppColors.greenCorrect;
                  textColor = AppColors.greenCorrect;
                } else if (res == false) {
                  borderColor = AppColors.redWrong;
                  textColor = AppColors.redWrong;
                }

                return Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: backgroundColor,
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
          ),
          const SizedBox(height: 20),
          // Баллы
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildPointBox(
                  'Deine Punkte: ${widget.myPoints}',
                  AppColors.primaryPurple,
                  Colors.white,
                  false,
                ),
                const SizedBox(width: 10),
                _buildPointBox(
                  '${widget.rivalLabel} ${widget.machinePoints}',
                  Colors.white,
                  AppColors.primaryPurple,
                  true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
          ),
          const SizedBox(height: 22),
          // Вопрос
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                MathContent(
                  content: widget.question,
                  isQuestion: true,
                  fontSize: 32,
                ),
              ],
            ),
          ),
          const SizedBox(height: 34),
          // Ответы
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.answers.length,
              itemBuilder: (context, i) {
                final selected = widget.selectedIndex == i;
                final isCorrect = widget.correctAnswerIndex == i;

                Color? cardBg;
                Color? borderCol;
                Color contentColor = Colors.black;

                if (widget.submitted && widget.correctAnswerIndex != null) {
                  if (isCorrect) {
                    cardBg = AppColors.greenCorrect;
                    borderCol = AppColors.greenCorrect;
                    contentColor = Colors.white;
                  } else if (selected) {
                    cardBg = AppColors.redWrong;
                    borderCol = AppColors.redWrong;
                    contentColor = Colors.white;
                  } else {
                    borderCol = Colors.grey.shade300;
                  }
                } else if (selected) {
                  cardBg = AppColors.primaryPurple;
                  borderCol = AppColors.primaryPurple;
                  contentColor = Colors.white;
                } else {
                  borderCol = Colors.grey.shade300;
                }

                return GestureDetector(
                  onTap: () => widget.onSelect?.call(i),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardBg ?? Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: borderCol ?? Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 25,
                          child: Text(
                            String.fromCharCode('a'.codeUnitAt(0) + i) + '.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                              height: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4.5),
                            child: MathContent(
                              content: widget.answers[i],
                              fontSize: 18,
                              color: contentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Кнопка
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: PrimaryButton(
              color: AppColors.primaryYellow,
              text: widget.submitted ? 'nächstes' : 'abgeben',
              enabled: widget.submitted || widget.selectedIndex != null,
              onPressed: widget.submitted ? widget.onNext : widget.onSubmit,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointBox(
    String text,
    Color bg,
    Color textColor,
    bool hasBorder,
  ) {
    return Expanded(
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: hasBorder ? Border.all(color: AppColors.primaryPurple) : null,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
