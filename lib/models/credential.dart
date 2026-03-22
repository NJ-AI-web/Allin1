// ================================================================
// Credential Model - Allin1 Super App
// ================================================================
// Data model for user credentials with encrypted fields.
// Supports multiple credential types: password, apiKey, secureNote,
// bankAccount, wifi, card, and other.
//
// Author: NJ TECH
// Version: 1.0.0
// ================================================================

import 'dart:convert';

/// Enum representing the type of credential stored.
enum CredentialType {
  password,
  apiKey,
  secureNote,
  bankAccount,
  wifi,
  card,
  other;

  /// Convert string to CredentialType
  static CredentialType fromString(String value) {
    return CredentialType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => CredentialType.other,
    );
  }

  /// Convert CredentialType to string for Firestore storage
  String toJson() => name;

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case CredentialType.password:
        return 'Password';
      case CredentialType.apiKey:
        return 'API Key';
      case CredentialType.secureNote:
        return 'Secure Note';
      case CredentialType.bankAccount:
        return 'Bank Account';
      case CredentialType.wifi:
        return 'WiFi';
      case CredentialType.card:
        return 'Card';
      case CredentialType.other:
        return 'Other';
    }
  }

  /// Get icon name for UI display
  String get iconName {
    switch (this) {
      case CredentialType.password:
        return 'lock';
      case CredentialType.apiKey:
        return 'key';
      case CredentialType.secureNote:
        return 'note';
      case CredentialType.bankAccount:
        return 'account_balance';
      case CredentialType.wifi:
        return 'wifi';
      case CredentialType.card:
        return 'credit_card';
      case CredentialType.other:
        return 'folder';
    }
  }
}

/// Credential model class containing all credential data.
/// Sensitive fields are stored encrypted.
class Credential {
  /// Unique identifier for the credential
  final String id;

  /// User ID of the credential owner
  final String userId;

  /// Display name/title of the credential (not encrypted)
  final String title;

  /// Type of credential (password, apiKey, etc.)
  final CredentialType type;

  /// Encrypted username/email field
  final String encryptedUsername;

  /// Encrypted password/secret field
  final String encryptedPassword;

  /// Encrypted URL/website field (optional)
  final String? encryptedUrl;

  /// Encrypted notes field (optional)
  final String? encryptedNotes;

  /// Encrypted extra field for additional data (card number, etc.)
  final String? encryptedExtra;

  /// Category ID for organization (optional)
  final String? categoryId;

  /// Whether this credential is marked as favorite
  final bool isFavorite;

  /// Whether this credential is pinned to top
  final bool isPinned;

  /// List of user IDs who can access this credential
  final List<String> sharedWith;

  /// Whether this credential is managed by admin
  final bool isAdminManaged;

  /// Whether this credential has been synced to cloud
  final bool isSynced;

  /// Whether this credential is soft-deleted
  final bool isDeleted;

  /// Timestamp when credential was created
  final DateTime createdAt;

  /// Timestamp when credential was last updated
  final DateTime updatedAt;

  /// Timestamp when credential was last accessed (optional)
  final DateTime? lastAccessedAt;

  /// Checksum for data integrity verification
  final String? checksum;

  const Credential({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    required this.encryptedUsername,
    required this.encryptedPassword,
    required this.createdAt,
    required this.updatedAt,
    this.encryptedUrl,
    this.encryptedNotes,
    this.encryptedExtra,
    this.categoryId,
    this.isFavorite = false,
    this.isPinned = false,
    this.sharedWith = const [],
    this.isAdminManaged = false,
    this.isSynced = false,
    this.isDeleted = false,
    this.lastAccessedAt,
    this.checksum,
  });

