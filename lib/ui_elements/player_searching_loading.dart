import 'package:flutter/material.dart';
import 'package:untitled2/ui_elements/loading_overlay.dart';

Widget LoadingView() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Центрируем по вертикали
        children: [
          const LoadingOverlay(),
          const SizedBox(height: 24),
          const Text(
            'Wir suchen nach einem Spieler,\nbitte warte',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    ),
  );
}
