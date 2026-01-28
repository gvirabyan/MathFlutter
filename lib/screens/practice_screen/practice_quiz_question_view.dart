import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../app_colors.dart';
import '../../ui_elements/dialogs/cancel_practice_quiz_dialog.dart';
import '../../ui_elements/practice_math_content.dart';
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
  final String appBarTitle;
  final List<String> answers;
  final int? correctAnswerIndex;
  final int secondsLeft;
  final int? selectedIndex;
  final List<bool?> results;
  final void Function(int index)? onSelect;
  final VoidCallback? onSubmit;
  final VoidCallback? onNext;
  final int? machineSelectedIndex;
  final bool showAnswerLoading;

  const PracticeQuizQuestionView({
    super.key,
    required this.submitted,
    required this.currentIndex,
    required this.total,
    required this.myPoints,
    required this.appBarTitle,
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
    this.machineSelectedIndex,
    required this.showAnswerLoading,
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
    final bool showThinkingText =
        !widget.submitted &&
            widget.secondsLeft > 52 &&
            widget.rivalLabel != 'Punkte der Mas...';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            final result = await CancelPracticeQuizDialog.show(context);
            if (result == true && context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                widget.appBarTitle,
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
        flexibleSpace: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0, // Прижато к правому краю
              bottom: 0,
              child: Opacity(
                opacity: 0.3, // Растянуто по высоте
                child: SvgPicture.asset(
                  'assets/pics_for_buttons/pointsRight.svg',
                  fit: BoxFit.cover, // Или BoxFit.fitHeight
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 20),
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

          showThinkingText
              ? Center(
            child: Text(
              "${widget.rivalLabel} denkt gerade ...",
              style: TextStyle(
                color: Colors.black,
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
            ),
          )
              : const SizedBox(height: 20),

          // Если условие неверно, место остается пустым, но высота сохраняется
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
          ),
          const SizedBox(height: 20),
          // Вопрос
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // --- Заголовок и Вопрос теперь внутри скролла ---
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: MathContent(
                    content: widget.question,
                    isQuestion: true,
                    fontSize: 10,
                  ),),
                const SizedBox(height: 32),
                Stack(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      // Обнуляем, так как padding уже есть у родителя
                      itemCount: widget.answers.length,
                      itemBuilder: (context, i) {
                        final selected = widget.selectedIndex == i;
                        final isCorrect = widget.correctAnswerIndex == i;
                        final isMachineSelected = widget.machineSelectedIndex == i;
                        Color? machineBorderColor;
                        double borderWidth = 1.5;

                        Color? cardBg;
                        Color? borderCol;
                        Color contentColor = Colors.black;

                        if (widget.submitted && isMachineSelected) {
                          machineBorderColor =
                          (i == widget.correctAnswerIndex)
                              ? AppColors.greenCorrect
                              : AppColors.redWrong;
                          borderWidth = 3.0;
                        }

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

                        List<BoxShadow>? externalBorders;
                        if (widget.submitted && isMachineSelected) {
                          externalBorders = [
                            const BoxShadow(
                              color: AppColors.primaryYellow,
                              spreadRadius: 3,
                              blurRadius: 0,
                            ),
                          ];
                        }

                        final bool showDoubleBorder =
                            widget.submitted &&
                                widget.machineSelectedIndex != null &&
                                isMachineSelected &&
                                cardBg != null;

                        return GestureDetector(
                          onTap: () => widget.onSelect?.call(i),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration:
                            showDoubleBorder
                                ? BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                (i == widget.correctAnswerIndex)
                                    ? AppColors.greenCorrect
                                    : AppColors.redWrong,
                                width: 2.0,
                              ),
                            )
                                : null,
                            padding:
                            showDoubleBorder
                                ? const EdgeInsets.all(4.0)
                                : EdgeInsets.zero,
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 60),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: cardBg ?? Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                  machineBorderColor ??
                                      borderCol ??
                                      Colors.grey.shade300,
                                  width: borderWidth,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 25,
                                    child: Text(
                                      String.fromCharCode('a'.codeUnitAt(0) + i) +
                                          '.',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: contentColor.withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: MathContent(
                                      content: widget.answers[i],
                                      fontSize: 22,
                                      color: contentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    if (widget.showAnswerLoading)
                      Positioned.fill(
                        child: AbsorbPointer(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                color: Colors.white.withOpacity(0.2),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryPurple,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: PrimaryButton(
              fontSize: 18,
              color: AppColors.primaryYellow,
              text: widget.submitted ? 'nächstes' : 'abgeben',
              enabled: (widget.submitted || widget.selectedIndex != null) &&
                  !widget.showAnswerLoading,
              isLoading: false,
              onPressed: widget.submitted ? widget.onNext : widget.onSubmit,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointBox(String text,
      Color bg,
      Color textColor,
      bool hasBorder,) {
    return Expanded(
      child: Container(
        height: 50,
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
