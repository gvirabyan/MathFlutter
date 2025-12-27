import 'package:flutter/material.dart';
import 'package:untitled2/screens/auth/reset_password_screen.dart';
import '../../services/auth_service.dart';
import 'auth_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}
class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              // ===== TITLE =====
              const Text(
                'Passwort vergessen',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // ===== EMAIL INPUT =====
               TextField(
                 controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Deine E-Mail',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black26),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ===== BUTTON =====
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                    setState(() => _loading = true);
                    debugPrint('FORGOT EMAIL = "$_emailController.text.trim()"');

                    final res = await AuthService.forgotPassword(
                      _emailController.text.trim(),
                    );
                    debugPrint('FORGOT RESPONSE = $res');

                    if (!mounted) return;
                    setState(() => _loading = false);

                    if (res['status'] == 'success') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ResetPasswordScreen(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            res['message'] ?? 'Fehler beim Senden der E-Mail',
                          ),
                        ),
                      );
                    }
                  },

                  // UI only
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7E2BFF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'E-Mail senden',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ===== BACK TO LOGIN =====
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AuthScreen(),
                      ),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: 'Zurück zur ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: 'Startseite',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
