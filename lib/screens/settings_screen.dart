// ================================================================
// Settings Screen - App Settings & Preferences
// Allin1 Super App
// ================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kSurface = Color(0xFF0D0D18);
const Color kCard = Color(0xFF141420);
const Color kCard2 = Color(0xFF1A1A28);
const Color kPurple = Color(0xFF7B6FE0);
const Color kPurple2 = Color(0xFF7B6FE0);
const Color kOrange = Color(0xFFE07C6F);
const Color kGreen = Color(0xFF3DBA6F);
const Color kGold = Color(0xFFF5C542);
const Color kRed = Color(0xFFE05555);
const Color kText = Color(0xFFEEEEF5);
const Color kMuted = Color(0xFF7777A0);
const Color kBorder = Color(0x267B6FE0);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings state
  bool _notificationsEnabled = true;
  bool _rideAlertsEnabled = true;
  bool _promotionalAlerts = false;
  final bool _darkModeEnabled = true; // App is already dark
  bool _locationEnabled = true;
  bool _biometricEnabled = false;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'INR (₹)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        backgroundColor: kSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Settings',
            style:
                GoogleFonts.outfit(color: kText, fontWeight: FontWeight.w600),),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Notifications'),
            const SizedBox(height: 12),
            _buildNotificationSettings(),
            const SizedBox(height: 28),
            _buildSectionHeader('Preferences'),
            const SizedBox(height: 12),
            _buildPreferenceSettings(),
            const SizedBox(height: 28),
            _buildSectionHeader('Language & Region'),
            const SizedBox(height: 12),
            _buildLanguageSettings(),
            const SizedBox(height: 28),
            _buildSectionHeader('Privacy & Security'),
            const SizedBox(height: 12),
            _buildPrivacySettings(),
            const SizedBox(height: 28),
            _buildSectionHeader('About'),
            const SizedBox(height: 12),
            _buildAboutSection(),
            const SizedBox(height: 40),
            _buildAppVersion(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.outfit(
        color: kMuted,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: kCard2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            subtitle: 'Receive push notifications',
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.directions_car_outlined,
            title: 'Ride Alerts',
            subtitle: 'Get updates about your rides',
            value: _rideAlertsEnabled,
            onChanged: (v) => setState(() => _rideAlertsEnabled = v),
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.campaign_outlined,
            title: 'Promotional Alerts',
            subtitle: 'Offers and deals',
            value: _promotionalAlerts,
            onChanged: (v) => setState(() => _promotionalAlerts = v),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceSettings() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: kCard2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.location_on_outlined,
            title: 'Location Services',
            subtitle: 'Allow app to access location',
            value: _locationEnabled,
            onChanged: (v) => setState(() => _locationEnabled = v),
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.fingerprint,
            title: 'Biometric Login',
            subtitle: 'Use fingerprint for quick login',
            value: _biometricEnabled,
            onChanged: (v) => setState(() => _biometricEnabled = v),
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: 'Use dark theme (currently active)',
            value: _darkModeEnabled,
            onChanged: null, // Disabled - always dark
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSettings() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: kCard2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          _buildTapTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: _selectedLanguage,
            onTap: _showLanguagePicker,
          ),
          _buildDivider(),
          _buildTapTile(
            icon: Icons.currency_exchange,
            title: 'Currency',
            subtitle: _selectedCurrency,
            onTap: _showCurrencyPicker,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySettings() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: kCard2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          _buildTapTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'View our privacy policy',
            onTap: () {},
          ),
          _buildDivider(),
          _buildTapTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'View terms and conditions',
            onTap: () {},
          ),
          _buildDivider(),
          _buildTapTile(
            icon: Icons.delete_outline,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account',
            titleColor: kRed,
            onTap: _showDeleteAccountDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: kCard2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          _buildTapTile(
            icon: Icons.star_outline,
            title: 'Rate App',
            subtitle: 'Rate us on Play Store',
            onTap: () {},
          ),
          _buildDivider(),
          _buildTapTile(
            icon: Icons.share_outlined,
            title: 'Share App',
            subtitle: 'Invite friends to join',
            onTap: () {},
          ),
          _buildDivider(),
          _buildTapTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help with issues',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kPurple, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.outfit(
                      color: kText,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),),
                Text(subtitle,
                    style: GoogleFonts.outfit(
                      color: kMuted,
                      fontSize: 12,
                    ),),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: kGold,
            activeTrackColor: kGold.withValues(alpha: 0.3),
            inactiveThumbColor: kMuted,
            inactiveTrackColor: kBorder,
          ),
        ],
      ),
    );
  }

  Widget _buildTapTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: kPurple, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.outfit(
                          color: titleColor ?? kText,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),),
                    Text(subtitle,
                        style: GoogleFonts.outfit(
                          color: kMuted,
                          fontSize: 12,
                        ),),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: kMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: kBorder,
      height: 1,
      indent: 60,
    );
  }

  Widget _buildAppVersion() {
    return Center(
      child: Column(
        children: [
          Text(
            'Allin1 Super App',
            style: GoogleFonts.outfit(
              color: kText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.0 (Build 1)',
            style: GoogleFonts.outfit(
              color: kMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Made with ❤️ in Erode',
            style: GoogleFonts.outfit(
              color: kMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Language',
                style: GoogleFonts.outfit(
                  color: kText,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),),
            const SizedBox(height: 16),
            _buildLanguageOption('English', 'English'),
            _buildLanguageOption('தமிழ்', 'Tamil'),
            _buildLanguageOption('हिंदी', 'Hindi'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String lang, String name) {
    final isSelected = _selectedLanguage == lang;
    return ListTile(
      onTap: () {
        setState(() => _selectedLanguage = lang);
        Navigator.pop(context);
      },
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? kGold.withValues(alpha: 0.1) : kCard,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(lang[0],
              style: GoogleFonts.outfit(
                color: isSelected ? kGold : kMuted,
                fontWeight: FontWeight.bold,
              ),),
        ),
      ),
      title: Text(name, style: GoogleFonts.outfit(color: kText)),
      trailing:
          isSelected ? const Icon(Icons.check_circle, color: kGold) : null,
    );
  }

  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Currency',
                style: GoogleFonts.outfit(
                  color: kText,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),),
            const SizedBox(height: 16),
            _buildCurrencyOption('INR (₹)', 'Indian Rupee'),
            _buildCurrencyOption(r'USD ($)', 'US Dollar'),
            _buildCurrencyOption('EUR (€)', 'Euro'),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyOption(String currency, String name) {
    final isSelected = _selectedCurrency == currency;
    return ListTile(
      onTap: () {
        setState(() => _selectedCurrency = currency);
        Navigator.pop(context);
      },
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? kGold.withValues(alpha: 0.1) : kCard,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(currency.split(' ')[0],
              style: GoogleFonts.outfit(
                color: isSelected ? kGold : kMuted,
                fontWeight: FontWeight.bold,
              ),),
        ),
      ),
      title: Text(name, style: GoogleFonts.outfit(color: kText)),
      trailing:
          isSelected ? const Icon(Icons.check_circle, color: kGold) : null,
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Account?',
            style:
                GoogleFonts.outfit(color: kText, fontWeight: FontWeight.w600),),
        content: Text(
          'This action cannot be undone. All your data including ride history, saved addresses, and payment methods will be permanently deleted.',
          style: GoogleFonts.outfit(color: kMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.outfit(color: kMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'Account deletion requested. Contact support for assistance.',
                    style: GoogleFonts.notoSansTamil(color: Colors.white),),
                backgroundColor: kOrange,
                behavior: SnackBarBehavior.floating,
              ),);
            },
            child: Text('Delete',
                style: GoogleFonts.outfit(
                    color: kRed, fontWeight: FontWeight.w600,),),
          ),
        ],
      ),
    );
  }
}
