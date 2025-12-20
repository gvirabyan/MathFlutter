import 'package:flutter/material.dart';
import 'package:untitled2/screens/activity_screen/answers_tab.dart';
import 'package:untitled2/screens/activity_screen/progress_tab.dart';
import 'package:untitled2/screens/activity_screen/status_tab.dart';
import 'package:untitled2/screens/activity_screen/top_list_tab.dart';
import 'package:untitled2/screens/auth/auth_screen.dart';
import 'package:untitled2/screens/practice_screen/practice_screen.dart';
import 'package:untitled2/screens/practice_screen/practice_vs_machine_tab.dart';
import 'package:untitled2/screens/practice_screen/practice_vs_player_tab.dart';
import 'package:untitled2/screens/profile_screen/about_us/profile_about_tab.dart';
import 'package:untitled2/screens/profile_screen/profile_account_tab.dart';
import 'package:untitled2/screens/profile_screen/profile_screen.dart';
import 'package:untitled2/screens/profile_screen/profile_security_tab.dart';
import 'package:untitled2/screens/profile_screen/profile_share_tab.dart';
import 'package:untitled2/screens/profile_screen/profile_sound_tab.dart';
import 'package:untitled2/screens/topics_screen/topics_1_2_tab.dart';
import 'package:untitled2/screens/topics_screen/topics_2_3_tab.dart';
import 'package:untitled2/screens/topics_screen/topics_3_4_tab.dart';
import 'package:untitled2/screens/topics_screen/topics_4_5tab.dart';
import 'package:untitled2/screens/topics_screen/topics_screen.dart';
import 'package:untitled2/ui_elements/main_app_bar.dart';
import 'package:untitled2/ui_elements/main_bottom_nav.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<_MainTabConfig> _tabs = [
    _MainTabConfig(
      title: 'Aktivität',
      subTabs: [
        _SubTabConfig(label: 'Mein Status', view: const StatusTab()),
        _SubTabConfig(label: 'Top List', view: const TopListTab()),
        _SubTabConfig(label: 'Meine Antworten', view: const AnswersTab()),
        _SubTabConfig(label: 'Progress', view: const ProgressTab()),
      ],
    ),
    _MainTabConfig(
      title: 'Themen',
      subTabs: [
        _SubTabConfig(label: '1.–2. Klasse', view: const Topics12Tab()),
        _SubTabConfig(label: '2.–3. Klasse', view: const Topics23Tab()),
        _SubTabConfig(label: '3.–4. Klasse', view: const Topics34Tab()),
        _SubTabConfig(label: '4.–5. Klasse', view: const Topics45Tab()),
      ],
    ),

    _MainTabConfig(
      title: 'Üben',
      subTabs: [
        _SubTabConfig(
          label: 'Spieler gegen Maschine',
          view: const PracticeVsMachineTab(),
        ),
        _SubTabConfig(
          label: 'Spieler gegen Spieler',
          view: const PracticeVsPlayerTab(),
        ),
      ],
    ),

    _MainTabConfig(
      title: 'Profil',
      subTabs: [
        _SubTabConfig(label: 'Account', view: const ProfileAccountTab()),
        _SubTabConfig(label: 'Sicherheit', view: const ProfileSecurityTab()),
        _SubTabConfig(label: 'Über uns', view: const ProfileAboutTab()),
        _SubTabConfig(label: 'Erfolg teilen', view: const ProfileShareTab()),
        _SubTabConfig(label: 'Ton', view: const ProfileSoundTab()),
      ],
    ),  ];

  @override
  Widget build(BuildContext context) {
    final current = _tabs[_currentIndex];

    Widget page = Scaffold(
      backgroundColor: Colors.white,
      appBar: MainAppBar(
        title: current.title,
        tabs: current.subTabs?.map((e) => Tab(text: e.label)).toList(),
      ),
      body: current.subTabs == null
          ? current.view!
          : TabBarView(
        children: current.subTabs!.map((e) => e.view).toList(),
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );


    // DefaultTabController должен быть ТОЛЬКО когда есть subTabs
    if (current.subTabs != null) {
      page = DefaultTabController(
        key: ValueKey(_currentIndex),
        length: current.subTabs!.length,
        child: page,
      );
    }

    return page;
  }
}

class _MainTabConfig {
  final String title;
  final Widget? view;
  final List<_SubTabConfig>? subTabs;

  _MainTabConfig({required this.title, this.view, this.subTabs})
    : assert(
        (view != null) ^ (subTabs != null),
        'Either view or subTabs must be provided (not both).',
      );
}

class _SubTabConfig {
  final String label;
  final Widget view;

  _SubTabConfig({required this.label, required this.view});
}
