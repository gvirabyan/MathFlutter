import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    // 🔹 Единый масштаб (можно легко подкрутить)
    final double scale = isQuestion ? 1.0 : 0.9;

    if (content.startsWith('@@@')) {
      return Html(
        data: content.substring(3),
        style: {
          "body": Style(
            fontSize: FontSize((isQuestion ? 18 : fontSize) * scale),
            lineHeight: LineHeight.number(1),
            fontFamily: 'Rubik',
            color: color,
          ),
        },
      );
    }
    else if (content.startsWith('@emoji@')) {
      return Text(
        content.substring(7),
        style: TextStyle(
          fontSize: (isQuestion ? 18 : fontSize) * scale,
          height: 1.4,
          color: color,
        ),
      );
    }
    else if (content.startsWith('@@')) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          content.substring(2),
          style: TextStyle(
            fontSize: (isQuestion ? 18 : fontSize) * scale,
            height: 1,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
            color: color,
          ),
        ),
      );
    }
    else if (content.startsWith('@pre@')) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          content.substring(5),
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: (isQuestion ? 18 : fontSize) * scale,
            color: color,
          ),
        ),
      );
    }
    else if (content.startsWith('@')) {
      return Text(
        content.substring(1),
        style: TextStyle(
          fontSize: (isQuestion ? 18 : fontSize) * scale,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      );
    }
    else {
      final processedContent = _preprocessLatex(content);

      return TeX2SVG(
        math: r'\(\displaystyle ' + processedContent + r'\)',
        teXInputType: TeXInputType.teX,
        formulaWidgetBuilder: (context, svg) {
          final double finalFontSize = (isQuestion ? 22 : 20) * scale;
          return SvgPicture.string(
            svg,
            height: finalFontSize,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          );
        },
      );
    }
  }

  String _preprocessLatex(String input) {
    String result = input.replaceAll('pi', r'\pi');

    // sqrt(x) -> \sqrt{x}
    result = result.replaceAllMapped(
      RegExp(r'sqrt\((.*?)\)'),
          (match) => r'\sqrt{' + (match.group(1) ?? '') + '}',
    );

    // делаем дроби визуально нормальными
    result = result.replaceAll(r'\frac', r'\dfrac');

    return result;
  }
}
