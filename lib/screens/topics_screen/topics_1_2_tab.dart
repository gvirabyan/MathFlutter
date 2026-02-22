import 'package:flutter/material.dart';
import '../../models/topic_progress_item.dart';
import '../../services/topics_cache_service.dart';
import '../../ui_elements/loading_overlay.dart';
import '../../ui_elements/topic_progress_item.dart';
import 'learning_quiz_question_screen.dart';

class Topics12Tab extends StatefulWidget {
  const Topics12Tab({super.key});

  @override
  State<Topics12Tab> createState() => _Topics12TabState();
}

class _Topics12TabState extends State<Topics12Tab> {
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
        categoryClassId: 1, // 1.–2. Klasse
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
          onTap: () {
            Navigator.push(
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
          },
        );
      }).toList(),
    );
  }
}