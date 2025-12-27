import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Tab>? tabs;

  const MainAppBar({super.key, required this.title, this.tabs});

  Future<int?> _loadDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('daily_goal');
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,

      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          FutureBuilder<int?>(
            future: _loadDailyGoal(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              return RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    const TextSpan(text: 'Dein Ziel heute: '),

                    TextSpan(
                      text: '${snapshot.data} Fragen',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      // 🎨 GRADIENT BACKGROUND
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple, Color(0xFF5B12C9)],
          ),
        ),
      ),

      bottom:
          tabs == null
              ? null
              : TabBar(
                isScrollable: true,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: tabs!,
              ),
    );
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(
      kToolbarHeight + (tabs == null ? 0 : kTextTabBarHeight),
    );
  }
}
