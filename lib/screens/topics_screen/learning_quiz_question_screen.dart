import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/screens/topics_screen/learning_quiz_question_view.dart';
import 'package:untitled2/services/questions_service.dart';
import 'package:untitled2/ui_elements/dialogs/exist_skiped_dialog.dart';

import '../../models/question_model.dart';
import '../../services/audio_service.dart';
import '../../services/category_answer_service.dart';
import '../../ui_elements/complete_of_learning_page.dart';
import '../../ui_elements/dialogs/second_answer_dialog.dart';
import '../../ui_elements/loading_overlay.dart';
import '../../ui_elements/solution_viewer.dart';
import '../../ui_elements/whiteboard_service.dart';

class LearningQuizQuestionScreen extends StatefulWidget {
  final int totalQuestions;
  final String categoryName;

  final int? categoryId;
  final bool learningMode;

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
  List<bool?> answersResult = [];

  List<QuestionModel> historyQuestions = [];
  int initialHistoryLength = 0;

  Map<int, String> historyUserAnswers = {};

  int index = 0;

  bool viewingHistory = false;
  int? historyIndex;

  late int secondsLeft;

  int? selectedIndex;

  void _handleShowSolution() {
    final currentQuestion =
        viewingHistory && historyIndex != null
            ? historyQuestions[historyIndex!]
            : questions[index];

    SolutionWebView.show(
      context,
      currentQuestion.id,
      widget.categoryName,
    );
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

    final List historyList = data['history'] ?? [];
    final List resultsList = data['results'] ?? [];

    final prefs = await SharedPreferences.getInstance();
    final shuffledOrdersJson = prefs.getString(
      'shuffled_answers_${widget.categoryId}',
    );
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

    historyQuestions =
        historyList.map((e) {
          final questionId = e['id'] as int;
          final correct = e['answer'].toString();
          final wrong =
              (e['wrong_answers'] as List? ?? [])
                  .map((w) => w.toString())
                  .toList();

          List<String> allAnswers;

          if (savedShuffledOrders.containsKey(questionId)) {
            allAnswers = savedShuffledOrders[questionId]!;
          } else {
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

          if (e['user_answer'] != null && e['user_answer']['answer'] != null) {
            final userAnswerText = e['user_answer']['answer'].toString();
            historyUserAnswers[questionModel.id] = userAnswerText;
          }

          return questionModel;
        }).toList();

    questions =
        resultsList.map((e) {
          final questionId = e['id'] as int;
          final correct = e['answer'].toString();
          final wrong =
              (e['wrong_answers'] as List? ?? [])
                  .map((w) => w.toString())
                  .toList();

          List<String> allAnswers;

          if (savedShuffledOrders.containsKey(questionId)) {
            allAnswers = savedShuffledOrders[questionId]!;
          } else {
            allAnswers = [correct, ...wrong];
            allAnswers.shuffle(Random());
            savedShuffledOrders[questionId] = allAnswers;
          }

          return QuestionModel.fromJson({...e, 'shuffled_answers': allAnswers});
        }).toList();

    final ordersToSave = savedShuffledOrders.map(
      (key, value) => MapEntry(key.toString(), value),
    );
    await prefs.setString(
      'shuffled_answers_${widget.categoryId}',
      json.encode(ordersToSave),
    );

    initialHistoryLength = historyQuestions.length;
    final total = (res['meta']?['total'] ?? 0) + initialHistoryLength;

    answersResult = List.generate(total, (i) {
      if (i < initialHistoryLength) {
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

    if (!isFirstCorrect) {
      AudioService().play('wrong');

      setState(() {
        submitted = true;
        q.userAnswerStatus = 'wrong';
      });
      await _finalizeAnswer(selected, null, false);
      return;
    }

    bool hasSecondAnswer =
        q.secondAnswer != null && q.secondAnswer!.trim().isNotEmpty;

    if (hasSecondAnswer) {
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
      AudioService().play('correct');

      setState(() {
        submitted = true;
        q.userAnswerStatus = 'correct';
      });
      await _finalizeAnswer(selected, null, true);
    }

  }

  void _nextQuestion() {
    final q = questions[index];
    final circleIndex = initialHistoryLength + index;

    if (submitted) {
      setState(() {
        if (q.userAnswerStatus == 'correct') {
          answersResult[circleIndex] = true;
        } else if (q.userAnswerStatus == 'wrong') {
          answersResult[circleIndex] = false;
        }

        if (!historyQuestions.contains(q)) {
          historyQuestions.add(q);
          historyUserAnswers[q.id] = q.userSelectedText ?? '';
        }
      });
    }

    int nextIndex = questions.indexWhere((q) => q.userAnswerStatus == null);

    if (nextIndex != -1) {
      setState(() {
        index = nextIndex;
        selectedIndex = null;
        submitted = false;
        viewingHistory = false;
      });
    } else {
      bool hasSkipped = questions.any((q) => q.userAnswerStatus == 'skipped');

      if (hasSkipped) {
        _showSkippedQuestionsDialog();
      } else {
        _finishQuiz();
      }
    }
  }

  void _showSkippedQuestionsDialog() {
    WhiteboardService.hideButton();

    showDialog(
      context: context,
      builder:
          (context) => ExistSkipedDialog(
            onShowSkipped: () {
              WhiteboardService.showButton(context);

              int skippedIndex = questions.indexWhere(
                (q) => q.userAnswerStatus == 'skipped',
              );

              Navigator.pop(context);

              setState(() {
                index = skippedIndex;
                selectedIndex = null;
                submitted = false;
                viewingHistory = false;
              });
            },
            onLeave: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            skippedCount:
                questions.where((q) => q.userAnswerStatus == 'skipped').length,
            onDismiss: () {
              WhiteboardService.showButton(context);
            },
          ),
    );
  }

  void _showHistoryQuestion(int circleIndex) {
    if (circleIndex < initialHistoryLength) {
      setState(() {
        viewingHistory = true;
        historyIndex = circleIndex;
      });
    } else {
      int sessionIndex = circleIndex - initialHistoryLength;
      if (sessionIndex < index) {
        setState(() {
          viewingHistory = true;
          historyIndex = circleIndex;
        });
      } else if (sessionIndex == index) {
        _returnToPresentQuestion();
      }
    }
  }

  void _returnToPresentQuestion() {
    setState(() {
      viewingHistory = false;
      historyIndex = null;
    });
  }

  Future<void> _finishQuiz() async {
    int correctCount =
        questions.where((q) => q.userAnswerStatus == 'correct').length;
    correctCount +=
        historyQuestions.where((q) => q.userAnswerStatus == 'correct').length;
    int totalPoints = correctCount * 3;

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => CompleteOfLearningPage(
              points: totalPoints,
              correctAnswers: correctCount,
              totalQuestions: widget.totalQuestions,
              onStartPractice: () {
                Navigator.pop(context);
              },
              onBottomIconTap: () {
                Navigator.pop(context);
              },
            ),
      ),
    );
  }

  @override
  void dispose() {
    WhiteboardService.hideButton();
    super.dispose();
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

    if (questions.isEmpty && historyQuestions.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _finishQuiz();
        }
      });
      return const Scaffold(body: Center(child: LoadingOverlay()));
    }

