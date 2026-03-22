// ================================================================
// DashboardScreen v5.0 — Allin1 Super App
// Fixed: blank screen crash + Modern Grid Tile UI
// Premium Swiggy/Zepto style dark theme
// ================================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/local_sync_service.dart';

import 'bike_taxi/bike_booking_screen.dart';
import 'earn/earn_dashboard_screen.dart';
import 'earn/rewards_hub_screen.dart';

// ── Theme ────────────────────────────────────────────────────────
const Color _surface = Color(0xFF12121E);
const Color _card = Color(0xFF1A1A2A);
const Color _card2 = Color(0xFF222235);
const Color _purple = Color(0xFF6C63FF);
const Color _purple2 = Color(0xFF9B8FF0);
const Color _orange = Color(0xFFFF6B35);
const Color _green = Color(0xFF00C853);
const Color _gold = Color(0xFFFFBB00);
const Color _red = Color(0xFFFF5252);

const Color _text = Color(0xFFEEEEF5);
const Color _muted = Color(0xFF7777A0);
const Color _border = Color(0x1AFFFFFF);

// ── Service tile data ─────────────────────────────────────────────
class _ServiceTile {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final bool isLive;
  final String badge;
  const _ServiceTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    this.isLive = false,
    this.badge = '',
  });
}

const List<_ServiceTile> _services = [
  _ServiceTile(
    emoji: '🏍️',
    title: 'Bike Taxi',
    subtitle: 'Fast rides in Erode',
    color: Color(0xFFFFBB00),
    bgColor: Color(0xFF1E1A08),
    isLive: true,
    badge: 'LIVE',
  ),
  _ServiceTile(
    emoji: '🍔',
    title: 'Food Delivery',
    subtitle: '16th Road specials',
    color: Color(0xFFFF5252),
    bgColor: Color(0xFF1E0E0E),
    badge: 'Soon',
  ),
  _ServiceTile(
    emoji: '🛒',
    title: 'Grocery',
    subtitle: 'Fresh & fast',
    color: Color(0xFF00C853),
    bgColor: Color(0xFF0A1E0E),
    badge: 'Soon',
  ),
  _ServiceTile(
    emoji: '📱',
    title: 'Tech Store',
    subtitle: 'NJ TECH gadgets',
    color: Color(0xFF6C63FF),
    bgColor: Color(0xFF10102A),
    badge: 'Soon',
  ),
  _ServiceTile(
    emoji: '🚗',
    title: 'Car Taxi',
    subtitle: 'Comfortable rides',
    color: Color(0xFF00BCD4),
    bgColor: Color(0xFF081A1E),
    badge: 'Soon',
  ),
  _ServiceTile(
    emoji: '💊',
    title: 'Pharmacy',
    subtitle: 'Medicines delivered',
    color: Color(0xFFFF6B35),
    bgColor: Color(0xFF1E1008),
    badge: 'Soon',
  ),
];

