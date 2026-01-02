import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';

import 'app_start.dart';
import 'app_text_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TeXRenderingServer.start();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AppStart(),
      theme: ThemeData(
        fontFamily: 'Rubik',
        textTheme: AppTextTheme.textTheme,
      ),
    );

  }
}
