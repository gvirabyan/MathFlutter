import 'package:flutter/material.dart';

class ProgressTab extends StatelessWidget {
  const ProgressTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dein Fortschritt',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          LinearProgressIndicator(
            value: 0.6,
            minHeight: 10,
          ),
          SizedBox(height: 12),
          Text('60% abgeschlossen'),
        ],
      ),
    );
  }
}
