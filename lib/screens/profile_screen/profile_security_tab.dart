import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../services/auth_service.dart';
import '../../ui_elements/primary_button.dart';

class ProfileSecurityTab extends StatefulWidget {
  const ProfileSecurityTab({super.key});

  @override
  State<ProfileSecurityTab> createState() => _ProfileSecurityTabState();
}

class _ProfileSecurityTabState extends State<ProfileSecurityTab> {
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirm = true;
  bool _saving = false;

  @override
  void dispose() {
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final password = passwordCtrl.text.trim();
    final confirm = confirmCtrl.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      _show('Bitte alle Felder ausfüllen');
      return;
    }

    if (password.length < 6) {
      _show('Passwort muss mindestens 6 Zeichen haben');
      return;
    }

    if (password != confirm) {
      _show('Passwörter stimmen nicht überein');
      return;
    }

    setState(() => _saving = true);

    /// 👉 Backend call
    final res = await AuthService.updateUser({
      'password': password,
    });

    setState(() => _saving = false);

    if (res['status'] == 'success') {
      passwordCtrl.clear();
      confirmCtrl.clear();
      _show('Passwort erfolgreich geändert');
    } else {
      _show(res['message'] ?? 'Fehler beim Ändern des Passworts');
    }
  }

  void _show(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Neues Passwort
          _label('Neues Passwort'),
          _passwordInput(
            controller: passwordCtrl,
            hidden: _hidePassword,
            onToggle: () =>
                setState(() => _hidePassword = !_hidePassword),
          ),
          _divider(),

          /// Bestätigen
          _label('Neues Passwort bestätigen'),
          _passwordInput(
            controller: confirmCtrl,
            hidden: _hideConfirm,
            onToggle: () =>
                setState(() => _hideConfirm = !_hideConfirm),
          ),
          _divider(),

          const Spacer(),

          /// SAVE BUTTON
          PrimaryButton(
            text: _saving ? 'SPEICHERN...' : 'SPEICHERN',
            enabled: !_saving,
            onPressed: _changePassword,
            color: AppColors.primaryYellow,
          ),
        ],
      ),
    );
  }

  // ===== helpers =====

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black,
          fontWeight: FontWeight.w300
        ),
      ),
    );
  }

  Widget _passwordInput({
    required TextEditingController controller,
    required bool hidden,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: hidden,
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        suffixIcon: IconButton(
          icon: Icon(
            hidden ? Icons.visibility_off : Icons.visibility,
            color: Colors.black38,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Divider(height: 1),
    );
  }
}
