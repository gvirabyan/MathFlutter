import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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

  // ✅ For history display
  final int? correctAnswerIndex;
  final String? userAnswerStatus;
  final bool isViewingHistory;

  // ✅ CHANGED: Use text for history, index for current
  final String? selectedAnswerText; // For history - the actual answer text
  final int? selectedIndex; // For current question only
  final List<bool?> results;

  final void Function(int index)? onSelect;
  final VoidCallback? onSubmit;
  final VoidCallback? onSkip;
  final VoidCallback? onNext;
  final VoidCallback? onShowSolution;
  final void Function(int index)? onCircleTap;
  final VoidCallback? onReturnToPresent;

  const LearningQuizQuestionView({
    super.key,
    this.onCircleTap,
    required this.submitted,
    this.onReturnToPresent,
    required this.currentIndex,
    required this.total,
    this.rivalLabel = 'Punkte der Maschine',
    required this.title,
    required this.question,
    required this.answers,
    this.correctAnswerIndex,
    this.userAnswerStatus,
    this.isViewingHistory = false,
    this.selectedAnswerText,
    required this.selectedIndex,
    required this.results,
    required this.onSelect,
    required this.onSubmit,
    this.onSkip,
    this.onNext,
    this.onShowSolution,
  });

  @override
  State<LearningQuizQuestionView> createState() =>
      _LearningQuizQuestionViewState();
}

class _LearningQuizQuestionViewState extends State<LearningQuizQuestionView> {
  final ScrollController _scrollController = ScrollController();
  bool _isInitialBuild = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(LearningQuizQuestionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToIndex(widget.currentIndex, animate: true);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialBuild) {
      _isInitialBuild = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToIndex(widget.currentIndex, animate: false);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToIndex(int index, {required bool animate}) {
    if (!_scrollController.hasClients) return;

    const double itemWidth = 64.0;
    const double spacing = 1.0;
    final double itemWithSpacing = itemWidth + spacing;
    final double viewportWidth = _scrollController.position.viewportDimension;

    double targetOffset =
        16.0 +
        (index * itemWithSpacing) -
        (viewportWidth / 2) +
        (itemWidth / 2);

    final double minScroll = _scrollController.position.minScrollExtent;
    final double maxScroll = _scrollController.position.maxScrollExtent;

    // Clamping manually to handle potential 0 maxScroll issues
    if (targetOffset < minScroll) targetOffset = minScroll;
    if (maxScroll > minScroll && targetOffset > maxScroll) {
      targetOffset = maxScroll;
    }

    if (animate) {
      // Для первого раза используем более длинную анимацию
      final isFirstLoad = _isInitialBuild;
      _scrollController.animateTo(
        targetOffset,
        duration: Duration(milliseconds: isFirstLoad ? 800 : 300),
        curve: isFirstLoad ? Curves.easeInOutCubic : Curves.easeInOut,
      );
    } else {
      _scrollController.jumpTo(targetOffset);
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
        title: Text(
          widget.title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
          const SizedBox(height: 14),

          // TOP CIRCLES
          SizedBox(
            height: 44,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: widget.total,
              separatorBuilder: (_, __) => const SizedBox(width: 1),
              itemBuilder: (context, i) {
                final res = widget.results[i];
                final isCurrent = i == widget.currentIndex;

                Color borderColor = Colors.grey.shade300;
                Color backgroundColor = Colors.transparent;
                Color textColor = Colors.black38;

                if (isCurrent) {
                  if (res == true) {
                    backgroundColor = AppColors.greenCorrect;
                    borderColor = AppColors.greenCorrect;
                    textColor = Colors.white;
                  } else if (res == false) {
                    backgroundColor = AppColors.redWrong;
                    borderColor = AppColors.redWrong;
                    textColor = Colors.white;
                  } else {
                    backgroundColor = Colors.black;
                    borderColor = Colors.black;
                    textColor = Colors.white;
                  }
                } else if (res == true) {
                  borderColor = AppColors.greenCorrect;
                  textColor = AppColors.greenCorrect;
                } else if (res == false) {
                  borderColor = AppColors.redWrong;
                  textColor = AppColors.redWrong;
                }

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

          Expanded(
            child: SingleChildScrollView(
              key: ValueKey('body_${widget.currentIndex}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 36),

                  // QUESTION TEXT
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
                      final answer = widget.answers[i];
                      final selected = widget.selectedIndex == i;
                      final isCorrect = widget.correctAnswerIndex == i;

                      final bool isUserChoice =
                          widget.isViewingHistory
                              ? (widget.selectedAnswerText == answer)
                              : (widget.selectedIndex == i);

                      String letter =
                          String.fromCharCode('a'.codeUnitAt(0) + i) + '.';

                      Color? backgroundColor;
                      Color? borderColor;
                      Color? textColor;
                      Color answersColor = Colors.black;

                      if (widget.isViewingHistory ||
                          (widget.submitted &&
                              widget.correctAnswerIndex != null)) {
                        final bool isCorrectAnswer =
                            widget.correctAnswerIndex == i;

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
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: backgroundColor ?? Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: borderColor ?? Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 25,
                                child: Text(
                                  letter,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: textColor,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4.5),
                                  child: MathContent(
                                    content: answer,
                                    fontSize: 18,
                                    color: answersColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
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
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          if (!widget.isViewingHistory)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 48,
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
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 5,
                    child: SizedBox(
                      height: 48,
                      child: PrimaryButton(
                        color: AppColors.primaryYellow,
                        text: (widget.submitted) ? 'nächstes' : 'abgeben',
                        enabled:
                            (widget.submitted || widget.selectedIndex != null),
                        onPressed:
                            widget.submitted ? widget.onNext : widget.onSubmit,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (widget.isViewingHistory)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Weitermachen',
                  enabled: true,
                  color: Colors.amber,
                  onPressed: widget.onReturnToPresent,
                ),
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
