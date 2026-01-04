import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/screens/topics_screen/learning_quiz_question_view.dart';
import 'package:untitled2/services/questions_service.dart';

import '../../models/question_model.dart';
import '../../services/category_answer_service.dart';
import '../../services/quiz_service.dart';
import '../../ui_elements/second_answer_dialog.dart';
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
    required this.categoryName, // ✅ Добавлено в обязательные параметры
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
          content: Text('Keine Erklärung für эту задачу verfügbar'),
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

    // ✅ HISTORY — ТОЛЬКО ИЗ BACKEND
    historyQuestions =
        historyList.map((e) {
          return QuestionModel.fromJson({
            'id': e['id'],
            ...e,
            'user_answer': e['user_answer'],
          });
        }).toList();

    // ✅ АКТУАЛЬНЫЕ ВОПРОСЫ
    questions = resultsList.map((e) => QuestionModel.fromJson(e)).toList();

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
    final bool isCorrect = selected == q.correctIndex;

    setState(() {
      submitted = true;

      if (q.secondAnswer == null) {
        questions[index].userAnswerStatus = isCorrect ? 'correct' : 'wrong';
      } else {
        questions[index].userAnswerStatus = null;
      }
    });

    // ✅ Learning mode - save to backend and add to history
    if (widget.learningMode && widget.categoryId != null && q.secondAnswer == null) {
      final circleIndex = historyQuestions.length + index;
      answersResult[circleIndex] = isCorrect;

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
    }
    if (q.secondAnswer != null && isCorrect) {
      final result = await SecondAnswerDialog.show(
        context,
        title: 'Errechne das Ergebnis',
        expression: q.answers[selected],
        correctSecondAnswer: q.secondAnswer!,
      );

      if (result != null) {
        _finishSecondAnswer(
          result.value,
          result.isCorrect,
        );
      }
    }else if (q.secondAnswer != null && !isCorrect) {
      // ❗ НЕТ second answer → сразу финальный wrong
      _finishSecondAnswer(null, false);
    }


  }

  void _nextQuestion() {
    // Ищем только те, где статус совсем пустой (еще не видели)
    int nextIndex = questions.indexWhere((q) => q.userAnswerStatus == null);

    if (nextIndex == -1) {
      // Если новых нет, можно закончить или пойти по второму кругу по 'skipped'
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
      displayIndex =
          isHistory ? historyIndex! : historyQuestions.length + index;
    }

    return LearningQuizQuestionView(
      key: ValueKey('${displayIndex}_${isHistory ? 'history' : 'current'}'),
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
      selectedIndex: selectedIndex,
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
      onShowSolution: _handleShowSolution, // ✅ Теперь используется созданная логика
      onCircleTap: _showHistoryQuestion,
      onReturnToPresent: _returnToPresentQuestion,
    );
  }

  void _finishSecondAnswer(String? value, bool isCorrect) async {
    final q = questions[index];

    final finalStatus = isCorrect ? 'correct' : 'wrong';

    setState(() {
      q.userAnswerStatus = finalStatus;

      final circleIndex = historyQuestions.length + index;
      answersResult[circleIndex] = isCorrect;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    await CategoryAnswerService.updateUserAnsweredQuestion(
      answerData: {
        'users_permissions_user': userId,
        'question': q.id,
        'category': widget.categoryId.toString(),
        'answer': q.answers[selectedIndex!],
        'second_answer': value ?? '',
        'status': finalStatus,
        'answer_type': 'topic',
      },
    );

    _nextQuestion(); // ✅ обычный next, как ты хотел
  }




  Future<void> _skipQuestion() async {
    final q = questions[index];
    final circleIndex = historyQuestions.length + index;

    setState(() {
      q.userAnswerStatus = 'skipped';
      // Устанавливаем null, чтобы кружок остался серым/нейтральным
      answersResult[circleIndex] = null;
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

    _nextQuestion(); // Переход к следующему согласно вашей новой логике
  }

}
