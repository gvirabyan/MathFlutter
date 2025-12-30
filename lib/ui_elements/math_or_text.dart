import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';

class SmartMathText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const SmartMathText({Key? key, required this.text, this.style}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Обычный текст @@@
    if (text.startsWith('@@@')) {
      return Text(text.substring(3), style: style ?? const TextStyle(fontSize: 18));
    }

    // 2. Моноширинный текст @@
    if (text.startsWith('@@')) {
      return Text(
        text.substring(2),
        style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 18),
      );
    }

    // 3. LaTeX рендеринг
    String content = text.startsWith('@') ? text.substring(1) : text;

    // Оборачиваем в стандартные теги TeXView
    return TeXView(
      loadingWidgetBuilder: (context) => const Center(child: CircularProgressIndicator()),
      child: TeXViewDocument(
        r'$$' + content + r'$$',
        style: TeXViewStyle(
          contentColor: style?.color ?? Colors.black,
          backgroundColor: Colors.transparent,
        ),
      ),
      // Это важно для работы внутри списков
      style: const TeXViewStyle(elevation: 0, backgroundColor: Colors.transparent),
    );
  }
}