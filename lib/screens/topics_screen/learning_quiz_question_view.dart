import 'package:flutter/material.dart';

import '../../ui_elements/primary_button.dart';

class LearningQuizQuestionView extends StatelessWidget {
  final bool submitted;
  final bool learningMode;
  final int currentIndex;
  final int total;
  final int myPoints;
  final int machinePoints;

  final String rivalLabel;

  final String title;
  final String question;
  final List<String> answers;

  // ✅ NEW: For history display
  final int? correctAnswerIndex;
  final String? userAnswerStatus;
  final bool isViewingHistory;

  final int secondsLeft;

  final int? selectedIndex;
  final List<bool?> results;

  final bool showTimer;
  final bool showScores;

  final void Function(int index)? onSelect;
  final VoidCallback? onSubmit;
  final VoidCallback? onSkip;
  final VoidCallback? onShowSolution;
  final void Function(int index)? onCircleTap;
  final VoidCallback? onReturnToPresent; // ✅ NEW

  LearningQuizQuestionView({
    super.key,
    this.onCircleTap,
    required this.submitted,
    required this.learningMode,
    this.onReturnToPresent, // ✅ NEW
    required this.currentIndex,
    required this.total,
    required this.myPoints,
    required this.machinePoints,
    this.rivalLabel = 'Punkte der Maschine',
    required this.title,
    required this.question,
    required this.answers,
    this.correctAnswerIndex, // ✅ NEW
    this.userAnswerStatus, // ✅ NEW
    this.isViewingHistory = false, // ✅ NEW
    required this.secondsLeft,
    required this.selectedIndex,
    required this.results,
    this.showTimer = true,
    this.showScores = true,
    required this.onSelect,
    required this.onSubmit,
    this.onSkip,
    this.onShowSolution,
  });

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // Auto-scroll to current index
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          currentIndex * 46.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Expanded(child: Text(title, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 10),

            // ✅ timer (optional)
            if (showTimer && !isViewingHistory)
              Row(
                children: [
                  const Icon(Icons.timer, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '0:${secondsLeft.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 14),

          // ✅ TOP CIRCLES WITH CLICK HANDLERS
          SizedBox(
            height: 42,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: total,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final res = results[i];
                final isCurrent = i == currentIndex && !isViewingHistory;

                Color borderColor = Colors.grey.shade300;
                Color backgroundColor = Colors.transparent;
                Color textColor = Colors.black;

                if (isCurrent) {
                  backgroundColor = Colors.black;
                  borderColor = Colors.black;
                  textColor = Colors.white;
                } else if (res == true) {
                  borderColor = Colors.green;
                  textColor = Colors.green;
                } else if (res == false) {
                  borderColor = Colors.red;
                  textColor = Colors.red;
                }

                // ✅ Make circles clickable
                return GestureDetector(
                  onTap: () => onCircleTap?.call(i),
                  child: Container(
                    width: 36,
                    height: 36,
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // ✅ "ZURÜCK ZUR AKTUELLEN FRAGE" BUTTON (when viewing history)

          // ✅ scores (optional)
          if (showScores && !isViewingHistory)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.deepPurple),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Deine Punkte: $myPoints',
                        style: const TextStyle(color: Colors.deepPurple),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.deepPurple),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$rivalLabel: $machinePoints',
                        style: const TextStyle(color: Colors.deepPurple),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // ✅ QUESTION TEXT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(question, style: const TextStyle(fontSize: 32)),
          ),

          const SizedBox(height: 24),

          // ✅ ANSWERS LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: answers.length,
              itemBuilder: (context, i) {
                final selected = selectedIndex == i;
                final isCorrect = correctAnswerIndex == i;

                // ✅ History mode: find user's answer
                int? userAnswerIndex;
                if (isViewingHistory && userAnswerStatus != null) {
                  // In history, selectedIndex represents the user's choice
                  userAnswerIndex = selectedIndex;
                }

                String letter =
                    String.fromCharCode('a'.codeUnitAt(0) + i) + '.';

                Color? backgroundColor;
                Color? borderColor;
                Color? textColor;

                debugPrint(
                    '[ANSWER ITEM] i=$i | '
                        'selectedIndex=$selectedIndex | '
                        'correctAnswerIndex=$correctAnswerIndex | '
                        'submitted=$submitted | '
                        'isViewingHistory=$isViewingHistory'
                );

                if (isViewingHistory || (learningMode && submitted)) {
                  final bool isUserChoice = selectedIndex == i;
                  final bool isCorrectAnswer = correctAnswerIndex == i;

                  debugPrint(
                      '→ paint i=$i | '
                          'isUserChoice=$isUserChoice | '
                          'isCorrectAnswer=$isCorrectAnswer'
                  );
                  if (isCorrectAnswer) {
                    // ✅ правильный ответ — ВСЕГДА зелёный
                    backgroundColor = Colors.green.withOpacity(0.1);
                    borderColor = Colors.green;
                    textColor = Colors.green;
                  } else if (isUserChoice && !isCorrectAnswer) {
                    // ❌ выбранный, но неправильный
                    backgroundColor = Colors.red.withOpacity(0.1);
                    borderColor = Colors.red;
                    textColor = Colors.red;
                  } else {
                    borderColor = Colors.grey.shade300;
                    textColor = Colors.black54;
                  }
                } else {
                  // ✅ NORMAL MODE: Just show selection
                  if (selected) {
                    backgroundColor = Colors.deepPurple.withOpacity(0.08);
                    borderColor = Colors.deepPurple;
                    textColor = Colors.deepPurple;
                  } else {
                    borderColor = Colors.grey.shade300;
                    textColor = Colors.black;
                  }
                }

                return GestureDetector(
                  onTap: isViewingHistory ? null : () => onSelect?.call(i),
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
                      children: [
                        Text(
                          letter,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            answers[i],
                            style: TextStyle(fontSize: 18, color: textColor),
                          ),
                        ),
                        // ✅ Show checkmark or X in history mode
                        if (isViewingHistory && isCorrect)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24,
                          )
                        else if (isViewingHistory &&
                            userAnswerIndex == i &&
                            !isCorrect)
                          const Icon(Icons.cancel, color: Colors.red, size: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ✅ SOLUTION LINK (only if not showing timer)
          if (!showTimer)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: onShowSolution,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    'Erklärung',
                    style: TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 8),

          // ✅ ACTION BUTTONS (skip/submit) - only in normal mode
          if (!isViewingHistory)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (!showTimer)
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.deepPurple,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: onSkip,
                          child: const Text(
                            'Überspringen',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (!showTimer) const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: PrimaryButton(
                      text: (learningMode && submitted) ? 'Weiter' : 'abgeben',
                      enabled:
                          learningMode
                              ? (submitted || selectedIndex != null)
                              : selectedIndex != null,
                      onPressed: learningMode && submitted ? onSkip : onSubmit,
                    ),
                  ),
                ],
              ),
            ),
          // ✅ CONTINUE BUTTON (only in history mode)
          if (isViewingHistory)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 54,
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Weiter', // или 'Continue'
                  enabled: true,
                  color: Colors.amber,
                  onPressed: onReturnToPresent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
