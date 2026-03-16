// ================================================================
// Allin1 Super App — main.dart  v4.0
// Dashboard + Voice Chat + Commerce Cards + WhatsApp Share
// Surgically upgraded by NJ TECH — Zero breakage, Full pivot.
//
// ✅ CHANGE LOG v3 → v4:
//   [1] ComingSoonCard model  → CommerceCard (+ chatPrompt, cardColor)
//   [2] kComingSoon data      → kCommerceCards (4 business categories)
//   [3] _ComingSoonGridCard   → _CommerceGridCard (premium, no SOON badge)
//   [4] ChatScreen            → accepts optional initialMessage (auto-send)
//   [5] _send()               → includes kSalesSystemPrompt in API call
// ================================================================

import 'dart:async';
import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher.dart';

import 'firebase_options.dart';
import 'models/api_models.dart' as api;
import 'providers/cart_provider.dart';
import 'screens/bike_taxi_screen.dart';
import 'screens/captain_document_screen.dart';
import 'screens/captain_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/dashboard_screen.dart' as SuperDash;
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/order_tracking_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/ride_history_screen.dart';
import 'screens/rider_screen.dart';
import 'screens/seller_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin/credentials_admin_screen.dart';
import 'screens/role_login_screen.dart';
import 'services/api_service.dart';

// ── Constants ────────────────────────────────────────────────────
const String kBackendUrl = 'https://nijamdeen-kutty-guru-api.hf.space/chat';

// ── [CHANGE 5] Sales Assistant System Context ────────────────────
// Injected as 'system' field in every API call.
// Your HF backend can read this and override the default persona.
const String kSalesSystemPrompt =
    'You are the "Allin1 Sales Assistant" by NJ TECH. '
    'Help customers order from: 🍔 Food Delivery (16th Road specials), '
    '🍅 Grocery (Erode Fresh), 📱 Tech Accessories (NJ TECH store), '
    '🚕 Bike Taxi (local Erode rides). '
    'Be friendly, use Tamil/English mix naturally. '
    'Proactively suggest items, collect address, confirm orders. '
    'Handle cross-category orders (e.g. biryani + charger). '
    'Focus on taking orders efficiently — you are a sales assistant, not a general Q&A bot.';

const Color kBg = Color(0xFF08080F);
const Color kSurface = Color(0xFF111118);
const Color kCard = Color(0xFF1A1A26);
const Color kCard2 = Color(0xFF20202E);
const Color kPurple = Color(0xFF7B6FE0);
const Color kPurple2 = Color(0xFF9B8FF0);
const Color kOrange = Color(0xFFE07C6F);
const Color kGreen = Color(0xFF3DBA6F);
const Color kGold = Color(0xFFF5C542);
const Color kText = Color(0xFFEEEEF5);
const Color kMuted = Color(0xFF7777A0);
const Color kBorder = Color(0x2E7B6FE0);

// ── Data Models ──────────────────────────────────────────────────
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'time': time.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        text: j['text'] as String,
        isUser: j['isUser'] as bool,
        time: DateTime.parse(j['time'] as String),
      );
}

class MarketRate {
  final String emoji;
  final String name;
  final String price;
  final String change;
  final bool isUp;

  const MarketRate({
    required this.emoji,
    required this.name,
    required this.price,
    required this.change,
    required this.isUp,
  });
}

// ── [CHANGE 1] CommerceCard — replaces old ComingSoonCard ────────
class CommerceCard {
  final String emoji;
  final String title;
  final String subtitle;
  final String chatPrompt; // auto-sent to chat on card tap
  final Color cardColor; // per-category accent glow

  const CommerceCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.chatPrompt,
    required this.cardColor,
  });
}

