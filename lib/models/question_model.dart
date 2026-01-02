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
    final String correct = (json['answer'] ?? '').toString();
    final List<String> wrong = (json['wrong_answers'] as List? ?? [])
        .map((e) => e.toString())
        .toList();

    final allAnswers = <String>[correct, ...wrong]..shuffle(Random());

    final int correctIndex = allAnswers.indexOf(correct);

    return QuestionModel(
      id: json['id'],
      title: (json['category_name'] ?? '').toString(),
      question: (json['question'] ?? '').toString(),
      answers: allAnswers,
      correctIndex: correctIndex,
    )..userAnswerStatus = json['user_answer']?['status'];
  }
}