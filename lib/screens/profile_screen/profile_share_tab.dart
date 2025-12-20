import 'package:flutter/material.dart';
import '../../services/parents_emails_service.dart';

class ProfileShareTab extends StatefulWidget {
  const ProfileShareTab({super.key});

  @override
  State<ProfileShareTab> createState() => _ProfileShareTabState();
}

class _ProfileShareTabState extends State<ProfileShareTab>
    with AutomaticKeepAliveClientMixin {
  bool isLoading = true;
  bool isSaving = false;
  String errorMsg = '';

  List<Map<String, dynamic>> parentsEmails = [];

  final List<TextEditingController> controllers =
  List.generate(4, (_) => TextEditingController());

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadParentsEmails();
  }

  Future<void> _loadParentsEmails() async {
    final res = await ParentsEmailsService.getParentsEmails();

    if (!mounted) return;

    if (res['status'] == 'success') {
      parentsEmails = (res['data'] as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    setState(() => isLoading = false);
  }

  bool get canAddMore => parentsEmails.length < 4;

  /// сколько input показывать (по одному)
  int get visibleInputs {
    for (int i = 0; i < controllers.length; i++) {
      if (controllers[i].text.trim().isEmpty) {
        return i + 1;
      }
    }
    return controllers.length;
  }

  bool get isSaveDisabled {
    final hasAtLeastOne =
    controllers.any((c) => c.text.trim().isNotEmpty);
    return !hasAtLeastOne || isSaving;
  }

  Future<void> _saveEmails() async {
    if (isSaveDisabled) return;

    setState(() {
      isSaving = true;
      errorMsg = '';
    });

    final emails = controllers
        .map((c) => c.text.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final res =
    await ParentsEmailsService.saveParentsEmails(emails);

    if (!mounted) return;

    if (res['status'] == 'success') {
      // 🔥 локально добавляем (без reload)
      for (final email in emails) {
        parentsEmails.add({
          'id': DateTime.now().millisecondsSinceEpoch,
          'email': email,
        });
      }

      for (final c in controllers) {
        c.clear();
      }
    } else {
      errorMsg = res['message'] ?? '';
    }

    setState(() => isSaving = false);
  }

  Future<void> _removeEmail(int id) async {
    final res =
    await ParentsEmailsService.removeParentEmail(id);

    if (!mounted) return;

    if (res['status'] == 'success') {
      parentsEmails.removeWhere((e) => e['id'] == id);
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          /// ---------- CONTENT ----------
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// SAVED EMAILS
                  if (parentsEmails.isNotEmpty) ...[
                    const Text(
                      'Gespeicherte E-Mails:',
                      style:
                      TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ...parentsEmails.map(
                          (e) => _SavedEmailItem(
                        email: e['email'],
                        onDelete: () =>
                            _removeEmail(e['id']),
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Du hast keine E-Mail-Adresse gespeichert',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],

                  const SizedBox(height: 24),

                  /// INPUTS (по одному)
                  if (canAddMore)
                    ...List.generate(
                      visibleInputs,
                          (index) => Padding(
                        padding:
                        const EdgeInsets.only(bottom: 16),
                        child: TextField(
                          controller: controllers[index],
                          keyboardType:
                          TextInputType.emailAddress,
                          onChanged: (_) => setState(() {}),
                          decoration:
                          const InputDecoration(
                            hintText:
                            'E-Mail Adresse angeben',
                            border:
                            UnderlineInputBorder(),
                          ),
                        ),
                      ),
                    ),

                  if (parentsEmails.length >= 4)
                    const Text(
                      'Du kannst maximal 4 E-Mail-Adressen hinzufügen.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),

                  if (errorMsg.isNotEmpty)
                    Padding(
                      padding:
                      const EdgeInsets.only(top: 12),
                      child: Text(
                        errorMsg,
                        style:
                        const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ),

          /// ---------- SAVE BUTTON (КАК В НАЧАЛЕ) ----------
          Padding(
            padding:
            const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed:
                isSaveDisabled ? null : _saveEmails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  disabledBackgroundColor:
                  Colors.amber.withOpacity(0.4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  'Speichern',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== SAVED EMAIL ITEM ===================== */

class _SavedEmailItem extends StatelessWidget {
  final String email;
  final VoidCallback onDelete;

  const _SavedEmailItem({
    required this.email,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(email)),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
