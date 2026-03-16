import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

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

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.2,
                  colors: [Color(0x332D1F4E), kBg],
                ),
              ),
            ),
          ),
          Positioned(
            right: -80,
            top: -40,
            child: _glowOrb(180, kPurple),
          ),
          Positioned(
            left: -60,
            bottom: -60,
            child: _glowOrb(220, kOrange),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TopNav(width: width),
                          const SizedBox(height: 26),
                          _HeroSection(width: width)
                              .animate()
                              .fadeIn(duration: 380.ms)
                              .slideY(begin: 0.05, duration: 420.ms),
                          const SizedBox(height: 28),
                          _KpiStrip(width: width).animate().fadeIn(delay: 120.ms),
                          const SizedBox(height: 32),
                          _SectionTitle(
                            title: 'Business Outcomes That Compound',
                            subtitle:
                                'Improve unit economics with faster fulfillment, higher repeat rate, and unified operations.',
                          ),
                          const SizedBox(height: 16),
                          _FeatureGrid(width: width),
                          const SizedBox(height: 34),
                          _SectionTitle(
                            title: 'Real Use Cases',
                            subtitle: 'Win dense neighborhoods with speed and reliability.',
                          ),
                          const SizedBox(height: 16),
                          _UseCaseList(width: width),
                          const SizedBox(height: 34),
                          _SectionTitle(
                            title: 'Built For Every Role',
                            subtitle:
                                'Dedicated flows for sellers, riders, admins, and customers with clear accountability.',
                          ),
                          const SizedBox(height: 16),
                          _RoleCards(width: width),
                          const SizedBox(height: 34),
                          _SectionTitle(
                            title: 'Operating Playbook',
                            subtitle: 'Launch fast, scale with control, and keep margins healthy.',
                          ),
                          const SizedBox(height: 16),
                          _StepsRow(width: width),
                          const SizedBox(height: 40),
                          _CTASection(width: width),
                          const SizedBox(height: 24),
                          _Footer(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.4), Colors.transparent],
        ),
      ),
    );
  }
}

class _TopNav extends StatelessWidget {
  final double width;

  const _TopNav({required this.width});

