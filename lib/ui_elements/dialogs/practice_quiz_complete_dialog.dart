import 'package:flutter/material.dart';

enum PracticeQuizResult { win, lose, draw }

class PracticeQuizCompleteDialog extends StatelessWidget {
  final PracticeQuizResult result;
  final int points;
  final VoidCallback onMyStatus;
  final VoidCallback onNewGame;

  const PracticeQuizCompleteDialog({
    super.key,
    required this.result,
    required this.points,
    required this.onMyStatus,
    required this.onNewGame,
  });

  static Future<void> show(
    BuildContext context, {
    required PracticeQuizResult result,
    required int points,
    required VoidCallback onMyStatus,
    required VoidCallback onNewGame,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder:
          (_) => PracticeQuizCompleteDialog(
            result: result,
            points: points,
            onMyStatus: onMyStatus,
            onNewGame: onNewGame,
          ),
    );
  }

  String get _title {
    switch (result) {
      case PracticeQuizResult.win:
        return 'Super! 🏆';
      case PracticeQuizResult.draw:
        return 'Unentschieden 🤝';
      case PracticeQuizResult.lose:
      default:
        return 'Oh schade 😿';
    }
  }

  String get _subtitle {
    switch (result) {
      case PracticeQuizResult.win:
        return 'Du hast $points Punkte gewonnen';
      case PracticeQuizResult.draw:
        return 'Du hast $points Punkte erhalten';
      case PracticeQuizResult.lose:
      default:
        return 'Du hast $points Punkte verloren';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Text(
                  _title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black.withOpacity(0.65),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onMyStatus();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            maxLines: 1,
                            'Mein Status',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onNewGame();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7A1BFF), // purple
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            'Neues Spiel',
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // close icon (top-right)
          Positioned(
            top: 6,
            right: 6,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
              splashRadius: 18,
            ),
          ),
        ],
      ),
    );
  }
}
