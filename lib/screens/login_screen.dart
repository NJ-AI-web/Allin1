// ================================================================
// LoginScreen v3.0 — Erode Super App
// Google Sign-In (FREE on Firebase Spark plan!)
// No Blaze plan needed · No brand verification · Works instantly
// ================================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ── Theme ──────────────────────────────────────────────────────
const Color kBg      = Color(0xFF08080F);
const Color kSurface = Color(0xFF0D0D18);
const Color kCard    = Color(0xFF141420);
const Color kCard2   = Color(0xFF1A1A28);
const Color kPurple  = Color(0xFF7B6FE0);
const Color kPurple2 = Color(0xFF9B8FF0);
const Color kOrange  = Color(0xFFE07C6F);
const Color kGreen   = Color(0xFF3DBA6F);
const Color kGold    = Color(0xFFF5C542);
const Color kText    = Color(0xFFEEEEF5);
const Color kMuted   = Color(0xFF7777A0);
const Color kBorder  = Color(0x267B6FE0);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  bool   _loading = false;
  String _error   = '';

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim  = CurvedAnimation(
      parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08), end: Offset.zero)
      .animate(CurvedAnimation(
        parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() { _animCtrl.dispose(); super.dispose(); }

  // ── Google Sign-In ──────────────────────────────────────────
  Future<void> _signInWithGoogle() async {
    setState(() { _loading = true; _error = ''; });
    try {
      // Step 1: Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser =
        await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User cancelled
        setState(() { _loading = false; });
        return;
      }

      // Step 2: Get auth details
      final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

      // Step 3: Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken:     googleAuth.idToken,
      );

      // Step 4: Sign in to Firebase
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Auth state change → StreamBuilder in main.dart
      // automatically navigates to DashboardScreen ✅

    } on Exception catch (e) {
      setState(() {
        _loading = false;
        _error   = 'Sign-in failed. மீண்டும் try பண்ணுங்கள்.\n$e';
      });
    }
  }

  // ── Anonymous (Guest / Dev mode) ───────────────────────────
  Future<void> _continueAsGuest() async {
    setState(() { _loading = true; _error = ''; });
    try {
      await FirebaseAuth.instance.signInAnonymously();
      // Auth state change handles navigation
    } catch (e) {
      setState(() {
        _loading = false;
        _error   = 'Guest login failed: $e';
      });
    }
  }

  // ================================================================
  // BUILD
  // ================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top,
                child: Column(
                  children: [

                    // ── TOP SPACE ───────────────────────────
                    const Spacer(flex: 2),

                    // ── LOGO + TITLE ────────────────────────
                    _buildLogoSection(),

                    const Spacer(flex: 2),

                    // ── SIGN-IN CARD ────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24),
                      child: _buildSignInCard(),
                    ),

                    const Spacer(),

                    // ── FOOTER ──────────────────────────────
                    _buildFooter(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── LOGO SECTION ─────────────────────────────────────────────
  Widget _buildLogoSection() {
    return Column(children: [
      // App icon with glow
      Container(
        width: 88, height: 88,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kPurple, kOrange],
            begin: Alignment.topLeft,
            end:   Alignment.bottomRight),
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Color(0x807B6FE0),
              blurRadius: 30, spreadRadius: 2,
              offset: Offset(0, 8)),
          ]),
        child: const Center(
          child: Text('🛒',
            style: TextStyle(fontSize: 42))),
      ),
      const SizedBox(height: 24),

      // App name
      ShaderMask(
        shaderCallback: (r) => const LinearGradient(
          colors: [kPurple2, kOrange],
        ).createShader(r),
        child: Text('Erode Super App',
          style: GoogleFonts.notoSansTamil(
            fontSize: 30, fontWeight: FontWeight.w800,
            color: Colors.white, letterSpacing: -0.5)),
      ),
      const SizedBox(height: 8),

      Text('நம்ம ஊரு ஆப்',
        style: GoogleFonts.notoSansTamil(
          fontSize: 16, color: kMuted)),
      const SizedBox(height: 16),

      // Feature pills
      Wrap(
        spacing: 8, runSpacing: 8,
        alignment: WrapAlignment.center,
        children: ['🍔 Food', '🍅 Grocery',
          '📱 Tech', '🚕 Bike Taxi']
          .map((t) => Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0x1A7B6FE0),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kBorder)),
            child: Text(t, style: const TextStyle(
              fontSize: 11, color: kPurple2))))
          .toList(),
      ),
    ]);
  }

  // ── SIGN-IN CARD ─────────────────────────────────────────────
  Widget _buildSignInCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3308080F),
            blurRadius: 30, offset: Offset(0, 10)),
        ]),
      child: Column(children: [

        Text('உள்நுழைக', style: GoogleFonts.notoSansTamil(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: kText)),
        const SizedBox(height: 6),
        const Text('Continue to Erode Super App',
          style: TextStyle(fontSize: 12, color: kMuted)),

        const SizedBox(height: 24),

        // ── Google Sign-In Button ────────────────────────
        _loading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(color: kPurple))
          : _googleButton(),

        // ── Divider ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(children: [
            Expanded(child: Divider(color: kBorder)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('or', style: TextStyle(
                fontSize: 12, color: kMuted))),
            Expanded(child: Divider(color: kBorder)),
          ]),
        ),

        // ── Guest Button ──────────────────────────────────
        _guestButton(),

        // ── Error ────────────────────────────────────────
        if (_error.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0x1AE05555),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0x4DE05555))),
            child: Row(children: [
              const Icon(Icons.error_outline,
                size: 16, color: Color(0xFFE05555)),
              const SizedBox(width: 8),
              Expanded(child: Text(_error,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFE05555)))),
            ]),
          ),
        ],
      ]),
    );
  }

  // ── GOOGLE BUTTON ─────────────────────────────────────────────
  Widget _googleButton() {
    return GestureDetector(
      onTap: _signInWithGoogle,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 12, offset: Offset(0, 4)),
          ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google G logo (SVG-style with text)
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4)),
              child: CustomPaint(painter: _GoogleLogoPainter()),
            ),
            const SizedBox(width: 12),
            Text('Continue with Google',
              style: GoogleFonts.notoSansTamil(
                fontSize: 15, fontWeight: FontWeight.w600,
                color: const Color(0xFF3C4043))),
          ],
        ),
      ),
    );
  }

  // ── GUEST BUTTON ─────────────────────────────────────────────
  Widget _guestButton() {
    return GestureDetector(
      onTap: _continueAsGuest,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: kCard2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline,
              size: 18, color: kMuted),
            const SizedBox(width: 8),
            Text('Guest-ஆ பார்க்க (Demo)',
              style: GoogleFonts.notoSansTamil(
                fontSize: 14, color: kMuted)),
          ],
        ),
      ),
    );
  }

  // ── FOOTER ───────────────────────────────────────────────────
  Widget _buildFooter() {
    return Column(children: [
      Text('Powered by NJ TECH · Erode',
        style: const TextStyle(
          fontSize: 11, color: kMuted)),
      const SizedBox(height: 4),
      ShaderMask(
        shaderCallback: (r) => const LinearGradient(
          colors: [kPurple2, kOrange],
        ).createShader(r),
        child: const Text('Food · Grocery · Tech · Bike Taxi',
          style: TextStyle(
            fontSize: 10, color: Colors.white,
            letterSpacing: 0.5)),
      ),
    ]);
  }
}

