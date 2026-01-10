// import 'package:flutter/material.dart';
// import 'package:untitled2/screens/practice_screen/practice_quiz_question_screen.dart';
//
// void _showNoPlayersPopup() {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (ctx) {
//       return Dialog(
//         backgroundColor: Colors.transparent,
//         insetPadding: const EdgeInsets.symmetric(horizontal: 24),
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(18),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // ❌ Close
//               Align(
//                 alignment: Alignment.topRight,
//                 child: GestureDetector(
//                   onTap: () => Navigator.of(ctx).pop(),
//                   child: const Icon(Icons.close, size: 22),
//                 ),
//               ),
//
//               const SizedBox(height: 8),
//
//               // Title
//               const Text(
//                 'Kein Spieler ist verfügbar',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//
//               const SizedBox(height: 12),
//
//               // Description
//               const Text(
//                 'Sorry, aktuell ist kein Spieler verfügbar 🤷‍♂️\n'
//                     'Probiere später noch einmal.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.black54,
//                   height: 1.4,
//                 ),
//               ),
//
//               const SizedBox(height: 24),
//
//               // Primary button
//               SizedBox(
//                 width: double.infinity,
//                 height: 48,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.of(ctx).pop();
//                     // go to solo practice
//                     Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (_) => const PracticeQuizQuestionScreen(
//                           totalQuestions: 10,
//                         ),
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF7C3AED), // purple
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: const Text(
//                     'Gehe zum Üben',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 12),
//
//               // Secondary button
//               SizedBox(
//                 width: double.infinity,
//                 height: 48,
//                 child: OutlinedButton(
//                   onPressed: () {
//                     Navigator.of(ctx).pop();
//                     _startVsPlayer(selectedQuestionsCount!);
//                   },
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: Color(0xFF7C3AED)),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     'Erneut versuchen',
//                     style: TextStyle(
//                       color: Color(0xFF7C3AED),
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
