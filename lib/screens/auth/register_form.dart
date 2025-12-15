import 'package:flutter/material.dart';
import '../../main.dart';
import '../../ui_elements/auth_input_decoration.dart';
import '../../ui_elements/primary_button.dart';
import '../../services/auth_service.dart';
import '../activity_screen/activity_screen.dart';
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
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: authInput('Passwort'),
        ),

        const SizedBox(height: 24),
        PrimaryButton(
          text: _loading ? 'Bitte warten…' : 'Anmelden',
          enabled: _isValid && !_loading,
          onPressed: _submit,
        ),
        const Spacer(),

        GestureDetector(
          onTap: () => widget.onSwitch(AuthMode.login),
          child: const Text('Ich habe schon einen Account'),
        ),
        const SizedBox(height: 16),

      ],
    );
  }
}
