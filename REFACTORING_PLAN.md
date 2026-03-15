# Refactoring Plan: Erode Super App

**Document Date:** March 13, 2026  
**Author:** Code Review Agent (Swarm Mode)  
**Project:** Erode Super App - Flutter Commerce Application  
**Current State:** 1,450-line monolithic main.dart  
**Target State:** Modular, testable, maintainable architecture  
**Estimated Timeline:** 3-4 weeks

---

## Executive Summary

This refactoring plan outlines the step-by-step migration from a monolithic 1,450-line `main.dart` to a well-organized, modular architecture with 15-20 files. The plan prioritizes zero breakage while systematically improving code quality, testability, and maintainability.

### Current State Analysis

| Metric | Value |
|--------|-------|
| **Total Lines** | 1,450 (main.dart) |
| **Files** | 1 (main.dart) + 4 new services |
| **Classes** | 17 (all in one file) |
| **Test Coverage** | ~60% (models/widgets), 0% (services) |
| **Cyclomatic Complexity** | High (estimated 45+) |
| **Maintainability Index** | Low (estimated 35/100) |

### Target State

| Metric | Target |
|--------|--------|
| **Total Files** | 18-22 |
| **Max Lines/File** | < 300 |
| **Test Coverage** | > 85% |
| **Cyclomatic Complexity** | < 15 per file |
| **Maintainability Index** | > 70/100 |

---

## Proposed File Structure

```
lib/
├── main.dart                      (50 lines)   - App entry point
├── app.dart                       (120 lines)  - MaterialApp configuration
│
├── config/
│   ├── api_config.dart            (230 lines)  - ✅ Already exists
│   ├── theme_config.dart          (80 lines)   - Color palette, themes
│   ├── app_config.dart            (60 lines)   - App-wide constants
│   └── security_config.dart       (70 lines)   - Security settings
│
├── models/
│   ├── chat_message.dart          (60 lines)   - ChatMessage model
│   ├── commerce_card.dart         (50 lines)   - CommerceCard model
│   ├── market_rate.dart           (50 lines)   - MarketRate model
│   └── api_models.dart            (445 lines)  - ✅ Already exists
│
├── screens/
│   ├── splash_screen.dart         (150 lines)  - SplashScreen
│   ├── dashboard_screen.dart      (200 lines)  - DashboardScreen
│   └── chat_screen.dart           (350 lines)  - ChatScreen
│
├── widgets/
│   ├── app_bar_widget.dart        (100 lines)  - _AppBar widget
│   ├── chat_bubble.dart           (150 lines)  - ChatBubble, _UserBubble, _BotBubble
│   ├── commerce_card_widget.dart  (120 lines)  - _CommerceGridCard
│   ├── live_chat_card.dart        (100 lines)  - _LiveChatCard
│   ├── market_ticker.dart         (80 lines)   - _MarketTicker
│   ├── welcome_view.dart          (80 lines)   - _WelcomeView
│   ├── typing_indicator.dart      (60 lines)   - _TypingBar, AnimatedDotsIndicator
│   └── input_bar.dart             (100 lines)  - _InputBar
│
├── services/
│   ├── api_service.dart           (882 lines)  - ✅ Already exists
│   ├── analytics_service.dart     (944 lines)  - ✅ Already exists
│   ├── speech_service.dart        (150 lines)  - Speech-to-text wrapper
│   ├── storage_service.dart       (120 lines)  - Hive storage wrapper
│   └── auth_service.dart          (100 lines)  - 🔴 NEW - Authentication
│
├── providers/
│   ├── chat_provider.dart         (120 lines)  - Chat state management
│   └── theme_provider.dart        (60 lines)   - Theme state management
│
├── utils/
│   ├── validators.dart            (100 lines)  - Input validation
│   ├── url_validator.dart         (60 lines)   - URL validation
│   ├── error_handler.dart         (80 lines)   - Error handling
│   └── extensions.dart            (80 lines)   - Dart extensions
│
└── routes/
    └── app_routes.dart            (50 lines)   - Navigation routes

Total: 21 files (excluding existing 4)
```

---

## Refactoring Principles

### 1. Zero Breakage Guarantee
- Each refactoring step maintains full functionality
- Tests pass after each step
- Rollback plan for each phase

