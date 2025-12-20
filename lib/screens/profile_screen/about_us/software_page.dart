import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SoftwarePopup extends StatelessWidget {
  const SoftwarePopup({super.key});

  void _open(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _SoftwareItem('Wonderpush', 'https://www.wonderpush.com'),
        _SoftwareItem('Microsoft Clarity', 'https://clarity.microsoft.com'),
        _SoftwareItem('Strapi', 'https://strapi.io/'),
        _SoftwareItem('Framework7', 'https://framework7.io/'),
        _SoftwareItem(
          'Google Places API',
          'https://developers.google.com/maps/documentation/places/web-service',
        ),
        _SoftwareItem('Moment.js', 'https://momentjs.com/'),
        _SoftwareItem(
          'better-sqlite3',
          'https://github.com/WiseLibs/better-sqlite3',
        ),
        _SoftwareItem(
          'i18n',
          'http://github.com/mashpie/i18n-node',
        ),
        _SoftwareItem(
          'PostgreSQL client',
          'http://github.com/brianc/node-postgres',
        ),
      ],
    );
  }
}

class _SoftwareItem extends StatelessWidget {
  final String title;
  final String url;

  const _SoftwareItem(this.title, this.url);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(url),
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
    );
  }
}
