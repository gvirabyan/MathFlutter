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
      title: Text(title),
      bottom: tabs == null
          ? null
          : TabBar(
        isScrollable: true,
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
