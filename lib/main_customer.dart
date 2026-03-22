// lib/main_customer.dart
// Erode Super App — CUSTOMER PWA Entry Point
// Fixed: back button logout + routing + geolocator web crash

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'screens/checkout_screen.dart';
import 'screens/customer_login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/landing_page.dart';
import 'services/local_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    debugPrint('Flutter error: ${details.exceptionAsString()}');
  };

  await runZonedGuarded(() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('Firebase init error: $e');
    }

    // ── Local-First: init Hive + LocalSyncService ────────────────
    await Hive.initFlutter();
    await LocalSyncService.instance.initialize();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    runApp(const CustomerApp());
  }, (error, stack) {
    debugPrint('Zone error: $error\n$stack');
  });
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Allin1 Super App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A1A),
        colorSchemeSeed: const Color(0xFF7B6FE0),
        useMaterial3: true,
        textTheme: GoogleFonts.notoSansTamilTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      // ── Auth Gate ─────────────────────────────────────────────
      // Uses PopScope on DashboardScreen to prevent back-to-login
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF0A0A1A),
              body: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF7B6FE0),
                ),
              ),
            );
          }
          // Logged in → Dashboard (back button intercepted inside)
          if (snapshot.hasData && snapshot.data != null) {
            return const _AuthenticatedRoot();
          }
          // Not logged in → Landing
          return const LandingPage();
        },
      ),
      routes: {
        '/landing': (_) => const LandingPage(),
        '/login': (_) => const CustomerLoginScreen(),
        '/dashboard': (_) => const _AuthenticatedRoot(),
        '/checkout': (_) => const CheckoutScreen(),
        '/rider': (_) => const _ComingSoonScreen(role: 'Rider'),
        '/seller': (_) => const _ComingSoonScreen(role: 'Seller'),
      },
    );
  }
}

// ── Authenticated Root — wraps Dashboard with back-button guard ──
class _AuthenticatedRoot extends StatelessWidget {
  const _AuthenticatedRoot();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // canPop = false prevents back nav to login screen
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        // Show exit confirmation instead of going to login
        showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A2A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'App மூட விரும்புகிறீர்களா?',
              style: TextStyle(
                color: Color(0xFFEEEEF5),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: const Text(
              'Allin1-ல இருந்து வெளியேற விரும்புகிறீர்களா?',
              style: TextStyle(color: Color(0xFF7777A0), fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'இல்லை',
                  style: TextStyle(color: Color(0xFF7777A0)),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5252),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, true);
                  SystemNavigator.pop(); // Close app
                },
                child: const Text(
                  'வெளியேறு',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
      child: const DashboardScreen(),
    );
  }
}

class _ComingSoonScreen extends StatelessWidget {
  final String role;
  const _ComingSoonScreen({required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08080F),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🚧', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              '$role — Coming Soon!',
              style: const TextStyle(
                color: Color(0xFFEEEEF5),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/dashboard',
                (r) => false,
              ),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('role', role));
  }
}
