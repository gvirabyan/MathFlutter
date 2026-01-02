import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/screens/topics_screen/learning_quiz_question_view.dart';
import 'package:untitled2/services/questions_service.dart';

import '../../models/question_model.dart';
import '../../services/category_answer_service.dart';
import '../../services/quiz_service.dart';

class LearningQuizQuestionScreen extends StatefulWidget {
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

  const LearningQuizQuestionScreen({
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
  State<LearningQuizQuestionScreen> createState() => _LearningQuizQuestionScreenState();
}

class _LearningQuizQuestionScreenState extends State<LearningQuizQuestionScreen> {
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

      // 2. ЗАГРУЖАЕМ СТАТУСЫ СТАРЫХ ОТВЕТОВ (История)
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;

      final answeredRes = await QuestionsService.getAnsweredQuestions(
        categoryId: widget.categoryId!,
        userId: userId,
      );
      final List answeredData = answeredRes['answers'] ?? [];

      // ✅ Create history questions from answered data
      historyQuestions = answeredData.map((item) {
        final questionData = item['attributes']['question']['data'];
        final q = QuestionModel.fromJson({
          'id': questionData['id'],
          ...questionData['attributes'],
          'user_answer': item['attributes'],
        });
        return q;
      }).toList();

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
      res = await QuizService.getQuizQuestions(
        limit: widget.totalQuestions,
        rival: widget.rival,
      );
      final List list = res['questions'] is List
          ? List.from(res['questions'])
          : [];
      questions = list.map((e) => QuestionModel.fromJson(e)).toList();
      answersResult = List.filled(questions.length, null);
      setState(() {
        index = 0;
        loading = false;
      });
    }

    if (widget.showTimer && !viewingHistory) _startTimer();
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

    int offset = widget.learningMode
        ? (widget.totalQuestions - questions.length)
        : 0;
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

      await CategoryAnswerService.updateUserAnsweredQuestion(
        answerData: answerData,
      );

      // Add to history
      final answeredQuestion = QuestionModel(
        id: q.id,
        title: q.title,
        question: q.question,
        answers: q.answers,
        correctIndex: q.correctIndex,
      );
      answeredQuestion.userAnswerStatus = isCorrect ? 'correct' : 'wrong';
      historyQuestions.add(answeredQuestion);
    }
    if (widget.learningMode && isCorrect) {
      await _openSecondAnswerDialog(q.answers[selected]);
    }

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

    if (widget.showTimer) _startTimer();
  }

  // ✅ NEW: Show history question
  void _showHistoryQuestion(int circleIndex) {
    // Calculate offset
    int offset = widget.learningMode
        ? (widget.totalQuestions - questions.length)
        : 0;
    if (offset < 0) offset = 0;

    // Can only view answered questions or current question
    final currentQuestionIndex = index + offset;

    if (circleIndex < offset) {
      // It's a history question
      timer?.cancel();
      setState(() {
        viewingHistory = true;
        historyIndex = circleIndex;
      });
    } else if (circleIndex == currentQuestionIndex) {
      // It's the current question - go back to it
      _returnToPresentQuestion();
    } else if (circleIndex > currentQuestionIndex) {
      // Future question - can't view
      return;
    }
  }

  // ✅ NEW: Return to present question
  void _returnToPresentQuestion() {
    setState(() {
      viewingHistory = false;
      historyIndex = null;
    });
    if (widget.showTimer && !submitted) {
      _startTimer();
    }
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty && historyQuestions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Keine Fragen verfügbar')),
      );
    }

    // Calculate current position
    int offset = widget.learningMode
        ? (widget.totalQuestions - questions.length)
        : 0;
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

    return LearningQuizQuestionView(
      key: ValueKey('${displayIndex}_${isHistory ? 'history' : 'current'}'),
      currentIndex: displayIndex,
      submitted: submitted,
      learningMode: widget.learningMode,
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
      isViewingHistory: isHistory,
      onSelect: (submitted || isHistory) ? null : (i) {
        setState(() => selectedIndex = i);
      },
      onSubmit: (selectedIndex == null || submitted || isHistory)
          ? null
          : () => _submitAnswer(selectedIndex),
      onSkip: isHistory ? null : () {
        _nextQuestion();
      },
      onShowSolution: () {
        // Implement solution dialog
      },
      onCircleTap: _showHistoryQuestion,
      onReturnToPresent: _returnToPresentQuestion,
    );
  }
  Future<void> _openSecondAnswerDialog(String firstAnswer)
  async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Zusatzantwort'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Erste Antwort:'),
                const SizedBox(height: 8),
                Text(firstAnswer, style: const TextStyle(fontSize: 22)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Antwort eingeben',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              secondAnswerValue = null;
              Navigator.pop(context);
            },
            child: const Text('Überspringen'),
          ),
          TextButton(
            onPressed: () {
              secondAnswerValue = controller.text;
              Navigator.pop(context);
            },
            child: const Text('Weiter'),
          ),
        ],
      ),
    );
  }

}

