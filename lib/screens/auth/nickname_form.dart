import 'package:flutter/material.dart';
import '../../app_start.dart';
import '../../ui_elements/auth_input_decoration.dart';
import '../../ui_elements/primary_button.dart';
import '../../services/auth_service.dart';
import 'auth_screen.dart';

class NicknameForm extends StatefulWidget {
  final void Function(AuthMode) onSwitch;

  const NicknameForm({super.key, required this.onSwitch});

  @override
  State<NicknameForm> createState() => _NicknameFormState();
}

class _NicknameFormState extends State<NicknameForm> {
  final _nicknameController = TextEditingController();
  bool _loading = false;

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

  Future<void> _submit() async {
    setState(() => _loading = true);

    final res = await AuthService.registerByNickname({
      'username': _nicknameController.text.trim(),
    });

    if (!mounted) return;
    setState(() => _loading = false);

    if (res['status'] == 'success') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res['message'] ?? 'Registrierung fehlgeschlagen',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ===== INPUT =====
        TextField(
          controller: _nicknameController,
          decoration: authInput('Nur Spitzname'),
        ),

        const SizedBox(height: 48),

        // ===== BUTTON =====
        PrimaryButton(
          text: _loading ? 'Bitte warten…' : 'Anmelden',
          enabled: _isValid && !_loading,
          onPressed: _submit,
        ),

        const Spacer(),

        // ===== BOTTOM TEXT =====
        GestureDetector(
          onTap: () => widget.onSwitch(AuthMode.login),
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
              children: [
                TextSpan(text: 'Ich habe schon einen Account'),
                TextSpan(
                  text: 'Einloggen',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}
