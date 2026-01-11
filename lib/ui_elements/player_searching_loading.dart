import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget LoadingView() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Центрируем по вертикали
        children: [
          const CircularProgressIndicator(
          ),
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