import 'package:flutter/material.dart';
import 'screens/pin_setup_screen.dart';
import 'screens/pin_lock_screen.dart';
import 'services/lifecycle_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLifecycleService lifecycleService = AppLifecycleService();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    lifecycleService.init(() {
      // Jab timeout ho jaye, Lock Screen pe wapas bhej do
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const PinLockScreen()),
            (route) => false,
      );
    });
  }

  @override
  void dispose() {
    lifecycleService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Secure Photo Gallery',
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const PinSetupScreen(),
    );
  }
}