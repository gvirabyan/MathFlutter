
import 'package:flutter/material.dart';
import 'status_tab.dart';
import 'top_list_tab.dart';
import 'answers_tab.dart';
import 'progress_tab.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabBarView(
      children: [
        StatusTab(),
        TopListTab(),
        AnswersTab(),
        ProgressTab(),
      ],
    );
  }
}
