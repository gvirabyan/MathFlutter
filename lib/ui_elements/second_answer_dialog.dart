import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum SecondAnswerState { idle, answered }

class SecondAnswerResult {
  final String? value;
  final bool isCorrect;

  SecondAnswerResult({
    required this.value,
    required this.isCorrect,
  });
}

class SecondAnswerDialog extends StatefulWidget {
  final String title;
  final String expression;
  final String correctSecondAnswer;

  const SecondAnswerDialog({
    super.key,
    required this.title,
    required this.expression,
    required this.correctSecondAnswer,
  });

  static Future<SecondAnswerResult?> show(
      BuildContext context, {
        required String title,
        required String expression,
        required String correctSecondAnswer,
      }) {
    return showDialog<SecondAnswerResult?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SecondAnswerDialog(
        title: title,
        expression: expression,
        correctSecondAnswer: correctSecondAnswer,
      ),
    );
  }

  @override
  State<SecondAnswerDialog> createState() => _SecondAnswerDialogState();
}

class _SecondAnswerDialogState extends State<SecondAnswerDialog> {
  final TextEditingController _controller = TextEditingController();

  SecondAnswerState _state = SecondAnswerState.idle;
  bool _isCorrect = false;

  void _increment() {
    final current = int.tryParse(_controller.text) ?? 0;
    _controller.text = (current + 1).toString();
  }

  void _decrement() {
    final current = int.tryParse(_controller.text) ?? 0;
    if (current > 0) {
      _controller.text = (current - 1).toString();
    }
  }

  void _onButtonPressed() {
    if (_state == SecondAnswerState.idle) {
      final value = _controller.text.trim();
      final isCorrect = value == widget.correctSecondAnswer;

      setState(() {
        _isCorrect = isCorrect;
        _state = SecondAnswerState.answered;
      });
    } else {
      Navigator.pop(
        context,
        SecondAnswerResult(
          value: _controller.text.trim(),
          isCorrect: _isCorrect,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAnswered = _state == SecondAnswerState.answered;

    final buttonColor = !isAnswered
        ? const Color(0xFFC084FC)
        : (_isCorrect ? Colors.green : Colors.red);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context, null),
              ),
            ),

            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              widget.expression,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _controller,
              enabled: !isAnswered,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                hintText: 'Ergebnis eingeben',
                border: const UnderlineInputBorder(),
                suffixIcon: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: !isAnswered ? _increment : null,
                      child: const Icon(Icons.arrow_drop_up),
                    ),
                    InkWell(
                      onTap: !isAnswered ? _decrement : null,
                      child: const Icon(Icons.arrow_drop_down),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _onButtonPressed,
              child: const Text(
                'Nächstes',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
