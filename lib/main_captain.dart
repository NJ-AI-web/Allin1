// lib/main_captain.dart
// Allin1 — CAPTAIN PWA Entry Point
// GPS + Ride management only!

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/bike_taxi/captain_home_screen.dart';
import 'screens/captain_screen.dart';
import 'screens/login_screen.dart';
import 'services/session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CaptainApp());
}

class CaptainApp extends StatelessWidget {
  const CaptainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Allin1 Captain',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF4CAF50),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginScreen(
              presetUserType: UserType.rider,
              lockUserType: true,
              title: 'Hero Login',
              subtitle: 'Sign in to start accepting rides',
              lockedUserLabel: 'Captain',
              postLoginRoute: '/captain-home',
            ),
        '/captain-home': (_) => const CaptainHomeScreen(),
        '/captain-ride': (_) => const CaptainScreen(),
      },
    );
  }
}
