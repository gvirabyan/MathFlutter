import 'dart:math';
import 'package:flutter/material.dart';

/// ===============================
///  MODELS & ENUMS
/// ===============================

// Добавляем перечисление стилей, как в Vue логике
enum TextStyleType { normal, mono, code, emoji, latex }

abstract class MathNode {}

class MathText extends MathNode {
  final String text;
  final TextStyleType styleType; // Добавлено поле стиля

  MathText(this.text, {this.styleType = TextStyleType.latex});
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

MathNode parseMath(String raw) {
  raw = raw.trim();
  if (raw.isEmpty) return MathText("");

  // 1. Проверка префиксов (Логика 1:1 из Vue)
  if (raw.startsWith('@@@')) {
    return MathText(raw.substring(3), styleType: TextStyleType.normal);
  }
  if (raw.startsWith('@@')) {
    return MathText(raw.substring(2), styleType: TextStyleType.mono);
  }
  if (raw.startsWith('@emoji@')) {
    return MathText(raw.substring(7), styleType: TextStyleType.emoji);
  }
  if (raw.startsWith('@pre@')) {
    return MathText(raw.substring(5), styleType: TextStyleType.code);
  }
  if (raw.startsWith('@')) {
    return MathText(raw.substring(1), styleType: TextStyleType.normal);
  }

  // 2. Если префиксов нет, проверяем на операторы верхнего уровня (+, -)
  final topLevelParts = _splitTopLevel(raw, ['+', '-']);
  if (topLevelParts.length > 1) {
    return MathRow(topLevelParts.map((p) {
      if (p == '+' || p == '-') return MathText(" $p ");
      return parseMath(p);
    }).toList());
  }

  // 3. Обработка дробей \frac{a}{b}
  final fracRegex = RegExp(r'\\frac\s*\{((?:[^{}]|\{[^{}]*\})*)\}\s*\{((?:[^{}]|\{[^{}]*\})*)\}');
  final fracMatch = fracRegex.firstMatch(raw);
  if (fracMatch != null) {
    return MathFraction(
      parseMath(fracMatch.group(1)!),
      parseMath(fracMatch.group(2)!),
    );
  }

  // 4. Обработка корней \sqrt{x}
  final sqrtRegex = RegExp(r'\\sqrt\s*\{((?:[^{}]|\{[^{}]*\})*)\}');
  final sqrtMatch = sqrtRegex.firstMatch(raw);
  if (sqrtMatch != null) {
    return MathSqrt(parseMath(sqrtMatch.group(1)!));
  }

  // 5. Очистка скобок для финального текста
  String clean = raw.replaceAll('{', '').replaceAll('}', '');
  return MathText(_normalizeSymbols(clean), styleType: TextStyleType.latex);
}

/// ===============================
///  HELPERS
/// ===============================

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

Widget buildMath(MathNode node, {double fontSize = 18, Color? color}) {
  if (node is MathText) {
    TextStyle style;
    switch (node.styleType) {
      case TextStyleType.mono:
        style = TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
          fontSize: fontSize,
          color: color,
        );
        break;
      case TextStyleType.code:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            node.text,
            style: TextStyle(fontFamily: 'monospace', fontSize: fontSize, color: Colors.black87),
          ),
        );
      case TextStyleType.emoji:
        style = TextStyle(fontSize: fontSize * 1.5, height: 1.5);
        break;
      case TextStyleType.normal:
        style = TextStyle(fontSize: fontSize, color: color, fontWeight: FontWeight.normal);
        break;
      default: // LaTeX (курсивный Serif)
        style = TextStyle(
          fontSize: fontSize,
          fontStyle: FontStyle.italic,
          fontFamily: 'serif',
          color: color,
        );
    }
    return Text(node.text, style: style);
  }

  if (node is MathRow) {
    return Wrap( // Заменил Row на Wrap для поддержки переноса (flex-flow в Vue)
      crossAxisAlignment: WrapCrossAlignment.center,
      children: node.children
          .map((e) => buildMath(e, fontSize: fontSize, color: color))
          .toList(),
    );
  }

  if (node is MathFraction) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildMath(node.numerator, fontSize: fontSize * 0.85, color: color),
        Container(
          width: max(_estimateWidth(node.numerator, fontSize), _estimateWidth(node.denominator, fontSize)),
          height: 1.5,
          margin: const EdgeInsets.symmetric(vertical: 2),
          color: color ?? Colors.black,
        ),
        buildMath(node.denominator, fontSize: fontSize * 0.85, color: color),
      ],
    );
  }

  if (node is MathSqrt) {
    return _buildSqrt(node.value, fontSize, color);
  }

  return const SizedBox();
}

double _estimateWidth(MathNode node, double fontSize) {
  if (node is MathText) return node.text.length * fontSize * 0.6;
  if (node is MathRow) return node.children.fold(0.0, (sum, e) => sum + _estimateWidth(e, fontSize));
  return fontSize * 2;
}

Widget _buildSqrt(MathNode value, double fontSize, Color? color) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only(top: fontSize * 0.2),
        child: Text('√', style: TextStyle(fontSize: fontSize * 1.2, color: color)),
      ),
      Expanded( // Обертка для контента под чертой корня
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 1.5, color: color ?? Colors.black),
            buildMath(value, fontSize: fontSize * 0.9, color: color),
          ],
        ),
      ),
    ],
  );
}