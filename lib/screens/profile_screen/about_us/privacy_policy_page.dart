import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPopup extends StatelessWidget {
  const PrivacyPopup({super.key});

  void _openLink(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return const _PrivacyContent();
  }
}

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Diese Datenschutzrichtlinie beschreibt, wie MatheApp personenbezogene Daten sammelt, verwendet und weitergibt.',
        ),
        const SizedBox(height: 16),

        const Text('Einführung', style: _h3),
        const Text(
          'Wir, das Team von MatheApp, nehmen den Schutz Ihrer persönlichen Daten sehr ernst und halten uns strikt an die '
              'Regeln der Datenschutzgesetze. Diese Datenschutzerklärung dient dazu, Sie über die Art, den Umfang und den Zweck '
              'der Erhebung und Verwendung personenbezogener Daten durch unsere mobile Anwendung MatheApp zu informieren.',
        ),
        const SizedBox(height: 16),

        const Text('Erhebung und Verarbeitung personenbezogener Daten', style: _h3),
        const Text(
          'Die Nutzung unserer App ist grundsätzlich ohne die Angabe personenbezogener Daten möglich. Für bestimmte '
              'Funktionen, wie die Authentifizierung, ist jedoch die Angabe eines Benutzernamens erforderlich. Weitere '
              'persönliche Informationen können vom Nutzer auf freiwilliger Basis eingetragen werden. Wir speichern und '
              'verarbeiten diese Daten ausschließlich für den Zweck, für den sie uns übermittelt wurden.',
        ),
        const SizedBox(height: 16),

        const Text('Cookies', style: _h3),
        const Text(
          'MatheApp verwendet keine Cookies oder ähnliche Technologien zur Erfassung persönlicher Daten.',
        ),
        const SizedBox(height: 16),

        const Text('Nutzung von Diensten Dritter', style: _h3),
        const Text(
          'Unsere App nutzt verschiedene Dienste Dritter, um die Funktionalität zu verbessern und das Benutzererlebnis '
              'zu optimieren:',
        ),
        const SizedBox(height: 8),
        const _Bullet('Microsoft Clarity für Analyse und Nutzerverhalten'),
        const _Bullet('Google Analytics für Analyse und Nutzerverhalten'),
        const _Bullet('Google Places API für Ortsinformationen'),
        const SizedBox(height: 8),

        const Text(
          'Bitte beachten Sie, dass diese Dienste eigene Datenschutzrichtlinien haben, die unabhängig von unserer '
              'Datenschutzerklärung sind.',
        ),
        const SizedBox(height: 16),

        const Text('Löschung von Daten', style: _h3),
        const Text(
          'Benutzer, die wünschen, dass ihre Daten aus unserer Anwendung gelöscht werden, können dies durch eine '
              'Nachricht über das Kontaktformular auf unserer Website https://schulmatheapp.de beantragen.',
        ),
        const SizedBox(height: 16),

        const Text('Sicherheit', style: _h3),
        const Text(
          'Wir treffen technische und organisatorische Sicherheitsmaßnahmen, um Ihre Daten gegen Manipulation, Verlust '
              'oder Zugriff unberechtigter Personen zu schützen.',
        ),
        const SizedBox(height: 16),

        const Text('Änderungen der Datenschutzerklärung', style: _h3),
        const Text(
          'Wir behalten uns vor, diese Datenschutzerklärung anzupassen, um stets den aktuellen rechtlichen Anforderungen '
              'zu entsprechen.',
        ),
        const SizedBox(height: 16),

        const Text('Kontakt', style: _h3),
        GestureDetector(
          onTap: () => launchUrl(Uri.parse('mailto:info@schulmatheapp.de')),
          child: const Text(
            'info@schulmatheapp.de',
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => launchUrl(Uri.parse('https://schulmatheapp.de')),
          child: const Text(
            'https://schulmatheapp.de',
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Datum der Datenschutzerklärung: 15.03.2024',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

const TextStyle _h3 = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• '),
        Expanded(child: Text(text)),
      ],
    );
  }
}
