import 'package:flutter/material.dart';
import '../../main.dart';
import '../../ui_elements/auth_input_decoration.dart';
import '../../ui_elements/primary_button.dart';
import '../../services/auth_service.dart';
import '../activity_screen/activity_screen.dart';
import 'auth_screen.dart';

class LoginForm extends StatefulWidget {
  final void Function(AuthMode) onSwitch;

  const LoginForm({super.key, required this.onSwitch});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  bool get _isValid =>
      _emailController.text.trim().isNotEmpty &&
          _passwordController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);

    final res = await AuthService.login({
      'identifier': _emailController.text.trim(),
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
            res['error']?['message'] ?? 'Login fehlgeschlagen',
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
          controller: _emailController,
          decoration: authInput('E-Mail'),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _passwordController,
          obscureText: _obscure,
          decoration: authInput('Passwort').copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),

        const SizedBox(height: 24),
        PrimaryButton(
          text: _loading ? 'Bitte warten…' : 'Einloggen',
          enabled: _isValid && !_loading,
          onPressed: _submit,
        ),
        const Spacer(),

        GestureDetector(
          onTap: () => widget.onSwitch(AuthMode.register),
          child: const Text('Nicht Mitglied? Anmelden'),
        ),
        const SizedBox(height: 16),

      ],
    );
  }
}
