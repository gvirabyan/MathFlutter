import 'package:flutter/material.dart';

class QuizQuestionView extends StatelessWidget {
  final int currentIndex;
  final int total;
  final int myPoints;
  final int machinePoints;
  final String title;
  final String question;
  final List<String> answers;
  final int secondsLeft;
  final int? selectedIndex;
  final List<bool?> results; // ✅
  final void Function(int index)? onSelect;
  final VoidCallback? onSubmit;

  const QuizQuestionView({
    super.key,
    required this.currentIndex,
    required this.total,
    required this.myPoints,
    required this.machinePoints,
    required this.title,
    required this.question,
    required this.answers,
    required this.secondsLeft,
    required this.selectedIndex,
    required this.results,
    required this.onSelect,
    required this.onSubmit,
  });

  Color _circleColor(int i) {
    if (results[i] == true) return Colors.green;
    if (results[i] == false) return Colors.red;
    if (i == currentIndex) return Colors.black;
    return Colors.grey.shade300;
  }

  Color _textColor(int i) {
    final bg = _circleColor(i);
    if (bg == Colors.grey.shade300) return Colors.black;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text('Spieler gegen Maschine'),
        actions: [
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '0:${secondsLeft.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          /// 🔢 номера вопросов
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: total,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                return CircleAvatar(
                  radius: 16,
                  backgroundColor: _circleColor(i),
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: _textColor(i),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          /// очки
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Deine Punkte: $myPoints',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Punkte der Maschine: $machinePoints',
                      style: const TextStyle(color: Colors.deepPurple),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
            return GestureDetector(
              onTap: onSelect == null ? null : () => onSelect!(i),
              child: Container(
                margin:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedIndex == i
                        ? Colors.deepPurple
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${String.fromCharCode(97 + i)}. ${answers[i]}',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            );
          }),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: Colors.amber,
              ),
              child: const Text(
                'abgeben',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
