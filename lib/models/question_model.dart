import 'dart:math';

class QuestionModel {
  final int id;
  final String title;
  final String question;
  final List<String> answers;
  final int correctIndex;
  String? userAnswerStatus;

  QuestionModel({
    required this.id,
    required this.title,
    required this.question,
    required this.answers,
    required this.correctIndex,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final String correct = normalizeQuestion(
      (json['answer'] ?? '').toString(),
    );

    final List<String> wrong =
    (json['wrong_answers'] as List? ?? [])
        .map((e) => normalizeQuestion(e.toString()))
        .toList();

    final List<String> allAnswers = [
      correct,
      ...wrong,
    ]..removeWhere((e) => e.isEmpty);

    allAnswers.shuffle(Random());

    final int correctIndex = allAnswers.indexOf(correct);
    return QuestionModel(
      id: json['id'],
      title: (json['category_name'] ?? '').toString(),
      question: normalizeQuestion(
        (json['question'] ?? '').toString(),
      ),
      answers: allAnswers,
      correctIndex: correctIndex,
    )
    ..userAnswerStatus = json['user_answer']?['status'];

  }

}

String normalizeQuestion(String raw) {
  var s = raw;

  // убрать переносы строк
  s = s.replaceAll('\n', ' ');

  // степени
  s = s.replaceAll('^2', '²');
  s = s.replaceAll('^3', '³');

  // \sqrt{n} → √n
  s = s.replaceAllMapped(
    RegExp(r'\\sqrt\{([^}]+)\}'),
        (m) => '√${m.group(1)}',
  );

  // a\sqrt{b} → a√b
  s = s.replaceAllMapped(
    RegExp(r'(\d+)\\sqrt\{([^}]+)\}'),
        (m) => '${m.group(1)}√${m.group(2)}',
  );

  // \sqrt n (без фигурных скобок)
  s = s.replaceAllMapped(
    RegExp(r'\\sqrt\s*([0-9]+)'),
        (m) => '√${m.group(1)}',
  );

  // знаки
  s = s.replaceAll(r'\times', '×');
  s = s.replaceAll(r'\div', '÷');

  // подчёркивания
  s = s.replaceAll(r'\_', '_');

  // минус → математический
  s = s.replaceAll('-', '−');

  // лишние пробелы
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

  return s;
}