// ── Static Data ──────────────────────────────────────────────────
const List<MarketRate> kMarketRates = [
  MarketRate(
    emoji: '🟡',
    name: 'மஞ்சள்',
    price: '₹9,400/kg',
    change: '▲ 2.1%',
    isUp: true,
  ),
  MarketRate(
    emoji: '🥥',
    name: 'தேங்காய்',
    price: '₹28/pc',
    change: '▼ 0.5%',
    isUp: false,
  ),
  MarketRate(
    emoji: '🌿',
    name: 'கொத்தமல்லி',
    price: '₹120/kg',
    change: '▲ 1.3%',
    isUp: true,
  ),
];

// ── [CHANGE 2] 4 Commerce categories replace the SOON cards ──────
const List<CommerceCard> kCommerceCards = [
  CommerceCard(
    emoji: '🍔',
    title: 'Food Delivery',
    subtitle: '16th Road Specials',
    chatPrompt:
        "நான் food order பண்ண வேண்டும். What are today's popular dishes and specials in Erode?",
    cardColor: Color(0xFFE07C6F),
  ),
  CommerceCard(
    emoji: '🍅',
    title: 'Grocery',
    subtitle: 'Erode Fresh',
    chatPrompt:
        "I want to order fresh groceries from Erode Fresh. Show me today's vegetables, fruits and essentials.",
    cardColor: Color(0xFF3DBA6F),
  ),
  CommerceCard(
    emoji: '📱',
    title: 'Tech Accessories',
    subtitle: 'By NJ TECH',
    chatPrompt:
        'I need mobile accessories from NJ TECH. Show me chargers, cables, earphones and other available accessories with prices.',
    cardColor: Color(0xFF7B6FE0),
  ),
  CommerceCard(
    emoji: '🚕',
    title: 'Bike Taxi',
    subtitle: 'Fast local rides',
    chatPrompt:
        'I need to book a bike taxi in Erode. Please ask me for my pickup location and destination.',
    cardColor: Color(0xFFF5C542),
  ),
];

// Quick chips updated to match commerce categories
const List<Map<String, String>> kQuickChips = [
  {'emoji': '🍔', 'text': 'Food Delivery — 16th Road Specials'},
  {'emoji': '🍅', 'text': 'Grocery — Erode Fresh order'},
  {'emoji': '📱', 'text': 'Mobile Accessories — NJ TECH'},
  {'emoji': '🚕', 'text': 'Bike Taxi — Quick ride booking'},
  {'emoji': '🟡', 'text': 'மஞ்சள் விலை இன்னைக்கு எவ்வளவு?'},
];

// ── Main ─────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    setPathUrlStrategy();
  }

  await Hive.initFlutter();
  await Hive.openBox('chat_history');

  // Initialize API Service with Qwen token
  await ApiService.instance.initialize(
    qwenToken:
        'dmy2Te5qdGLItvvG9_xegryBQmO8Ksfn9XI8_r_0NuTKNoVLF0JGsLg54HqZySQ03_Y1o2c11Q46vqjY485fpw',
  );

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init: $e');
  }

  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),
      ],
      child: const Allin1App(),
    ),
  );
}

// ================================================================
// CLASS 1 — Allin1App
// ================================================================
class Allin1App extends StatelessWidget {
  const Allin1App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Allin1 Super App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBg,
        colorSchemeSeed: kPurple,
        useMaterial3: true,
        textTheme: GoogleFonts.notoSansTamilTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: kIsWeb
          ? const LandingScreen()
          : StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SplashScreen();
                }
                if (snap.hasData) {
                  return const SplashScreen(); // Show splash then Dashboard
                }
                return const LoginScreen();
              },
            ),
      routes: {
        '/login': (ctx) => const LoginScreen(),
        '/chat': (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments;
          return ChatScreen(initialMessage: args is String ? args : null);
        },
        '/seller': (ctx) => const SellerLoginScreen(),
        '/rider': (ctx) => const RiderLoginScreen(),
        '/admin': (ctx) => const AdminLoginScreen(),
        '/seller-portal': (ctx) => const SellerScreen(),
        '/rider-portal': (ctx) => const RiderScreen(),
        '/admin-panel': (ctx) => const AdminDashboardScreen(),
        '/ai1admin': (ctx) => const AdminDashboardScreen(),
        '/credentials-admin': (ctx) => const CredentialsAdminScreen(),
        '/profile': (ctx) => const ProfileScreen(),
        '/settings': (ctx) => const SettingsScreen(),
        '/payment': (ctx) => const PaymentScreen(),
        '/cart': (ctx) => const CartScreen(),
        '/order-tracking': (ctx) => const OrderTrackingScreen(orderId: ''),
        '/notifications': (ctx) => const NotificationsScreen(),
        '/captain-docs': (ctx) => const CaptainDocumentScreen(),
        '/ride-history': (ctx) => const RideHistoryScreen(),
        '/captain': (ctx) => const CaptainScreen(),
        '/bike-taxi': (ctx) => const BikeTaxiScreen(),
      },
    );
  }
}