  /// Create Credential from JSON map
  factory Credential.fromJson(Map<String, dynamic> json) {
    return Credential(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      type: CredentialType.fromString(json['type'] as String),
      encryptedUsername: json['encryptedUsername'] as String,
      encryptedPassword: json['encryptedPassword'] as String,
      encryptedUrl: json['encryptedUrl'] as String?,
      encryptedNotes: json['encryptedNotes'] as String?,
      encryptedExtra: json['encryptedExtra'] as String?,
      categoryId: json['categoryId'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
      sharedWith: (json['sharedWith'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isAdminManaged: json['isAdminManaged'] as bool? ?? false,
      isSynced: json['isSynced'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.parse(
            json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
          ),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ??
          DateTime.parse(
            json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
          ),
      lastAccessedAt: json['lastAccessedAt'] != null
          ? (json['lastAccessedAt'] is Timestamp
              ? (json['lastAccessedAt'] as Timestamp).toDate()
              : DateTime.parse(json['lastAccessedAt'] as String))
          : null,
      checksum: json['checksum'] as String?,
    );
  }

  /// Convert Credential to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'type': type.toJson(),
      'encryptedUsername': encryptedUsername,
      'encryptedPassword': encryptedPassword,
      if (encryptedUrl != null) 'encryptedUrl': encryptedUrl,
      if (encryptedNotes != null) 'encryptedNotes': encryptedNotes,
      if (encryptedExtra != null) 'encryptedExtra': encryptedExtra,
      if (categoryId != null) 'categoryId': categoryId,
      'isFavorite': isFavorite,
      'isPinned': isPinned,
      'sharedWith': sharedWith,
      'isAdminManaged': isAdminManaged,
      'isSynced': isSynced,
      'isDeleted': isDeleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (lastAccessedAt != null) 'lastAccessedAt': lastAccessedAt,
      if (checksum != null) 'checksum': checksum,
    };
  }

  /// Serialize to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Create a copy with modified fields
  Credential copyWith({
    String? id,
    String? userId,
    String? title,
    CredentialType? type,
    String? encryptedUsername,
    String? encryptedPassword,
    String? encryptedUrl,
    String? encryptedNotes,
    String? encryptedExtra,
    String? categoryId,
    bool? isFavorite,
    bool? isPinned,
    List<String>? sharedWith,
    bool? isAdminManaged,
    bool? isSynced,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastAccessedAt,
    String? checksum,
  }) {
    return Credential(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      type: type ?? this.type,
      encryptedUsername: encryptedUsername ?? this.encryptedUsername,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      encryptedUrl: encryptedUrl ?? this.encryptedUrl,
      encryptedNotes: encryptedNotes ?? this.encryptedNotes,
      encryptedExtra: encryptedExtra ?? this.encryptedExtra,
      categoryId: categoryId ?? this.categoryId,
      isFavorite: isFavorite ?? this.isFavorite,
      isPinned: isPinned ?? this.isPinned,
      sharedWith: sharedWith ?? this.sharedWith,
      isAdminManaged: isAdminManaged ?? this.isAdminManaged,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      checksum: checksum ?? this.checksum,
    );
  }

  /// Create empty credential for initialization
  factory Credential.empty({
    required String userId,
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return Credential(
      id: id ?? '',
      userId: userId,
      title: '',
      type: CredentialType.password,
      encryptedUsername: '',
      encryptedPassword: '',
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  /// Check if credential is valid (has required fields)
  bool get isValid =>
      id.isNotEmpty &&
      userId.isNotEmpty &&
      title.isNotEmpty &&
      encryptedUsername.isNotEmpty &&
      encryptedPassword.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Credential && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Credential(id: $id, title: $title, type: ${type.name})';
  }
}

/// Firestore Timestamp class for compatibility
/// This is a simple implementation - in production, use cloud_firestore Timestamp
class Timestamp {
  final int seconds;
  final int nanoseconds;

  const Timestamp(this.seconds, this.nanoseconds);

  factory Timestamp.now() {
    final now = DateTime.now();
    return Timestamp(
      now.millisecondsSinceEpoch ~/ 1000,
      now.microsecondsSinceEpoch % 1000000,
    );
  }

  factory Timestamp.fromDate(DateTime date) {
    return Timestamp(
      date.millisecondsSinceEpoch ~/ 1000,
      date.microsecondsSinceEpoch % 1000000,
    );
  }

  DateTime toDate() {
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }

  Map<String, dynamic> toJson() {
    return {
      'seconds': seconds,
      'nanoseconds': nanoseconds,
    };
  }
}
