// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_math_fork/flutter_math.dart';
//
// class LatexText extends StatelessWidget {
//   final String latex;
//   final bool block;
//
//   const LatexText({
//     super.key,
//     required this.latex,
//     this.block = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Math.tex(
//       latex,
//       mathStyle: block ? MathStyle.display : MathStyle.text,
//       textStyle: const TextStyle(fontSize: 20),
//       onErrorFallback: (err) => Text(latex),
//     );
//   }
// }
// Widget buildQuestionText(String text) {
//   if (text.startsWith('@@@')) {
//     return Text(
//       text.substring(3),
//     );
//   }
//
//   if (text.startsWith('@@')) {
//     return Text(
//       text.substring(2),
//       style: const TextStyle(
//         fontFamily: 'monospace',
//         fontSize: 20,
//         letterSpacing: 4,
//         fontWeight: FontWeight.bold,
//       ),
//     );
//   }
//
//   if (text.startsWith('@emoji@')) {
//     return Text(
//       text.substring(7),
//       style: const TextStyle(fontSize: 24),
//     );
//   }
//
//   if (text.startsWith('@pre@')) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(8),
//       color: Colors.grey.shade200,
//       child: Text(
//         text.substring(5),
//         style: const TextStyle(fontFamily: 'monospace'),
//       ),
//     );
//   }
//
//   if (text.startsWith('@')) {
//     return Text(
//       text.substring(1),
//       style: const TextStyle(fontSize: 20),
//     );
//   }
//
//   // 🔥 DEFAULT → REAL LaTeX
//   return LatexText(
//     latex: text,
//     block: true,
//   );
// }
//
