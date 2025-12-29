import 'dart:async';
import 'package:flutter/material.dart';
import 'package:untitled2/screens/practice_screen/practice_quiz_question_view.dart';
import '../../models/question_model.dart';
import '../../services/quiz_service.dart';

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

class _PracticeQuizQuestionScreenState
    extends State<PracticeQuizQuestionScreen> {
  bool loading = true;
  bool submitted = false;

  bool showSecondAnswerDialog = false;
  String? secondAnswerValue;

  List<QuestionModel> questions = [];
  List<bool?> answersResult = []; // для цветов сверху

  // ✅ NEW: Store history of answered questions
  List<QuestionModel> historyQuestions = [];

  int index = 0;

  // ✅ NEW: Flag to show if we're viewing history
  bool viewingHistory = false;
  int? historyIndex;

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

  String normalizeQuestion(String raw) {
    return raw
        .replaceAll(r'\div', '÷')
        .replaceAll(r'\times', '×')
        .replaceAll(r'\_', '_');
  }

  Future<void> _loadQuiz() async {
    Map<String, dynamic> res;

    // Обычный режим без изменений
    res = await QuizService.getQuizQuestions(
      limit: widget.totalQuestions,
      rival: widget.rival,
    );
    final List list =
        res['questions'] is List ? List.from(res['questions']) : [];
    questions = list.map((e) => QuestionModel.fromJson(e)).toList();
    answersResult = List.filled(questions.length, null);
    setState(() {
      index = 0;
      loading = false;
    });

    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();
    secondsLeft = widget.timeLimitSeconds;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft == 0) {
        _submitAnswer(null);
      } else {
        if (mounted) setState(() => secondsLeft--);
      }
    });
  }

  void _submitAnswer(int? selected) async {
    if (submitted || selected == null) return;

    final q = questions[index];
    final bool isCorrect = selected == q.correctIndex;

    int offset = 0;
    if (offset < 0) offset = 0;

    timer?.cancel();

    setState(() {
      submitted = true;
      questions[index].userAnswerStatus = isCorrect ? 'correct' : 'wrong';

      if ((index + offset) < answersResult.length) {
        answersResult[index + offset] = isCorrect;
      }

      if (widget.awardPoints) {
        if (isCorrect) {
          myPoints++;
        } else {
          machinePoints++;
        }
      }
    });
    // ✅ Learning mode - save to backend and add to history
  }

  void _nextQuestion() {
    final nextIndex = questions.indexWhere((q) => q.userAnswerStatus == null);

    if (nextIndex == -1) {
      _finishQuiz();
      return;
    }

    setState(() {
      index = nextIndex;
      selectedIndex = null;
      submitted = false;
      viewingHistory = false;
      historyIndex = null;
    });

    _startTimer();
  }

  Future<void> _finishQuiz() async {
    if (widget.saveResult) {
      await QuizService.saveQuizResult(
        data: {
          'my_points': myPoints,
          'machine_points': machinePoints,
          'rival': widget.rival,
        },
      );
    }

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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (questions.isEmpty && historyQuestions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Keine Fragen verfügbar')),
      );
    }

    // Calculate current position
    int offset = 0;
    if (offset < 0) offset = 0;

    // Determine which question to show
    QuestionModel displayQuestion;
    int displayIndex;
    bool isHistory = false;

    if (viewingHistory && historyIndex != null) {
      displayQuestion = historyQuestions[historyIndex!];
      displayIndex = historyIndex!;
      isHistory = true;
    } else {
      displayQuestion = questions[index];
      displayIndex = index + offset;
    }

    return PracticeQuizQuestionView(
      key: ValueKey('${displayIndex}_${isHistory ? 'history' : 'current'}'),
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
      correctAnswerIndex:
          (isHistory || submitted) ? displayQuestion.correctIndex : null,
      userAnswerStatus: isHistory ? displayQuestion.userAnswerStatus : null,
      secondsLeft: secondsLeft,
      selectedIndex: selectedIndex,
      onSelect:
          (submitted || isHistory)
              ? null
              : (i) {
                setState(() => selectedIndex = i);
              },
      onSubmit:
          (selectedIndex == null || submitted || isHistory)
              ? null
              : () => _submitAnswer(selectedIndex),
    );
  }
}