// ── Google Logo Painter ──────────────────────────────────────────
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.width / 2;
    final r = size.width / 2;

    // Blue arc (top-right)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(c, c), radius: r),
      -1.57, 1.57, false,
      Paint()..color = const Color(0xFF4285F4)
        ..strokeWidth = size.width * 0.22
        ..style = PaintingStyle.stroke);

    // Red arc (bottom-right)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(c, c), radius: r),
      0, 1.57, false,
      Paint()..color = const Color(0xFFEA4335)
        ..strokeWidth = size.width * 0.22
        ..style = PaintingStyle.stroke);

    // Yellow arc (bottom-left)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(c, c), radius: r),
      1.57, 1.57, false,
      Paint()..color = const Color(0xFFFBBC05)
        ..strokeWidth = size.width * 0.22
        ..style = PaintingStyle.stroke);

    // Green arc (top-left)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(c, c), radius: r),
      3.14, 1.57, false,
      Paint()..color = const Color(0xFF34A853)
        ..strokeWidth = size.width * 0.22
        ..style = PaintingStyle.stroke);

    // White horizontal line (G cutout)
    canvas.drawLine(
      Offset(c, c),
      Offset(size.width, c),
      Paint()..color = const Color(0xFF4285F4)
        ..strokeWidth = size.width * 0.22);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
