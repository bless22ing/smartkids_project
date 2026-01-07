import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SmartKidsApp());
}

class SmartKidsApp extends StatelessWidget {
  const SmartKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartKids School System',

      // 👇 APPLY SHARED THEMES
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // Later you can switch to ThemeMode.system
      themeMode: ThemeMode.light,

      home: const AuthGate(),
    );
  }
}
