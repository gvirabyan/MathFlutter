import 'package:flutter/material.dart';

class TopListTab extends StatelessWidget {
  const TopListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.purple.shade100,
            child: Text('${index + 1}'),
          ),
          title: Text('Benutzer ${index + 1}'),
          trailing: const Text(
            '1200',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}
