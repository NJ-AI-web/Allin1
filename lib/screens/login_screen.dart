// ================================================================
// LoginScreen v3.0 — Allin1 Super App
// Google Sign-In (FREE on Firebase Spark plan!)
// No Blaze plan needed · No brand verification · Works instantly
// ================================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dashboard_screen.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';

// ── Theme ──────────────────────────────────────────────────────
const Color kBg = Color(0xFF08080F);
const Color kSurface = Color(0xFF0D0D18);
const Color kCard = Color(0xFF141420);
const Color kCard2 = Color(0xFF1A1A28);
const Color kPurple = Color(0xFF7B6FE0);
const Color kPurple2 = Color(0xFF9B8FF0);
const Color kOrange = Color(0xFFE07C6F);
const Color kGreen = Color(0xFF3DBA6F);
const Color kGold = Color(0xFFF5C542);
const Color kText = Color(0xFFEEEEF5);
const Color kMuted = Color(0xFF7777A0);
const Color kBorder = Color(0x267B6FE0);

class LoginScreen extends StatefulWidget {
  final UserType? presetUserType;
  final bool lockUserType;
  final String? title;
  final String? subtitle;
  final String? lockedUserLabel;
  final String? postLoginRoute;

  const LoginScreen({
    super.key,
    this.presetUserType,
    this.lockUserType = false,
    this.title,
    this.subtitle,
    this.lockedUserLabel,
    this.postLoginRoute,
  });
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  String _error = '';
  UserType _selectedUserType = UserType.user; // Default to passenger/user

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    if (widget.presetUserType != null) {
      _selectedUserType = widget.presetUserType!;
    }
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic),
    );
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      // Use AuthService with selected user type
      final authService = AuthService();
      final result = await authService.loginWithGoogle(
        userType: _selectedUserType,
        rememberMe: true,
      );

      if (!mounted) return;

      if (result.success) {
        _navigateAfterLogin();
      } else {
        setState(() {
          _loading = false;
          _error = result.error ?? 'Google sign-in failed';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Sign-in failed. மீண்டும் try பண்ணுங்கள்.\n$e';
      });
    }
  }

  // ── Anonymous (Guest / Dev mode) ───────────────────────────
  Future<void> _continueAsGuest() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      // Use standard anonymous sign-in
      final UserCredential result =
          await FirebaseAuth.instance.signInAnonymously();

      if (result.user != null) {
        // Navigate directly to Dashboard after successful guest login
        if (mounted) {
          _selectedUserType = UserType.user;
          _navigateAfterLogin();
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _loading = false;
        if (e.code == 'admin-restricted-operation') {
          _error =
              'Guest login is disabled. Please enable Anonymous sign-in in Firebase Console.';
        } else {
          _error = 'Guest login failed: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Guest login failed: $e';
      });
    }
  }

  void _navigateAfterLogin() {
    if (!mounted) return;
    if (widget.postLoginRoute != null && widget.postLoginRoute!.isNotEmpty) {
      Navigator.of(context).pushReplacementNamed(widget.postLoginRoute!);
      return;
    }
    if (_selectedUserType == UserType.admin) {
      Navigator.of(context).pushReplacementNamed('/admin-panel');
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
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
                      padding: const EdgeInsets.symmetric(horizontal: 24),
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
    return Column(
      children: [
        // App icon with glow
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kPurple, kOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: Color(0x807B6FE0),
                blurRadius: 30,
                spreadRadius: 2,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.shopping_cart, size: 42, color: Colors.white),
          ),
        ),
        const SizedBox(height: 24),

        // App name
        ShaderMask(
          shaderCallback: (r) => const LinearGradient(
            colors: [kPurple2, kOrange],
          ).createShader(r),
          child: Text(
            'Allin1 Super App',
            style: GoogleFonts.notoSansTamil(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),

        Text(
          'நம்ம ஊரு ஆப்',
          style: GoogleFonts.notoSansTamil(fontSize: 16, color: kMuted),
        ),
        const SizedBox(height: 16),

        // Feature pills
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _pill(Icons.restaurant, 'Food'),
            _pill(Icons.local_grocery_store, 'Grocery'),
            _pill(Icons.devices, 'Tech'),
            _pill(Icons.directions_bike, 'Bike Taxi'),
          ],
        ),
      ],
    );
  }

  Widget _pill(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: kCard2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: kPurple2),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: kText)),
          ],
        ),
      );

  // ── User Type Selector ────────────────────────────────────────
  Widget _buildUserTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Login as:',
          style: TextStyle(
              fontSize: 12, color: kMuted, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Rider Button
            Expanded(
              child: _userTypeButton(
                icon: Icons.directions_car,
                label: 'Rider',
                isSelected: _selectedUserType == UserType.rider,
                color: kGreen,
                onTap: () => setState(() => _selectedUserType = UserType.rider),
              ),
            ),
            const SizedBox(width: 8),
            // User/Passenger Button
            Expanded(
              child: _userTypeButton(
                icon: Icons.person,
                label: 'User',
                isSelected: _selectedUserType == UserType.user,
                color: kPurple,
                onTap: () => setState(() => _selectedUserType = UserType.user),
              ),
            ),
            const SizedBox(width: 8),
            // Admin Button
            Expanded(
              child: _userTypeButton(
                icon: Icons.admin_panel_settings,
                label: 'Admin',
                isSelected: _selectedUserType == UserType.admin,
                color: kOrange,
                onTap: () => setState(() => _selectedUserType = UserType.admin),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLockedUserTypeBadge() {
    String label;
    IconData icon;
    Color color;

    switch (_selectedUserType) {
      case UserType.rider:
        label = 'Rider';
        icon = Icons.directions_car;
        color = kGreen;
        break;
      case UserType.admin:
        label = 'Admin';
        icon = Icons.admin_panel_settings;
        color = kOrange;
        break;
      case UserType.user:
      default:
        label = 'User';
        icon = Icons.person;
        color = kPurple;
        break;
    }

    if (widget.lockedUserLabel != null && widget.lockedUserLabel!.isNotEmpty) {
      label = widget.lockedUserLabel!;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                '$label Login',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _userTypeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : kCard2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : kBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : kMuted, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? color : kMuted,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SIGN-IN CARD ─────────────────────────────────────────────
  Widget _buildSignInCard() {
    final cardTitle = widget.title ?? 'Sign In';
    final cardSubtitle = widget.subtitle ?? 'Continue to Allin1 Super App';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3308080F),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            cardTitle,
            style: GoogleFonts.notoSansTamil(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: kText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            cardSubtitle,
            style: TextStyle(fontSize: 12, color: kMuted),
          ),

          const SizedBox(height: 24),

          // ── User Type Selector ────────────────────────────────
          if (widget.lockUserType)
            _buildLockedUserTypeBadge()
          else
            _buildUserTypeSelector(),

          const SizedBox(height: 16),

          // ── Google Sign-In Button ────────────────────────
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(color: kPurple),
            )
          else
            _googleButton(),

          // ── Divider ──────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(child: Divider(color: kBorder)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child:
                      Text('or', style: TextStyle(fontSize: 12, color: kMuted)),
                ),
                Expanded(child: Divider(color: kBorder)),
              ],
            ),
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
                border: Border.all(color: const Color(0x4DE05555)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 16,
                    color: Color(0xFFE05555),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFE05555),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google G logo (SVG-style with text)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
              child: CustomPaint(painter: _GoogleLogoPainter()),
            ),
            const SizedBox(width: 12),
            Text(
              'Continue with Google',
              style: GoogleFonts.notoSansTamil(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3C4043),
              ),
            ),
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
          border: Border.all(color: kBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline, size: 18, color: kMuted),
            const SizedBox(width: 8),
            Text(
              'Guest-ஆ பார்க்க (Demo)',
              style: GoogleFonts.notoSansTamil(fontSize: 14, color: kMuted),
            ),
          ],
        ),
      ),
    );
  }

  // ── FOOTER ───────────────────────────────────────────────────
  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          'Powered by NJ TECH',
          style: TextStyle(fontSize: 11, color: kMuted),
        ),
        const SizedBox(height: 4),
        ShaderMask(
          shaderCallback: (r) => const LinearGradient(
            colors: [kPurple2, kOrange],
          ).createShader(r),
          child: const Text(
            'Food · Grocery · Tech · Bike Taxi',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
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
      -1.57,
      1.57,
      false,
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = size.width * 0.22
        ..style = PaintingStyle.stroke,
    );

    // Red arc (bottom-right)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(c, c), radius: r),
      0,
      1.57,
      false,
      Paint()
        ..color = const Color(0xFFEA4335)
        ..strokeWidth = size.width * 0.22
        ..style = PaintingStyle.stroke,
    );

    // Yellow arc (bottom-left)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(c, c), radius: r),
      1.57,
      1.57,
      false,
      Paint()
        ..color = const Color(0xFFFBBC05)
        ..strokeWidth = size.width * 0.22
        ..style = PaintingStyle.stroke,
    );

    // Green arc (top-left)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(c, c), radius: r),
      3.14,
      1.57,
      false,
      Paint()
        ..color = const Color(0xFF34A853)
        ..strokeWidth = size.width * 0.22
        ..style = PaintingStyle.stroke,
    );

    // White horizontal line (G cutout)
    canvas.drawLine(
      Offset(c, c),
      Offset(size.width, c),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = size.width * 0.22,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
