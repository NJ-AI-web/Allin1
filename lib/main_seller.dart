// lib/main_seller.dart
// Allin1 — SELLER Web App Entry Point

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/seller_dashboard_screen.dart';
import 'screens/seller_screen.dart';
import 'services/session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SellerApp());
}

class SellerApp extends StatelessWidget {
  const SellerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Allin1 Partner Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF11998E),
          secondary: Color(0xFF38EF7D),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginScreen(
              presetUserType: UserType.rider,
              lockUserType: true,
              title: 'Seller Login',
              subtitle: 'Manage your Allin1 store',
              lockedUserLabel: 'Seller',
              postLoginRoute: '/seller-home',
            ),
        '/seller-home': (_) => const SellerDashboardScreen(),
        '/seller-store': (_) => const SellerScreen(),
      },
    );
  }
}
