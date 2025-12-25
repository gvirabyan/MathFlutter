import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Tab>? tabs;

  const MainAppBar({
    super.key,
    required this.title,
    this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,

      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),

      // 🎨 GRADIENT BACKGROUND
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8419FF),
              Color(0xFF5B12C9),
            ],
          ),
        ),
      ),

      bottom: tabs == null
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
