// ================================================================
// API Models - Allin1 Super App Backend
// ================================================================
// Data transfer objects (DTOs) for API requests and responses.
// Includes serialization/deserialization logic.
//
// Author: NJ TECH Backend Team
// Version: 1.0.0
// ================================================================

import 'dart:convert';

// ================================================================
// Request Models
// ================================================================

/// Base request model for all API calls.
///
/// Provides common fields like request ID and timestamp for tracing.
abstract class ApiRequest {
  /// Unique request identifier for tracing and debugging
  final String requestId;

  /// Timestamp when the request was created
  final DateTime timestamp;

  ApiRequest({String? requestId, DateTime? timestamp})
      : requestId = requestId ?? _generateRequestId(),
        timestamp = timestamp ?? DateTime.now();

  /// Convert to JSON map for API transmission
  Map<String, dynamic> toJson();

  /// Serialize to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Generate a unique request ID
  static String _generateRequestId() {
    // Simple UUID-like format: timestamp-random
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toRadixString(16);
    final random = DateTime.now().microsecondsSinceEpoch % 100000;
    return 'req_${timestamp}_${random.toString().padLeft(5, '0')}';
  }
}

/// Chat message request model.
///
/// Sends a user message with conversation history and optional system context.
/// This is the primary request type for the commerce voice chat feature.
class ChatRequest extends ApiRequest {
  /// The user's message text
  final String message;

  /// Conversation history for context (last N messages)
  final List<MessageHistory> history;

  /// System prompt to guide the AI's behavior
  /// E.g., "You are Erode's Sales Assistant..."
  final String? systemPrompt;

  /// Optional user identifier for personalization
  final String? userId;

  /// Optional session identifier for conversation tracking
  final String? sessionId;

  /// Language preference (e.g., 'ta' for Tamil, 'en' for English)
  final String? language;

