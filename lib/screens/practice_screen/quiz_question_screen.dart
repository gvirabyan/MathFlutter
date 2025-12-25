import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/question_model.dart';
import '../../services/quiz_service.dart';
import 'quiz_question_view.dart';

class QuizQuestionScreen extends StatefulWidget {
  final int totalQuestions;

  const QuizQuestionScreen({
    super.key,
    required this.totalQuestions,
  });

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  bool loading = true;
  bool submitted = false;

  List<QuestionModel> questions = [];
  List<bool?> answersResult = []; // ✅ для цветов сверху

  int index = 0;

  int myPoints = 0;
  int machinePoints = 0;

  int secondsLeft = 60;
  Timer? timer;

  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    final res = await QuizService.getQuizQuestions(
      limit: widget.totalQuestions,
      rival: 'machine',
    );

    questions = (res['questions'] as List)
        .map((e) => QuestionModel.fromJson(e))
        .toList();

    answersResult = List<bool?>.filled(questions.length, null);

    _startTimer();

    if (mounted) {
      setState(() => loading = false);
    }
  }

  void _startTimer() {
    timer?.cancel();
    secondsLeft = 60;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft == 0) {
        _submitAnswer(null);
      } else {
        if (mounted) {
          setState(() => secondsLeft--);
        }
      }
    });
  }

  void _submitAnswer(int? selected) {
    if (submitted) return;
    submitted = true;

    timer?.cancel();

    final bool correct =
        selected != null &&
            selected == questions[index].correctIndex;

    answersResult[index] = correct; // ✅ сохраняем результат

    setState(() {
      if (correct) {
        myPoints++;
      } else {
        machinePoints++;
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (index + 1 < questions.length) {
      setState(() {
        index++;
        selectedIndex = null;
        submitted = false;
      });
      _startTimer();
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    await QuizService.saveQuizResult(
      data: {
        'my_points': myPoints,
        'machine_points': machinePoints,
      },
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final q = questions[index];

    return QuizQuestionView(
      key: ValueKey(index),
      currentIndex: index,
      total: questions.length,
      myPoints: myPoints,
      machinePoints: machinePoints,
      title: q.title,
      question: q.question,
      answers: q.answers,
      secondsLeft: secondsLeft,
      selectedIndex: selectedIndex,
      results: answersResult, // ✅ передаём результаты
      onSelect: submitted
          ? null
          : (i) => setState(() => selectedIndex = i),
      onSubmit: selectedIndex == null || submitted
          ? null
          : () => _submitAnswer(selectedIndex),
    );
  }
}
