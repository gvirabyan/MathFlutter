import 'dart:async';
import 'package:flutter/material.dart';
import 'package:untitled2/screens/practice_screen/practice_quiz_question_view.dart';

import '../../models/question_model.dart';
import '../../services/quiz_service.dart';
import '../../ui_elements/dialogs/practice_quiz_complete_dialog.dart';

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
    this.rivalLabel = 'Punkte der Maschine',
    this.awardPoints = true,
    this.saveResult = true,
    this.timeLimitSeconds = 60,
  });

  @override
  State<PracticeQuizQuestionScreen> createState() =>
      _PracticeQuizQuestionScreenState();
}

class _PracticeQuizQuestionScreenState extends State<PracticeQuizQuestionScreen> {
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

    final List list = res['questions'] is List ? List.from(res['questions']) : [];
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
        _submitTimeout(); // ✅ instead of _submitAnswer(null)
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

    // timeout = wrong
    setState(() {
      submitted = true;
      questions[index].userAnswerStatus = 'wrong';

      // mark circle as wrong (only if within bounds)
      if (index >= 0 && index < answersResult.length) {
        answersResult[index] = false;
      }

      if (widget.awardPoints) {
        machinePoints++;
      }
    });
  }

  Future<void> _submitAnswer(int selected) async {
    if (submitted) return;

    final q = questions[index];
    final bool isCorrect = selected == q.correctIndex;

    timer?.cancel();

    setState(() {
      submitted = true;
      questions[index].userAnswerStatus = isCorrect ? 'correct' : 'wrong';

      // mark circle
      if (index >= 0 && index < answersResult.length) {
        answersResult[index] = isCorrect;
      }

      if (widget.awardPoints) {
        if (isCorrect) {
          myPoints++;
        } else {
          machinePoints++;
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
        : (myPoints < machinePoints ? PracticeQuizResult.lose : PracticeQuizResult.draw);

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

      secondsLeft: secondsLeft,
      selectedIndex: selectedIndex,

      onSelect: submitted
          ? null
          : (i) {
        setState(() => selectedIndex = i);
      },

      // submit only before submitted
      onSubmit: (selectedIndex == null || submitted)
          ? null
          : () => _submitAnswer(selectedIndex!),

      // ✅ new: next button action when submitted
      onNext: submitted ? _nextQuestion : null,
    );
  }
}