// ================================================================
// MAIN SCREEN
// ================================================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _navIndex = 0;
  User? _user;

  @override
  void initState() {
    super.initState();
    // Safely get user — no crash if null
    try {
      _user = FirebaseAuth.instance.currentUser;
    } catch (_) {}
  }

  String get _firstName {
    if (_user == null) {
      return 'Guest';
    }
    final name = _user!.displayName ?? _user!.email ?? 'User';
    return name.split(' ').first;
  }

  String get _avatarLetter {
    if (_user == null) {
      return 'G';
    }
    final name = _user!.displayName ?? _user!.email ?? 'U';
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _navIndex == 0
                  ? _HomeTab(user: _user, firstName: _firstName)
                  : _navIndex == 1
                      ? const _ComingSoonTab(icon: '💬', label: 'Chat')
                      : _navIndex == 2
                          ? const _ComingSoonTab(icon: '🏍️', label: 'My Rides')
                          : _AccountTab(user: _user),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── APP BAR ──────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_purple, _orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _avatarLetter,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'வணக்கம், $_firstName! 👋',
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _text,
                  ),
                ),
                const Text(
                  'Erode, Tamil Nadu 📍',
                  style: TextStyle(fontSize: 10, color: _muted),
                ),
              ],
            ),
          ),
          // Live badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x1A00C853),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x4D00C853)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: _green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Live',
                  style: TextStyle(
                    fontSize: 10,
                    color: _green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Notification bell
          Stack(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: _border),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  size: 18,
                  color: _muted,
                ),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: _red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── BOTTOM NAV ───────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.chat_bubble_outline_rounded, 'label': 'Chat'},
      {'icon': Icons.history_rounded, 'label': 'Rides'},
      {'icon': Icons.person_outline_rounded, 'label': 'Account'},
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 20),
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final active = i == _navIndex;
          return GestureDetector(
            onTap: () => setState(() => _navIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: active ? const Color(0x1A6C63FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    items[i]['icon']! as IconData,
                    size: 22,
                    color: active ? _purple2 : _muted,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    items[i]['label']! as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: active ? _purple2 : _muted,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ================================================================
// HOME TAB
// ================================================================
class _HomeTab extends StatelessWidget {
  final User? user;
  final String firstName;
  const _HomeTab({required this.user, required this.firstName});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wallet Card
          _WalletCard(user: user),
          const SizedBox(height: 16),

          // AI Assistant banner
          _AIBanner(),
          const SizedBox(height: 20),

          // Section title
          Row(
            children: [
              Text(
                'என்ன வேண்டும் இன்றைக்கு?',
                style: GoogleFonts.notoSansTamil(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // SERVICE GRID — Premium 2x3 layout
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: _services.length,
            itemBuilder: (context, i) => _ServiceGridTile(
              tile: _services[i],
              onTap: () {
                if (_services[i].title == 'Earn Allin1') {
                  Navigator.push(
                    context,
                    PageRouteBuilder<void>(
                      pageBuilder: (_, __, ___) => const EarnDashboardScreen(),
                      transitionsBuilder: (_, anim, __, child) =>
                          FadeTransition(opacity: anim, child: child),
                    ),
                  );
                } else if (_services[i].isLive) {
                  Navigator.push(
                    context,
                    PageRouteBuilder<void>(
                      pageBuilder: (_, __, ___) => const BikeBookingScreen(),
                      transitionsBuilder: (_, anim, __, child) =>
                          FadeTransition(opacity: anim, child: child),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${_services[i].title} — வெகு விரைவில்! 🚀',
                        style: GoogleFonts.notoSansTamil(
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: _card2,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 20),

          // Promo banner
          _PromoBanner(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<User?>('user', user))
      ..add(StringProperty('firstName', firstName));
  }
}

// ================================================================
// WALLET CARD
// ================================================================
class _WalletCard extends StatelessWidget {
  final User? user;
  const _WalletCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push<void>(
        context,
        MaterialPageRoute<void>(builder: (c) => const RewardsHubScreen()),
      ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1035), Color(0xFF0D0D1E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x336C63FF)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x336C63FF),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0x1A6C63FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0x336C63FF)),
                        ),
                        child: const Center(
                          child: Text(
                            '₹',
                            style: TextStyle(
                              fontSize: 14,
                              color: _purple2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Allin1 Wallet',
                        style: TextStyle(
                          fontSize: 12,
                          color: _muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x1A00C853),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0x3300C853),
                          ),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 9,
                            color: _green,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '₹ 0.00',
                    style: TextStyle(
                      fontSize: 28,
                      color: _text,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      _WalletBtn(
                        icon: Icons.add_circle_outline,
                        label: 'Add Money',
                      ),
                      SizedBox(width: 10),
                      _WalletBtn(
                        icon: Icons.send_outlined,
                        label: 'Transfer',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<User?>('user', user));
  }
}

class _WalletBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  const _WalletBtn({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _purple2),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: _purple2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<IconData>('icon', icon))
      ..add(StringProperty('label', label));
  }
}

// ================================================================
// WALLET BALANCE TEXT â€” reads live from Firestore
// ================================================================
// ================================================================
// AI ASSISTANT BANNER
// ================================================================
class _AIBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x336C63FF)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_purple, Color(0xFF9B35FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  '🤖',
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Sales Assistant',
                        style: TextStyle(
                          fontSize: 13,
                          color: _text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x1A00C853),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0x4D00C853),
                          ),
                        ),
                        child: const Text(
                          'LIVE NOW',
                          style: TextStyle(
                            fontSize: 7,
                            color: _green,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Food, Grocery, Tech, Bike Taxi — எதுவும் order பண்ணலாம்',
                    style: GoogleFonts.notoSansTamil(
                      fontSize: 10,
                      color: _muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: _muted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// PREMIUM SERVICE GRID TILE
// ================================================================
class _ServiceGridTile extends StatelessWidget {
  final _ServiceTile tile;
  final VoidCallback onTap;
  const _ServiceGridTile({required this.tile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: tile.bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: tile.color.withValues(alpha: tile.isLive ? 0.5 : 0.2),
            width: tile.isLive ? 1.5 : 1,
          ),
          boxShadow: tile.isLive
              ? [
                  BoxShadow(
                    color: tile.color.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emoji icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: tile.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: tile.color.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        tile.emoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: tile.isLive
                          ? tile.color.withValues(alpha: 0.15)
                          : const Color(0x0FFFFFFF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: tile.isLive
                            ? tile.color.withValues(alpha: 0.4)
                            : const Color(0x1AFFFFFF),
                      ),
                    ),
                    child: Text(
                      tile.badge,
                      style: TextStyle(
                        fontSize: 8,
                        color: tile.isLive ? tile.color : _muted,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              // Title & subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tile.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: tile.isLive ? _text : const Color(0xAAEEEEF5),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tile.subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: tile.isLive
                          ? tile.color.withValues(alpha: 0.8)
                          : _muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<_ServiceTile>('tile', tile))
      ..add(ObjectFlagProperty<VoidCallback>.has('onTap', onTap));
  }
}

// ================================================================
// PROMO BANNER
// ================================================================
class _PromoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1035), Color(0xFF1A1020)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x22FFBB00)),
      ),
      child: Row(
        children: [
          const Text('🏍️', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'உங்கள் முதல் ride FREE!',
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _gold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Erode-ல Bike Taxi book பண்ணுங்க',
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 10,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0x1AFFBB00),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x4DFFBB00)),
            ),
            child: const Text(
              'Book →',
              style: TextStyle(
                fontSize: 11,
                color: _gold,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// COMING SOON TAB
// ================================================================
class _ComingSoonTab extends StatelessWidget {
  final String icon;
  final String label;
  const _ComingSoonTab({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              color: _text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'வெகு விரைவில்...',
            style: GoogleFonts.notoSansTamil(
              fontSize: 13,
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('icon', icon))
      ..add(StringProperty('label', label));
  }
}

// ================================================================
// ACCOUNT TAB
// ================================================================
class _AccountTab extends StatelessWidget {
  final User? user;
  const _AccountTab({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user?.displayName ?? user?.email ?? 'Guest';
    final email = user?.email ?? '';
    final isAnon = user?.isAnonymous ?? true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Avatar circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_purple, _orange],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                isAnon ? '👤' : name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isAnon ? 'Guest User' : name,
            style: const TextStyle(
              fontSize: 18,
              color: _text,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              email,
              style: const TextStyle(
                fontSize: 12,
                color: _muted,
              ),
            ),
          ],
          const SizedBox(height: 24),
          // Menu items
          _accountItem(Icons.history_rounded, 'My Rides', () {}),
          _accountItem(Icons.payment_rounded, 'Payments', () {}),
          _accountItem(Icons.notifications_outlined, 'Notifications', () {}),
          _accountItem(Icons.settings_outlined, 'Settings', () {}),
          const SizedBox(height: 8),
          // Sign out
          GestureDetector(
            onTap: () async {
              // ── Local-First: wipe cache before signing out ──
              await LocalSyncService.instance.clearAll();
              await FirebaseAuth.instance.signOut();
            },
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0x1AFF5252),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x33FF5252)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    size: 18,
                    color: _red,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Sign Out',
                    style: GoogleFonts.notoSansTamil(
                      fontSize: 14,
                      color: _red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: _purple2),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: _text,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: _muted,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<User?>('user', user));
  }
}