  @override
  Widget build(BuildContext context) {
    final isWide = width >= 900;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [kPurple, kOrange]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('??', style: TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Allin1 Super App',
                style: GoogleFonts.spaceGrotesk(
                  color: kText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (isWide) ...[
              _NavLink(label: 'Seller', route: '/seller'),
              _NavLink(label: 'Rider', route: '/rider'),
              _NavLink(label: 'Admin', route: '/admin'),
              _NavLink(label: 'Login', route: '/login'),
            ],
          ],
        ),
        if (!isWide) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _NavButton(label: 'Seller Login', route: '/seller'),
              _NavButton(label: 'Rider Login', route: '/rider'),
              _NavButton(label: 'Admin Login', route: '/admin'),
              _NavButton(label: 'Customer Login', route: '/login'),
            ],
          ),
        ],
      ],
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final String route;

  const _NavLink({required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, route),
        style: TextButton.styleFrom(
          foregroundColor: kMuted,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
        child: Text(label, style: GoogleFonts.outfit(fontSize: 13)),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final String route;

  const _NavButton({required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => Navigator.pushNamed(context, route),
      style: OutlinedButton.styleFrom(
        foregroundColor: kText,
        side: BorderSide(color: kBorder),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      child: Text(label, style: GoogleFonts.outfit(fontSize: 12)),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final double width;

  const _HeroSection({required this.width});

  @override
  Widget build(BuildContext context) {
    final isWide = width >= 900;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: kPurple.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _HeroCopy()),
                const SizedBox(width: 18),
                SizedBox(width: 320, child: _HeroPanel()),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroCopy(),
                const SizedBox(height: 18),
                _HeroPanel(),
              ],
            ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: kPurple.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'AI-powered operating system for local commerce',
            style: GoogleFonts.outfit(
              color: kPurple2,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Launch a profit-first super app for your city',
          style: GoogleFonts.spaceGrotesk(
            color: kText,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Allin1 unifies commerce, mobility, messaging, and payments so every order improves unit economics. '
          'Capture demand, shorten delivery time, and increase wallet share with one operational stack.',
          style: GoogleFonts.outfit(color: kMuted, fontSize: 14, height: 1.6),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              icon: const Icon(Icons.login, size: 18),
              label: const Text('Customer Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/seller'),
              icon: const Icon(Icons.storefront_outlined, size: 18),
              label: const Text('Seller Login'),
              style: OutlinedButton.styleFrom(
                foregroundColor: kText,
                side: BorderSide(color: kBorder),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/rider'),
              icon: const Icon(Icons.directions_bike_outlined, size: 18),
              label: const Text('Rider Login'),
              style: OutlinedButton.styleFrom(
                foregroundColor: kText,
                side: BorderSide(color: kBorder),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/admin'),
              icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
              label: const Text('Admin Login'),
              style: OutlinedButton.styleFrom(
                foregroundColor: kText,
                side: BorderSide(color: kBorder),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Executive snapshot',
            style: GoogleFonts.spaceGrotesk(
              color: kText,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          _HeroMetric(label: 'Order cost', value: 'Lowered'),
          _HeroMetric(label: 'Repeat rate', value: 'Higher'),
          _HeroMetric(label: 'Fulfillment time', value: 'Faster'),
          _HeroMetric(label: 'Wallet adoption', value: 'Unified'),
          const SizedBox(height: 12),
          Text(
            'Unified fleet + smart ordering = stronger margins.',
            style: GoogleFonts.outfit(color: kMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;

  const _HeroMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: GoogleFonts.outfit(color: kMuted, fontSize: 12))),
          Text(value, style: GoogleFonts.spaceGrotesk(color: kGold, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _KpiStrip extends StatelessWidget {
  final double width;

  const _KpiStrip({required this.width});

  @override
  Widget build(BuildContext context) {
    return _ResponsiveWrap(
      width: width,
      minCardWidth: 200,
      maxColumns: 4,
      children: const [
        _MetricCard(label: 'Lower cost per order', value: 'Built-in'),
        _MetricCard(label: 'Higher repeat rate', value: 'AI-assisted'),
        _MetricCard(label: 'Faster fulfillment', value: 'Unified fleet'),
        _MetricCard(label: 'Launch speed', value: 'Days'),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const _MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              color: kGold,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.outfit(color: kMuted, fontSize: 12)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            color: kText,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: GoogleFonts.outfit(color: kMuted, fontSize: 13),
        ),
      ],
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  final double width;

  const _FeatureGrid({required this.width});

  @override
  Widget build(BuildContext context) {
    final items = [
      _Feature(
        icon: Icons.shopping_bag_outlined,
        title: 'Unified commerce',
        text: 'Food, grocery, and tech in a single cart with shared fulfillment.',
        color: kOrange,
      ),
      _Feature(
        icon: Icons.directions_bike_outlined,
        title: 'Mobility + logistics',
        text: 'Rides and delivery share one fleet to reduce idle time.',
        color: kGreen,
      ),
      _Feature(
        icon: Icons.chat_bubble_outline,
        title: 'Realtime messaging',
        text: 'Order-specific chat for faster resolution and higher completion.',
        color: kPurple,
      ),
      _Feature(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Wallet and payouts',
        text: 'Instant refunds, payouts, and a unified balance across services.',
        color: kGold,
      ),
      _Feature(
        icon: Icons.assistant_outlined,
        title: 'AI sales assistant',
        text: 'Captures orders, confirms addresses, and reduces drop-off.',
        color: kPurple2,
      ),
      _Feature(
        icon: Icons.security_outlined,
        title: 'Operational control',
        text: 'Role-based access, audit trails, and live analytics.',
        color: kMuted,
      ),
    ];

    return _ResponsiveWrap(
      width: width,
      minCardWidth: 240,
      maxColumns: 3,
      children: items.map((f) => _FeatureCard(feature: f)).toList(growable: false),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String text;
  final Color color;

  const _Feature({
    required this.icon,
    required this.title,
    required this.text,
    required this.color,
  });
}

class _FeatureCard extends StatelessWidget {
  final _Feature feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: feature.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature.icon, color: feature.color),
          ),
          const SizedBox(height: 10),
          Text(
            feature.title,
            style: GoogleFonts.spaceGrotesk(
              color: kText,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            feature.text,
            style: GoogleFonts.outfit(color: kMuted, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _UseCaseList extends StatelessWidget {
  final double width;

  const _UseCaseList({required this.width});

  @override
  Widget build(BuildContext context) {
    final cases = [
      'Food delivery with AI-guided ordering and live tracking.',
      'Grocery marketplace with rapid fulfillment and inventory alerts.',
      'Tech accessories storefront with smart upsells and bundles.',
      'Bike taxi for instant local rides and shared delivery fleet.',
      'Business pages with offers, posts, and customer chat.',
      'Unified wallet for refunds, rewards, and faster repeat orders.',
    ];

    return _ResponsiveWrap(
      width: width,
      minCardWidth: 320,
      maxColumns: 2,
      children: cases
          .map(
            (c) => Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: kGreen, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      c,
                      style: GoogleFonts.outfit(color: kText, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _RoleCards extends StatelessWidget {
  final double width;

  const _RoleCards({required this.width});

  @override
  Widget build(BuildContext context) {
    final roles = [
      _Role(
        title: 'Seller',
        text: 'Catalog, pricing, order queue, promotions, and payouts.',
        icon: Icons.storefront_outlined,
        route: '/seller',
        color: kOrange,
      ),
      _Role(
        title: 'Rider',
        text: 'Smart dispatch, earnings, navigation, and wallet.',
        icon: Icons.directions_bike_outlined,
        route: '/rider',
        color: kGreen,
      ),
      _Role(
        title: 'Admin',
        text: 'Onboarding, safety, fraud controls, and analytics.',
        icon: Icons.admin_panel_settings_outlined,
        route: '/admin',
        color: kPurple,
      ),
      _Role(
        title: 'Customer',
        text: 'One app for food, grocery, tech, and rides.',
        icon: Icons.person_outline,
        route: '/login',
        color: kGold,
      ),
    ];

    return _ResponsiveWrap(
      width: width,
      minCardWidth: 240,
      maxColumns: 4,
      children: roles.map((r) => _RoleCard(role: r)).toList(growable: false),
    );
  }
}

class _Role {
  final String title;
  final String text;
  final IconData icon;
  final String route;
  final Color color;

  const _Role({
    required this.title,
    required this.text,
    required this.icon,
    required this.route,
    required this.color,
  });
}

class _RoleCard extends StatelessWidget {
  final _Role role;

  const _RoleCard({required this.role});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, role.route),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kCard2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: role.color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(role.icon, color: role.color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.title,
                    style: GoogleFonts.spaceGrotesk(
                      color: kText,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role.text,
                    style: GoogleFonts.outfit(color: kMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepsRow extends StatelessWidget {
  final double width;

  const _StepsRow({required this.width});

  @override
  Widget build(BuildContext context) {
    final steps = [
      _StepItem(
        title: '1. Launch',
        text: 'Deploy quickly with prebuilt modules and branding.',
      ),
      _StepItem(
        title: '2. Onboard',
        text: 'Bring sellers and riders onto the platform with verification.',
      ),
      _StepItem(
        title: '3. Scale',
        text: 'Expand categories, optimize routes, and grow margins.',
      ),
    ];

    return _ResponsiveWrap(
      width: width,
      minCardWidth: 220,
      maxColumns: 3,
      children: steps.map((s) => _StepCard(step: s)).toList(growable: false),
    );
  }
}

class _StepItem {
  final String title;
  final String text;

  const _StepItem({required this.title, required this.text});
}

class _StepCard extends StatelessWidget {
  final _StepItem step;

  const _StepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step.title,
            style: GoogleFonts.spaceGrotesk(
              color: kGold,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            step.text,
            style: GoogleFonts.outfit(color: kMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _CTASection extends StatelessWidget {
  final double width;

  const _CTASection({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPurple, kOrange.withValues(alpha: 0.9)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: width >= 720
          ? Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ready to operate a city-scale super app?',
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start with Allin1 and unlock commerce, mobility, and AI-driven operations.',
                        style: GoogleFonts.outfit(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: kPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  child: const Text('Get Started'),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to operate a city-scale super app?',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start with Allin1 and unlock commerce, mobility, and AI-driven operations.',
                  style: GoogleFonts.outfit(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: kPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  child: const Text('Get Started'),
                ),
              ],
            ),
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: kBorder),
        const SizedBox(height: 10),
        Text(
          'Allin1 Super App ? Powered by NJ TECH',
          style: GoogleFonts.outfit(color: kMuted, fontSize: 11),
        ),
      ],
    );
  }
}

class _ResponsiveWrap extends StatelessWidget {
  final double width;
  final double minCardWidth;
  final int maxColumns;
  final List<Widget> children;
  final double spacing;

  const _ResponsiveWrap({
    required this.width,
    required this.minCardWidth,
    required this.maxColumns,
    required this.children,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    final cols = _columns(width, minCardWidth, maxColumns);
    final cardWidth = _cardWidth(width, cols, spacing);

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: children
          .map((child) => SizedBox(width: cardWidth, child: child))
          .toList(growable: false),
    );
  }

  int _columns(double width, double minWidth, int maxCols) {
    final cols = (width / (minWidth + spacing)).floor();
    if (cols < 1) return 1;
    if (cols > maxCols) return maxCols;
    return cols;
  }

  double _cardWidth(double width, int cols, double spacing) {
    final totalSpacing = spacing * (cols - 1);
    return (width - totalSpacing) / cols;
  }
}
