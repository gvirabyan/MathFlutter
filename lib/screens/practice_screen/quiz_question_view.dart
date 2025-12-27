import 'package:flutter/material.dart';

class QuizQuestionView extends StatelessWidget {
  final int currentIndex;
  final int total;
  final int myPoints;
  final int machinePoints;
  final String rivalLabel; // ✅ new
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
    this.rivalLabel = 'Punkte der Maschine', // ✅ default
    required this.title,
    required this.question,
    required this.answers,
    required this.secondsLeft,
    required this.selectedIndex,
    required this.results,
    required this.onSelect,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
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

          // ✅ top circles
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: total,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final r = (i < results.length) ? results[i] : null;
                Color border = Colors.grey.shade300;
                Color bg = Colors.transparent;

                if (r == true) {
                  border = Colors.green;
                  bg = Colors.green.withOpacity(0.15);
                } else if (r == false) {
                  border = Colors.red;
                  bg = Colors.red.withOpacity(0.15);
                }

                final isCurrent = i == currentIndex;

                return CircleAvatar(
                  radius: 16,
                  backgroundColor: isCurrent ? Colors.deepPurple : bg,
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCurrent ? Colors.deepPurple : border,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCurrent ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // ✅ scores
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
                  color: selected ? Colors.deepPurple.withOpacity(0.08) : Colors.white,
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
