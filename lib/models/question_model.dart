import 'dart:math';

import 'math_renderer.dart';

class QuestionModel {
  final int id;
  final String title;

  final MathNode question;
  final List<MathNode> answers;

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
    final MathNode correct = parseMath(
      (json['answer'] ?? '').toString(),
    );

    final List<MathNode> wrong =
    (json['wrong_answers'] as List? ?? [])
        .map((e) => parseMath(e.toString()))
        .toList();

    final allAnswers = <MathNode>[correct, ...wrong]..shuffle(Random());

    final int correctIndex = allAnswers.indexWhere(
          (a) => mathNodeToPlainText(a) == mathNodeToPlainText(correct),
    );

    return QuestionModel(
      id: json['id'],
      title: (json['category_name'] ?? '').toString(),
      question: parseMath((json['question'] ?? '').toString()),
      answers: allAnswers,
      correctIndex: correctIndex,
    )..userAnswerStatus = json['user_answer']?['status'];
  }
}
String mathNodeToPlainText(MathNode node) {
  if (node is MathText) return node.text;

  if (node is MathRow) {
    return node.children.map(mathNodeToPlainText).join('');
  }

  if (node is MathFraction) {
    return '${mathNodeToPlainText(node.numerator)}/'
        '${mathNodeToPlainText(node.denominator)}';
  }

  if (node is MathSqrt) {
    return 'sqrt(${mathNodeToPlainText(node.value)})';
  }

  return '';
}