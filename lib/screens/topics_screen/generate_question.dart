import 'package:flutter/material.dart';
import 'package:untitled2/screens/topics_screen/reciew_question.dart';
import 'package:untitled2/services/questions_service.dart';

import '../../ui_elements/math_content.dart';

// ---------------------------------------------------------------------------
// MODEL
// ---------------------------------------------------------------------------
class Exercise {
  final String id;
  final String question;
  final String answer;
  final List<String> wrongAnswers;
  final String? secondAnswer;

  Exercise({
    required this.id,
    required this.question,
    required this.answer,
    required this.wrongAnswers,
    this.secondAnswer,
  });
}

// ---------------------------------------------------------------------------
// MOCK DATA — замени на свой API вызов
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// PAGE
// ---------------------------------------------------------------------------
class GenerateQuestionPage extends StatefulWidget {
  final int categoryId;
  final VoidCallback? onBack;

  const GenerateQuestionPage({
    super.key,
    required this.categoryId,
    this.onBack,
  });

  @override
  State<GenerateQuestionPage> createState() => _GenerateQuestionPageState();
}

class _GenerateQuestionPageState extends State<GenerateQuestionPage> {
  bool _isLoading = true;
  String _categoryName = '';
  List<Exercise> _allQuestions = [];
  final Map<String, Exercise> _shortlisted = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final resp = await QuestionsService.getQuestionsForAdmin(
        categoryId: widget.categoryId,
        isAdmin: true,
      );
      // API возвращает { "data": { "results": [...], "category_name": "..." }, "meta": {...} }
      final inner = resp['data'] as Map<String, dynamic>;
      setState(() {
        _categoryName = inner['category_name'] as String? ?? '';
        _allQuestions =
            (inner['results'] as List? ?? [])
                .map(
                  (e) => Exercise(
                    id: e['id'].toString(),
                    question: e['question'] as String? ?? '',
                    answer: e['answer'] as String? ?? '',
                    wrongAnswers:
                        (e['wrong_answers'] as List? ?? [])
                            .map((v) => v.toString())
                            .toList(),
                    secondAnswer:
                        (e['second_answer'] as String?)?.isEmpty == true
                            ? null
                            : e['second_answer'] as String?,
                  ),
                )
                .toList();
        _isLoading = false;
      });
    } catch (e, st) {
      setState(() => _isLoading = false);
    }
  }

  void _toggleExercise(int index) {
    final q = _allQuestions[index];
    setState(() {
      if (_shortlisted.containsKey(q.id)) {
        _shortlisted.remove(q.id);
      } else {
        _shortlisted[q.id] = q;
      }
    });
  }

  void _removeShortlisted(String id) => setState(() => _shortlisted.remove(id));

  Future<void> _createQuestions() async {
    setState(() => _isLoading = true);
    final buffer = StringBuffer('Topic name: $_categoryName\n');
    int i = 1;
    for (final q in _shortlisted.values) {
      buffer.write('Exercise example $i: ${q.question}\n');
      buffer.write('Correct answer: ${q.answer}\n');
      buffer.write('Wrong answers: [${q.wrongAnswers.join(',')}]\n');
      buffer.write('Second answer: ${q.secondAnswer}\n');
      i++;
    }
    await QuestionsService.createNewQuestions({
      'categoryId': widget.categoryId,
      'content': buffer.toString(),
    });    setState(() => _isLoading = false);
    if (mounted) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Done'),
              content: Text(buffer.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: widget.onBack ?? () => Navigator.maybePop(context),
        ),
        title: Text(_isLoading ? 'Loading...' : _categoryName),
        actions: [
          TextButton(
            onPressed: _shortlisted.isEmpty ? null : _createQuestions,
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Основной список ───────────────────────────────────────────
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 140),
            itemCount: _allQuestions.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final ex = _allQuestions[index];
              final isShortlisted = _shortlisted.containsKey(ex.id);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Вопрос
                    MathContent(
                      content: ex.question,
                      isQuestion: true,
                      fontSize: 18,
                    ),
                    const SizedBox(height: 8),

                    // Правильный ответ — жёлтый фон
                    Container(
                      width: double.infinity,
                      color: Colors.yellow,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: MathContent(
                        content: ex.answer,
                        isQuestion: false,
                        fontSize: 16,
                      ),
                    ),

                    // Неправильные ответы
                    ...ex.wrongAnswers.map(
                      (wa) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: MathContent(
                          content: wa,
                          isQuestion: false,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    // Второй ответ — голубой фон
                    if (ex.secondAnswer != null)
                      Container(
                        width: double.infinity,
                        color: Colors.lightBlue[100],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Text(ex.secondAnswer!),
                      ),

                    const SizedBox(height: 10),

                    // Кнопка Add / Remove
                    ElevatedButton(
                      onPressed: () => _toggleExercise(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isShortlisted ? Colors.red[300] : null,
                      ),
                      child: Text(isShortlisted ? 'Remove' : 'Add Exercise'),
                    ),
                  ],
                ),
              );
            },
          ),

          // ── Лоадер ───────────────────────────────────────────────────
          if (_isLoading) const Center(child: CircularProgressIndicator()),

          // ── Фиксированная панель снизу ────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 140),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ссылка на Review
                  TextButton(
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ReviewQuestionPage(
                                  categoryId: widget.categoryId,
                                ),
                          ),
                        ),
                    child: const Text('Review'),
                  ),

                  // Shortlisted вопросы
                  Flexible(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children:
                          _shortlisted.values.map((ex) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: MathContent(
                                      content: ex.question,
                                      isQuestion: false,
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _removeShortlisted(ex.id),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
