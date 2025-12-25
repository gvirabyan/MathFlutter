import 'dart:math';

class QuestionModel {
  final String title;
  final String question;
  final List<String> answers;
  final int correctIndex;

  QuestionModel({
    required this.title,
    required this.question,
    required this.answers,
    required this.correctIndex,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final String correct = (json['answer'] ?? '').toString();

    final List<String> wrong = (json['wrong_answers'] as List? ?? [])
        .map((e) => e.toString())
        .toList();

    // собираем все ответы
    final List<String> allAnswers = [
      correct,
      ...wrong,
    ]..removeWhere((e) => e.isEmpty);

    // перемешиваем
    allAnswers.shuffle(Random());

    final int correctIndex = allAnswers.indexOf(correct);

    return QuestionModel(
      title: (json['category_name'] ?? '').toString(),
      question: (json['question'] ?? '').toString(),
      answers: allAnswers,
      correctIndex: correctIndex,
    );
  }
}
