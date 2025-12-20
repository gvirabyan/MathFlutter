import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReleaseNotesPopup extends StatefulWidget {
  const ReleaseNotesPopup({super.key});

  @override
  State<ReleaseNotesPopup> createState() => _ReleaseNotesPopupState();
}

class _ReleaseNotesPopupState extends State<ReleaseNotesPopup> {
  List<dynamic>? versions;

  @override
  void initState() {
    super.initState();
    _loadVersions();
  }

  Future<void> _loadVersions() async {
    // TODO: change language if needed
    final jsonStr = await rootBundle.loadString('assets/locales/de.json');
    final data = json.decode(jsonStr);
    setState(() {
      versions = data['versions'];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (versions == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: versions!.map((v) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'v${v['v']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              v['date'],
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 6),
            ...List<Widget>.from(
              v['changes'].map(
                    (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $c'),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }
}
