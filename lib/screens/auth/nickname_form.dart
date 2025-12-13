import 'package:flutter/material.dart';
import '../../ui_elements/auth_input_decoration.dart';
import '../../ui_elements/primary_button.dart';
import 'auth_screen.dart';

class NicknameForm extends StatelessWidget {
  final void Function(AuthMode) onSwitch;

  const NicknameForm({
    super.key,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(decoration: authInput('Nur Spitzname')),
        const Spacer(),
        const PrimaryButton(text: 'Anmelden'),
      ],
    );
  }
}