  ChatRequest({
    required this.message,
    this.history = const [],
    this.systemPrompt,
    this.userId,
    this.sessionId,
    this.language,
    super.requestId,
    super.timestamp,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'history': history.map((h) => h.toJson()).toList(),
      if (systemPrompt != null) 'system': systemPrompt,
      if (userId != null) 'userId': userId,
      if (sessionId != null) 'sessionId': sessionId,
      if (language != null) 'language': language,
      'requestId': requestId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  ChatRequest copyWith({
    String? message,
    List<MessageHistory>? history,
    String? systemPrompt,
    String? userId,
    String? sessionId,
    String? language,
  }) {
    return ChatRequest(
      message: message ?? this.message,
      history: history ?? this.history,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      language: language ?? this.language,
      requestId: requestId,
      timestamp: timestamp,
    );
  }
}

/// A single message in the conversation history.
class MessageHistory {
  /// Role of the message sender: 'user' or 'assistant'
  final String role;

  /// The message content
  final String content;

  /// Optional timestamp of the original message
  final DateTime? timestamp;

  MessageHistory({
    required this.role,
    required this.content,
    this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };
  }

  factory MessageHistory.fromJson(Map<String, dynamic> json) {
    return MessageHistory(
      role: json['role'] as String,
      content: json['content'] as String,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }
}

// ================================================================
// Response Models
// ================================================================

/// Base response model for all API responses.
///
/// Provides common fields for status tracking and error handling.
abstract class ApiResponse {
  /// HTTP status code from the server
  final int statusCode;

  /// Whether the request was successful
  final bool success;

  /// Error message if the request failed
  final String? errorMessage;

  /// Request ID for tracing (echoed from request)
  final String? requestId;

  /// Response timestamp
  final DateTime timestamp;

  /// Raw response body (for debugging)
  final String? rawBody;

  ApiResponse({
    required this.statusCode,
    required this.success,
    this.errorMessage,
    this.requestId,
    this.rawBody,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Chat message response model.
///
/// Contains the AI's response to a chat request.
class ChatResponse extends ApiResponse {
  /// The AI's response text
  final String response;

  /// Suggested actions or follow-ups (if provided by backend)
  final List<String> suggestions;

  /// Detected intent from user message (if provided by backend)
  final String? detectedIntent;

  /// Confidence score for the response (0.0 - 1.0)
  final double? confidence;

  /// Metadata about the response (e.g., processing time, model used)
  final Map<String, dynamic>? metadata;

  ChatResponse({
    required this.response,
    required super.statusCode,
    required super.success,
    this.suggestions = const [],
    this.detectedIntent,
    this.confidence,
    this.metadata,
    super.errorMessage,
    super.requestId,
    super.rawBody,
    super.timestamp,
  });

  /// Create from JSON response
  factory ChatResponse.fromJson(
    Map<String, dynamic> json, {
    required int statusCode,
    String? rawBody,
  }) {
    // Handle different response formats
    final responseText = json['response'] as String? ??
        json['message'] as String? ??
        json['reply'] as String? ??
        'Sorry, no response received.';

    final suggestionsJson = json['suggestions'];
    final suggestions = suggestionsJson is List
        ? suggestionsJson.map((s) => s.toString()).toList()
        : <String>[];

    final metadata = json['metadata'];
    final metadataMap = metadata is Map<String, dynamic> ? metadata : null;

    return ChatResponse(
      response: responseText,
      suggestions: suggestions,
      detectedIntent: json['intent'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      metadata: metadataMap,
      statusCode: statusCode,
      success: statusCode >= 200 && statusCode < 300,
      errorMessage: json['error'] as String?,
      requestId: json['requestId'] as String?,
      rawBody: rawBody,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'response': response,
      'suggestions': suggestions,
      if (detectedIntent != null) 'intent': detectedIntent,
      if (confidence != null) 'confidence': confidence,
      if (metadata != null) 'metadata': metadata,
      'statusCode': statusCode,
      'success': success,
      if (errorMessage != null) 'errorMessage': errorMessage,
      if (requestId != null) 'requestId': requestId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  ChatResponse copyWith({
    String? response,
    List<String>? suggestions,
    String? detectedIntent,
    double? confidence,
    Map<String, dynamic>? metadata,
    int? statusCode,
    bool? success,
    String? errorMessage,
    String? requestId,
  }) {
    return ChatResponse(
      response: response ?? this.response,
      suggestions: suggestions ?? this.suggestions,
      detectedIntent: detectedIntent ?? this.detectedIntent,
      confidence: confidence ?? this.confidence,
      metadata: metadata ?? this.metadata,
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      errorMessage: errorMessage ?? this.errorMessage,
      requestId: requestId ?? this.requestId,
    );
  }
}

/// Error response model for API failures.
class ApiErrorResponse extends ApiResponse {
  /// Error code for programmatic handling
  final String errorCode;

  /// Detailed error information
  final Map<String, dynamic>? errorDetails;

  /// Suggested user action to resolve the error
  final String? userMessage;

  /// Whether the error is retryable
  final bool isRetryable;

  ApiErrorResponse({
    required this.errorCode,
    required super.statusCode,
    this.errorDetails,
    this.userMessage,
    this.isRetryable = false,
    super.errorMessage,
    super.requestId,
    super.rawBody,
    super.timestamp,
  }) : super(success: false);

  factory ApiErrorResponse.fromJson(
    Map<String, dynamic> json, {
    required int statusCode,
    String? rawBody,
  }) {
    final errorCode = json['errorCode'] as String? ?? 'UNKNOWN_ERROR';
    final errorDetails = json['details'];
    final detailsMap =
        errorDetails is Map<String, dynamic> ? errorDetails : null;

    return ApiErrorResponse(
      errorCode: errorCode,
      errorDetails: detailsMap,
      userMessage: json['userMessage'] as String?,
      isRetryable:
          json['isRetryable'] as bool? ?? _isStatusCodeRetryable(statusCode),
      statusCode: statusCode,
      errorMessage: json['message'] as String? ?? json['error'] as String?,
      requestId: json['requestId'] as String?,
      rawBody: rawBody,
    );
  }

  static bool _isStatusCodeRetryable(int statusCode) {
    return statusCode >= 500 || statusCode == 429 || statusCode == 408;
  }

  Map<String, dynamic> toJson() {
    return {
      'errorCode': errorCode,
      'errorDetails': errorDetails,
      'userMessage': userMessage,
      'isRetryable': isRetryable,
      'statusCode': statusCode,
      'errorMessage': errorMessage,
      if (requestId != null) 'requestId': requestId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

// ================================================================
// Cache Models
// ================================================================

/// Cached API response with metadata.
class CachedResponse {
  /// The cached response data
  final Map<String, dynamic> data;

  /// When the response was cached
  final DateTime cachedAt;

  /// Time-to-live in seconds
  final int ttlSeconds;

  /// When the cache expires
  DateTime get expiresAt => cachedAt.add(Duration(seconds: ttlSeconds));

  /// Whether the cache is still valid
  bool get isValid => DateTime.now().isBefore(expiresAt);

  /// Cache key used to store this response
  final String cacheKey;

  CachedResponse({
    required this.data,
    required this.cachedAt,
    required this.ttlSeconds,
    required this.cacheKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'cachedAt': cachedAt.toIso8601String(),
      'ttlSeconds': ttlSeconds,
      'cacheKey': cacheKey,
    };
  }

  factory CachedResponse.fromJson(Map<String, dynamic> json) {
    return CachedResponse(
      data: json['data'] as Map<String, dynamic>,
      cachedAt: DateTime.parse(json['cachedAt'] as String),
      ttlSeconds: json['ttlSeconds'] as int,
      cacheKey: json['cacheKey'] as String,
    );
  }

  /// Create from an API response
  factory CachedResponse.fromApiResponse(
    Map<String, dynamic> responseData,
    String cacheKey,
    int ttlSeconds,
  ) {
    return CachedResponse(
      data: responseData,
      cachedAt: DateTime.now(),
      ttlSeconds: ttlSeconds,
      cacheKey: cacheKey,
    );
  }
}

// ================================================================
// Performance Metrics
// ================================================================

/// Request performance metrics for monitoring.
class RequestMetrics {
  /// Total request duration in milliseconds
  final int durationMs;

  /// Connection time in milliseconds
  final int connectionTimeMs;

  /// Request send time in milliseconds
  final int sendTimeMs;

  /// Response receive time in milliseconds
  final int receiveTimeMs;

  /// Whether the request was served from cache
  final bool servedFromCache;

  /// Number of retry attempts
  final int retryCount;

  /// Whether failover was used
  final bool usedFailover;

  /// Server processing time (if provided in response headers)
  final int? serverProcessingTimeMs;

  RequestMetrics({
    required this.durationMs,
    this.connectionTimeMs = 0,
    this.sendTimeMs = 0,
    this.receiveTimeMs = 0,
    this.servedFromCache = false,
    this.retryCount = 0,
    this.usedFailover = false,
    this.serverProcessingTimeMs,
  });

  Map<String, dynamic> toJson() {
    return {
      'durationMs': durationMs,
      'connectionTimeMs': connectionTimeMs,
      'sendTimeMs': sendTimeMs,
      'receiveTimeMs': receiveTimeMs,
      'servedFromCache': servedFromCache,
      'retryCount': retryCount,
      'usedFailover': usedFailover,
      if (serverProcessingTimeMs != null)
        'serverProcessingTimeMs': serverProcessingTimeMs,
    };
  }

  /// Check if the request was slow
  bool get isSlow => durationMs > 3000;

  /// Check if the request was very slow (potential issue)
  bool get isVerySlow => durationMs > 10000;
}
