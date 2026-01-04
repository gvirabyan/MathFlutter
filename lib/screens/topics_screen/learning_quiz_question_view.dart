import 'package:flutter/material.dart';
import 'package:untitled2/app_colors.dart';

import '../../ui_elements/math_content.dart';
import '../../ui_elements/primary_button.dart';

class LearningQuizQuestionView extends StatefulWidget {
  final bool submitted;
  final int currentIndex;
  final int total;

  final String rivalLabel;

  final String title;
  final String question;
  final List<String> answers;

  // ✅ NEW: For history display
  final int? correctAnswerIndex;
  final String? userAnswerStatus;
  final bool isViewingHistory;

  final int? selectedIndex;
  final List<bool?> results;

  final void Function(int index)? onSelect;
  final VoidCallback? onSubmit;
  final VoidCallback? onSkip;
  final VoidCallback? onShowSolution;
  final void Function(int index)? onCircleTap;
  final VoidCallback? onReturnToPresent; // ✅ NEW

  const LearningQuizQuestionView({
    super.key,
    this.onCircleTap,
    required this.submitted,
    this.onReturnToPresent, // ✅ NEW
    required this.currentIndex,
    required this.total,
    this.rivalLabel = 'Punkte der Maschine',
    required this.title,
    required this.question,
    required this.answers,
    this.correctAnswerIndex, // ✅ NEW
    this.userAnswerStatus, // ✅ NEW
    this.isViewingHistory = false, // ✅ NEW
    required this.selectedIndex,
    required this.results,
    required this.onSelect,
    required this.onSubmit,
    this.onSkip,
    this.onShowSolution,
  });

  @override
  State<LearningQuizQuestionView> createState() =>
      _LearningQuizQuestionViewState();
}

class _LearningQuizQuestionViewState extends State<LearningQuizQuestionView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToIndex(widget.currentIndex);
    });
  }

  @override
  void didUpdateWidget(LearningQuizQuestionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToIndex(widget.currentIndex);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToIndex(int index) {
    if (_scrollController.hasClients) {
      final double itemWidth = 64.0;
      final double itemSpacing = 10.0;
      final double itemWithSpacing = itemWidth + itemSpacing;
      final double viewportWidth = _scrollController.position.viewportDimension;

      double targetOffset =
          (index * itemWithSpacing) - (viewportWidth / 2) + (itemWidth / 2);

      targetOffset = targetOffset.clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      );

      _scrollController.animateTo(
        targetOffset,
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
                widget.title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 10),

            // ✅ timer (optional)
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 14),

            // ✅ TOP CIRCLES WITH CLICK HANDLERS
            SizedBox(
              height: 44,
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: widget.total,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final res = widget.results[i];
                  final isCurrent =
                      i == widget.currentIndex && !widget.isViewingHistory;

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

                  // ✅ Make circles clickable
                  return GestureDetector(
                    onTap: () => widget.onCircleTap?.call(i),
                    child: Container(
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
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.shade300,
              ),
            ),

            const SizedBox(height: 36),

            // ✅ QUESTION TEXT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MathContent(
                content: widget.question,
                isQuestion: true,
                fontSize: 32,
              ),
            ),

            const SizedBox(height: 36),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.answers.length,
              itemBuilder: (context, i) {
                final selected = widget.selectedIndex == i;
                final isCorrect = widget.correctAnswerIndex == i;

                int? userAnswerIndex;
                if (widget.isViewingHistory &&
                    widget.userAnswerStatus != null) {
                  // In history, selectedIndex represents the user's choice
                  userAnswerIndex = widget.selectedIndex;
                }

                String letter =
                    String.fromCharCode('a'.codeUnitAt(0) + i) + '.';

                Color? backgroundColor;
                Color? borderColor;
                Color? textColor;
                Color answersColor = Colors.black;

                if (widget.isViewingHistory ||
                    (widget.submitted && widget.correctAnswerIndex != null)) {
                  final bool isUserChoice = widget.selectedIndex == i;
                  final bool isCorrectAnswer = widget.correctAnswerIndex == i;

                  if (isCorrectAnswer) {
                    backgroundColor = AppColors.greenCorrect;
                    textColor = Colors.green;
                    answersColor = Colors.white;
                  } else if (isUserChoice && !isCorrectAnswer) {
                    backgroundColor = AppColors.redWrong;
                    textColor = Colors.red;
                    answersColor = Colors.white;
                  } else {
                    borderColor = Colors.grey.shade300;
                    textColor = Colors.black54;
                  }
                } else {
                  if (selected) {
                    backgroundColor = AppColors.primaryPurple;
                    textColor = Colors.white;
                    answersColor = Colors.white;
                  } else {
                    borderColor = Colors.grey.shade300;
                    textColor = Colors.black38;
                  }
                }

                return GestureDetector(
                  onTap:
                      widget.isViewingHistory
                          ? null
                          : () => widget.onSelect?.call(i),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: backgroundColor ?? Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: borderColor ?? Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      // ✅ Оставляем center, чтобы буквы были четко по середине высоты контейнера
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 25, // Фиксированная ширина для букв a., b., c.
                          child: Text(
                            letter,
                            style: TextStyle(
                              fontSize: 18,
                              color: textColor,
                              height: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Padding(
                            // ✅ РЕГУЛИРОВКА ЗДЕСЬ:
                            // Увеличивай число в top, чтобы опустить ответ ниже.
                            // Начни с 4.0 или 5.0, пока визуально ответ не встанет на одну линию с буквой.
                            padding: const EdgeInsets.only(top: 4.5),
                            child: MathContent(
                              content: widget.answers[i],
                              fontSize: 18,
                              color: answersColor,
                            ),
                          ),
                        ),
                        // Иконки для режима истории
                        if (widget.isViewingHistory && widget.correctAnswerIndex == i)
                          const Padding(
                            padding: EdgeInsets.only(top: 4.0), // Иконку тоже чуть спустим в тон ответу
                            child: Icon(Icons.check_circle, color: Colors.green, size: 24),
                          )
                        else if (widget.isViewingHistory && userAnswerIndex == i && !isCorrect)
                          const Padding(
                            padding: EdgeInsets.only(top: 4.0),
                            child: Icon(Icons.cancel, color: Colors.red, size: 24),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 54),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: widget.onShowSolution,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryPurple,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    'Erklärung',
                    style: TextStyle(
                      fontSize: 15,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ✅ ACTION BUTTONS (skip/submit) - only in normal mode
            if (!widget.isViewingHistory)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: widget.onSkip,
                          child: const Text(
                            'überspringen',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 8,
                      child: PrimaryButton(
                        color: AppColors.primaryYellow,
                        text: (widget.submitted) ? 'nächstes' : 'abgeben',
                        enabled:
                            (widget.submitted || widget.selectedIndex != null),
                        onPressed:
                            widget.submitted ? widget.onSkip : widget.onSubmit,
                      ),
                    ),
                  ],
                ),
              ),
            // ✅ CONTINUE BUTTON (only in history mode)
            if (widget.isViewingHistory)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 54,
                  width: double.infinity,
                  child: PrimaryButton(
                    text: 'Weitermachen', // или 'Continue'
                    enabled: true,
                    color: Colors.amber,
                    onPressed: widget.onReturnToPresent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
