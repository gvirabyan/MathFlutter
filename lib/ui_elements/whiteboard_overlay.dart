import 'package:flutter/material.dart';

class Stroke {
  final List<Offset> points;
  final Color color;
  Stroke(this.points, this.color);
}

class WhiteboardOverlay extends StatefulWidget {
  final List<Stroke> initialStrokes;
  final Function(List<Stroke>) onSave;

  const WhiteboardOverlay({
    super.key,
    required this.initialStrokes,
    required this.onSave
  });

  @override
  State<WhiteboardOverlay> createState() => _WhiteboardOverlayState();
}

class _WhiteboardOverlayState extends State<WhiteboardOverlay> {
  late List<Stroke> _strokes;
  List<Offset> _currentPoints = [];

  final List<Color> _colors = [
    Colors.white, Colors.yellow, Colors.orange,

  ];
  Color _selectedColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _strokes = List.from(widget.initialStrokes); // Загружаем историю
  }

  void _sync() => widget.onSave(_strokes);

  void _endStroke() {
    if (_currentPoints.isNotEmpty) {
      setState(() {
        _strokes.add(Stroke(List.of(_currentPoints), _selectedColor));
        _currentPoints = [];
      });
      _sync();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Container(color: Colors.black.withOpacity(0.4))),
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (d) => setState(() => _currentPoints = [d.localPosition]),
            onPanUpdate: (d) => setState(() => _currentPoints.add(d.localPosition)),
            onPanEnd: (_) => _endStroke(),
            child: CustomPaint(
              painter: _WhiteboardPainter(
                  strokes: _strokes,
                  current: _currentPoints,
                  currentColor: _selectedColor
              ),
            ),
          ),
        ),
        // Панель управления
        Positioned(
          left: 0, right: 0, bottom: 30,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Селектор цветов по центру
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _colors.map((c) => GestureDetector(
                        onTap: () => setState(() => _selectedColor = c),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 26, height: 26,
                          decoration: BoxDecoration(
                            color: c, shape: BoxShape.circle,
                            border: Border.all(
                                color: _selectedColor == c ? Colors.white : Colors.black54,
                                width: 2
                            ),
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                  // Фиолетовые кнопки справа
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ActionButton(
                          icon: Icons.refresh,
                          onPressed: () {
                            setState(() => _strokes.clear());
                            _sync();
                          },
                        ),
                        const SizedBox(width: 8),
                        _ActionButton(
                          icon: Icons.history,
                          onPressed: _strokes.isEmpty ? null : () {
                            setState(() => _strokes.removeLast());
                            _sync();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  const _ActionButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Opacity(
        opacity: onPressed == null ? 0.5 : 1.0,
        child: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF7B2CFE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}

class _WhiteboardPainter extends CustomPainter {
  final List<Stroke> strokes;
  final List<Offset> current;
  final Color currentColor;
  _WhiteboardPainter({required this.strokes, required this.current, required this.currentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var s in strokes) {
      paint.color = s.color;
      _draw(canvas, s.points, paint);
    }
    if (current.isNotEmpty) {
      paint.color = currentColor;
      _draw(canvas, current, paint);
    }
  }

  void _draw(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.length < 2) return;
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}