// ================================================================
// CLASS 2 — SplashScreen
// ================================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.7, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const SuperDash.DashboardScreen(),
            transitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPurple, kOrange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: kPurple.withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🛒', style: TextStyle(fontSize: 44)),
                  ),
                ),
                const SizedBox(height: 24),
                ShaderMask(
                  shaderCallback: (r) => const LinearGradient(
                    colors: [kPurple2, kOrange],
                  ).createShader(r),
                  child: Text(
                    'Allin1 Super App',
                    style: GoogleFonts.notoSansTamil(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Food · Grocery · Tech · Bike Taxi',
                  style: TextStyle(
                    fontSize: 11,
                    color: kMuted,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Powered by BAPX & NJ TECH',
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 10,
                    color: kPurple,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// CLASS 3 — DashboardScreen (v4.1 — Dual Mode: Customer + Captain)
// ================================================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _captainMode = false;

  @override
  Widget build(BuildContext context) {
    if (_captainMode) {
      return CaptainScreen(
        onExitCaptain: () => setState(() => _captainMode = false),
      );
    }
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            _DashAppBar(
              onCaptainToggle: () =>
                  setState(() => _captainMode = !_captainMode),
              captainMode: _captainMode,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'வணக்கம்! 👋',
                      style: GoogleFonts.notoSansTamil(
                        fontSize: 13,
                        color: kMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ShaderMask(
                      shaderCallback: (r) => const LinearGradient(
                        colors: [kText, kPurple2],
                      ).createShader(r),
                      child: Text(
                        'என்ன வேண்டும்\nஇன்றைக்கு?',
                        style: GoogleFonts.notoSansTamil(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Live chat card — unchanged
                    _LiveChatCard(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChatScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Market ticker — unchanged
                    const _MarketTicker(),
                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RideHistoryScreen(),),),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: kCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: kBorder),),
                        child: Row(children: [
                          const Text('🏍️', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Text('My Rides',
                              style: GoogleFonts.notoSansTamil(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: kText,),),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_ios,
                              size: 12, color: kMuted,),
                        ],),
                      ),
                    ),

                    // ── [CHANGE 3] Commerce grid section label ───
                    const Row(
                      children: [
                        Text('🛍️', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 6),
                        Text(
                          'OUR SERVICES',
                          style: TextStyle(
                            fontSize: 10,
                            color: kMuted,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ── [CHANGE 3] Commerce grid ─────────────────
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.25,
                      children: kCommerceCards
                          .map((c) => _CommerceGridCard(data: c))
                          .toList(),
                    ),

                    const SizedBox(height: 16),
                    const _DisclaimerBar(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// CLASS 4 — ChatScreen
// ── [CHANGE 4] Added optional initialMessage ─────────────────────
// ================================================================
class ChatScreen extends StatefulWidget {
  /// When set (from commerce card tap), auto-sent as opening message.
  final String? initialMessage;
  const ChatScreen({super.key, this.initialMessage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('initialMessage', initialMessage));
  }
}

// ================================================================
// CLASS 5 — _ChatScreenState
// ================================================================
class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<ChatMessage> _messages = [];

  bool _loading = false;
  bool _listening = false;

  late Box _box;
  final SpeechToText _speech = SpeechToText();
  bool _speechOk = false;
  late AnimationController _dotCtrl;

  @override
  void initState() {
    super.initState();
    _box = Hive.box('chat_history');
    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _initSpeech();
    _loadHistory();

    // ── [CHANGE 4] Auto-send pre-filled category prompt ──────────
    if (widget.initialMessage != null) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _send(widget.initialMessage!);
      });
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _dotCtrl.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    _speechOk =
        await _speech.initialize(onError: (e) => debugPrint('Speech: $e'));
    setState(() {});
  }

  void _loadHistory() {
    final saved = _box.get('messages');
    if (saved != null) {
      final decoded = jsonDecode(saved as String) as List<dynamic>;
      setState(() {
        _messages.addAll(
          decoded.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)),
        );
      });
    }
  }

  Future<void> _saveHistory() async {
    await _box.put(
      'messages',
      jsonEncode(_messages.map((m) => m.toJson()).toList()),
    );
  }

  Future<void> _clearChat() async {
    await _box.delete('messages');
    setState(_messages.clear);
  }

  void _showClearDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard2,
        title: const Text('Chat Clear', style: TextStyle(color: kText)),
        content:
            const Text('உரையாடல் அழிக்கவா?', style: TextStyle(color: kMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('வேண்டாம்', style: TextStyle(color: kMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _clearChat();
            },
            child: const Text('ஆமாம்', style: TextStyle(color: kOrange)),
          ),
        ],
      ),
    );
  }

  // ── [CHANGE 5] _send() injects kSalesSystemPrompt ────────────
  Future<void> _send(String text) async {
    final t = text.trim();
    if (t.isEmpty || _loading) return;

    try {
      await FirebaseAnalytics.instance.logEvent(name: 'message_sent');
    } catch (_) {}

    setState(() {
      _messages.add(ChatMessage(text: t, isUser: true, time: DateTime.now()));
      _loading = true;
    });
    _input.clear();
    _scrollDown();

    final history = _messages
        .take(_messages.length - 1)
        .map(
          (m) => api.MessageHistory(
            role: m.isUser ? 'user' : 'assistant',
            content: m.text,
          ),
        )
        .toList();

    try {
      final chatResponse = await ApiService.instance.sendChat(
        message: t,
        history: history,
        systemPrompt: kSalesSystemPrompt,
      );

      final reply = chatResponse.success
          ? chatResponse.response
          : 'சர்வர் பிழை. மீண்டும் முயற்சிக்கவும். 🙏';

      setState(() {
        _messages
            .add(ChatMessage(text: reply, isUser: false, time: DateTime.now()));
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'பிழை ஏற்பட்டது: $e',
            isUser: false,
            time: DateTime.now(),
          ),
        );
        _loading = false;
      });
      debugPrint('Send error: $e');
    }

    await _saveHistory();
    _scrollDown();
  }

  Future<void> _toggleMic() async {
    if (!_speechOk) return;
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
    } else {
      setState(() => _listening = true);
      await _speech.listen(
        onResult: (r) => setState(() {
          _input.text = r.recognizedWords;
          _input.selection = TextSelection.fromPosition(
            TextPosition(offset: _input.text.length),
          );
        }),
        localeId: 'ta_IN',
        listenOptions: SpeechListenOptions(listenMode: ListenMode.dictation),
      );
    }
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _shareOnWhatsApp(String text) async {
    final encoded = Uri.encodeComponent(
      '*Allin1 Super App — NJ TECH கூறுகிறது:*\n\n$text\n\n'
      '_Powered by NJ TECH_\n_App: Allin1 Super App (Free)_',
    );
    final uri = Uri.parse('https://wa.me/?text=$encoded');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Align(
                child: Opacity(
                  opacity: 0.06,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [kPurple, kOrange, Colors.transparent],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                    child: const Center(
                      child: Text('🧘', style: TextStyle(fontSize: 120)),
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                _AppBar(
                  title: 'Allin1 Sales Assistant',
                  subtitle: 'உங்கள் order ready-ஆக சொல்லுங்கள்...',
                  showBack: true,
                  onBack: () => Navigator.pop(context),
                  onDelete: _showClearDialog,
                ),
                if (_messages.isEmpty && !_loading)
                  Expanded(child: _WelcomeView(onChipTap: _send))
                else
                  Expanded(
                    child: ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (_, i) => ChatBubble(
                        message: _messages[i],
                        onCopy: () {
                          Clipboard.setData(
                            ClipboardData(text: _messages[i].text),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('நகலெடுக்கப்பட்டது'),
                              duration: Duration(seconds: 1),
                              backgroundColor: kPurple,
                            ),
                          );
                        },
                        onShare: () => _shareOnWhatsApp(_messages[i].text),
                      ),
                    ),
                  ),
                if (_loading) _TypingBar(controller: _dotCtrl),
                _InputBar(
                  controller: _input,
                  isListening: _listening,
                  onSend: () => _send(_input.text),
                  onMic: _toggleMic,
                ),
                const _DisclaimerBar(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// CLASS 6 — _AppBar (unchanged logic, icon updated to 🛒)
// ================================================================
class _AppBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final VoidCallback? onDelete;

  const _AppBar({
    required this.title,
    required this.subtitle,
    required this.showBack,
    this.onBack,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(bottom: BorderSide(color: kBorder)),
      ),
      child: Row(
        children: [
          if (showBack)
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kBorder),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 14,
                  color: kMuted,
                ),
              ),
            ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPurple, kOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text('🛒', style: TextStyle(fontSize: 20)),
                ),
              ),
              Positioned(
                right: 1,
                bottom: 1,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: kGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: kSurface, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kText,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: kMuted),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete ?? () {},
            icon: const Icon(Icons.delete_outline, color: kOrange, size: 20),
            tooltip: 'Clear',
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined, color: kMuted, size: 20),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Colors.red,
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
    properties.add(StringProperty('subtitle', subtitle));
    properties.add(DiagnosticsProperty<bool>('showBack', showBack));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onBack', onBack));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onDelete', onDelete));
  }
}

