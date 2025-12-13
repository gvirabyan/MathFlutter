import 'package:flutter/material.dart';
import '../../ui_elements/auth_input_decoration.dart';
import '../../ui_elements/primary_button.dart';
import 'auth_screen.dart';

class RegisterForm extends StatelessWidget {
  final void Function(AuthMode) onSwitch;

  const RegisterForm({
    super.key,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(decoration: authInput('Spitzname')),
        const SizedBox(height: 20),
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
          children: const [
            Icon(Icons.radio_button_unchecked, size: 20),
            SizedBox(width: 8),
            Text('Angemeldet bleiben'),
          ],
        ),

        const Spacer(),

        const PrimaryButton(text: 'Anmelden'),
        const SizedBox(height: 16),

        GestureDetector(
          onTap: () => onSwitch(AuthMode.login),
          child: const Text(
            'Ich habe schon einen Account\nEinloggen',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
