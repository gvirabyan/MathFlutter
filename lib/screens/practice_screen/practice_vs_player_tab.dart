import 'package:flutter/material.dart';

class PracticeVsPlayerTab extends StatelessWidget {
  const PracticeVsPlayerTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.group,
            size: 64,
            color: Colors.deepPurple,
          ),
          SizedBox(height: 16),
          Text(
            'Spieler gegen Spieler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
