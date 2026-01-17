import 'dart:math';

class QuestionModel {
  final int id;
  final String title;

  final String question;
  final List<String> answers;
  String? userSelectedText;

  final int correctIndex;
  String? userAnswerStatus;
  final String? secondAnswer;
  final String? solution;

  QuestionModel({
    required this.id,
    required this.title,
    required this.question,
    required this.answers,
    required this.correctIndex,
    this.secondAnswer,
    this.solution,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final String correct = (json['answer'] ?? '').toString();

    // ✅ FIX: Check if answers are already shuffled (from history)
    List<String> allAnswers;
    int correctIndex;

    if (json['shuffled_answers'] != null) {
      // ✅ Answers already shuffled - use them as is
      allAnswers = (json['shuffled_answers'] as List)
          .map((e) => e.toString())
          .toList();
      correctIndex = allAnswers.indexOf(correct);
    } else {
      // ✅ First time - shuffle and save order
      final List<String> wrong =
      (json['wrong_answers'] as List? ?? [])
          .map((e) => e.toString())
          .toList();

      allAnswers = <String>[correct, ...wrong]..shuffle(Random());
      correctIndex = allAnswers.indexOf(correct);
    }

    return QuestionModel(
      id: json['id'],
      title: (json['category_name'] ?? '').toString(),
      question: (json['question'] ?? '').toString(),
      answers: allAnswers,
      correctIndex: correctIndex,
      solution: json['solution']?.toString(),
      secondAnswer: json['second_answer'],
    )..userAnswerStatus = json['user_answer']?['status'];
  }

  // ✅ NEW: Convert to JSON with shuffled answers preserved
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_name': title,
      'question': question,
      'answer': answers[correctIndex],
      'shuffled_answers': answers, // ✅ Save shuffled order
      'wrong_answers': answers.where((a) => a != answers[correctIndex]).toList(),
      'second_answer': secondAnswer,
      'solution': solution,
      'user_answer': userAnswerStatus != null
          ? {'status': userAnswerStatus}
          : null,
    };
  }
}