### 2. Incremental Approach
- Small, testable changes
- Feature flags for gradual rollout
- A/B testing capability

### 3. Test-Driven Refactoring
- Write tests before refactoring
- Maintain >90% coverage throughout
- No regression in test metrics

### 4. Documentation First
- Document before extracting
- Maintain API compatibility
- Update README for each change

---

## Phase 1: Foundation (Week 1)

### Day 1-2: Configuration & Constants

**Task 1.1: Extract Configuration**
```dart
// lib/config/theme_config.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color bg = Color(0xFF08080F);
  static const Color surface = Color(0xFF111118);
  static const Color card = Color(0xFF1A1A26);
  static const Color card2 = Color(0xFF20202E);
  static const Color purple = Color(0xFF7B6FE0);
  static const Color purple2 = Color(0xFF9B8FF0);
  static const Color orange = Color(0xFFE07C6F);
  static const Color green = Color(0xFF3DBA6F);
  static const Color gold = Color(0xFFF5C542);
  static const Color text = Color(0xFFEEEEF5);
  static const Color muted = Color(0xFF7777A0);
  static const Color border = Color(0x2E7B6FE0);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorSchemeSeed: AppColors.purple,
      useMaterial3: true,
      // ... rest of theme
    );
  }
}
```

**Task 1.2: Extract Constants**
```dart
// lib/config/app_config.dart
class AppConfig {
  static const String appName = 'Erode Super App';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Food · Grocery · Tech · Bike Taxi';
  
  // Animation durations
  static const Duration splashFadeDuration = Duration(milliseconds: 1200);
  static const Duration splashDelay = Duration(milliseconds: 3200);
  static const Duration transitionDuration = Duration(milliseconds: 600);
  
  // Chat limits
  static const int maxMessageLength = 2000;
  static const int maxChatHistory = 100;
  static const int messageDebounceMs = 500;
}
```

**Acceptance Criteria:**
- [ ] All constants extracted
- [ ] No functionality changes
- [ ] All tests pass
- [ ] Documentation updated

---

### Day 3-4: Model Extraction

**Task 1.3: Extract ChatMessage**
```dart
// lib/models/chat_message.dart
import 'dart:convert';

/// Represents a chat message in the conversation.
/// 
/// This model handles serialization/deserialization for storage.
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          isUser == other.isUser &&
          time == other.time;

  @override
  int get hashCode => Object.hash(text, isUser, time);
}
```

**Task 1.4: Extract CommerceCard and MarketRate**
```dart
// lib/models/commerce_card.dart
import 'package:flutter/material.dart';

/// Represents a commerce category card on the dashboard.
class CommerceCard {
  final String emoji;
  final String title;
  final String subtitle;
  final String chatPrompt;
  final Color cardColor;

  const CommerceCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.chatPrompt,
    required this.cardColor,
  });

  @override
  bool operator ==(Object other) => /* ... */;
  @override
  int get hashCode => Object.hash(emoji, title, subtitle, chatPrompt, cardColor);
}

// Static data moved here
class CommerceCards {
  static const List<CommerceCard> all = [
    CommerceCard(
      emoji: '🍔',
      title: 'Food Delivery',
      subtitle: '16th Road Specials',
      chatPrompt: 'நான் food order பண்ண வேண்டும்...',
      cardColor: Color(0xFFE07C6F),
    ),
    // ... other cards
  ];
}
```

**Acceptance Criteria:**
- [ ] All models extracted
- [ ] Tests updated for new imports
- [ ] No circular dependencies
- [ ] Documentation complete

---

### Day 5: Security Configuration

**Task 1.5: Create Security Config**
```dart
// lib/config/security_config.dart
class SecurityConfig {
  static const bool requireAuthentication = true;
  static const bool requireHttps = true;
  static const int maxInputLength = 2000;
  static const List<String> allowedUrlSchemes = ['https', 'http'];
}
```

---

## Phase 2: Widget Extraction (Week 2)

### Day 1-2: Basic Widgets

**Task 2.1: Extract AppBar Widget**
```dart
// lib/widgets/app_bar_widget.dart
import 'package:flutter/material.dart';
import '../config/theme_config.dart';

class AppAppBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final VoidCallback? onDelete;

  const AppAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.showBack,
    this.onBack,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // ... existing implementation
    );
  }
}
```

