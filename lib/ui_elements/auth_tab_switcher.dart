import 'package:flutter/material.dart';
import '../screens/auth/auth_screen.dart';

class AuthTabSwitcher extends StatelessWidget {
  final AuthMode current;
  final ValueChanged<AuthMode> onChanged;

  const AuthTabSwitcher({
    super.key,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget tab(String text, AuthMode mode) {
      final selected = current == mode;

      return GestureDetector(
        onTap: () => onChanged(mode),
        child: Column(
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? Colors.black : Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            if (selected)
              Container(
                width: 40,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        tab('Registrieren', AuthMode.register),
        const SizedBox(width: 24),
        tab('Nur Spitzname', AuthMode.nickname),
      ],
    );
  }
}