// ================================================================
// _DashAppBar — Dashboard AppBar with Captain Mode toggle
// ================================================================
class _DashAppBar extends StatelessWidget {
  final VoidCallback onCaptainToggle;
  final bool captainMode;

  const _DashAppBar({
    required this.onCaptainToggle,
    required this.captainMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(bottom: BorderSide(color: kBorder)),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPurple, kOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text('🛒', style: TextStyle(fontSize: 20)),
                ),
              ),
              Positioned(
                right: 1,
                bottom: 1,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: kGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: kSurface, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Allin1 Super App',
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kText,
                  ),
                ),
                const Text(
                  'Online · NJ TECH · 4-in-1 Platform',
                  style: TextStyle(fontSize: 10, color: kMuted),
                ),
              ],
            ),
          ),
          // ── Captain / Customer Mode Toggle ──
          GestureDetector(
            onTap: onCaptainToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: captainMode
                    ? const Color(0x1AF5C542)
                    : const Color(0x1A7B6FE0),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: captainMode
                      ? const Color(0x66F5C542)
                      : const Color(0x407B6FE0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    captainMode ? '🏍️' : '👤',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    captainMode ? 'CAPTAIN' : 'CUSTOMER',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: captainMode ? kGold : kPurple2,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete_outline, color: kOrange, size: 20),
            tooltip: 'Clear',
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<VoidCallback>.has('onCaptainToggle', onCaptainToggle));
    properties.add(DiagnosticsProperty<bool>('captainMode', captainMode));
  }
}