**Task 2.2: Extract Chat Bubble Widgets**
```dart
// lib/widgets/chat_bubble.dart
class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const ChatBubble({
    super.key,
    required this.message,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return message.isUser
        ? UserBubble(text: message.text)
        : BotBubble(text: message.text, onCopy: onCopy, onShare: onShare);
  }
}

class UserBubble extends StatelessWidget {
  // ... implementation
}

class BotBubble extends StatelessWidget {
  // ... implementation
}
```

---

### Day 3-4: Dashboard Widgets

**Task 2.3: Extract Commerce Card Widget**
```dart
// lib/widgets/commerce_card_widget.dart
class CommerceCardWidget extends StatelessWidget {
  final CommerceCard data;
  final VoidCallback onTap;

  const CommerceCardWidget({
    super.key,
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        // ... existing implementation
      ),
    );
  }
}
```

**Task 2.4: Extract Market Ticker**
```dart
// lib/widgets/market_ticker.dart
class MarketTickerWidget extends StatelessWidget {
  const MarketTickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // ... existing implementation
    );
  }
}
```

---

### Day 5: Chat Widgets

**Task 2.5: Extract Input Bar and Typing Indicator**
```dart
// lib/widgets/input_bar.dart
class InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isListening;
  final VoidCallback onSend;
  final VoidCallback onMic;

  const InputBar({
    super.key,
    required this.controller,
    required this.isListening,
    required this.onSend,
    required this.onMic,
  });

  @override
  Widget build(BuildContext context) {
    // ... implementation
  }
}

// lib/widgets/typing_indicator.dart
class TypingIndicator extends StatelessWidget {
  final AnimationController controller;

  const TypingIndicator({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // ... implementation
  }
}
```

---

## Phase 3: Screen Extraction (Week 3)

### Day 1-2: Splash and Dashboard

**Task 3.1: Extract SplashScreen**
```dart
// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import '../config/theme_config.dart';
import '../config/app_config.dart';
import 'dashboard_screen.dart';

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
      duration: AppConfig.splashFadeDuration,
    );
    // ... rest of implementation
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... existing implementation
    );
  }
}
```

**Task 3.2: Extract DashboardScreen**
```dart
// lib/screens/dashboard_screen.dart
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppAppBar(
              title: AppConfig.appName,
              subtitle: 'Online · NJ TECH · 4-in-1 Platform',
              showBack: false,
            ),
            Expanded(
              child: SingleChildScrollView(
                // ... existing implementation
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### Day 3-5: Chat Screen

**Task 3.3: Extract ChatScreen**
```dart
// lib/screens/chat_screen.dart
class ChatScreen extends StatefulWidget {
  final String? initialMessage;
  const ChatScreen({super.key, this.initialMessage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<ChatMessage> _messages = [];
  
  bool _loading = false;
  bool _listening = false;
  bool _isSending = false;  // Fix for race condition
  
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
    
    if (widget.initialMessage != null) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _send(widget.initialMessage!);
      });
    }
  }

  @override
  void dispose() {
    // Fix: Proper cleanup
    if (_speech.isListening) {
      _speech.stop();
    }
    Hive.box('chat_history').close();
    _input.dispose();
    _scroll.dispose();
    _dotCtrl.dispose();
    super.dispose();
  }

  // ... rest of implementation
}
```

---

## Phase 4: Services & State Management (Week 4)

### Day 1-2: Service Layer

**Task 4.1: Create Speech Service Wrapper**
```dart
// lib/services/speech_service.dart
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  Future<bool> initialize() async {
    try {
      _isInitialized = await _speech.initialize();
      return _isInitialized;
    } catch (e) {
      debugPrint('Speech initialization failed: $e');
      return false;
    }
  }

  Future<void> startListening(Function(String) onResult) async {
    if (!_isInitialized) return;
    
    await _speech.listen(
      onResult: (result) => onResult(result.recognizedWords),
      localeId: 'ta_IN',
      listenMode: ListenMode.dictation,
    );
    _isListening = true;
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    await _speech.stop();
    _isListening = false;
  }

  void dispose() {
    if (_isListening) {
      _speech.stop();
    }
  }
}
```

**Task 4.2: Create Storage Service Wrapper**
```dart
// lib/services/storage_service.dart
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_message.dart';

