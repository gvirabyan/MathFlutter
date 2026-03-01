import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:untitled2/services/push_notification_service.dart';

import 'app_start.dart';
import 'app_text_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await PushNotificationService.initialize();

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