    QuestionModel displayQuestion;
    int displayIndex;
    bool isHistory = false;
    String? historySelectedAnswerText;

    if (viewingHistory && historyIndex != null) {
      if (historyIndex! < initialHistoryLength) {
        displayQuestion = historyQuestions[historyIndex!];
        historySelectedAnswerText = historyUserAnswers[displayQuestion.id];
      } else {
        displayQuestion = questions[historyIndex! - initialHistoryLength];
        historySelectedAnswerText = displayQuestion.userSelectedText;
      }
      displayIndex = historyIndex!;
      isHistory = true;
    } else {
      displayQuestion = questions[index];
      displayIndex = initialHistoryLength + index;
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
      selectedAnswerText: isHistory ? historySelectedAnswerText : null,
      selectedIndex: isHistory ? null : selectedIndex,
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
      onSkip: isHistory ? null : _skipQuestion,
      onNext: isHistory ? null : _nextQuestion,
      onShowSolution: _handleShowSolution,
      onCircleTap: _showHistoryQuestion,
      onReturnToPresent: _returnToPresentQuestion,
    );
  }

  Future<void> _skipQuestion() async {
    if (submitted) {
      _nextQuestion();
      return;
    }
    AudioService().play('skipped');

    final q = questions[index];

    setState(() {
      q.userAnswerStatus = 'skipped';
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

  Future<void> _finalizeAnswer(
    int selectedIndex,
    String? secondAnswerVal,
    bool isFinalCorrect,
  ) async {
    final q = questions[index];

    q.userSelectedText = q.answers[selectedIndex];

    setState(() {
      q.userAnswerStatus = isFinalCorrect ? 'correct' : 'wrong';
    });

    await Future.delayed(Duration.zero);

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
