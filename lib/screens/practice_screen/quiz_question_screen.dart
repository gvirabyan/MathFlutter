import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/services/questions_service.dart';

import '../../models/question_model.dart';
import '../../services/category_answer_service.dart';
import '../../services/quiz_service.dart';
import 'quiz_question_view.dart';

class QuizQuestionScreen extends StatefulWidget {
  final int totalQuestions;

  /// learning mode
  final int? categoryId;
  final bool learningMode;

  /// backend params / mode
  final String rival;
  final String rivalLabel;

  /// UI toggles
  final bool showTimer;
  final bool showScores;

  /// logic toggles
  final bool awardPoints;
  final bool saveResult;

  /// timer
  final int timeLimitSeconds;

  const QuizQuestionScreen({
    super.key,
    required this.totalQuestions,
    this.categoryId,
    this.learningMode = false,
    this.rival = 'machine',
    this.rivalLabel = 'Punkte der Maschine',
    this.showTimer = true,
    this.showScores = true,
    this.awardPoints = true,
    this.saveResult = true,
    this.timeLimitSeconds = 60,
  });

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  bool loading = true;
  bool submitted = false;

  List<QuestionModel> questions = [];
  List<bool?> answersResult = []; // для цветов сверху

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

  String normalizeQuestion(String raw) {
    return raw
        .replaceAll(r'\div', '÷')
        .replaceAll(r'\times', '×')
        .replaceAll(r'\_', '_');
  }

  Future<void> _loadQuiz() async {
    Map<String, dynamic> res;

    if (widget.learningMode && widget.categoryId != null) {
      // 1. Загружаем текущие вопросы (неотвеченные)
      res = await QuestionsService.getTopicQuestions(
        categoryId: widget.categoryId!,
        page: 1,
      );
      final data = res['data'];
      final List resultsList = data != null && data['results'] is List
          ? List.from(data['results'])
          : [];

      questions = resultsList.map((e) => QuestionModel.fromJson(e)).toList();

      // 2. ЗАГРУЖАЕМ СТАТУСЫ СТАРЫХ ОТВЕТОВ (Зеленый/Красный)
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;

      final answeredRes = await QuestionsService.getAnsweredQuestions(
        categoryId: widget.categoryId!,
        userId: userId,
      );
      final List answeredData = answeredRes['answers'] ?? [];

      // Создаем список булевых значений из ответов в базе
      List<bool> oldStatuses = answeredData.map((item) {
        return item['attributes']['status'] == 'correct';
      }).toList();

      // 3. ВЫЧИСЛЯЕМ СМЕЩЕНИЕ
      int completedCount = widget.totalQuestions - questions.length;
      if (completedCount < 0) completedCount = 0;

      // 4. ЗАПОЛНЯЕМ КРУЖОЧКИ РЕАЛЬНЫМИ ЦВЕТАМИ
      answersResult = List.generate(widget.totalQuestions, (i) {
        if (i < completedCount) {
          // Если индекс есть в списке отвеченных — берем его статус, иначе true
          return i < oldStatuses.length ? oldStatuses[i] : true;
        }
        return null; // Еще не отвеченные
      });

      if (mounted) {
        setState(() {
          index = 0;
          loading = false;
        });
      }
    } else {
      // Обычный режим без изменений
      res = await QuizService.getQuizQuestions(limit: widget.totalQuestions, rival: widget.rival);
      final List list = res['questions'] is List ? List.from(res['questions']) : [];
      questions = list.map((e) => QuestionModel.fromJson(e)).toList();
      answersResult = List.filled(questions.length, null);
      setState(() { index = 0; loading = false; });
    }

    if (widget.showTimer) _startTimer();
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
    // 1. Базовые проверки
    if (submitted || selected == null) return;

    final q = questions[index];
    final bool isCorrect = selected == q.correctIndex;

    // Вычисляем смещение для UI-кружочков
    int offset = widget.learningMode ? (widget.totalQuestions - questions.length) : 0;
    if (offset < 0) offset = 0;

    timer?.cancel();

    setState(() {
      submitted = true;

      // ✅ ПРАВИЛЬНО: Обновляем статус вопроса в текущем списке
      questions[index].userAnswerStatus = isCorrect ? 'correct' : 'wrong';

      // ✅ ПРАВИЛЬНО: Обновляем кружочек в UI (с учетом смещения)
      // Это закрасит именно 5-й кружок, если 4 уже пройдено
      if ((index + offset) < answersResult.length) {
        answersResult[index + offset] = isCorrect;
      }

      // Начисляем очки (только один раз!)
      if (widget.awardPoints) {
        if (isCorrect) {
          myPoints++;
        } else {
          machinePoints++;
        }
      }
    });

    // ✅ LEARNING MODE — отправка на бэкенд
    if (widget.learningMode && widget.categoryId != null) {
      final answerText = q.answers[selected];
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      final answerData = {
        'users_permissions_user': userId,
        'question': q.id,
        'category': widget.categoryId.toString(),
        'answer': answerText.toString(),
        'status': isCorrect ? 'correct' : 'wrong',
        'answer_type': 'topic',
      };

      // Отправляем данные
      await CategoryAnswerService.updateUserAnsweredQuestion(
        answerData: answerData,
      );
    }

    // Переход к следующему вопросу
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _nextQuestion();
    });
  }

  void _nextQuestion() {
    // Ищем следующий неотвеченный во всем списке
    final nextIndex = questions.indexWhere((q) => q.userAnswerStatus == null);

    if (nextIndex == -1) {
      _finishQuiz();
      return;
    }

    setState(() {
      index = nextIndex;
      selectedIndex = null;
      submitted = false;
    });

    if (widget.showTimer) _startTimer();
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

    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Keine Fragen verfügbar')),
      );
    }

    final q = questions[index];
    int offset = widget.learningMode ? (widget.totalQuestions - questions.length) : 0;
    if (offset < 0) offset = 0;

    return QuizQuestionView(
      key: ValueKey(index),
      currentIndex: index + offset,
      total: widget.totalQuestions,
      results: answersResult,
      myPoints: myPoints,
      machinePoints: machinePoints,
      rivalLabel: widget.rivalLabel,
      title: q.title,
      question: q.question,
      answers: q.answers,
      secondsLeft: secondsLeft,
      selectedIndex: selectedIndex,
      showTimer: widget.showTimer,
      showScores: widget.showScores,
      onSelect: submitted ? null : (i) => setState(() => selectedIndex = i),
      onSubmit:
          selectedIndex == null || submitted
              ? null
              : () => _submitAnswer(selectedIndex),
    );
  }
}
