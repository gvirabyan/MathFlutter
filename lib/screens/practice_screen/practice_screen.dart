// import 'package:flutter/material.dart';
//
// import 'practice_vs_machine_tab.dart';
// import 'practice_vs_player_tab.dart';
//
// class PracticeScreen extends StatefulWidget {
//   const PracticeScreen({super.key});
//
//   @override
//   State<PracticeScreen> createState() => _PracticeScreenState();
// }
//
// class _PracticeScreenState extends State<PracticeScreen>
//     with SingleTickerProviderStateMixin {
//   late final TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Practice'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'Maschine'),
//             Tab(text: 'Spieler'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           PracticeVsMachineTab(),
//           PracticeVsPlayerTab(),
//         ],
//       ),
//     );
//   }
// }
