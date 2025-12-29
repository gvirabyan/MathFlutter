import 'package:flutter/material.dart';

import '../../ui_elements/primary_button.dart';

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
  final VoidCallback? onSkip;
  final VoidCallback? onShowSolution;
  final void Function(int index)? onCircleTap;


  QuizQuestionView({
    super.key,
    this.onCircleTap,
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
    this.onSkip,
    this.onShowSolution,

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
            Expanded(child: Text(title, overflow: TextOverflow.ellipsis)),
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
                  borderColor = Colors.red; // Неправильный — красный ободок
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
            child: Text(question, style: const TextStyle(fontSize: 32)),
          ),

          const SizedBox(height: 24),

          ...List.generate(answers.length, (i) {
            final selected = selectedIndex == i;

            String letter = String.fromCharCode('a'.codeUnitAt(0) + i) + '.';

            return GestureDetector(
              onTap: () => onCircleTap?.call(i),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:
                      selected
                          ? Colors.deepPurple.withOpacity(0.08)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? Colors.deepPurple : Colors.grey.shade300,
                    width: 1.5, // Немного увеличим толщину для четкости
                  ),
                ),
                child: Row(
                  children: [
                    // Блок с буквой
                    Text(
                      letter,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: selected ? Colors.deepPurple : Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 12), // Отступ между буквой и текстом
                    // Текст ответа
                    Expanded(
                      child: Text(
                        answers[i],
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const Spacer(),
          // ... после Spacer()

          if(!showTimer)
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
                    // Подчеркивание как в вебе
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8), // Отступ между ссылкой и кнопками
          // Ваши кнопки Skip и Senden (Row из предыдущего шага)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                // ... код кнопок Skip и Senden
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                if(!showTimer)
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
                const SizedBox(width: 12),
                // Кнопка Senden (Отправить)
                Expanded(
                  flex: 3,
                  child: PrimaryButton(
                    text: 'abgeben', // Текст из твоего примера
                    enabled: selectedIndex != null, // Твоя логика активации
                    onPressed: onSubmit,
                     color: Colors.yellow,
                    // Если хочешь желтый, раскомментируй
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
