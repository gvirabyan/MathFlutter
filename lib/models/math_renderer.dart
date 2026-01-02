import 'dart:math';

import 'package:flutter/material.dart';

/// ===============================
///  MATH NODE MODEL
/// ===============================

abstract class MathNode {}

class MathText extends MathNode {
  final String text;

  MathText(this.text);
}

class MathRow extends MathNode {
  final List<MathNode> children;

  MathRow(this.children);
}

class MathFraction extends MathNode {
  final MathNode numerator;
  final MathNode denominator;

  MathFraction(this.numerator, this.denominator);
}

class MathSqrt extends MathNode {
  final MathNode value;

  MathSqrt(this.value);
}

/// ===============================
///  PARSER (LaTeX → MathNode)
/// ===============================

// Внутри parseMath добавь обработку сложных случаев или используй цикл по токенам

MathNode parseMath(String raw) {
  raw = raw.trim();
  if (raw.isEmpty) return MathText("");

  // 1. Обработка сложения/вычитания (на верхнем уровне, игнорируя то, что в скобках)
  final topLevelParts = _splitTopLevel(raw, ['+', '-']);
  if (topLevelParts.length > 1) {
    return MathRow(topLevelParts.map((p) {
      if (p == '+' || p == '-') return MathText(" $p ");
      return parseMath(p);
    }).toList());
  }

  // 2. Обработка дробей (улучшенная регулярка)
  final fracRegex = RegExp(r'\\frac\s*\{((?:[^{}]|\{[^{}]*\})*)\}\s*\{((?:[^{}]|\{[^{}]*\})*)\}');
  final fracMatch = fracRegex.firstMatch(raw);
  if (fracMatch != null) {
    return MathFraction(
      parseMath(fracMatch.group(1)!),
      parseMath(fracMatch.group(2)!),
    );
  }

  // 3. Обработка корней
  final sqrtRegex = RegExp(r'\\sqrt\s*\{((?:[^{}]|\{[^{}]*\})*)\}');
  final sqrtMatch = sqrtRegex.firstMatch(raw);
  if (sqrtMatch != null) {
    return MathSqrt(parseMath(sqrtMatch.group(1)!));
  }

  // 4. Очистка оставшихся скобок и нормализация
  String clean = raw.replaceAll('{', '').replaceAll('}', '');
  return MathText(_normalizeSymbols(clean));
}

// Помощник для разделения строки только на верхнем уровне вложенности скобок
List<String> _splitTopLevel(String input, List<String> operators) {
  List<String> parts = [];
  int bracketLevel = 0;
  int lastSplit = 0;

  for (int i = 0; i < input.length; i++) {
    if (input[i] == '{') bracketLevel++;
    if (input[i] == '}') bracketLevel--;

    if (bracketLevel == 0 && operators.contains(input[i])) {
      parts.add(input.substring(lastSplit, i).trim());
      parts.add(input[i]);
      lastSplit = i + 1;
    }
  }
  parts.add(input.substring(lastSplit).trim());
  return parts.where((p) => p.isNotEmpty).toList();
}

List<String> _splitByOperators(String s) {
  final result = <String>[];
  final buffer = StringBuffer();

  for (int i = 0; i < s.length; i++) {
    final c = s[i];
    if (c == '+' || c == '-') {
      if (buffer.isNotEmpty) {
        result.add(buffer.toString());
        buffer.clear();
      }
      result.add(c);
    } else {
      buffer.write(c);
    }
  }

  if (buffer.isNotEmpty) {
    result.add(buffer.toString());
  }

  return result;
}

String _normalizeSymbols(String s) {
  return s
      .replaceAll('-', '−')
      .replaceAll(r'\times', '×')
      .replaceAll(r'\div', '÷')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// ===============================
///  RENDERER (MathNode → Widget)
/// ===============================

Widget buildMath(
  MathNode node, {
  double fontSize = 18,
  Color color = Colors.black,
}) {
  if (node is MathText) {
    return Text(node.text, style: TextStyle(fontSize: fontSize, color: color));
  }

  if (node is MathRow) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children:
          node.children
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: buildMath(e, fontSize: fontSize, color: color),
                ),
              )
              .toList(),
    );
  }

  if (node is MathFraction) {
    final width = max(
      _estimateWidth(node.numerator, fontSize),
      _estimateWidth(node.denominator, fontSize),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: buildMath(
            node.numerator,
            fontSize: fontSize * 0.85,
            color: color,
          ),
        ),
        Container(
          width: width,
          height: 1.5,
          margin: const EdgeInsets.symmetric(vertical: 2),
          color: color,
        ),
        Center(
          child: buildMath(
            node.denominator,
            fontSize: fontSize * 0.85,
            color: color,
          ),
        ),
      ],
    );
  }

  if (node is MathSqrt) {
    return _buildSqrt(node.value, fontSize, color);
  }

  return const SizedBox();
}

double _estimateWidth(MathNode node, double fontSize) {
  if (node is MathText) {
    return node.text.length * fontSize * 0.6;
  }
  if (node is MathRow) {
    return node.children
        .map((e) => _estimateWidth(e, fontSize))
        .fold(0.0, (a, b) => a + b);
  }
  return fontSize * 2;
}

Widget _buildSqrt(MathNode value, double fontSize, Color color) {
  final width = _estimateWidth(value, fontSize * 0.9);

  return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.baseline,
    textBaseline: TextBaseline.alphabetic,
    children: [
      Text(
        '√',
        style: TextStyle(
          fontSize: fontSize * 1.1,
          height: 1,
          color: color,
        ),
      ),
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: width,
            height: 1.5,
            color: color,
          ),
          const SizedBox(height: 4),
          buildMath(
            value,
            fontSize: fontSize * 0.9,
            color: color,
          ),
        ],
      ),
    ],
  );
}

