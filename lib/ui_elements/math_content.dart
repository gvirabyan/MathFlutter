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
      final emojiContent = content.substring(7);
      final plainText = emojiContent.replaceAll(RegExp(r'<[^>]*>'), '');
      return Text(
        plainText,
        style: TextStyle(
          fontSize: (isQuestion ? 18 : fontSize) * scale,
          height: 1.4,
          color: color,
        ),
      );
    }
    else if (content.startsWith('@@')) {
      final monoContent = content.substring(2);
      final plainText = monoContent
          .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
          .replaceAll('&nbsp;', ' '); // Replace &nbsp; with a space
      final lines = plainText.trim().split('\n');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines
            .map((line) => Text(
          line.trim(),
          style: TextStyle(
            fontSize: (isQuestion ? 18 : fontSize) * scale,
            height: 1.2, // Adjust height for better spacing
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
            color: color,
          ),
        ))
            .toList(),
      );
    }
    else if (content.startsWith('@pre@')) {
      final preContent = content.substring(5);
      final plainText = preContent.replaceAll('<br>', '\n');
      final lines = plainText.trim().split('\n');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines
            .map((line) => Text(
          line.trim(),
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: (isQuestion ? 18 : fontSize) * scale,
            color: color,
          ),
        ))
            .toList(),
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
      final lines = content.split('\n');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((line) {
          if (line.startsWith(r'$$') && line.endsWith(r'$$')) {
            // It's a plain text line
            return Text(
              line.substring(2, line.length - 2),
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: (isQuestion ? 16 : 14) * scale,
                color: color,
              ),
            );
          } else {
            // It's a LaTeX line
            final processedContent = _preprocessLatex(line);
            return _LatexRenderer(
              math: r'\displaystyle ' + processedContent,
              color: color,
              fontSize: (isQuestion ? 18 : 16) * scale,
            );
          }
        }).toList(),
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

class _LatexRenderer extends StatefulWidget {
  final String math;
  final Color color;
  final double fontSize;

  const _LatexRenderer({
    required this.math,
    required this.color,
    required this.fontSize,
  });

  @override
  State<_LatexRenderer> createState() => _LatexRendererState();
}

class _LatexRendererState extends State<_LatexRenderer> {
  bool _isReady = false;
  late String _currentMath;

  @override
  void initState() {
    super.initState();
    _currentMath = widget.math;
  }

  @override
  void didUpdateWidget(_LatexRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.math != widget.math) {
      setState(() {
        _isReady = false;
        _currentMath = widget.math;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _isReady ? 1.0 : 0.0,
      child: TeX2SVG(
        math: widget.math,
        teXInputType: TeXInputType.teX,
        formulaWidgetBuilder: (context, svg) {
          if (!_isReady) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _isReady = true;
                });
              }
            });
          }
          return SvgPicture.string(
            svg,
            height: widget.fontSize,
            colorFilter: ColorFilter.mode(widget.color, BlendMode.srcIn),
          );
        },
      ),
    );
  }
}
