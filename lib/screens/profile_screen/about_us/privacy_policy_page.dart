import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPopup extends StatelessWidget {
  const PrivacyPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datenschutz'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: const _PrivacyContent(),
      ),
    );
  }
}

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Diese Datenschutzrichtlinie beschreibt, wie MatheApp personenbezogene Daten sammelt, verwendet und weitergibt.',
        ),
        SizedBox(height: 16),

        Text('Einführung', style: _h3),
        Text(
          'Wir, das Team von MatheApp, nehmen den Schutz Ihrer persönlichen Daten sehr ernst und halten uns strikt an die '
              'Regeln der Datenschutzgesetze. Diese Datenschutzerklärung dient dazu, Sie über die Art, den Umfang und den Zweck '
              'der Erhebung und Verwendung personenbezogener Daten durch unsere mobile Anwendung MatheApp zu informieren.',
        ),
        SizedBox(height: 16),

        Text('Erhebung und Verarbeitung personenbezogener Daten', style: _h3),
        Text(
          'Die Nutzung unserer App ist grundsätzlich ohne die Angabe personenbezogener Daten möglich. Für bestimmte '
              'Funktionen, wie die Authentifizierung, ist jedoch die Angabe eines Benutzernamens erforderlich. Weitere '
              'persönliche Informationen können vom Nutzer auf freiwilliger Basis eingetragen werden. Wir speichern und '
              'verarbeiten diese Daten ausschließlich für den Zweck, für den sie uns übermittelt wurden.',
        ),
        SizedBox(height: 16),

        Text('Cookies', style: _h3),
        Text(
          'MatheApp verwendet keine Cookies oder ähnliche Technologien zur Erfassung persönlicher Daten.',
        ),
        SizedBox(height: 16),

        Text('Nutzung von Diensten Dritter', style: _h3),
        Text(
          'Unsere App nutzt verschiedene Dienste Dritter, um die Funktionalität zu verbessern und das Benutzererlebnis '
              'zu optimieren:',
        ),
        SizedBox(height: 8),
        _Bullet('Microsoft Clarity für Analyse und Nutzerverhalten'),
        _Bullet('Google Analytics für Analyse und Nutzerverhalten'),
        _Bullet('Google Places API für Ortsinformationen'),
        SizedBox(height: 8),

        Text(
          'Bitte beachten Sie, dass diese Dienste eigene Datenschutzrichtlinien haben, die unabhängig von unserer '
              'Datenschutzerklärung sind.',
        ),
        SizedBox(height: 16),

        Text('Löschung von Daten', style: _h3),
        Text(
          'Benutzer, die wünschen, dass ihre Daten aus unserer Anwendung gelöscht werden, können dies durch eine '
              'Nachricht über das Kontaktformular auf unserer Website https://schulmatheapp.de beantragen.',
        ),
        SizedBox(height: 16),

        Text('Sicherheit', style: _h3),
        Text(
          'Wir treffen technische und organisatorische Sicherheitsmaßnahmen, um Ihre Daten gegen Manipulation, Verlust '
              'oder Zugriff unberechtigter Personen zu schützen.',
        ),
        SizedBox(height: 16),

        Text('Änderungen der Datenschutzerklärung', style: _h3),
        Text(
          'Wir behalten uns vor, diese Datenschutzerklärung anzupassen, um stets den aktuellen rechtlichen Anforderungen '
              'zu entsprechen.',
        ),
        SizedBox(height: 16),

        Text('Kontakt', style: _h3),
        GestureDetector(
          onTap: () =>
              launchUrl(Uri.parse('mailto:info@schulmatheapp.de')),
          child: Text(
            'info@schulmatheapp.de',
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        ),
        SizedBox(height: 6),
        GestureDetector(
          onTap: () =>
              launchUrl(Uri.parse('https://schulmatheapp.de')),
          child: Text(
            'https://schulmatheapp.de',
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        ),
        SizedBox(height: 20),

        Text(
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
