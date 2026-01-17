import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/screens/topics_screen/learning_quiz_question_view.dart';
import 'package:untitled2/services/questions_service.dart';

import '../../models/question_model.dart';
import '../../services/category_answer_service.dart';
import '../../ui_elements/dialogs/second_answer_dialog.dart';
import '../../ui_elements/loading_overlay.dart';
import '../../ui_elements/solution_viewer.dart';
import '../../ui_elements/whiteboard_service.dart';

class LearningQuizQuestionScreen extends StatefulWidget {
  final int totalQuestions;
  final String categoryName;
  /// learning mode
  final int? categoryId;
  final bool learningMode;

  /// backend params / mode

  /// logic toggles
  final bool awardPoints;
  final bool saveResult;

  const LearningQuizQuestionScreen({
    super.key,
    required this.totalQuestions,
    this.categoryId,
    required this.categoryName,
    this.learningMode = false,
    this.awardPoints = true,
    this.saveResult = true,
  });

  @override
  State<LearningQuizQuestionScreen> createState() =>
      _LearningQuizQuestionScreenState();
}

class _LearningQuizQuestionScreenState
    extends State<LearningQuizQuestionScreen> {
  bool loading = true;
  bool submitted = false;

  bool showSecondAnswerDialog = false;
  String? secondAnswerValue;

  List<QuestionModel> questions = [];
  List<bool?> answersResult = []; // для цветов сверху

  // ✅ NEW: Store history of answered questions
  List<QuestionModel> historyQuestions = [];
  // ✅ FIXED: Store user's selected answer TEXT (not index) for history questions
  Map<int, String> historyUserAnswers = {}; // questionId -> selectedAnswerText

  int index = 0;

  // ✅ NEW: Flag to show if we're viewing history
  bool viewingHistory = false;
  int? historyIndex;

  late int secondsLeft;

  int? selectedIndex;

  void _handleShowSolution() {
    final currentQuestion = viewingHistory && historyIndex != null
        ? historyQuestions[historyIndex!]
        : questions[index];

    final sol = currentQuestion.solution;

    if (sol != null && sol.isNotEmpty) {
      // ✅ Показываем наше созданное окно
      SolutionViewer.show(context, sol);
    } else {
      // Если решения нет, показываем небольшое уведомление (как f7.dialog.alert в Vue)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("'Solution doesn't exists"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadQuiz();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      WhiteboardService.showButton(context);
    });
  }

  Future<void> _loadQuiz() async {
    setState(() => loading = true);

    final res = await QuestionsService.getTopicQuestions(
      categoryId: widget.categoryId!,
      page: 1,
    );

    final data = res['data'] ?? {};

    // ✅ BACKEND-ИСТИНА
    final List historyList = data['history'] ?? [];
    final List resultsList = data['results'] ?? [];

    // ✅ Load saved shuffled orders from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final shuffledOrdersJson = prefs.getString('shuffled_answers_${widget.categoryId}');
    Map<int, List<String>> savedShuffledOrders = {};

    if (shuffledOrdersJson != null) {
      try {
        final decoded = json.decode(shuffledOrdersJson) as Map<String, dynamic>;
        savedShuffledOrders = decoded.map(
              (key, value) => MapEntry(
            int.parse(key),
            (value as List).map((e) => e.toString()).toList(),
          ),
        );
      } catch (e) {
        debugPrint('Error loading shuffled orders: $e');
      }
    }

    // ✅ HISTORY — with saved shuffle order
    historyQuestions = historyList.map((e) {
      final questionId = e['id'] as int;
      final correct = e['answer'].toString();
      final wrong = (e['wrong_answers'] as List? ?? []).map((w) => w.toString()).toList();

      List<String> allAnswers;

      // ✅ Use saved shuffle order if exists
      if (savedShuffledOrders.containsKey(questionId)) {
        allAnswers = savedShuffledOrders[questionId]!;
      } else {
        // First time seeing this question - shuffle
        allAnswers = [correct, ...wrong];
        allAnswers.shuffle(Random());
        savedShuffledOrders[questionId] = allAnswers;
      }

      final questionModel = QuestionModel.fromJson({
        'id': questionId,
        ...e,
        'shuffled_answers': allAnswers,
        'user_answer': e['user_answer'],
      });

      // ✅ Store the user's actual selected answer TEXT
      if (e['user_answer'] != null && e['user_answer']['answer'] != null) {
        final userAnswerText = e['user_answer']['answer'].toString();
        historyUserAnswers[questionModel.id] = userAnswerText;
      }

      return questionModel;
    }).toList();

    // ✅ АКТУАЛЬНЫЕ ВОПРОСЫ - with saved shuffle order
    questions = resultsList.map((e) {
      final questionId = e['id'] as int;
      final correct = e['answer'].toString();
      final wrong = (e['wrong_answers'] as List? ?? []).map((w) => w.toString()).toList();

      List<String> allAnswers;

      // ✅ Use saved shuffle order if exists
      if (savedShuffledOrders.containsKey(questionId)) {
        allAnswers = savedShuffledOrders[questionId]!;
      } else {
        // First time seeing this question - shuffle
        allAnswers = [correct, ...wrong];
        allAnswers.shuffle(Random());
        savedShuffledOrders[questionId] = allAnswers;
      }

      return QuestionModel.fromJson({
        ...e,
        'shuffled_answers': allAnswers,
      });
    }).toList();

    // ✅ Save shuffled orders to SharedPreferences
    final ordersToSave = savedShuffledOrders.map(
          (key, value) => MapEntry(key.toString(), value),
    );
    await prefs.setString(
      'shuffled_answers_${widget.categoryId}',
      json.encode(ordersToSave),
    );

    // ✅ ОБЩЕЕ КОЛ-ВО ВОПРОСОВ
    final total = (res['meta']?['total'] ?? 0) + historyQuestions.length;

    // ✅ КРУЖКИ (1-в-1 как Vue)
    answersResult = List.generate(total, (i) {
      if (i < historyQuestions.length) {
        return historyQuestions[i].userAnswerStatus == 'correct';
      }
      return null;
    });

    setState(() {
      index = 0;
      submitted = false;
      viewingHistory = false;
      historyIndex = null;
      loading = false;
    });
  }

  void _submitAnswer(int? selected) async {
    if (submitted || selected == null) return;

    final q = questions[index];
    final bool isFirstCorrect = selected == q.correctIndex;

    // Если первого ответа нет или он неверный, то и второй не нужен — сразу Wrong
    if (!isFirstCorrect) {
      setState(() {
        submitted = true;
        q.userAnswerStatus = 'wrong';
      });
      await _finalizeAnswer(selected, null, false);
      return;
    }

    // Если первый верный, проверяем наличие Второго Ответа
    bool hasSecondAnswer = q.secondAnswer != null && q.secondAnswer!.trim().isNotEmpty;

    if (hasSecondAnswer) {
      // Показываем диалог
      final result = await SecondAnswerDialog.show(
        context,
        title: 'Errechne das Ergebnis',
        expression: q.answers[selected],
        correctSecondAnswer: q.secondAnswer!,
      );

      if (result != null) {
        setState(() {
          submitted = true;
          q.userAnswerStatus = result.isCorrect ? 'correct' : 'wrong';
        });
        await _finalizeAnswer(selected, result.value, result.isCorrect);
      }
    } else {
      setState(() {
        submitted = true;
        q.userAnswerStatus = 'correct';
      });
      await _finalizeAnswer(selected, null, true);
    }
  }

  void _nextQuestion() {
    // Ищем только те, где статус совсем пустой (еще не видели)
    int nextIndex = questions.indexWhere((q) => q.userAnswerStatus == null);

    if (nextIndex == -1) {
      _finishQuiz();
      return;
    }

    setState(() {
      index = nextIndex;
      selectedIndex = null;
      submitted = false;
      viewingHistory = false;
    });
  }

  // ✅ NEW: Show history question
  void _showHistoryQuestion(int circleIndex) {
    if (circleIndex < historyQuestions.length) {
      setState(() {
        viewingHistory = true;
        historyIndex = circleIndex;
      });
    } else if (circleIndex == historyQuestions.length + index) {
      _returnToPresentQuestion();
    }
  }

  // ✅ NEW: Return to present question
  void _returnToPresentQuestion() {
    setState(() {
      viewingHistory = false;
      historyIndex = null;
    });
  }

  Future<void> _finishQuiz() async {
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    WhiteboardService.hideButton();
    // ✅ Optional: Clear shuffled orders when leaving category
    // Uncomment if you want fresh shuffle each time user enters category
    // _clearShuffledOrders();
    super.dispose();
  }

  // ✅ Optional method to clear saved shuffle orders
  Future<void> _clearShuffledOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('shuffled_answers_${widget.categoryId}');
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: LoadingOverlay()));
    }

    if (questions.isEmpty && historyQuestions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Keine Fragen verfügbar')),
      );
    }

    // Determine which question to show
    QuestionModel displayQuestion;
    int displayIndex;
    bool isHistory = false;
    String? historySelectedAnswerText; // ✅ CHANGED: Store text instead of index

    if (viewingHistory && historyIndex != null) {
      displayQuestion = historyQuestions[historyIndex!];
      displayIndex = historyIndex!;
      isHistory = true;

      // ✅ FIX: Get the actual user's selected answer TEXT from our map
      historySelectedAnswerText = historyUserAnswers[displayQuestion.id];

    } else {
      displayQuestion = questions[index];
      displayIndex = historyQuestions.length + index;
    }

    return LearningQuizQuestionView(
      key: const ValueKey('learning_quiz_view'),
      currentIndex: displayIndex,
      submitted: submitted,
      total: widget.totalQuestions,
      results: answersResult,

      title: widget.categoryName,
      question: displayQuestion.question,
      answers: displayQuestion.answers,
      correctAnswerIndex:
      (isHistory || submitted) ? displayQuestion.correctIndex : null,
      userAnswerStatus: isHistory ? displayQuestion.userAnswerStatus : null,
      selectedAnswerText: isHistory ? historySelectedAnswerText : null, // ✅ CHANGED
      selectedIndex: isHistory ? null : selectedIndex, // ✅ Only for current question
      isViewingHistory: isHistory,
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
      onSkip:
      isHistory
          ? null
          : () {
        _skipQuestion();
      },
      onShowSolution: _handleShowSolution,
      onCircleTap: _showHistoryQuestion,
      onReturnToPresent: _returnToPresentQuestion,
    );
  }

  Future<void> _skipQuestion() async {
    final q = questions[index];
    final circleIndex = historyQuestions.length + index;

    // ✅ Don't change circle color for skipped - keep it null (grey)
    setState(() {
      q.userAnswerStatus = 'skipped';
      // answersResult[circleIndex] stays null (grey circle)
    });

    if (widget.learningMode && widget.categoryId != null) {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      final answerData = {
        'users_permissions_user': userId,
        'question': q.id,
        'category': widget.categoryId.toString(),
        'answer': '',
        'status': 'skipped',
        'answer_type': 'topic',
      };

      await CategoryAnswerService.updateUserAnsweredQuestion(
        answerData: answerData,
      );
    }

    _nextQuestion();
  }

  Future<void> _finalizeAnswer(int selectedIndex, String? secondAnswerVal, bool isFinalCorrect) async {
    final q = questions[index];
    final circleIndex = historyQuestions.length + index;

    // ✅ FIX: Update circle color FIRST with setState
    setState(() {
      answersResult[circleIndex] = isFinalCorrect;
      q.userAnswerStatus = isFinalCorrect ? 'correct' : 'wrong';
    });

    // ✅ Wait a frame to ensure UI updates
    await Future.delayed(Duration.zero);

    // Then send to backend
    if (widget.learningMode && widget.categoryId != null) {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      final answerData = {
        'users_permissions_user': userId,
        'question': q.id,
        'category': widget.categoryId.toString(),
        'answer': q.answers[selectedIndex].toString(),
        'second_answer': secondAnswerVal ?? '',
        'status': isFinalCorrect ? 'correct' : 'wrong',
        'answer_type': 'topic',
      };

      await CategoryAnswerService.updateUserAnsweredQuestion(
        answerData: answerData,
      );
    }
  }
}