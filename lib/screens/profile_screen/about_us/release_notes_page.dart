import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../ui_elements/loading_overlay.dart';

class ReleaseNotesPopup extends StatefulWidget {
  const ReleaseNotesPopup({super.key});

  @override
  State<ReleaseNotesPopup> createState() => _ReleaseNotesPopupState();
}

class _ReleaseNotesPopupState extends State<ReleaseNotesPopup> {
  List<dynamic>? versions;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadVersions();
  }

  Future<void> _loadVersions() async {
    try {
      final jsonStr =
      await rootBundle.loadString('assets/locales/de.json');
      final data = json.decode(jsonStr);

      if (!mounted) return;

      setState(() {
        versions = data['versions'] as List<dynamic>;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Versionshinweise'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (error != null) {
      return Center(
        child: Text(
          error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (versions == null) {
      return const Center(child: LoadingOverlay());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: versions!.map<Widget>((v) {
          final List changes = v['changes'] as List;

          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'v${v['v']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  v['date'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                ...changes.map<Widget>(
                      (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $c'),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
