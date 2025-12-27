import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/screens/activity_screen/answers_tab.dart';
import 'package:untitled2/screens/activity_screen/progress_tab.dart';
import 'package:untitled2/screens/activity_screen/status_tab.dart';
import 'package:untitled2/screens/activity_screen/top_list_tab.dart';
import 'package:untitled2/screens/auth/auth_screen.dart';
import 'package:untitled2/screens/practice_screen/practice_screen.dart';
import 'package:untitled2/screens/practice_screen/practice_vs_machine_tab.dart';
import 'package:untitled2/screens/practice_screen/practice_vs_player_tab.dart'; // Добавьте импорт
import 'package:untitled2/screens/profile_screen/about_us/profile_about_tab.dart';
import 'package:untitled2/screens/profile_screen/profile_account_tab.dart';
import 'package:untitled2/screens/profile_screen/profile_security_tab.dart';
import 'package:untitled2/screens/profile_screen/profile_share_tab.dart';
import 'package:untitled2/screens/profile_screen/profile_sound_tab.dart';
import 'package:untitled2/screens/topics_screen/topics_10_11_tab.dart';
import 'package:untitled2/screens/topics_screen/topics_11_12_tab.dart';
import 'package:untitled2/screens/topics_screen/topics_1_2_tab.dart';
import 'package:untitled2/screens/topics_screen/topics_2_3_tab.dart';
import 'package:untitled2/screens/topics_screen/topics_3_4_tab.dart';
import 'package:untitled2/screens/topics_screen/topics_4_5tab.dart';
import 'package:untitled2/screens/topics_screen/topics_5_6_tab.dart';
import 'package:untitled2/screens/topics_screen/topics_6_7_tab.dart';
import 'package:untitled2/screens/topics_screen/topics_7_8_tab.dart';
import 'package:untitled2/screens/topics_screen/topics_8_9_tab.dart';
import 'package:untitled2/screens/topics_screen/topics_9_10_tab.dart';
import 'package:untitled2/ui_elements/main_app_bar.dart';
import 'package:untitled2/ui_elements/main_bottom_nav.dart';


class AppStart extends StatefulWidget {
  const AppStart({super.key});

  @override
  State<AppStart> createState() => _AppStartState();
}

class _AppStartState extends State<AppStart> {

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');
    final userId = prefs.getInt('user_id');

    final shortToken = token == null
        ? 'null'
        : '${token.substring(0, 6)}…${token.substring(token.length - 4)}';

    debugPrint('AUTH CHECK → user_id: $userId, token: $shortToken');
    if (token != null && token.isNotEmpty && userId != null) {

      // ✅ авторизован
      _go(const MainScreen());

    } else {
      // ❌ не авторизован
      _go(const AuthScreen());
    }
  }

  bool _navigated = false;

  void _go(Widget page) {
    if (_navigated) return;
    _navigated = true;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Можно лоадер или splash
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
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

  // Данные для режима практики (имитация состояния)
  bool startPracticeVsFriend = false;

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
        // 1–4
        _SubTabConfig(label: '1.–2. Klasse', view: Topics12Tab()),
        _SubTabConfig(label: '2.–3. Klasse', view: Topics23Tab()),
        _SubTabConfig(label: '3.–4. Klasse', view: Topics34Tab()),
        _SubTabConfig(label: '4.–5. Klasse', view: Topics45Tab()),

        // 5–8
        _SubTabConfig(label: '5.–6. Klasse', view: Topics56Tab()),
        _SubTabConfig(label: '6.–7. Klasse', view: Topics67Tab()),
        _SubTabConfig(label: '7.–8. Klasse', view: Topics78Tab()),
        _SubTabConfig(label: '8.–9. Klasse', view: Topics89Tab()),

        // 9–12
        _SubTabConfig(label: '9.–10. Klasse', view: Topics910Tab()),
        _SubTabConfig(label: '10.–11. Klasse', view: Topics1011Tab()),
        _SubTabConfig(label: '11.–12. Klasse', view: Topics1112Tab()),
      ]
      ,
    ),
    _MainTabConfig(
      title: 'Üben',
      subTabs: [
        _SubTabConfig(
          label: 'Spiel vs Maschine',
          view: PracticeVsMachineTab(),
        ),
        _SubTabConfig(
          label: 'Mit Freunden',
          view: PracticeVsPlayerTab(),
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
    ),
  ];

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
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            startPracticeVsFriend = false;
          });
        },
      ),
    );

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
