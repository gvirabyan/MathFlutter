import 'package:flutter/material.dart';

class AnswerDialog extends StatelessWidget {
  final String question;

  const AnswerDialog({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return AlertDialog(
      title: Text(question),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(labelText: 'Deine Antwort'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
