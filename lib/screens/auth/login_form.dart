import 'package:flutter/material.dart';
import '../../ui_elements/auth_input_decoration.dart';
import '../../ui_elements/primary_button.dart';
import 'auth_screen.dart';

class LoginForm extends StatelessWidget {
  final void Function(AuthMode) onSwitch;

  const LoginForm({
    super.key,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(decoration: authInput('E-Mail')),
        const SizedBox(height: 20),
        TextField(
          decoration: authInput('Passwort').copyWith(
            suffixIcon: const Icon(Icons.visibility_off),
          ),
          obscureText: true,
        ),

        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Row(
              children: [
                Icon(Icons.radio_button_unchecked, size: 20),
                SizedBox(width: 8),
                Text('Angemeldet bleiben'),
              ],
            ),
            Text('Passwort vergessen'),
          ],
        ),

        const Spacer(),

        const PrimaryButton(text: 'Einloggen'),
        const SizedBox(height: 16),

        GestureDetector(
          onTap: () => onSwitch(AuthMode.register),
          child: const Text(
            'Nicht Mitglied? Anmelden',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
