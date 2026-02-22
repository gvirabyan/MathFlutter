import 'package:flutter/material.dart';
import 'package:untitled2/services/questions_service.dart';

import '../../ui_elements/math_content.dart';
import 'generate_question.dart';

class ReviewQuestionPage extends StatefulWidget {
  final int categoryId;
  final VoidCallback? onBack;

  const ReviewQuestionPage({super.key, required this.categoryId, this.onBack});

  @override
  State<ReviewQuestionPage> createState() => _ReviewQuestionPageState();
}

class _ReviewQuestionPageState extends State<ReviewQuestionPage> {
  bool _isLoading = true;
  String _categoryName = '';
  List<_ExerciseWithMeta> _allQuestions = [];

  // double-tap guard для Delete (500ms — как в Vue версии)
  int _clickedToDelete = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final resp = await QuestionsService.getQuestionsForAdmin(
        categoryId: widget.categoryId,
      );
      // API возвращает { "data": { "results": [...], "category_name": "..." }, "meta": {...} }
      final inner = resp['data'] as Map<String, dynamic>;
      setState(() {
        _categoryName = inner['category_name'] as String? ?? '';
        _allQuestions = (inner['results'] as List? ?? [])
            .map((e) => _ExerciseWithMeta(
          exercise: Exercise(
            id: e['id'].toString(),
            question: e['question'] as String? ?? '',
            answer: e['answer'] as String? ?? '',
            wrongAnswers: (e['wrong_answers'] as List? ?? [])
                .map((v) => v.toString())
                .toList(),
            secondAnswer: (e['second_answer'] as String?)?.isEmpty == true
                ? null
                : e['second_answer'] as String?,
          ),
          publishedAt: e['publishedAt'] as String?,
        ))
            .toList();
        _isLoading = false;
      });
    } catch (e, st) {

          setState(() => _isLoading = false);
  }
  }

  // ── Логика Delete с double-tap защитой ───────────────────────────────────
  void _handleDelete(int index) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_clickedToDelete != 0 && now - _clickedToDelete < 500) {
      _doEdit(index, 'delete');
    } else {
      _clickedToDelete = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Нажми ещё раз для подтверждения'),
          duration: Duration(milliseconds: 500),
        ),
      );
    }
  }

  Future<void> _doEdit(int index, String action) async {
    setState(() => _isLoading = true);
    final item = _allQuestions[index];

    // TODO: заменить на реальный API
    // await updateExercise(questionId: item.exercise.id, action: action);
    await Future.delayed(const Duration(milliseconds: 600));

    setState(() {
      if (action == 'delete') {
        _allQuestions.removeAt(index);
      } else if (action == 'publish') {
        _allQuestions[index] = item.copyWith(
          publishedAt: DateTime.now().toIso8601String(),
        );
      } else if (action == 'unpublish') {
        _allQuestions[index] = item.copyWith(clearPublished: true);
      }
      _isLoading = false;
    });
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Text(
              '${_allQuestions.length}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Основной список ───────────────────────────────────────────
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
            // +1 для кнопки "Generate" в конце списка
            itemCount: _allQuestions.length + 1,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              // Последний элемент — кнопка Generate
              if (index == _allQuestions.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: TextButton(
                    onPressed:
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => GenerateQuestionPage(
                          categoryId: widget.categoryId,
                        ),
                      ),
                    ),
                    child: const Text('Generate'),
                  ),
                );
              }

              final item = _allQuestions[index];
              final ex = item.exercise;
              final isPublished = item.publishedAt != null;

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

                    // Action row: Publish/Unpublish · ID · Delete
                    Row(
                      children: [
                        if (!isPublished)
                          _AdminButton(
                            label: 'Publish',
                            color: const Color(0xFF157508),
                            onPressed: () => _doEdit(index, 'publish'),
                          ),
                        if (isPublished)
                          _AdminButton(
                            label: 'Unpublish',
                            color: const Color(0xFFF8E302),
                            textColor: Colors.black,
                            onPressed: () => _doEdit(index, 'unpublish'),
                          ),
                        const SizedBox(width: 20),
                        Text(
                          ex.id,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 20),
                        _AdminButton(
                          label: 'Delete',
                          color: Colors.red,
                          onPressed: () => _handleDelete(index),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // ── Лоадер ───────────────────────────────────────────────────
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _ExerciseWithMeta {
  final Exercise exercise;
  final String? publishedAt;

  const _ExerciseWithMeta({required this.exercise, this.publishedAt});

  _ExerciseWithMeta copyWith({
    String? publishedAt,
    bool clearPublished = false,
  }) {
    return _ExerciseWithMeta(
      exercise: exercise,
      publishedAt: clearPublished ? null : (publishedAt ?? this.publishedAt),
    );
  }
}

class _AdminButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  const _AdminButton({
    required this.label,
    required this.color,
    required this.onPressed,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: const TextStyle(
          fontFamily: 'Rubik',
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      child: Text(label),
    );
  }
}