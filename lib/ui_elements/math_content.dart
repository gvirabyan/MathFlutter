import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutter_html/flutter_html.dart';

class MathContent extends StatelessWidget {
  final String content;
  final double fontSize;
  final Color color;
  final bool isQuestion;

  const MathContent({
    Key? key,
    required this.content,
    this.fontSize = 18.0,
    this.color = Colors.black,
    this.isQuestion = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double scale = isQuestion ? 1.0 : 0.9;

    // ✅ Обработка специальных форматов (работает везде одинаково)
    if (content.startsWith('@@@')) {
      return Html(
        data: content.substring(3),
        style: {
          "body": Style(
            fontSize: FontSize((isQuestion ? 18 : fontSize) * scale),
            lineHeight: LineHeight.number(1.4),
            fontFamily: 'Rubik',
            color: color,
          ),
        },
      );
    }

    if (content.startsWith('@emoji@')) {
      return Text(
        content.substring(7),
        style: TextStyle(
          fontSize: (isQuestion ? 18 : fontSize) * scale,
          height: 1.4,
          color: color,
        ),
      );
    }

    if (content.startsWith('@@')) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          content.substring(2),
          style: TextStyle(
            fontSize: (isQuestion ? 18 : fontSize) * scale,
            height: 1.2,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
            color: color,
          ),
        ),
      );
    }

    if (content.startsWith('@pre@')) {
      // 1. Убираем @pre@
      String raw = content.substring(5).trim();

      // 2. Разбиваем по <br>
      List<String> lines = raw.split('<br>');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.end, // числа выравниваются вправо
        mainAxisSize: MainAxisSize.min,
        children: lines.map((line) {
          return Text(
            line.trim(),
            style: TextStyle(
              fontFamily: 'monospace', // чтобы цифры ровно стояли
              fontSize: (isQuestion ? 18 : fontSize) * scale,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          );
        }).toList(),
      );
    }


    if (content.startsWith('@')) {
      return Text(
        content.substring(1),
        style: TextStyle(
          fontSize: (isQuestion ? 18 : fontSize) * scale,
          fontWeight: FontWeight.bold,
          color: color,
          height: 1.3,
        ),
      );
    }

    // ✅ LaTeX контент
    final processedContent = _preprocessLatex(content);

    // ✅ КРИТИЧЕСКОЕ: На Android используем упрощённый рендеринг
    if (!kIsWeb && Platform.isAndroid) {
      return _buildAndroidMath(processedContent, scale);
    }

    // ✅ На Web и iOS используем TeXView
    return _buildTeXView(processedContent, scale);
  }

  // ✅ Метод для Android - преобразуем LaTeX в Unicode
  Widget _buildAndroidMath(String content, double scale) {
    String readable = _convertLatexToUnicode(content);

    return SelectableText(
      readable,
      style: TextStyle(
        fontSize: (isQuestion ? 20 : fontSize) * scale,
        fontFamily: 'Rubik',
        color: color,
        height: 1.3,
      ),
    );
  }

  // ✅ Метод для Web/iOS - используем TeXView
  Widget _buildTeXView(String content, double scale) {
    return TeXView(
      loadingWidgetBuilder: (context) => Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.5)),
          ),
        ),
      ),
      child: TeXViewColumn(
        children: [
          TeXViewDocument(
            r'\( \sf ' + content + r' \)',
            style: TeXViewStyle(
              contentColor: color,
              backgroundColor: Colors.transparent,
              padding: const TeXViewPadding.all(0),
              margin: const TeXViewMargin.all(0),
              fontStyle: TeXViewFontStyle(
                fontSize: ((isQuestion ? 22 : 20) * scale).toInt(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Конвертация LaTeX в Unicode для Android
  String _convertLatexToUnicode(String latex) {
    String result = latex
    // Греческие буквы
        .replaceAll(r'\pi', 'π')
        .replaceAll(r'\alpha', 'α')
        .replaceAll(r'\beta', 'β')
        .replaceAll(r'\gamma', 'γ')
        .replaceAll(r'\delta', 'δ')
        .replaceAll(r'\theta', 'θ')
        .replaceAll(r'\lambda', 'λ')
        .replaceAll(r'\mu', 'μ')
        .replaceAll(r'\sigma', 'σ')
        .replaceAll(r'\omega', 'ω')

    // Математические операторы
        .replaceAll(r'\times', '×')
        .replaceAll(r'\div', '÷')
        .replaceAll(r'\pm', '±')
        .replaceAll(r'\leq', '≤')
        .replaceAll(r'\geq', '≥')
        .replaceAll(r'\neq', '≠')
        .replaceAll(r'\approx', '≈')
        .replaceAll(r'\infty', '∞')

    // Корень
        .replaceAllMapped(
      RegExp(r'\\sqrt\{([^}]+)\}'),
          (m) => '√(${m.group(1)})',
    )

    // Дроби: \dfrac{a}{b} → (a)/(b)
        .replaceAllMapped(
      RegExp(r'\\d?frac\{([^}]+)\}\{([^}]+)\}'),
          (m) => '(${m.group(1)})/(${m.group(2)})',
    )

    // Степени: x^{2} → x²
        .replaceAllMapped(
      RegExp(r'([a-zA-Z0-9]+)\^\{?([0-9])\}?'),
          (m) {
        final base = m.group(1);
        final exp = m.group(2);
        final superscripts = ['⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'];
        return '$base${superscripts[int.parse(exp!)]}';
      },
    )

    // Убираем лишние команды
        .replaceAll(r'\left', '')
        .replaceAll(r'\right', '')
        .replaceAll(r'\cdot', '·')
        .replaceAll(r'\,', ' ');

    return result;
  }

  String _preprocessLatex(String input) {
    String result = input
        .replaceAll('pi', r'\pi')
        .replaceAll(r'\frac', r'\dfrac');

    // sqrt(x) -> \sqrt{x}
    result = result.replaceAllMapped(
      RegExp(r'sqrt\(([^)]+)\)'),
          (match) => r'\sqrt{' + (match.group(1) ?? '') + '}',
    );

    return result;
  }
}