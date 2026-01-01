import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_text_theme.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Tab>? tabs;
  final int? dailyGoal;

  const MainAppBar({super.key, required this.title, this.tabs, this.dailyGoal});
  static const double _myToolbarHeight = 100.0;


  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      titleSpacing: 32,
      centerTitle: false,
      toolbarHeight: _myToolbarHeight,
      actions: [
        Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.only(right: 24),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_outlined,size: 26,),
              color: Colors.white,
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },

            ),
          ),
        ),
      ],

      title: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 28
              ),
            ),
            if (dailyGoal != null)
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70, // основной цвет
                  ),
                  children: [
                    const TextSpan(text: 'Dein Ziel heute '),
                    TextSpan(
                      text: dailyGoal == -1 ? '…' : '$dailyGoal Fragen',
                      style: const TextStyle(
                        color: AppColors.primaryYellow,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),

          ],
        ),
      ),

      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryPurple, Color(0xFF5B12C9)],
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
            labelStyle: AppTextTheme.textTheme.titleMedium,

          ),
    );
  }

  @override
  Size get preferredSize {
    double tabsHeight = tabs == null ? 0 : kTextTabBarHeight;
    return Size.fromHeight(_myToolbarHeight + tabsHeight);
  }
}