class StorageService {
  static const String _boxName = 'chat_history';
  static const String _messagesKey = 'messages';
  
  late Box _box;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  Future<void> saveMessages(List<ChatMessage> messages) async {
    final json = messages.map((m) => m.toJson()).toList();
    await _box.put(_messagesKey, jsonEncode(json));
  }

  List<ChatMessage> loadMessages() {
    final saved = _box.get(_messagesKey);
    if (saved == null) return [];
    
    final decoded = jsonDecode(saved as String) as List<dynamic>;
    return decoded
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> clear() async {
    await _box.delete(_messagesKey);
  }

  Future<void> close() async {
    await _box.close();
  }
}
```

---

### Day 3: State Management

**Task 4.3: Implement Provider-based State**
```dart
// lib/providers/chat_provider.dart
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/storage_service.dart';

class ChatProvider extends ChangeNotifier {
  final StorageService _storage;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  ChatProvider(this._storage);

  List<ChatMessage> get messages => UnmodifiableListView(_messages);
  bool get isLoading => _isLoading;

  Future<void> loadHistory() async {
    final saved = _storage.loadMessages();
    _messages.addAll(saved);
    notifyListeners();
  }

  void addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  Future<void> saveHistory() async {
    await _storage.saveMessages(_messages);
  }

  @override
  void dispose() {
    _messages.clear();
    super.dispose();
  }
}
```

---

### Day 4: Utility Classes

**Task 4.4: Create Validators**
```dart
// lib/utils/validators.dart
class InputValidator {
  static const int maxLength = 2000;
  
  static final RegExp _dangerousPatterns = RegExp(
    r'(<script|javascript:|data:|vbscript:)',
    caseSensitive: false,
  );

  static ValidationResult validate(String input) {
    final trimmed = input.trim();
    
    if (trimmed.isEmpty) {
      return ValidationResult.invalid('Message cannot be empty');
    }
    
    if (trimmed.length > maxLength) {
      return ValidationResult.invalid('Message too long');
    }
    
    if (_dangerousPatterns.hasMatch(trimmed)) {
      return ValidationResult.invalid('Invalid content');
    }
    
    final sanitized = trimmed.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    return ValidationResult.valid(sanitized);
  }
}

class ValidationResult {
  final bool isValid;
  final String? error;
  final String? sanitizedValue;

  ValidationResult.valid(this.sanitizedValue)
      : isValid = true,
        error = null;

  ValidationResult.invalid(this.error)
      : isValid = false,
        sanitizedValue = null;
}
```

**Task 4.5: Create URL Validator**
```dart
// lib/utils/url_validator.dart
import 'package:url_launcher/url_launcher.dart';

class UrlValidator {
  static const List<String> _allowedSchemes = ['https', 'http'];

