import 'package:flutter/material.dart';
import '../../models/topic_progress_item.dart';
import '../../services/category_service.dart';
import '../../ui_elements/topic_progress_item.dart';

class Topics78Tab extends StatefulWidget {
  const Topics78Tab({super.key});

  @override
  State<Topics78Tab> createState() => _Topics78TabState();
}

class _Topics78TabState extends State<Topics78Tab> {
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
        categoryClassId: 7, // 3.–4. Klasse
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
            // TODO: переход внутрь темы 3.–4. Klasse
          },
        );
      }).toList(),
    );
  }
}
