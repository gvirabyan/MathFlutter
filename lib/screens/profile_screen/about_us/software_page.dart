import 'package:flutter/material.dart';

class SoftwarePage extends StatelessWidget {
  const SoftwarePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Software-Lizenzen'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => Divider(
          height: 24,
          thickness: 0.6,
          color: Colors.grey.withOpacity(0.3),
        ),
        itemBuilder: (context, index) {
          return Text(
            _items[index],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          );
        },
      ),
    );
  }
}

/// 🔹 только названия, без ссылок
const List<String> _items = [
  'Wonderpush',
  'Microsoft Clarity',
  'Strapi',
  'Framework7',
  'Google Places API',
  'Moment.js',
  'better-sqlite3',
  'i18n',
  'PostgreSQL client',
];
