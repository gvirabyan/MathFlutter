// import 'package:flutter/material.dart';
// import 'package:untitled2/screens/practice_screen/practice_quiz_question_screen.dart';
// import '../topics_screen/learning_quiz_question_screen.dart';
//
// class PracticeVsMachineTab extends StatelessWidget {
//   const PracticeVsMachineTab({super.key});
//
//   void _startQuiz(BuildContext context, int count) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => PracticeQuizQuestionScreen(totalQuestions: count),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       padding: const EdgeInsets.symmetric(vertical: 16),
//       children: [
//         _item(
//           context,
//           title: '10 Fragen',
//           score: '+10, +5, -2',
//           count: 10,
//         ),
//         _divider(),
//         _item(
//           context,
//           title: '20 Fragen',
//           score: '+20, +10, -4',
//           count: 20,
//         ),
//         _divider(),
//         _item(
//           context,
//           title: '30 Fragen',
//           score: '+30, +15, -6',
//           count: 30,
//         ),
//         _divider(),
//       ],
//     );
//   }
//
//   Widget _item(
//       BuildContext context, {
//         required String title,
//         required String score,
//         required int count,
//       }) {
//     return InkWell(
//       onTap: () => _startQuiz(context, count),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
//         child: Row(
//           children: [
//             /// LEFT
//             Expanded(
//               child: Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//
//             /// RIGHT
//             Text(
//               score,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF7C3AED), // фиолетовый как на скрине
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _divider() {
//     return const Divider(
//       height: 1,
//       thickness: 1,
//       indent: 20,
//       endIndent: 20,
//     );
//   }
// }
