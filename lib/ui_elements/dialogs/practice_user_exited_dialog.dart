import 'package:flutter/material.dart';

import '../../app_colors.dart';

Future<bool?> showRivalLeftDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },                  child: const Icon(Icons.close, size: 20),
                ),
              ),
              const Text(
                'Ups!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              const Text(
                'Dein Gegner hat das Spiel verlassen 🤪.\n'
                'Du hast das Spiel gewonnen.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, height: 1.2),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 32,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
