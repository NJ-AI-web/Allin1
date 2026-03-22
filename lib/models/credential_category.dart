// ================================================================
// Credential Category Model - Allin1 Super App
// ================================================================
// Data model for credential categories.
// Allows users to organize their credentials into categories.
//
// Author: NJ TECH
// Version: 1.0.0
// ================================================================

import 'dart:convert';

/// Credential Category model class for organizing credentials.
class CredentialCategory {
  /// Unique identifier for the category
  final String id;

  /// User ID of the category owner
  final String userId;

  /// Display name of the category
  final String name;

  /// Icon name for UI display (Material Icons)
  final String? icon;

  /// Hex color code for the category (e.g., '#FF5733')
  final String? color;

  /// Sort order for display priority
  final int sortOrder;

  /// Timestamp when category was created
  final DateTime createdAt;

  const CredentialCategory({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
    this.icon,
    this.color,
    this.sortOrder = 0,
  });

  /// Create CredentialCategory from JSON map
  factory CredentialCategory.fromJson(Map<String, dynamic> json) {
    return CredentialCategory(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.parse(
            json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
          ),
    );
  }

  /// Convert CredentialCategory to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      'sortOrder': sortOrder,
      'createdAt': createdAt,
    };
  }

  /// Serialize to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Create a copy with modified fields
  CredentialCategory copyWith({
    String? id,
    String? userId,
    String? name,
    String? icon,
    String? color,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return CredentialCategory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Create empty category for initialization
  factory CredentialCategory.empty({
    required String userId,
    String? id,
    DateTime? createdAt,
  }) {
    return CredentialCategory(
      id: id ?? '',
      userId: userId,
      name: '',
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// Default categories for new users
  static List<CredentialCategory> getDefaultCategories(String userId) {
    final now = DateTime.now();
    return [
      CredentialCategory(
        id: '${userId}_work',
        userId: userId,
        name: 'Work',
        icon: 'work',
        color: '#2196F3',
        createdAt: now,
      ),
      CredentialCategory(
        id: '${userId}_personal',
        userId: userId,
        name: 'Personal',
        icon: 'person',
        color: '#4CAF50',
        sortOrder: 1,
        createdAt: now,
      ),
      CredentialCategory(
        id: '${userId}_finance',
        userId: userId,
        name: 'Finance',
        icon: 'account_balance',
        color: '#FF9800',
        sortOrder: 2,
        createdAt: now,
      ),
      CredentialCategory(
        id: '${userId}_social',
        userId: userId,
        name: 'Social',
        icon: 'people',
        color: '#9C27B0',
        sortOrder: 3,
        createdAt: now,
      ),
    ];
  }

  /// Check if category is valid
  bool get isValid => id.isNotEmpty && userId.isNotEmpty && name.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is CredentialCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CredentialCategory(id: $id, name: $name, icon: $icon, color: $color)';
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
