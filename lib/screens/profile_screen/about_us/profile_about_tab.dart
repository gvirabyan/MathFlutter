import 'package:flutter/material.dart';
import 'package:untitled2/screens/profile_screen/about_us/release_notes_page.dart';
import 'package:url_launcher/url_launcher.dart';

import 'privacy_policy_page.dart';
import 'software_page.dart';

class ProfileAboutTab extends StatelessWidget {
  const ProfileAboutTab({super.key});

  void _openExternalLink(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _openPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => page,
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _AboutItem(
          title: 'Datenschutz',
          onTap: () => _openPage(context, const PrivacyPopup()),
        ),
        _AboutItem(
          title: 'Software-Lizenzen',
          onTap: () => _openPage(context, const SoftwarePage()),
        ),
        _AboutItem(
          title: 'Versionshinweise',
          onTap: () => _openPage(context, const ReleaseNotesPopup()),
        ),
      ],
    );
  }
}

/* ===================== UI ITEM ===================== */

class _AboutItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _AboutItem({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFE0E0E0),
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }
}