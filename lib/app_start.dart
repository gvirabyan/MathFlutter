import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/screens/activity_screen/answers_tab.dart';
import 'package:untitled2/screens/activity_screen/progress_tab.dart';
import 'package:untitled2/screens/activity_screen/status_tab.dart';
import 'package:untitled2/screens/activity_screen/top_list_tab.dart';
import 'package:untitled2/screens/auth/auth_screen.dart';
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
import 'package:untitled2/services/auth_service.dart';
import 'package:untitled2/services/unsaved_changes_service.dart';
import 'package:untitled2/ui_elements/dialogs/search_dialog.dart';
import 'package:untitled2/ui_elements/loading_overlay.dart';
import 'package:untitled2/ui_elements/main_app_bar.dart';
import 'package:untitled2/ui_elements/main_bottom_nav.dart';
import 'package:untitled2/ui_elements/notification_panel.dart';

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

    if (token != null && token.isNotEmpty && userId != null) {
      _go(const MainScreen());
    } else {
      _go(const AuthScreen());
    }
  }

  bool _navigated = false;

  void _go(Widget page) {
    if (_navigated) return;
    _navigated = true;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    // Можно лоадер или splash
    return const Scaffold(body: Center(child: LoadingOverlay()));
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();

  static MainScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<MainScreenState>();
  }
}

class MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  int? _dailyGoal;
  bool _goalLoaded = false;
  TabController? _tabController;
  bool _isReverting = false;

  void _onGoalChanged(int newGoal) {
    setState(() {
      _dailyGoal = newGoal;
      _goalLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDailyGoal();
    UnsavedChangesService().addListener(_onUnsavedChangesChanged);
    _initTabController();
  }

  @override
  void dispose() {
    UnsavedChangesService().removeListener(_onUnsavedChangesChanged);
    _tabController?.dispose();
    super.dispose();
  }

  void _onUnsavedChangesChanged() {
    if (mounted) setState(() {});
  }

  void setMainIndex(int index, {int? subIndex}) {
    setState(() {
      _currentIndex = index;
      _initTabController();
      if (subIndex != null && _tabController != null) {
        _tabController!.index = subIndex;
      }
    });
  }

  void _initTabController() {
    final current = _tabs[_currentIndex];
    if (current.subTabs != null) {
      _tabController?.dispose();
      _tabController = TabController(
        length: current.subTabs!.length,
        vsync: this,
      );
      _tabController!.addListener(_handleTabSelection);
    } else {
      _tabController?.dispose();
      _tabController = null;
    }
  }

  void _handleTabSelection() async {
    if (_tabController == null || _isReverting) return;
    if (_tabController!.indexIsChanging) {
      if (UnsavedChangesService().hasUnsavedChanges) {
        final confirmed = await UnsavedChangesService().showConfirmDialog(
          context,
        );
        if (!confirmed) {
          _isReverting = true;
          _tabController!.index = _tabController!.previousIndex;
          _isReverting = false;
        }
      }
    }
  }

  bool startPracticeVsFriend = false;

  late final List<_MainTabConfig> _tabs = [
    _MainTabConfig(
      title: 'Aktivität',
      subTabs: [
        _SubTabConfig(
          label: 'Mein Status',
          view: StatusTab(onGoalUpdated: _onGoalChanged),
        ),
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
      ],
    ),
    _MainTabConfig(
      title: 'Üben',
      subTabs: [
        _SubTabConfig(
          label: 'Spieler vs Maschine',
          view: PracticeVsMachineTab(),
        ),
        _SubTabConfig(label: 'Spieler vs Speiler', view: PracticeVsPlayerTab()),
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
        dailyGoal: _goalLoaded ? _dailyGoal : -1,
        controller: _tabController,
        onSearchTap:
            _currentIndex == 1
                ? () {
                  showGeneralDialog(
                    context: context,
                    barrierDismissible: false,
                    pageBuilder:
                        (context, _, __) =>
                            const SearchOverlay(), // Твой UI поиска
                  );
                }
                : null,
      ),
      endDrawer: const NotificationPanel(),
      body:
          current.subTabs == null
              ? current.view!
              : TabBarView(
                controller: _tabController,
                physics:
                    UnsavedChangesService().hasUnsavedChanges
                        ? const NeverScrollableScrollPhysics()
                        : null,
                children: current.subTabs!.map((e) => e.view).toList(),
              ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) async {
          if (index == _currentIndex) return;
          if (UnsavedChangesService().hasUnsavedChanges) {
            final confirmed = await UnsavedChangesService().showConfirmDialog(
              context,
            );
            if (!confirmed) return;
          }
          setState(() {
            _currentIndex = index;
            _initTabController();
            startPracticeVsFriend = false;
          });
        },
      ),
    );

    return page;
  }

  Future<void> _loadDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();

    // 1️⃣ пробуем локально
    final localGoal = prefs.getInt('daily_goal');
    if (localGoal != null) {
      setState(() {
        _dailyGoal = localGoal;
        _goalLoaded = true;
      });
      return;
    }

    // 2️⃣ идём на backend
    final res = await AuthService.getUser();

    if (res['status'] == 'success') {
      final user = res['user'];
      final backendGoal = user['everyday_goal'];

      if (backendGoal is int) {
        await prefs.setInt('daily_goal', backendGoal);

        setState(() {
          _dailyGoal = backendGoal;
          _goalLoaded = true;
        });
        return;
      }
    }

    // 3️⃣ fallback = 10
    const fallback = 10;
    await prefs.setInt('daily_goal', fallback);

    setState(() {
      _dailyGoal = fallback;
      _goalLoaded = true;
    });
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
