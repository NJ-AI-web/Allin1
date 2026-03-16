import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';


// ================================================================
// Theme Colors - Dark Theme
// ================================================================
const Color kBg = Color(0xFF08080F);
const Color kSurface = Color(0xFF0D0D18);
const Color kCard = Color(0xFF141420);
const Color kCard2 = Color(0xFF1A1A28);
const Color kPurple = Color(0xFF7B6FE0);
const Color kPurple2 = Color(0xFF9B8FF0);
const Color kDarkPurple = Color(0xFF2D1F4E);
const Color kOrange = Color(0xFFE07C6F);
const Color kRedBrown = Color(0xFFB85C4A);
const Color kGreen = Color(0xFF3DBA6F);
const Color kGold = Color(0xFFF5C542);
const Color kText = Color(0xFFEEEEF5);
const Color kMuted = Color(0xFF7777A0);
const Color kBorder = Color(0x267B6FE0);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const String _foodPrompt =
      'I want to order food. Show me today’s popular dishes and specials.';
  static const String _groceryPrompt =
      'I want to order fresh groceries. Show me vegetables, fruits, and essentials.';
  static const String _techPrompt =
      'I need tech accessories. Show me chargers, cables, and earphones with prices.';
  static const String _chatPrompt =
      'Hi! I want to place an order. Please guide me.';

  // ================================================================
  // BUILD
  // ================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Wallet Card at the very top
                _buildWalletCard(),
                const SizedBox(height: 24),

                // 2. Tamil Header Text
                _buildTamilHeader(),
                const SizedBox(height: 20),

                // 3. AI Chat Card with LIVE NOW badge
                _buildAIChatCard(),
                const SizedBox(height: 20),

                // 4. Services Grid - 4 Large Rectangular Cards
                _buildServicesGrid(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      // Bottom Navigation
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ================================================================
  // 1. WALLET CARD - Allin1 Wallet Balance
  // ================================================================
  Widget _buildWalletCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1428), Color(0xFF252038)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPurple.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: kPurple.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wallet Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kPurple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: kPurple2,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Allin1 Wallet Balance',
                    style: GoogleFonts.notoSansTamil(
                      color: kMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Active',
                  style: GoogleFonts.notoSansTamil(
                    color: kGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Balance
          Text(
            '₹ 12,450.00',
            style: GoogleFonts.notoSansTamil(
              color: kText,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              _buildWalletButton(
                icon: Icons.add_circle_outline,
                label: 'Add Money',
                onTap: () => Navigator.pushNamed(context, '/payment'),
              ),
              const SizedBox(width: 24),
              _buildWalletButton(
                icon: Icons.send,
                label: 'Transfer',
                onTap: () => Navigator.pushNamed(context, '/payment'),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildWalletButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: kPurple2, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.notoSansTamil(
              color: kText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // 2. TAMIL HEADER TEXT
  // ================================================================
  Widget _buildTamilHeader() {
    return Text(
      'என்ன வேண்டும் இன்றைக்கு?',
      style: GoogleFonts.notoSansTamil(
        color: kText,
        fontSize: 26,
        fontWeight: FontWeight.w700,
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1);
  }

  // ================================================================
  // 3. AI CHAT CARD - Dark Purple with LIVE NOW Badge
  // ================================================================
  Widget _buildAIChatCard() {
    return InkWell(
      onTap: () => _openChat(_chatPrompt),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2D1F4E), Color(0xFF1A1428)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kPurple.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: kPurple.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kPurple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: kPurple2,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LIVE NOW Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: kGreen,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'LIVE NOW',
                          style: GoogleFonts.notoSansTamil(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    'Sales Assistant-கிடம் கேளுங்கள்',
                    style: GoogleFonts.notoSansTamil(
                      color: kText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Subtitle
                  Text(
                    'Food, Grocery, Tech, Bike Taxi — எதுவும் order பண்ணலாமே',
                    style: GoogleFonts.notoSansTamil(
                      color: kMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Right Arrow
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kPurple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: kPurple2,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1);
  }

  // ================================================================
  // 4. SERVICES GRID - 4 Large Rectangular Cards
  // ================================================================
  Widget _buildServicesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Food Delivery Card (Red/Brown tint)
        _buildServiceCard(
          title: 'Food Delivery',
          subtitle: 'Delicious meals delivered',
          icon: Icons.restaurant_menu,
          gradientColors: [Color(0xFF4A2C2A), Color(0xFF2D1A18)],
          accentColor: kRedBrown,
          onTap: () => _openChat(_foodPrompt),
        ),
        const SizedBox(height: 12),

        // Grocery Card (Green tint)
        _buildServiceCard(
          title: 'Grocery',
          subtitle: 'Fresh groceries at your door',
          icon: Icons.local_grocery_store,
          gradientColors: [Color(0xFF1A3D2A), Color(0xFF0F2418)],
          accentColor: kGreen,
          onTap: () => _openChat(_groceryPrompt),
        ),
        const SizedBox(height: 12),

        // Tech Accessories Card (Blue/Purple tint)
        _buildServiceCard(
          title: 'Tech Accessories',
          subtitle: 'Latest gadgets & accessories',
          icon: Icons.devices,
          gradientColors: [Color(0xFF2A2A4A), Color(0xFF1A1A2D)],
          accentColor: kPurple,
          onTap: () => _openChat(_techPrompt),
        ),
        const SizedBox(height: 12),

        // Bike Taxi Card (Yellow/Gold tint)
        _buildServiceCard(
          title: 'Bike Taxi',
          subtitle: 'Quick rides at affordable prices',
          icon: Icons.directions_bike,
          gradientColors: [Color(0xFF3D3520), Color(0xFF252010)],
          accentColor: kGold,
          onTap: () {
            Navigator.pushNamed(context, '/bike-taxi');
          },
        ),
      ],
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.notoSansTamil(
                      color: kText,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.notoSansTamil(
                      color: kMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              color: accentColor,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // BOTTOM NAVIGATION
  // ================================================================
  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(
          top: BorderSide(
            color: kBorder,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: _buildNavItem(Icons.home_filled, 'Home', true),
          ),
          GestureDetector(
            onTap: () => _openChat(_chatPrompt),
            child: _buildNavItem(Icons.chat_bubble_outline, 'Chat', false),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/ride-history'),
            child: _buildNavItem(Icons.history, 'Rides', false),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: _buildNavItem(Icons.person_outline, 'Account', false),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? kPurple : kMuted,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.notoSansTamil(
            color: isActive ? kPurple : kMuted,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  void _openChat(String message) {
    Navigator.pushNamed(context, '/chat', arguments: message);
  }
}