  static bool isValidUrl(String urlString) {
    try {
      final uri = Uri.parse(urlString);
      if (!_allowedSchemes.contains(uri.scheme)) {
        return false;
      }
      
      final lower = urlString.toLowerCase();
      if (lower.contains('javascript:') || 
          lower.contains('data:') ||
          lower.contains('vbscript:')) {
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> launchSafeUrl(String urlString) async {
    if (!isValidUrl(urlString)) return;
    
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
```

---

### Day 5: Integration & Testing

**Task 4.6: Update main.dart**
```dart
// lib/main.dart - Final version (50 lines)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('chat_history');

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // Set system UI overlay
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const ErodeSuperApp());
}
```

**Task 4.7: Create app.dart**
```dart
// lib/app.dart
import 'package:flutter/material.dart';
import 'config/theme_config.dart';
import 'screens/splash_screen.dart';

class ErodeSuperApp extends StatelessWidget {
  const ErodeSuperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Erode Super App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
```

---

## Migration Strategy

### Approach: Strangler Fig Pattern

1. **Create new files alongside old**
2. **Gradually move functionality**
3. **Test after each extraction**
4. **Delete old code when complete**

### Rollback Plan

For each phase:
1. Tag repository before changes
2. Keep old code commented during transition
3. Maintain feature flags for gradual rollout
4. Test suite must pass before proceeding

### Testing Strategy

**Before Each Refactoring:**
- Write characterization tests
- Document current behavior
- Establish baseline metrics

**After Each Refactoring:**
- Run all existing tests
- Verify no regressions
- Update documentation
- Measure code quality metrics

---

## Quality Metrics

### Target Metrics

| Metric | Current | Target |
|--------|---------|--------|
| **Lines/File** | 1,450 | < 300 |
| **Cyclomatic Complexity** | 45+ | < 15 |
| **Test Coverage** | 60% | > 85% |
| **Maintainability Index** | 35 | > 70 |
| **Technical Debt Ratio** | High | < 5% |

### Measurement Tools

```bash
# Code metrics
dart pub global activate dart_code_metrics
dart code metrics analyze lib

# Test coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Complexity analysis
dart pub global activate dart_code_metrics
dart code metrics analyze lib --reporter=console
```

---

## Risk Management

### Identified Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Breaking changes | Low | High | Comprehensive tests |
| Performance regression | Low | Medium | Performance benchmarks |
| Merge conflicts | Medium | Medium | Small, frequent commits |
| Scope creep | Medium | Low | Strict phase boundaries |

### Contingency Plans

1. **If tests fail:** Revert to previous tag, investigate, retry
2. **If performance drops:** Profile, optimize, or rollback specific changes
3. **If timeline slips:** Prioritize critical extractions, defer nice-to-haves

---

## Success Criteria

### Phase Completion Criteria

Each phase is complete when:
- [ ] All tasks in phase completed
- [ ] All tests passing
- [ ] No regression in functionality
- [ ] Documentation updated
- [ ] Code review completed
- [ ] Metrics meet targets

### Overall Success Criteria

Refactoring is successful when:
- [ ] All 21 files created and functional
- [ ] Test coverage > 85%
- [ ] All critical security issues fixed
- [ ] Performance equal or better
- [ ] Team trained on new structure
- [ ] Documentation complete

---

## Post-Refactoring Tasks

### Immediate (Week 5)
1. Add golden tests for UI components
2. Implement CI/CD pipeline
3. Set up automated code quality checks
4. Create architecture decision records

### Short-term (Month 2)
1. Add integration tests
2. Implement performance monitoring
3. Set up error tracking (Sentry/Crashlytics)
4. Create developer onboarding guide

### Long-term (Month 3+)
1. Implement feature flags
2. Add A/B testing framework
3. Set up automated performance regression detection
4. Create component library documentation

---

## Appendix A: Import Map

### Before
```dart
// Everything in main.dart
import 'package:flutter/material.dart';
// ... all imports in one file
```

### After
```dart
// Each file imports only what it needs
// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../widgets/chat_bubble.dart';
import '../services/speech_service.dart';
```

---

## Appendix B: Dependency Graph

```
main.dart
  └── app.dart
        └── screens/splash_screen.dart
              └── screens/dashboard_screen.dart
                    ├── widgets/app_bar_widget.dart
                    ├── widgets/live_chat_card.dart
                    ├── widgets/market_ticker.dart
                    ├── widgets/commerce_card_widget.dart
                    └── screens/chat_screen.dart
                          ├── widgets/chat_bubble.dart
                          ├── widgets/welcome_view.dart
                          ├── widgets/typing_indicator.dart
                          ├── widgets/input_bar.dart
                          ├── services/speech_service.dart
                          └── services/storage_service.dart
```

---

## Appendix C: Checklist

### Pre-Refactoring
- [ ] Backup current code
- [ ] Create git branch
- [ ] Run all tests
- [ ] Document current behavior
- [ ] Set up metrics tracking

### During Refactoring
- [ ] Extract one component at a time
- [ ] Test after each extraction
- [ ] Update imports
- [ ] Remove old code
- [ ] Commit frequently

### Post-Refactoring
- [ ] Run full test suite
- [ ] Verify all functionality
- [ ] Update documentation
- [ ] Measure metrics
- [ ] Code review
- [ ] Merge to main

---

*Generated by Code Review Agent (Swarm Mode)*  
*Powered by NJ TECH · Erode*  
*Version: 1.0.0*
