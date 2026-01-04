import 'package:flutter/material.dart';
import '../app_colors.dart';
import 'whiteboard_overlay.dart';

class WhiteboardService {
  static OverlayEntry? _boardEntry;
  static OverlayEntry? _buttonEntry;
  static bool _isBoardVisible = false;

  // ✅ Хранилище для рисунков, чтобы они не стирались
  static List<Stroke> history = [];

  static void showButton(BuildContext context) {
    if (_buttonEntry != null) return;
    _buttonEntry = OverlayEntry(
      builder: (_) => Positioned(
        right: 0,
        top: MediaQuery.of(context).size.height * 0.42,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () => toggleBoard(context),
            child: Container(
              width: 44,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
                border: Border.all(color: AppColors.primaryPurple, width: 1),
              ),
              child: const Center(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    'WHITEBOARD',
                    style: TextStyle(
                      color: AppColors.primaryPurple,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_buttonEntry!);
  }

  static void toggleBoard(BuildContext context) {
    if (_isBoardVisible) {
      _hideBoard();
    } else {
      _showBoard(context);
    }
  }

  static void _showBoard(BuildContext context) {
    if (_boardEntry != null) return;
    _boardEntry = OverlayEntry(
      builder: (_) => WhiteboardOverlay(
        initialStrokes: history, // ✅ Передаем сохраненные штрихи
        onSave: (newStrokes) => history = newStrokes, // ✅ Сохраняем при изменениях
      ),
    );

    if (_buttonEntry != null) {
      Overlay.of(context, rootOverlay: true).insert(_boardEntry!, below: _buttonEntry);
    } else {
      Overlay.of(context, rootOverlay: true).insert(_boardEntry!);
    }
    _isBoardVisible = true;
  }

  static void _hideBoard() {
    _boardEntry?.remove();
    _boardEntry = null;
    _isBoardVisible = false;
  }

  static void hideButton() {
    _hideBoard();
    _buttonEntry?.remove();
    _buttonEntry = null;
    history.clear(); // Очищаем историю при полном выходе с экрана
  }
}