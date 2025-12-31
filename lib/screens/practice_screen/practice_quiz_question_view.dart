import 'package:flutter/material.dart';
import 'package:untitled2/ui_elements/math_or_text.dart';
import '../../ui_elements/primary_button.dart';

class PracticeQuizQuestionView extends StatelessWidget {
  final bool submitted;
  final int currentIndex;
  final int total;
  final int myPoints;
  final int machinePoints;

  final String rivalLabel;

  final String title;
  final String question;
  final List<String> answers;

  // correct answer shown only after submit
  final int? correctAnswerIndex;

  final int secondsLeft;

  final int? selectedIndex;
  final List<bool?> results;

  final void Function(int index)? onSelect;
  final VoidCallback? onSubmit;

  // ✅ NEW: next action after submit (Weiter)
  final VoidCallback? onNext;

  PracticeQuizQuestionView({
    super.key,
    required this.submitted,
    required this.currentIndex,
    required this.total,
    required this.myPoints,
    required this.machinePoints,
    this.rivalLabel = 'Punkte der Maschine',
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
            Expanded(child: Text("Player VS Machine", overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 10),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 18),
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

          SizedBox(
            height: 42,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: total,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final bool? res = (i >= 0 && i < results.length) ? results[i] : null;
                final isCurrent = i == currentIndex;

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

                return GestureDetector(
                  child: Container(
                    width: 40,
                    height: 40,
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.deepPurple,
                    ),
                    child: Text(
                      'Deine Punkte: $myPoints',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                 Text(
                  question,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),              ],
            ),
          ),


          const SizedBox(height: 24),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: answers.length,
              itemBuilder: (context, i) {
                final selected = selectedIndex == i;
                final isCorrectAnswer = correctAnswerIndex == i;

                String letter = String.fromCharCode('a'.codeUnitAt(0) + i) + '.';

                Color? backgroundColor;
                Color? borderColor;
                Color? textColor;

                if (submitted && correctAnswerIndex != null) {
                  // ✅ After submit: show green correct, red selected wrong
                  if (isCorrectAnswer) {
                    backgroundColor = Colors.green.withOpacity(0.1);
                    borderColor = Colors.green;
                    textColor = Colors.green;
                  } else if (selected && !isCorrectAnswer) {
                    backgroundColor = Colors.red.withOpacity(0.1);
                    borderColor = Colors.red;
                    textColor = Colors.red;
                  } else {
                    borderColor = Colors.grey.shade300;
                    textColor = Colors.black54;
                  }
                } else {
                  // ✅ Before submit: same design as you had
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
                  onTap: () => onSelect?.call(i),
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
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PrimaryButton(
                    color: Colors.yellow,
                    text: submitted ? 'nächstes' : 'abgeben',
                    enabled: submitted ? true : (selectedIndex != null),
                    onPressed: submitted ? onNext : onSubmit,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
