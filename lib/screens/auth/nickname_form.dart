import 'package:flutter/material.dart';
import '../../ui_elements/auth_input_decoration.dart';
import '../../ui_elements/primary_button.dart';
import 'auth_screen.dart';

class NicknameForm extends StatefulWidget {
  final void Function(AuthMode) onSwitch;

  const NicknameForm({super.key, required this.onSwitch});

  @override
  State<NicknameForm> createState() => _NicknameFormState();
}

class _NicknameFormState extends State<NicknameForm> {
  final _nicknameController = TextEditingController();

  bool get _isValid => _nicknameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nicknameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _nicknameController,
          decoration: authInput('Nur Spitzname'),
        ),

        const Spacer(),

        PrimaryButton(
          text: 'Weiter',
          enabled: _isValid,
          onPressed: () => widget.onSwitch(AuthMode.register),
        ),
      ],
    );
  }
}
