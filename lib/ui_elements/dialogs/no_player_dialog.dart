// import 'dart:ui';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import '../../screens/practice_screen/practice_quiz_question_screen.dart';
//
// void _showNoPlayersPopup() {
//   showDialog(
//     context: context,
//     barrierDismissible: true,
//     builder: (ctx) {
//       return Dialog(
//         backgroundColor: Colors.white,
//         surfaceTintColor: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         insetPadding: const EdgeInsets.symmetric(horizontal: 24),
//         child: Stack(
//           children: [
//             // Кнопка закрытия (крестик) в углу
//             Positioned(
//               right: 8,
//               top: 8,
//               child: IconButton(
//                 onPressed: () => Navigator.of(ctx).pop(),
//                 icon: const Icon(Icons.close, color: Colors.black54, size: 28),
//                 splashRadius: 20,
//               ),
//             ),
//
//             Padding(
//               padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Заголовок
//                   const Text(
//                     'Kein Spieler ist verfügbar',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.w800, // Extra Bold
//                       color: Colors.black,
//                       letterSpacing: -0.5,
//                     ),
//                   ),
//
//                   const SizedBox(height: 18),
//
//                   // Описание с эмодзи
//                   RichText(
//                     textAlign: TextAlign.center,
//                     text: TextSpan(
//                       style: const TextStyle(
//                         fontSize: 17,
//                         color: Colors.black,
//                         height: 1.3,
//                         fontWeight: FontWeight.w400,
//                       ),
//                       children: [
//                         const TextSpan(text: 'Sorry, aktuell ist kein Spieler verfügbar '),
//                         WidgetSpan(
//                           alignment: PlaceholderAlignment.middle,
//                           child: Text('🤷‍♀️', style: TextStyle(fontSize: 18)),
//                         ),
//                         const TextSpan(text: '.\nProbiere später noch einmal.'),
//                       ],
//                     ),
//                   ),
//
//                   const SizedBox(height: 32),
//
//                   // Фиолетовая кнопка "Gehe zum Üben"
//                   SizedBox(
//                     width: double.infinity,
//                     height: 54,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.of(ctx).pop();
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (_) => const PracticeQuizQuestionScreen(
//                               totalQuestions: 10,
//                             ),
//                           ),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF8B2CFF), // Яркий фиолетовый как на скрине
//                         foregroundColor: Colors.white,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: const Text(
//                         'Gehe zum Üben',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 12),
//
//                   // Фиолетовая кнопка "Erneut versuchen"
//                   SizedBox(
//                     width: double.infinity,
//                     height: 54,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.of(ctx).pop();
//                         _startVsPlayer(selectedQuestionsCount!);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF8B2CFF),
//                         foregroundColor: Colors.white,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: const Text(
//                         'Erneut versuchen',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }