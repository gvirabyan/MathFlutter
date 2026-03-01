import 'package:flutter/material.dart';
import '../../models/topic_progress_item.dart';
import '../../services/topics_cache_service.dart';
import '../../ui_elements/loading_overlay.dart';
import '../../ui_elements/topic_progress_item.dart';
import 'learning_quiz_question_screen.dart';

class Topics1112Tab extends StatefulWidget {
  const Topics1112Tab({super.key});

  @override
  State<Topics1112Tab> createState() => _Topics1112TabState();
}

class _Topics1112TabState extends State<Topics1112Tab> {
  static const int _categoryClassId = 11;

  bool isLoading = true;
  List<TopicProgressItem> items = [];
  final _cacheService = TopicsCacheService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await _cacheService.getCategoriesForClass(
        categoryClassId: _categoryClassId,
        onUpdate: (updatedItems) {
          if (mounted) {
            setState(() {
              items = updatedItems;
            });
          }
        },
      );

      setState(() {
        items = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  /// Тихое обновление без индикатора загрузки
  Future<void> _silentRefresh() async {
    try {
      _cacheService.clearCacheForClass(_categoryClassId);
      final result = await _cacheService.getCategoriesForClass(
        categoryClassId: _categoryClassId,
        onUpdate: (updatedItems) {
          if (mounted) setState(() => items = updatedItems);
        },
      );
      if (mounted) setState(() => items = result);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: LoadingOverlay());
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: items.map((e) {
        return TopicProgressItemWidget(
          title: e.title,
          done: e.done,
          total: e.total,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LearningQuizQuestionScreen(
                  categoryId: e.categoryId,
                  categoryName: e.title,
                  learningMode: true,
                  totalQuestions: e.total,
                  awardPoints: false,
                  saveResult: false,
                ),
              ),
            );
            _silentRefresh();
          },
        );
      }).toList(),
    );
  }
}