// lib/main_admin.dart
// Allin1 — ADMIN Panel Entry Point
// HIDDEN — Not for public!

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/admin/commission_settings_screen.dart';
import 'screens/admin/credentials_admin_screen.dart';
import 'screens/login_screen.dart';
import 'services/session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Allin1 Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE05555),
          secondary: Color(0xFFF5C542),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginScreen(
              presetUserType: UserType.admin,
              lockUserType: true,
              title: '🔐 Admin Access',
              subtitle: 'Authorized personnel only',
              lockedUserLabel: 'Admin',
              postLoginRoute: '/admin-home',
            ),
        '/admin-home': (_) => const CommissionSettingsScreen(),
        '/admin-credentials': (_) => const CredentialsAdminScreen(),
      },
    );
  }
}