// ================================================================
// CLASS 7 — _LiveChatCard (subtitle updated)
// ================================================================
class _LiveChatCard extends StatelessWidget {
  final VoidCallback onTap;
  const _LiveChatCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1e1836), Color(0xFF1a1428)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x597B6FE0)),
          boxShadow: [
            BoxShadow(
              color: kPurple.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: kGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kGreen.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: kGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'LIVE NOW',
                          style: TextStyle(
                            fontSize: 9,
                            color: kGreen,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '💬 Sales Assistant-கிடம் கேளுங்கள்',
                    style: GoogleFonts.notoSansTamil(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: kText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Food, Grocery, Tech, Bike Taxi — எதுவும் order பண்ணலாம்',
                    style: TextStyle(fontSize: 11, color: kMuted),
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: kPurple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: const Icon(Icons.arrow_forward_ios,
                  size: 14, color: kPurple2,),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<VoidCallback>.has('onTap', onTap));
  }
}

// ================================================================
// CLASS 8 — _MarketTicker (unchanged)
// ================================================================
class _MarketTicker extends StatelessWidget {
  const _MarketTicker();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('📊', style: TextStyle(fontSize: 13)),
              SizedBox(width: 6),
              Text(
                'ERODE MARKET — TODAY',
                style: TextStyle(
                  fontSize: 10,
                  color: kMuted,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...kMarketRates.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(r.emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      r.name,
                      style: GoogleFonts.notoSansTamil(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: kText,
                      ),
                    ),
                  ),
                  Text(
                    r.price,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kGold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    r.change,
                    style: TextStyle(
                      fontSize: 11,
                      color: r.isUp ? kGreen : kOrange,
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
}

// ================================================================
// CLASS 9 — _CommerceGridCard  ← [CHANGE 3] Full replacement
//   • No SOON badge
//   • Per-category color glow border + gradient bg
//   • InkWell ripple on tap
//   • Navigates to ChatScreen with auto-sent prompt
// ================================================================
class _CommerceGridCard extends StatelessWidget {
  final CommerceCard data;
  const _CommerceGridCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (data.title == 'Bike Taxi') {
            Navigator.push(
              context,
              PageRouteBuilder<void>(
                pageBuilder: (_, __, ___) => const BikeTaxiScreen(),
                transitionDuration: const Duration(milliseconds: 350),
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
              ),
            );
          } else {
            Navigator.push(
              context,
              PageRouteBuilder<void>(
                pageBuilder: (_, __, ___) =>
                    ChatScreen(initialMessage: data.chatPrompt),
                transitionDuration: const Duration(milliseconds: 350),
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: data.cardColor.withValues(alpha: 0.18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kCard, data.cardColor.withValues(alpha: 0.08)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: data.cardColor.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: data.cardColor.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top: emoji circle + arrow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: data.cardColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: data.cardColor.withValues(alpha: 0.3),),
                    ),
                    child: Center(
                      child: Text(
                        data.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: data.cardColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: data.cardColor.withValues(alpha: 0.3),),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: data.cardColor,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Title
              Text(
                data.title,
                style: GoogleFonts.notoSansTamil(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: kText,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 3),
              // Subtitle in category color
              Text(
                data.subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: data.cardColor.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                ),
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
    properties.add(DiagnosticsProperty<CommerceCard>('data', data));
  }
}

// ================================================================
// CLASS 10 — _WelcomeView (chips updated to commerce)
// ================================================================
class _WelcomeView extends StatelessWidget {
  final void Function(String) onChipTap;
  const _WelcomeView({required this.onChipTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            'என்ன order பண்ணலாம்?',
            style: GoogleFonts.notoSansTamil(fontSize: 13, color: kMuted),
          ),
          const SizedBox(height: 16),
          ...kQuickChips.map(
            (c) => GestureDetector(
              onTap: () => onChipTap(c['text']!),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorder),
                ),
                child: Row(
                  children: [
                    Text(c['emoji']!, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        c['text']!,
                        style: GoogleFonts.notoSansTamil(
                          fontSize: 14,
                          color: kText,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: kMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        ObjectFlagProperty<void Function(String)>.has('onChipTap', onChipTap),);
  }
}

// ================================================================
// CLASSES 11–17 — ALL UNCHANGED (chat pipeline intact)
// ================================================================

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const ChatBubble({
    required this.message,
    required this.onCopy,
    required this.onShare,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return message.isUser
        ? _UserBubble(text: message.text)
        : _BotBubble(text: message.text, onCopy: onCopy, onShare: onShare);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ChatMessage>('message', message));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onCopy', onCopy));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onShare', onShare));
  }
}

class _UserBubble extends StatelessWidget {
  final String text;
  const _UserBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 60),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF9B8FF0), kPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: kPurple.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.notoSansTamil(fontSize: 14, color: Colors.white),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('text', text));
  }
}

class _BotBubble extends StatelessWidget {
  final String text;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _BotBubble({
    required this.text,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [kPurple, kOrange]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('🛒', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Allin1 Sales Assistant',
                  style: TextStyle(fontSize: 10, color: kMuted),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(color: kBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Markdown(
                    data: text,
                    styleSheet: MarkdownStyleSheet(
                      p: GoogleFonts.notoSansTamil(
                        fontSize: 14,
                        color: kText,
                        height: 1.6,
                      ),
                      strong: GoogleFonts.notoSansTamil(
                        fontWeight: FontWeight.w700,
                        color: kPurple2,
                      ),
                      listBullet: const TextStyle(color: kPurple2),
                    ),
                    onTapLink: (t, href, title) async {
                      if (href != null) {
                        final uri = Uri.parse(href);
                        if (await canLaunchUrl(uri)) await launchUrl(uri);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _BubbleAction(
                        icon: Icons.copy,
                        label: 'நகலெடு',
                        onTap: onCopy,
                      ),
                      const SizedBox(width: 14),
                      _BubbleAction(
                        icon: Icons.share,
                        label: 'WhatsApp',
                        onTap: onShare,
                        color: const Color(0xFF25D366),
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
    properties.add(StringProperty('text', text));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onCopy', onCopy));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onShare', onShare));
  }
}

class _BubbleAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _BubbleAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? kMuted;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: c),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, color: c)),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
    properties.add(StringProperty('label', label));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onTap', onTap));
    properties.add(ColorProperty('color', color));
  }
}

class _TypingBar extends StatelessWidget {
  final AnimationController controller;
  const _TypingBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedDotsIndicator(controller: controller),
          ),
          const SizedBox(width: 8),
          const Text(
            'Order தயாரிக்கிறேன்...',
            style: TextStyle(fontSize: 11, color: kMuted),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<AnimationController>('controller', controller),);
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isListening;
  final VoidCallback onSend;
  final VoidCallback onMic;

  const _InputBar({
    required this.controller,
    required this.isListening,
    required this.onSend,
    required this.onMic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(top: BorderSide(color: kBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isListening ? Colors.red : kBorder,
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: controller,
                style: GoogleFonts.notoSansTamil(color: kText, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Order பண்ணுங்கள்...',
                  hintStyle: TextStyle(color: kMuted, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onMic,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isListening ? Colors.red : kCard,
                shape: BoxShape.circle,
                border: Border.all(color: isListening ? Colors.red : kBorder),
              ),
              child: Icon(
                isListening ? Icons.mic : Icons.mic_none,
                color: isListening ? Colors.white : kMuted,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kPurple, kPurple2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kPurple.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<TextEditingController>('controller', controller),);
    properties.add(DiagnosticsProperty<bool>('isListening', isListening));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onSend', onSend));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onMic', onMic));
  }
}

class _DisclaimerBar extends StatelessWidget {
  const _DisclaimerBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: kBg,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Orders are AI-assisted. Please confirm before final payment.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9.5, color: kMuted),
          ),
          SizedBox(height: 2),
          Text(
            'Powered by NJ TECH · Allin1 Super App',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.5,
              color: kPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedDotsIndicator extends StatelessWidget {
  final AnimationController controller;
  const AnimatedDotsIndicator({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            final phase = (controller.value + i * 0.33) % 1.0;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: kPurple.withValues(alpha: 0.3 + phase * 0.7),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<AnimationController>('controller', controller),);
  }
}
