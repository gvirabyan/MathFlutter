import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MathContent extends StatefulWidget {
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
  State<MathContent> createState() => _MathContentState();
}

class _MathContentState extends State<MathContent> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // Запускаем анимацию появления после того, как виджет вставлен в дерево
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  String _decodeHtml(String input) {
    return input
        .replaceAll('&times;', '×')
        .replaceAll('&times', '×')
        .replaceAll('&divide;', '÷')
        .replaceAll('&divide', '÷')
        .replaceAll('&middot;', '·')
        .replaceAll('&nbsp;', ' ');
  }

  String _preprocessLatex(String input) {
    String result = input.replaceAll('pi', r'\pi');
    result = result.replaceAllMapped(
      RegExp(r'sqrt\((.*?)\)'),
          (match) => r'\sqrt{' + (match.group(1) ?? '') + '}',
    );
    result = result.replaceAll(r'\frac', r'\dfrac');
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final double scale = widget.isQuestion ? 1.0 : 0.9;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 700),
      opacity: _isVisible ? 1.0 : 0.0,
      child: _buildBody(context, scale),
    );
  }

  Widget _buildBody(BuildContext context, double scale) {
    final content = widget.content;
    final color = widget.color;
    final fontSize = widget.fontSize;
    final isQuestion = widget.isQuestion;

    if (content.startsWith('@@@')) {
      return Html(
        data: content.substring(3),
        style: {
          "body": Style(
            fontSize: FontSize((isQuestion ? 20 : fontSize) * scale),
            lineHeight: LineHeight.number(1),
            fontFamily: 'Rubik',
            color: color,
          ),
        },
      );
    } else if (content.startsWith('@emoji@')) {
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
    } else if (content.startsWith('@@')) {
      final monoContent = _decodeHtml(content.substring(2));
      final plainText = monoContent
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll('&nbsp;', ' ');
      final lines = plainText.trim().split('\n');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: lines
            .map((line) => Text(
          line.trim(),
          style: TextStyle(
            fontSize: (isQuestion ? 18 : fontSize) * scale,
            height: 1.2,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
            color: color,
          ),
        ))
            .toList(),
      );
    } else if (content.startsWith('@pre@')) {
      final preContent = content.substring(5);
      final plainText = preContent.replaceAll('<br>', '\n');

      final lines = plainText.split('\n');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
        lines
            .map(
              (line) => Text(
            line,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: (isQuestion ? 18 : fontSize) * scale,
              color: color,
            ),
          ),
        )
            .toList(),
      );
    } else if (content.startsWith('@')) {
      return Text(
        content.substring(1),
        style: TextStyle(
          fontSize: (isQuestion ? 18 : fontSize) * scale,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      );
    } else {
      final lines = content.split('\n');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((line) {
          if (line.startsWith(r'$$') && line.endsWith(r'$$')) {
            return Text(
              line.substring(2, line.length - 2),
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: (isQuestion ? 16 : 14) * scale,
                color: color,
              ),
            );
          } else {
            final processedContent = _preprocessLatex(line);
            return _LatexRenderer(
              math: r'\displaystyle ' + processedContent,
              color: color,
              fontSize: (isQuestion ? 18 : 16) * scale,
              processedContent: processedContent,
            );
          }
        }).toList(),
      );
    }
  }
}

class _LatexRenderer extends StatelessWidget {
  final String math;
  final Color color;
  final double fontSize;
  final String processedContent;

  const _LatexRenderer({
    required this.math,
    required this.color,
    required this.fontSize,
    required this.processedContent,
  });

  @override
  Widget build(BuildContext context) {
    return TeX2SVG(
      math: math,
      teXInputType: TeXInputType.teX,
      formulaWidgetBuilder: (context, svg) {
        final hasFraction = processedContent.contains(r'\over') ||
            processedContent.contains(r'\dfrac');
        final heightMultiplier = hasFraction ? 1.8 : 1.0;
        return SvgPicture.string(
          svg,
          height: fontSize * heightMultiplier,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        );
      },
    );
  }
}