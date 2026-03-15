# Migration Guide - Erode Super App Backend Services
**Version:** 1.0.0  
**Date:** March 13, 2026  
**Author:** NJ TECH Backend Team

---

## Overview

This guide walks you through migrating from the basic `http` package to the production-ready `ApiService` with Dio, including Firebase Analytics integration.

---

## Table of Contents

1. [Installation](#installation)
2. [Configuration](#configuration)
3. [Migration Steps](#migration-steps)
4. [API Reference](#api-reference)
5. [Examples](#examples)
6. [Testing](#testing)
7. [Troubleshooting](#troubleshooting)

---

## Installation

### 1. Add Dependencies

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  # HTTP & API (replace http with dio)
  dio: ^5.4.0
  
  # Firebase (if not already added)
  firebase_core: ^2.31.0
  firebase_analytics: ^10.10.0
  firebase_crashlytics: ^3.5.0
  firebase_performance: ^0.9.4+0
  
  # Local Storage (if not already added)
  hive_flutter: ^1.1.0
  hive: ^2.2.3
  
  # Utilities
  uuid: ^4.4.0

dev_dependencies:
  # For testing
  mocktail: ^1.0.0
```

### 2. Install Packages

```bash
flutter pub get
```

### 3. Initialize Firebase (if not already done)

Follow the [Firebase setup guide](https://firebase.google.com/docs/flutter/setup) for your platform.

---

## Configuration

### 1. Update main.dart

```dart
import 'package:erode_superapp/services/api_service.dart';
import 'package:erode_superapp/services/analytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('chat_history');
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase skipped: $e');
  }
  
  // Initialize API Service
  await ApiService.instance.initialize();
  
  // Initialize Analytics
  await AnalyticsService.instance.initialize(
    enableAnalytics: true,
    enableCrashlytics: !kDebugMode,
    enablePerformance: !kDebugMode,
  );
  
  runApp(const NammaGuruApp());
}
```

---

## Migration Steps

### Step 1: Replace HTTP Calls

#### Before (Old Code)
```dart
import 'package:http/http.dart' as http;

const String kBackendUrl = 'https://nijamdeen-kutty-guru-api.hf.space/chat';

Future<void> _send(String text) async {
  final history = [...]; // message history
  
  try {
    final res = await http.post(
      Uri.parse(kBackendUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': t,
        'history': history,
        'system': kSalesSystemPrompt,
      }),
    ).timeout(const Duration(seconds: 30));
    
    final reply = res.statusCode == 200
        ? (jsonDecode(utf8.decode(res.bodyBytes)) as Map)['response']
        : 'Error';
        
    // Handle response...
  } catch (e) {
    // Handle error...
  }
}
```

#### After (New Code)
```dart
import 'package:erode_superapp/services/api_service.dart';
import 'package:erode_superapp/models/api_models.dart';

Future<void> _send(String text) async {
  final history = [...]; // message history
  
  try {
    final response = await ApiService.instance.sendChat(
      message: text,
      history: history,
      systemPrompt: kSalesSystemPrompt,
    );
    
    final reply = response.text;
    
    // Handle response...
  } on ApiServiceException catch (e) {
    // Handle specific errors
    debugPrint('API Error: ${e.message}');
  } catch (e) {
    debugPrint('Unexpected error: $e');
  }
}
```

### Step 2: Add Analytics Tracking

```dart
import 'package:erode_superapp/services/analytics_service.dart';

// Track message sent
await AnalyticsService.instance.trackMessageSent(
  messageLength: text.length,
  responseTime: response.metrics.requestDuration,
);

// Track commerce interaction
await AnalyticsService.instance.trackViewCommerceCategory(
  categoryId: 'food',
  categoryName: 'Food Delivery',
);

// Track order (when implemented)
await AnalyticsService.instance.trackPurchase(
  transactionId: order.id,
  value: order.total,
  currency: 'INR',
  items: order.items.map((i) => AnalyticsEcommerceItem(
    itemId: i.productId,
    itemName: i.name,
    price: i.price,
    quantity: i.quantity,
  )).toList(),
);
```

### Step 3: Handle Loading States

```dart
// Old way
setState(() => _loading = true);

// New way with API Service
ApiService.instance.onRequestStart = (requestId) {
  setState(() => _loading = true);
};

ApiService.instance.onRequestComplete = (requestId, success) {
  setState(() => _loading = false);
};
```

---

## API Reference

### ApiService

#### Methods

```dart
// Send chat message
Future<ChatResponse> sendChat({
  required String message,
  required List<Map<String, dynamic>> history,
  String? systemPrompt,
  String? userId,
  String? sessionId,
})

// Initialize service
Future<void> initialize()

// Clear cache
Future<void> clearCache()

// Get cache size
Future<int> getCacheSize()
```

#### Callbacks

```dart
// Request lifecycle
apiService.onRequestStart = (requestId) { ... };
apiService.onRequestComplete = (requestId, success) { ... };
apiService.onRequestError = (requestId, error) { ... };

// Circuit breaker
apiService.onCircuitBreakerChange = (state) { ... };

// Rate limiting
apiService.onRateLimitExceeded = (limit) { ... };
```

### AnalyticsService

#### Event Tracking

```dart
// General events
await analytics.trackEvent(name: 'custom_event', parameters: {...});

// Chat events
await analytics.trackMessageSent(messageLength: 100, responseTime: 1500);
await analytics.trackVoiceMessageUsed();
await analytics.trackQuickChipUsed(chipText: 'Order food');

// Commerce events
await analytics.trackViewCommerceCategory(categoryId: 'food');
await analytics.trackAddToCart(productId: 'item_123');
await analytics.trackPurchase(...);

// Screen views
await analytics.trackScreenView(screenName: 'DashboardScreen');
```

---

## Examples

### Example 1: Simple Chat Request

```dart
try {
  final response = await ApiService.instance.sendChat(
    message: 'Hello',
    history: [],
    systemPrompt: 'You are a helpful assistant',
  );
  
  print('Response: ${response.text}');
  print('Confidence: ${response.confidenceScore}');
  print('Intent: ${response.detectedIntent}');
} on ApiServiceException catch (e) {
  print('Error: ${e.message}');
}
```

### Example 2: Chat with Analytics

```dart
final stopwatch = Stopwatch()..start();

try {
  final response = await ApiService.instance.sendChat(
    message: text,
    history: history,
  );
  
  stopwatch.stop();
  
  await AnalyticsService.instance.trackMessageSent(
    messageLength: text.length,
    responseTime: stopwatch.elapsedMilliseconds,
    hasResponse: true,
  );
  
  // Display response...
} on ApiServiceException catch (e) {
  await AnalyticsService.instance.trackError(
    errorType: 'api_error',
    errorMessage: e.message,
    context: 'chat_send',
  );
  
  // Show error...
}
```

### Example 3: Caching

```dart
// Response is automatically cached if TTL > 0
final response = await ApiService.instance.sendChat(
  message: 'What are your services?',
  history: [],
);

// Next identical request within TTL will use cache
final cachedResponse = await ApiService.instance.sendChat(
  message: 'What are your services?',
  history: [],
);

// Check if response was from cache
print(cachedResponse.isFromCache); // true
```

---

## Testing

### Unit Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:erode_superapp/services/api_service.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;
  
  setUp(() {
    mockApiService = MockApiService();
  });
  
  test('should send chat message', () async {
    when(() => mockApiService.sendChat(
      message: any(named: 'message'),
      history: any(named: 'history'),
    )).thenAnswer((_) async => ChatResponse(
      text: 'Hello!',
      confidenceScore: 0.95,
    ));
    
    final response = await mockApiService.sendChat(
      message: 'Hello',
      history: [],
    );
    
    expect(response.text, equals('Hello!'));
  });
}
```

### Integration Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('Full chat flow', (tester) async {
    await tester.pumpWidget(const NammaGuruApp());
    await tester.pumpAndSettle();
    
    // Tap on chat card
    await tester.tap(find.text('Live Chat'));
    await tester.pumpAndSettle();
    
    // Send message
    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();
    
    // Wait for response
    await tester.pump(const Duration(seconds: 2));
    
    // Verify response displayed
    expect(find.textContaining('Hello'), findsOneWidget);
  });
}
```

---

## Troubleshooting

### Issue: "DioException: connection refused"

**Solution:** Check if the API URL is correct and the server is running.

```dart
// Enable debug logging
ApiService.instance.setLogLevel(LogLevel.debug);

// Check circuit breaker state
print(ApiService.instance.circuitState);
```

### Issue: "FirebaseException: No app"

**Solution:** Initialize Firebase before using AnalyticsService.

```dart
await Firebase.initializeApp();
await AnalyticsService.instance.initialize(enableAnalytics: true);
```

### Issue: "HiveError: Box not found"

**Solution:** Initialize Hive before using ApiService.

```dart
await Hive.initFlutter();
await Hive.openBox('api_cache');
```

### Issue: Tests failing with "Binding not initialized"

**Solution:** Initialize binding in test setup.

```dart
setUp(() {
  TestWidgetsFlutterBinding.ensureInitialized();
});
```

---

## Performance Tips

1. **Reuse History**: Don't recreate message history on every request
2. **Debounce Voice Input**: Use request debouncing for voice transcription
3. **Cache Static Content**: Enable caching for FAQ, market rates, etc.
4. **Monitor Metrics**: Use callbacks to track slow requests
5. **Handle Errors Gracefully**: Show user-friendly error messages

---

## Security Best Practices

1. **Validate Input**: Sanitize user input before sending to API
2. **Rate Limiting**: Don't allow rapid-fire requests
3. **Secure Storage**: Use `flutter_secure_storage` for sensitive data
4. **HTTPS Only**: Always use HTTPS for API calls
5. **Error Messages**: Don't expose internal errors to users

---

## Next Steps

1. ✅ Run `flutter pub get`
2. ✅ Initialize services in `main.dart`
3. ✅ Migrate chat calls to use `ApiService`
4. ✅ Add analytics tracking
5. ✅ Test with network throttling
6. ✅ Test failover logic
7. ✅ Monitor performance metrics

---

## Support

For issues or questions:
- Check the [API Service documentation](lib/services/api_service.dart)
- Review [API Configuration](lib/config/api_config.dart)
- Contact NJ TECH team

---

*Generated for Erode Super App v1.0.0*  
*Powered by NJ TECH · Erode*
