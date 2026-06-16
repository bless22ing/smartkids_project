import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  // Connect Dart world to native Android/iOS world
  // Always first when you have async code before runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all Firebase services before the app starts
  // await means: wait here until Firebase is fully ready
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Start the app
  // ProviderScope must wrap everything — it's Riverpod's brain
  runApp(
    const ProviderScope(
      child: SmartKidsApp(),
    ),
  );
}

class SmartKidsApp extends ConsumerWidget {
  const SmartKidsApp({super.key});

  // ConsumerWidget gives us 'ref' — our key to read Riverpod providers
  // Use ConsumerWidget instead of StatelessWidget when you need ref
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // ref.watch() reads a provider AND rebuilds this widget when it changes
    // We watch the router because later it will react to auth state changes
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'SmartKids School System',

      // MaterialApp.router works with go_router
      // Instead of 'home:', we give it a routerConfig
      routerConfig: router,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
    );
  }
}