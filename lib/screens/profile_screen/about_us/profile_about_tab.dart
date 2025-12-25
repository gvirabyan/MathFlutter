import 'dart:io';
import 'package:flutter/material.dart';
import 'package:untitled2/screens/profile_screen/about_us/release_notes_page.dart';
import 'package:url_launcher/url_launcher.dart';

import 'privacy_policy_page.dart';
import 'software_page.dart';

// ⬇️ импорт твоих страниц


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
        fullscreenDialog: true, // iOS-style с X
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // ---------------- Datenschutz ----------------
        _AboutItem(
          title: 'Datenschutz',
          onTap: () {
            _openPage(
              context,
              const PrivacyPopup(),
            );
          },
        ),

        // ---------------- Software-Lizenzen ----------------
        _AboutItem(
          title: 'Software-Lizenzen',
          onTap: () {
            _openPage(
              context,
              const SoftwarePage(),
            );
          },
        ),

        // ---------------- Versionshinweise ----------------
        _AboutItem(
          title: 'Versionshinweise',
          onTap: () {
            _openPage(
              context,
              const ReleaseNotesPopup(),
            );
          },
        ),

        // ---------------- WRITE REVIEW ----------------
        /*if (Platform.isAndroid)
          _AboutItem(
            title: 'Bewertung schreiben',
            onTap: () {
              _openExternalLink(
                'https://play.google.com/store/apps/details?id=io.framework7.matheapp',
              );
            },
          ),

        if (Platform.isIOS)
          _AboutItem(
            title: 'Bewertung schreiben',
            onTap: () {
              _openExternalLink(
                'https://apps.apple.com/de/app/matheappde/id6447060725',
              );
            },
          ),*/
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black38,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
