import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:untitled2/screens/practice_screen/practice_quiz_question_view.dart';

import '../../models/question_model.dart';
import '../../services/quiz_service.dart';
import '../../ui_elements/dialogs/practice_quiz_complete_dialog.dart';
import '../../ui_elements/dialogs/second_answer_dialog.dart';

class PracticeQuizQuestionScreen extends StatefulWidget {
  final int totalQuestions;

  final String rival;
  final String rivalLabel;

  /// logic toggles
  final bool awardPoints;
  final bool saveResult;

  /// timer
  final int timeLimitSeconds;

  const PracticeQuizQuestionScreen({
    super.key,
    required this.totalQuestions,
    this.rival = 'machine',
    this.rivalLabel = 'Punkte der Mas...',
    this.awardPoints = true,
    this.saveResult = true,
    this.timeLimitSeconds = 60,
  });

  @override
  State<PracticeQuizQuestionScreen> createState() =>
      _PracticeQuizQuestionScreenState();
}

class _PracticeQuizQuestionScreenState
    extends State<PracticeQuizQuestionScreen> {
  bool loading = true;
  bool submitted = false;

  List<QuestionModel> questions = [];
  List<bool?> answersResult = [];

  int index = 0;

  int myPoints = 0;
  int machinePoints = 0;

  late int secondsLeft;
  Timer? timer;

  int? selectedIndex;
  int? machineSelectedIndex;

  @override
  void initState() {
    super.initState();
    secondsLeft = widget.timeLimitSeconds;
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    final res = await QuizService.getQuizQuestions(
      limit: widget.totalQuestions,
      rival: widget.rival,
    );

    final List list =
        res['questions'] is List ? List.from(res['questions']) : [];
    questions = list.map((e) => QuestionModel.fromJson(e)).toList();

    // IMPORTANT: results length must match "total" circles count
    answersResult = List.filled(widget.totalQuestions, null);

    if (!mounted) return;
    setState(() {
      index = 0;
      loading = false;
      submitted = false;
      selectedIndex = null;
      myPoints = 0;
      machinePoints = 0;
    });

    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();
    secondsLeft = widget.timeLimitSeconds;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft <= 0) {
        t.cancel();
        _submitTimeout();
        return;
      }

      if (mounted) {
        setState(() => secondsLeft--);
      }
    });
  }

  void _submitTimeout() {
    if (submitted) return;
    timer?.cancel();

    final q = questions[index]; // берем текущий вопрос
    bool machineGotItRight = Random().nextDouble() < 0.3;
    int? mSelected;

    if (machineGotItRight) {
      mSelected = q.correctIndex;
      if (widget.awardPoints) machinePoints++;
    } else {
      List<int> wrongIndices = [];
      for (int i = 0; i < q.answers.length; i++) {
        if (i != q.correctIndex) wrongIndices.add(i);
      }
      mSelected = wrongIndices[Random().nextInt(wrongIndices.length)];
    }

    setState(() {
      submitted = true;
      machineSelectedIndex = mSelected; // теперь рамка покажется и при таймауте
      questions[index].userAnswerStatus = 'wrong';

      if (index >= 0 && index < answersResult.length) {
        answersResult[index] = false;
      }
    });
  }

  Future<void> _submitAnswer(int selected) async {
    if (submitted) return;

    final q = questions[index];
    bool isPrimaryCorrect = selected == q.correctIndex;
    bool isFinalCorrect = isPrimaryCorrect;

    timer?.cancel();

    // 1. Логика второго ответа (если есть)
    if (isPrimaryCorrect &&
        q.secondAnswer != null &&
        q.secondAnswer!.trim().isNotEmpty) {
      final result = await SecondAnswerDialog.show(
        context,
        title: 'Errechne das Ergebnis',
        expression: q.answers[selected],
        correctSecondAnswer: q.secondAnswer!,
      );
      if (result != null) {
        isFinalCorrect = result.isCorrect;
      }
    }

    setState(() {
      submitted = true;
      questions[index].userAnswerStatus = isFinalCorrect ? 'correct' : 'wrong';

      if (index >= 0 && index < answersResult.length) {
        answersResult[index] = isFinalCorrect;
      }

      if (widget.awardPoints) {
        if (isFinalCorrect) {
          myPoints++;
        }
        bool machineGotItRight = Random().nextDouble() < 0.3;
        if (machineGotItRight) {
          machineSelectedIndex = q.correctIndex; // Машина выбрала правильный
          machinePoints++;
        } else {
          List<int> wrongIndices = [];
          for (int i = 0; i < q.answers.length; i++) {
            if (i != q.correctIndex) wrongIndices.add(i);
          }
          machineSelectedIndex = wrongIndices[Random().nextInt(wrongIndices.length)];
        }
      }
    });
  }

  void _nextQuestion() {
    // If backend returned fewer questions than totalQuestions, finish by questions length
    if (index + 1 >= questions.length) {
      _finishQuiz();
      return;
    }

    setState(() {
      index++;
      selectedIndex = null;
      submitted = false;
      machineSelectedIndex = null;
    });

    _startTimer();
  }

  Future<void> _finishQuiz() async {
    timer?.cancel();

    if (widget.saveResult) {
      await QuizService.saveQuizResult(
        data: {
          'my_points': myPoints,
          'machine_points': machinePoints,
          'rival': widget.rival,
        },
      );
    }

    // ✅ вычисляем результат
    final PracticeQuizResult result =
        myPoints > machinePoints
            ? PracticeQuizResult.win
            : (myPoints < machinePoints
                ? PracticeQuizResult.lose
                : PracticeQuizResult.draw);

    // ✅ points для текста (как пример)
    final int pointsText = (myPoints - machinePoints).abs();

    if (!mounted) return;

    await PracticeQuizCompleteDialog.show(
      context,
      result: result,
      points: pointsText,
      onMyStatus: () {
        // закрываем экран квиза (диалог уже закроется сам внутри)
        Navigator.of(context).pop();
        // тут можешь навигировать на статус, если нужно
        // Navigator.pushNamed(context, '/activity');
      },
      onNewGame: () {
        // повторить игру на тех же вопросах
        setState(() {
          index = 0;
          myPoints = 0;
          machinePoints = 0;
          submitted = false;
          selectedIndex = null;

          answersResult = List.filled(widget.totalQuestions, null);
          for (final q in questions) {
            q.userAnswerStatus = null;
          }
        });

        _startTimer();
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Keine Fragen verfügbar')),
      );
    }

    final displayQuestion = questions[index];
    final displayIndex = index;

    return PracticeQuizQuestionView(
      key: ValueKey(displayIndex),
      currentIndex: displayIndex,
      submitted: submitted,
      total: widget.totalQuestions,
      results: answersResult,
      myPoints: myPoints,
      machinePoints: machinePoints,
      rivalLabel: widget.rivalLabel,
      title: displayQuestion.title,
      question: displayQuestion.question,
      answers: displayQuestion.answers,

      // show correct only after submit
      correctAnswerIndex: submitted ? displayQuestion.correctIndex : null,
      machineSelectedIndex: machineSelectedIndex,
      secondsLeft: secondsLeft,
      selectedIndex: selectedIndex,

      onSelect:
          submitted
              ? null
              : (i) {
                setState(() => selectedIndex = i);
              },

      // submit only before submitted
      onSubmit:
          (selectedIndex == null || submitted)
              ? null
              : () => _submitAnswer(selectedIndex!),

      // ✅ new: next button action when submitted
      onNext: submitted ? _nextQuestion : null,
    );
  }
}
