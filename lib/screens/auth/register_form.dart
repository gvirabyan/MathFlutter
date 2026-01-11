import 'package:flutter/material.dart';
import '../../app_start.dart';
import '../../ui_elements/auth_input_decoration.dart';
import '../../ui_elements/primary_button.dart';
import '../../services/auth_service.dart';
import 'auth_screen.dart';

class RegisterForm extends StatefulWidget {
  final void Function(AuthMode) onSwitch;

  const RegisterForm({super.key, required this.onSwitch});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _obscure = true; // 👁 show/hide password
  bool _rememberMe = false; // ⭕ checkbox

  bool get _isValid =>
      _nicknameController.text.trim().isNotEmpty &&
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nicknameController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);

    final res = await AuthService.register({
      'username': _nicknameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
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
            res['error']?['message'] ?? 'Registrierung fehlgeschlagen',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _nicknameController,
          decoration: authInput('Spitzname'),
        ),
        const SizedBox(height: 20),

        TextField(
          controller: _emailController,
          decoration: authInput('E-Mail'),
        ),
        const SizedBox(height: 20),

        // ===== PASSWORD WITH EYE ICON =====
        TextField(
          controller: _passwordController,
          obscureText: _obscure,
          decoration: authInput('Passwort').copyWith(
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),

        // ===== CHECKBOX =====
        const SizedBox(height: 16),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _rememberMe = !_rememberMe;
                });
              },
              child: Icon(
                _rememberMe
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Angemeldet bleiben', style: TextStyle(fontSize: 14)),
          ],
        ),

        const SizedBox(height: 24),

        PrimaryButton(
          text: _loading ? 'Bitte warten…' : 'Anmelden',
          enabled: _isValid && !_loading,
          onPressed: _submit,
        ),

        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Text(
              'Ich habe schon einen Account ',
              style: TextStyle(fontSize: 16),
            ),
            GestureDetector(
              onTap: () => widget.onSwitch(AuthMode.login),
              child: const Text(
                'Einloggen',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}
