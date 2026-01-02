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
    if (content.startsWith('@@@')) {
      return Html(
        data: content.substring(3),
        style: {
          "body": Style(
            fontSize: FontSize(isQuestion ? 20 : fontSize),
            lineHeight: LineHeight.number(1),
            fontFamily: 'Rubik',
            color: color,
          ),
        },
      );
    } else if (content.startsWith('@emoji@')) {
      return Text(
        content.substring(7),
        style: TextStyle(
          fontSize: isQuestion ? 20 : fontSize,
          height: 1.5,
          color: color,
        ),
      );
    } else if (content.startsWith('@@')) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          content.substring(2),
          style: TextStyle(
            fontSize: isQuestion ? 20 : fontSize,
            height: 1,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            letterSpacing: 5,
            color: color,
          ),
        ),
      );
    } else if (content.startsWith('@pre@')) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          content.substring(5),
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: isQuestion ? 20 : fontSize,
            color: color,
          ),
        ),
      );
    } else if (content.startsWith('@')) {
      return Text(
        content.substring(1),
        style: TextStyle(
          fontSize: isQuestion ? 20 : fontSize,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      );
    } else {
      final processedContent = _preprocessLatex(content);
      return TeXWidget(
        math: '\\( \\sf $processedContent \\)',
        teXStyle: TeXStyle(
          normalColor: color,
          fontStyle: TeXViewFontStyle(
            fontSize: isQuestion ? 20 : 18,
          ),
        ),
      );
    }
  }

  String _preprocessLatex(String input) {
    String result = input.replaceAll('pi', r'\pi');
    // More robust sqrt replacement
    result = result.replaceAllMapped(RegExp(r'sqrt\((.*?)\)'), (match) {
      return r'\sqrt{' + (match.group(1) ?? '') + '}';
    });
    result = result.replaceAll(r'\frac', r'\dfrac');
    return result;
  }
}
