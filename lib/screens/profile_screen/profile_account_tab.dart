import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:untitled2/app_colors.dart';
import 'package:untitled2/services/unsaved_changes_service.dart';
import 'package:untitled2/ui_elements/dialogs/account_error_info_dialog.dart';

import '../../screens/auth/auth_screen.dart';
import '../../services/audio_service.dart';
import '../../services/auth_service.dart';
import '../../services/google_places_service.dart';
import '../../ui_elements/dialogs/account_info_save_dialog.dart';
import '../../ui_elements/loading_overlay.dart';
import '../../ui_elements/primary_button.dart';

class ProfileAccountTab extends StatefulWidget {
  const ProfileAccountTab({super.key});

  @override
  State<ProfileAccountTab> createState() => _ProfileAccountTabState();
}

class _ProfileAccountTabState extends State<ProfileAccountTab> {

  Widget _autocompleteInput({
    required TextEditingController controller,
    required String placeType,
    String? hint,
    bool enabled = true,
    Function(Map<String, dynamic>)? onSelected,
  }) {
    // Создаём контроллер для управления списком
    final suggestionsController = SuggestionsController<Map<String, dynamic>>();

    return TypeAheadField<Map<String, dynamic>>(
      controller: controller,
      suggestionsController: suggestionsController, // ← передаём контроллер
      hideOnUnfocus: false,
      emptyBuilder: (context) => const SizedBox.shrink(),
      hideWithKeyboard: false,
      constraints: const BoxConstraints(maxHeight: 300),

      builder: (context, ctrl, focusNode) {
        return TextField(
          controller: ctrl,
          focusNode: focusNode,
          enabled: enabled,
          onChanged: (_) => _checkForChanges(),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38),
            border: InputBorder.none,
          ),
        );
      },
      suggestionsCallback: (search) {
        if (search.trim().isEmpty) return [];
        return GooglePlacesService().searchPlaces(search, placeType);
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          dense: true,
          title: Text(suggestion['description'] ?? ''),
        );
      },
      onSelected: (suggestion) {
        controller.text = suggestion['description'] ?? '';
        suggestionsController.close(); // ← закрываем список вручную
        FocusManager.instance.primaryFocus?.unfocus(); // ← убираем клавиатуру
        _checkForChanges();
        if (onSelected != null) onSelected(suggestion);
      },
    );
  }

  // ===== controllers =====
  final emailCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final surnameCtrl = TextEditingController();
  final nicknameCtrl = TextEditingController();
  final birthCtrl = TextEditingController();
  final countryCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final schoolCtrl = TextEditingController();
  final classCtrl = TextEditingController();

  bool _loading = true; // initial load
  bool _saving = false; // save profile
  bool _processing = false; // logout / delete


  @override
  void initState() {
    super.initState();
    _loadUser();
    UnsavedChangesService().discardCallback = _loadUser;
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    nameCtrl.dispose();
    surnameCtrl.dispose();
    nicknameCtrl.dispose();
    birthCtrl.dispose();
    countryCtrl.dispose();
    cityCtrl.dispose();
    schoolCtrl.dispose();
    classCtrl.dispose();
    UnsavedChangesService().discardCallback = null;
    super.dispose();
  }

  // ===== API =====

  Future<void> _loadUser() async {


    final res = await AuthService.getUser();

    if (res['status'] == 'success') {
      final u = res['user'];

      emailCtrl.text = (u['email'] ?? '').toString();
      nameCtrl.text = (u['name'] ?? '').toString();
      surnameCtrl.text = (u['surname'] ?? '').toString();
      nicknameCtrl.text = (u['username'] ?? '').toString();
      birthCtrl.text = (u['dateOfBirth'] ?? '').toString();
      countryCtrl.text = (u['country'] ?? '').toString();
      cityCtrl.text = (u['city'] ?? '').toString();
      schoolCtrl.text = (u['institution']['name'] ?? '').toString();
      classCtrl.text = (u['class'] ?? '').toString();
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  void _checkForChanges() {
    UnsavedChangesService().hasUnsavedChanges = true;
  }

  Future<void> _saveProfile() async {
    if (_saving || _processing) return;

    setState(() => _saving = true);

    final body = {
      'name': nameCtrl.text.trim(),
      'surname': surnameCtrl.text.trim(),
      'username': nicknameCtrl.text.trim(),
      'birthDate': birthCtrl.text.trim(),
      'country': countryCtrl.text.trim(),
      'city': cityCtrl.text.trim(),
      'school': schoolCtrl.text.trim(),
      'class': classCtrl.text.trim(),
    };

    final res = await AuthService.updateUser(body);

    if (!mounted) return;
    setState(() => _saving = false);

    final ok = res['status'] == 'success';
    if (ok) {
      UnsavedChangesService().hasUnsavedChanges = false;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AccountInfoSaveDialog(),
      );
      AudioService().play('formSubmit');
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AccountErrorInfoDialog(),
      );
    }
  }

  Future<void> _logout() async {
    if (_processing) return;

    setState(() => _processing = true);
    await AuthService.logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (_) => false,
    );
  }

  Future<void> _deleteAccount() async {
    if (_processing) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Konto löschen'),
            content: const Text(
              'Möchtest du dein Konto wirklich löschen? '
              'Diese Aktion kann nicht rückgängig gemacht werden.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Löschen'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _processing = true);

    final res = await AuthService.deleteNicknamedUser();
    final ok = res['status'] == 'success';

    // даже если delete не успешен — не оставляем мусорный токен
    await AuthService.logout();

    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message']?.toString() ?? 'Fehler beim Löschen'),
        ),
      );
    }
    AudioService().play('formSubmit');

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (_) => false,
    );
  }

  // ===== UI =====

  @override
  Widget build(BuildContext context) {
   if (_loading) {
      return const Center(child: LoadingOverlay());
    }

    final bool disableInputs = _processing;

    return PopScope(
      canPop: !UnsavedChangesService().hasUnsavedChanges,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final shouldPop = await UnsavedChangesService().showConfirmDialog(
          context,
          onSave: _saveProfile,
        );
        if (shouldPop == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('E-Mail Adresse'),
              _input(emailCtrl, enabled: !disableInputs),
              _divider(),

              _label('Name'),
              _input(nameCtrl, enabled: !disableInputs),
              _divider(),

              _label('Nachname'),
              _input(surnameCtrl, enabled: !disableInputs),
              _divider(),

              _label('Spitzname'),
              _input(nicknameCtrl, enabled: !disableInputs),
              _divider(),

              _label('Geburtsdatum'),
              _input(birthCtrl, enabled: !disableInputs),
              _divider(),

              _label('Land'),
              _autocompleteInput(
                controller: countryCtrl,
                placeType: 'country', // Поиск только стран
                hint: 'In welchem Land lebst du?',
                enabled: !disableInputs,
                onSelected: (_) {
                  // Логика из Vue: при смене страны чистим остальное
                  cityCtrl.clear();
                  schoolCtrl.clear();
                  classCtrl.clear();
                },
              ),
              _divider(),

              _label('Stadt'),
              _autocompleteInput(
                controller: cityCtrl,
                placeType: '(cities)', // Поиск только городов
                hint: 'In welcher Stadt lebst du?',
                enabled: !disableInputs,
                onSelected: (_) {
                  schoolCtrl.clear();
                  classCtrl.clear();
                },
              ),
              _divider(),

              _label('Schule'),
              _autocompleteInput(
                controller: schoolCtrl,
                placeType: 'school', // Поиск учебных заведений
                hint: 'Name deiner Schule',
                enabled: !disableInputs,
                onSelected: (suggestion) {
                  // Тут можно сохранить place_id, если ваш бэкенд его требует
                  // String placeId = suggestion['place_id'];
                  classCtrl.clear();
                },
              ),
              _divider(),

              _label('Klasse'),
              _input(
                classCtrl,
                hint: 'Deine Klasse (z.B. 7a oder 7.1)',
                enabled: !disableInputs,
              ),
              _divider(),

              const SizedBox(height: 4),

              /// SAVE
              PrimaryButton(
                text: _saving ? 'SPEICHERN...' : 'SPEICHERN',
                enabled: !_saving && !_processing,
                onPressed: _saveProfile,
                color: AppColors.primaryYellow,
              ),

              const SizedBox(height: 24),

              /// LOGOUT
              Center(
                child:
                    _processing
                        ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : GestureDetector(
                          onTap: _logout,
                          child: const Text(
                            'Abmelden',
                            style: TextStyle(
                              color: Color(0xFF7B2CFF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
              ),

              const SizedBox(height: 16),

              /// DELETE ACCOUNT
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: _processing ? null : _deleteAccount,
                  child: const Text(
                    'Konto löschen',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController controller, {
    String? hint,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      onChanged: (_) => _checkForChanges(),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38),
        border: InputBorder.none,
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
