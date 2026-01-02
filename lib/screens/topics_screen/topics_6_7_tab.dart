import 'package:flutter/material.dart';
import '../../models/topic_progress_item.dart';
import '../../services/category_service.dart';
import '../../ui_elements/topic_progress_item.dart';
import 'learning_quiz_question_screen.dart';

class Topics67Tab extends StatefulWidget {
  const Topics67Tab({super.key});

  @override
  State<Topics67Tab> createState() => _Topics67TabState();
}

class _Topics67TabState extends State<Topics67Tab> {
  bool isLoading = true;
  List<TopicProgressItem> items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final categories = await CategoryService.getCategoriesByClass(
        categoryClassId: 6, // 3.–4. Klasse
        isAdmin: false,
      );

      final result = categories.map<TopicProgressItem>((cat) {
        return TopicProgressItem(
          categoryId: cat['id'],
          title: cat['attributes']['name'],
          done: cat['answers'] ?? 0,
          total: cat['questions'] ?? 0,
        );
      }).toList();

      setState(() => items = result);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
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
                builder: (_) =>
                    LearningQuizQuestionScreen(
                      categoryId: e.categoryId,
                      learningMode: true,
                      totalQuestions: e.total,

                      awardPoints: false,
                      saveResult: false,
                    ),
              ),
            );          },
        );
      }).toList(),
    );
  }
}
