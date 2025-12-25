import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MainBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  Color _iconColor(bool active) =>
      active ? const Color(0xFF8419FF) : const Color(0xFF777481);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.black.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: onTap,
        showUnselectedLabels: true,
        selectedItemColor: const Color(0xFF8419FF),
        unselectedItemColor: const Color(0xFF777481),
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/buttons/activity.svg',
              width: 26,
              colorFilter: ColorFilter.mode(
                _iconColor(currentIndex == 0),
                BlendMode.srcIn,
              ),
            ),
            label: 'Aktivität',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/buttons/topics.svg',
              width: 18,
              colorFilter: ColorFilter.mode(
                _iconColor(currentIndex == 1),
                BlendMode.srcIn,
              ),
            ),
            label: 'Themen',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/buttons/practice.svg',
              width: 20,
              colorFilter: ColorFilter.mode(
                _iconColor(currentIndex == 2),
                BlendMode.srcIn,
              ),
            ),
            label: 'Üben',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/buttons/profile.svg',
              width: 30,
              colorFilter: ColorFilter.mode(
                _iconColor(currentIndex == 3),
                BlendMode.srcIn,
              ),
            ),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
