// ================================================================
// Password Utilities - Allin1 Super App
// ================================================================
// Secure password hashing and verification utilities.
// Provides PBKDF2-based password hashing for secure storage.
//
// Author: NJ TECH
// Version: 1.0.0
// ================================================================

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Password strength levels
enum PasswordStrength {
  weak,
  fair,
  good,
  strong,
  veryStrong,
}

/// Utility class for password hashing and verification.
/// Uses PBKDF2 with HMAC-SHA256 for secure password hashing.
class PasswordUtils {
  // ================================================================
  // Constants
  // ================================================================

  /// Default number of PBKDF2 iterations
  static const int defaultIterations = 100000;

  /// Salt length in bytes
  static const int saltLength = 32;

  /// Hash length in bytes (256 bits)
  static const int hashLength = 32;

  // ================================================================
  // Password Hashing Methods
  // ================================================================

  /// Hash a password using PBKDF2 with HMAC-SHA256.
  /// Returns a string in format: base64(salt):base64(hash):iterations
  static String hashPassword(
    String password, {
    int iterations = defaultIterations,
    String? existingSalt,
  }) {
    // Generate salt if not provided
    final salt = existingSalt != null && existingSalt.isNotEmpty
        ? base64Decode(existingSalt)
        : _generateSalt();

    // Derive key using PBKDF2
    final hash = _pbkdf2(password, salt, iterations);

    // Return in format: salt:hash:iterations
    return '${base64Encode(salt)}:${base64Encode(hash)}:$iterations';
  }

  /// Verify a password against a stored hash.
  /// Returns true if the password matches the hash.
  static bool verifyPassword(String password, String storedHash) {
    try {
      final parts = storedHash.split(':');
      if (parts.length != 3) {
        return false;
      }

      final salt = base64Decode(parts[0]);
      final storedHashBytes = base64Decode(parts[1]);
      final iterations = int.parse(parts[2]);

      // Derive hash with same parameters
      final computedHash = _pbkdf2(password, salt, iterations);

      // Compare hashes using constant-time comparison
      return _constantTimeEquals(computedHash, storedHashBytes);
    } catch (e) {
      return false;
    }
  }

  /// Generate a secure random salt.
  static Uint8List _generateSalt() {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(saltLength, (_) => random.nextInt(256)),
    );
  }

  /// PBKDF2 key derivation function.
  static Uint8List _pbkdf2(String password, Uint8List salt, int iterations) {
    final passwordBytes = utf8.encode(password);
    Uint8List derivedKey = Uint8List.fromList(passwordBytes);

    for (int i = 0; i < iterations; i++) {
      final hmac = Hmac(sha256, derivedKey);
      final digest = hmac.convert(salt);
      derivedKey = Uint8List.fromList(digest.bytes);
    }

    return derivedKey;
  }

  /// Constant-time comparison to prevent timing attacks.
  static bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) {
      return false;
    }

    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }

    return result == 0;
  }

  // ================================================================
  // Password Strength Validation
  // ================================================================

  /// Calculate password strength.
  static PasswordStrength calculateStrength(String password) {
    if (password.isEmpty) {
      return PasswordStrength.weak;
    }

    int score = 0;

    // Length scoring
    if (password.length >= 8) {
      score++;
    }
    if (password.length >= 12) {
      score++;
    }
    if (password.length >= 16) {
      score++;
    }

    // Character type scoring
    if (RegExp('[a-z]').hasMatch(password)) {
      score++;
    }
    if (RegExp('[A-Z]').hasMatch(password)) {
      score++;
    }
    if (RegExp('[0-9]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      score++;
    }

    // Determine strength
    if (score <= 2) {
      return PasswordStrength.weak;
    }
    if (score <= 4) {
      return PasswordStrength.fair;
    }
    if (score <= 5) {
      return PasswordStrength.good;
    }
    if (score <= 6) {
      return PasswordStrength.strong;
    }
    return PasswordStrength.veryStrong;
  }

  /// Get strength label for display.
  static String getStrengthLabel(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.fair:
        return 'Fair';
      case PasswordStrength.good:
        return 'Good';
      case PasswordStrength.strong:
        return 'Strong';
      case PasswordStrength.veryStrong:
        return 'Very Strong';
    }
  }

  /// Get strength color hex for display.
  static int getStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 0xFFE53935; // Red
      case PasswordStrength.fair:
        return 0xFFFF9800; // Orange
      case PasswordStrength.good:
        return 0xFFFFC107; // Yellow
      case PasswordStrength.strong:
        return 0xFF8BC34A; // Light Green
      case PasswordStrength.veryStrong:
        return 0xFF4CAF50; // Green
    }
  }

  /// Validate password meets minimum requirements.
  static bool isValidPassword(String password, {int minLength = 8}) {
    if (password.length < minLength) {
      return false;
    }
    if (!RegExp('[a-zA-Z]').hasMatch(password)) {
      return false;
    }
    if (!RegExp('[0-9]').hasMatch(password)) {
      return false;
    }
    return true;
  }

  // ================================================================
  // Password Generation
  // ================================================================

  /// Generate a secure random password.
  static String generatePassword({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSpecial = true,
  }) {
    String chars = '';

    if (includeLowercase) {
      chars += 'abcdefghijklmnopqrstuvwxyz';
    }
    if (includeUppercase) {
      chars += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    }
    if (includeNumbers) {
      chars += '0123456789';
    }
    if (includeSpecial) {
      chars += r'!@#$%^&*()_+-=[]{}|;:,.<>?';
    }

    if (chars.isEmpty) {
      chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    }

    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)])
        .join();
  }

  /// Generate a memorable password phrase.
  static String generatePassphrase({
    int wordCount = 4,
    String separator = '-',
  }) {
    final words = [
      'apple',
      'banana',
      'cherry',
      'dragon',
      'eagle',
      'forest',
      'garden',
      'harbor',
      'island',
      'jungle',
      'kitchen',
      'lemon',
      'mountain',
      'nature',
      'ocean',
      'planet',
      'quantum',
      'river',
      'sunset',
      'thunder',
      'unique',
      'valley',
      'winter',
      'yellow',
      'zebra',
      'anchor',
      'bright',
      'castle',
      'dolphin',
      'energy',
      'falcon',
      'glacier',
      'horizon',
      'ivory',
      'jasmine',
      'kingdom',
      'lantern',
      'marble',
      'nebula',
      'orchid',
      'phoenix',
      'quartz',
      'rainbow',
      'silver',
      'tiger',
      'umbrella',
      'violet',
      'whisper',
      'xenon',
      'youth',
      'zenith',
      'amber',
      'bronze',
      'crystal',
      'diamond',
      'emerald',
      'flame',
      'golden',
      'honor',
      'indigo',
      'joyful',
      'kindness',
      'legacy',
    ];

    final random = Random.secure();
    final selectedWords = <String>[];

    for (int i = 0; i < wordCount; i++) {
      selectedWords.add(words[random.nextInt(words.length)]);
    }

    return selectedWords.join(separator);
  }

  // ================================================================
  // Password Comparison
  // ================================================================

  /// Check if two passwords are the same (for confirmation).
  /// Uses constant-time comparison.
  static bool passwordsMatch(String password, String confirmPassword) {
    return _constantTimeEquals(
      Uint8List.fromList(utf8.encode(password)),
      Uint8List.fromList(utf8.encode(confirmPassword)),
    );
  }
}
