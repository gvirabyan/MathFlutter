import 'package:flutter/material.dart';

class AnswersTab extends StatelessWidget {
  const AnswersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text('Quiz ${index + 1}'),
            subtitle: const Text('Rechne in zwei Schritten'),
            trailing: const Text(
              '✔ 8 / 10',
              style: TextStyle(color: Colors.green),
            ),
          ),
        );
      },
    );
  }
}
