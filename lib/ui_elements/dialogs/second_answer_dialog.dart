import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_colors.dart';
import '../../services/audio_service.dart';
import '../math_content.dart';

enum SecondAnswerState { idle, answered }

class SecondAnswerResult {
  final String? value;
  final bool isCorrect;

  SecondAnswerResult({required this.value, required this.isCorrect});
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
      builder:
          (_) => SecondAnswerDialog(
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
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    _controller.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    final isNotEmpty = _controller.text.trim().isNotEmpty;
    if (isNotEmpty != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isNotEmpty;
      });
    }
  }

  void _onButtonPressed() {
    if (_state == SecondAnswerState.idle) {
      final valueStr = _controller.text.trim().replaceAll(',', '.'); // Заменяем запятую на точку, если юзер ее ввел

      // Пытаемся превратить ввод пользователя в число
      final userValue = double.tryParse(valueStr);
      // Пытаемся превратить правильный ответ из ассетов/базы в число
      final correctValue = double.tryParse(widget.correctSecondAnswer.replaceAll(',', '.'));

      bool isCorrect = false;

      if (userValue != null && correctValue != null) {
        // Сравниваем их как числа (10.0 станет равно 10)
        isCorrect = userValue == correctValue;
      } else {
        // Если это не числа (например, текст), сравниваем как строки
        isCorrect = valueStr == widget.correctSecondAnswer;
      }

      setState(() {
        _isCorrect = isCorrect;
        _state = SecondAnswerState.answered;
      });

      // Добавляем озвучку результата
      if (isCorrect) {
        AudioService().play('correct');
      } else {
        AudioService().play('wrong');
      }

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

    final buttonColor =
    !isAnswered
        ?  AppColors.primaryPurple
        : (_isCorrect ? Colors.green : Colors.red);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            MathContent(
              content: widget.expression,
              isQuestion: true,
              fontSize: 32,
            ),

            TextField(
              controller: _controller,
              enabled: !isAnswered,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*$')),
              ],
              decoration: const InputDecoration(
                hintText: 'Ergebnis eingeben',
                border: UnderlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                // Добавляем цвет для состояния disabled
                disabledBackgroundColor: AppColors.primaryPurple.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Кнопка активна, если уже ответили ИЛИ если введен текст
              onPressed: (isAnswered || _isButtonEnabled) ? _onButtonPressed : null,
              child: Text(
                _state == SecondAnswerState.idle ? 'abgeben' : 'nächstes',
                style: TextStyle(
                  fontSize: 16,
                  // Если кнопка заблокирована, делаем текст полупрозрачным
                  color: (isAnswered || _isButtonEnabled) ? Colors.white : Colors.white60,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}