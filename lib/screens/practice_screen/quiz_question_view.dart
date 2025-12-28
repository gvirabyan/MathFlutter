import 'package:flutter/material.dart';

class QuizQuestionView extends StatelessWidget {
  final int currentIndex;
  final int total;
  final int myPoints;
  final int machinePoints;

  final String rivalLabel;

  final String title;
  final String question;
  final List<String> answers;

  final int secondsLeft;

  final int? selectedIndex;
  final List<bool?> results;

  final bool showTimer;
  final bool showScores;

  final void Function(int index)? onSelect;
  final VoidCallback? onSubmit;

   QuizQuestionView({
    super.key,
    required this.currentIndex,
    required this.total,
    required this.myPoints,
    required this.machinePoints,
    this.rivalLabel = 'Punkte der Maschine',
    required this.title,
    required this.question,
    required this.answers,
    required this.secondsLeft,
    required this.selectedIndex,
    required this.results,
    this.showTimer = true,
    this.showScores = true,
    required this.onSelect,
    required this.onSubmit,
  });

  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
// Авто-прокрутка к текущему индексу
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          currentIndex * 46.0, // 36 (ширина) + 10 (отступ)
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
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),

            // ✅ timer (optional)
            if (showTimer)
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

          // top circles
          SizedBox(
            height: 42,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: total,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final res = results[i]; // Статус из нашего списка
                final isCurrent = i == currentIndex;

                // Логика цветов точно как на картинке:
                Color borderColor = Colors.grey.shade300;
                Color backgroundColor = Colors.transparent;
                Color textColor = Colors.black;

                if (isCurrent) {
                  backgroundColor = Colors.black; // Текущий — черный круг
                  borderColor = Colors.black;
                  textColor = Colors.white;
                } else if (res == true) {
                  borderColor = Colors.green; // Правильный — зеленый ободок
                  textColor = Colors.green;
                } else if (res == false) {
                  borderColor = Colors.red;   // Неправильный — красный ободок
                  textColor = Colors.red;
                }

                return Container(
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
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // ✅ scores (optional)
          if (showScores)
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              question,
              style: const TextStyle(fontSize: 32),
            ),
          ),

          const SizedBox(height: 24),

          ...List.generate(answers.length, (i) {
            final selected = selectedIndex == i;

            return GestureDetector(
              onTap: onSelect == null ? null : () => onSelect!(i),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.deepPurple.withOpacity(0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? Colors.deepPurple : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Text(
                  answers[i],
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            );
          }),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: onSubmit,
                child: const Text(
                  'Senden',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
