// ================================================================
// Auth Service - Enhanced Authentication
// Allin1 Super App v1.0
// ================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'session_service.dart';

// ================================================================
// Auth Result Class
// ================================================================
class AuthResult {
  final bool success;
  final String? error;
  final User? user;

  AuthResult({
    required this.success,
    this.error,
    this.user,
  });
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '357526153693-02b0behmsf3k720jujg3e8j82frj04q7.apps.googleusercontent.com',
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SessionService _sessionService = SessionService();

  // ================================================================
  // Check if Username Exists
  // ================================================================
  Future<bool> isUsernameTaken(String username) async {
    final normalizedUsername = username.toLowerCase().trim();
    final querySnapshot = await _firestore
        .collection('users')
        .where('usernameLower', isEqualTo: normalizedUsername)
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  // ================================================================
  // Validate Username Format
  // ================================================================
  String? validateUsername(String username) {
    if (username.isEmpty) {
      return 'Username is required';
    }
    if (username.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (username.length > 20) {
      return 'Username must be less than 20 characters';
    }
    // Only allow alphanumeric and underscore
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null; // Valid
  }

  // ================================================================
  // Register New User (Rider or Regular User)
  // ================================================================
  Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
    required String username,
    required UserType userType,
    String? phoneNumber,
  }) async {
    try {
      // Validate username format
      final usernameError = validateUsername(username);
      if (usernameError != null) {
        return AuthResult(success: false, error: usernameError);
      }

      // Check if username is taken
      final isTaken = await isUsernameTaken(username);
      if (isTaken) {
        return AuthResult(success: false, error: 'Username is already taken');
      }

      // Create Firebase user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return AuthResult(success: false, error: 'Failed to create account');
      }

      // Save user data to Firestore
      await _saveUserData(
        uid: credential.user!.uid,
        email: email,
        username: username,
        userType: userType,
        phoneNumber: phoneNumber,
      );

      // Save session
      await _sessionService.saveSession(
        userType: userType,
        uid: credential.user!.uid,
        email: email,
        displayName: username,
        phoneNumber: phoneNumber,
      );

      return AuthResult(success: true, user: credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult(success: false, error: 'Registration failed: $e');
    }
  }

  // ================================================================
  // Login with Email
  // ================================================================
  Future<AuthResult> loginWithEmail({
    required String email,
    required String password,
    required UserType userType,
    bool rememberMe = false,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return AuthResult(success: false, error: 'Login failed');
      }

      // Verify user type
      final userData = await getUserData(credential.user!.uid);
      if (userData == null) {
        return AuthResult(success: false, error: 'User data not found');
      }

      final storedUserType = UserType.values[userData['userType'] as int? ?? 1];
      if (storedUserType != userType) {
        await _auth.signOut();
        return AuthResult(
          success: false,
          error: 'This account is not registered as ${userType.name}',
        );
      }

      // Save session
      await _sessionService.saveSession(
        userType: userType,
        uid: credential.user!.uid,
        email: email,
        displayName: userData['username'] as String?,
        phoneNumber: userData['phone'] as String?,
        rememberMe: rememberMe,
      );

      return AuthResult(success: true, user: credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult(success: false, error: 'Login failed: $e');
    }
  }

  // ================================================================
  // Login with Google
  // ================================================================
  Future<AuthResult> loginWithGoogle({
    required UserType userType,
    bool rememberMe = false,
  }) async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult(success: false, error: 'Google sign-in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        return AuthResult(success: false, error: 'Google sign-in failed');
      }

      // Check if user exists in Firestore
      final userData = await getUserData(userCredential.user!.uid);

      // Save or update user data
      if (userData == null) {
        // New user - create record
        await _saveUserData(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          username: userCredential.user!.displayName ?? 'user',
          userType: userType,
          phoneNumber: userCredential.user!.phoneNumber,
        );
      }

      // Save session
      await _sessionService.saveSession(
        userType: userType,
        uid: userCredential.user!.uid,
        email: userCredential.user!.email ?? '',
        displayName: userCredential.user!.displayName,
        phoneNumber: userCredential.user!.phoneNumber,
        rememberMe: rememberMe,
      );

      return AuthResult(success: true, user: userCredential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult(success: false, error: 'Google sign-in failed: $e');
    }
  }

  // ================================================================
  // Login as Guest
  // ================================================================
  Future<AuthResult> loginAsGuest() async {
    try {
      final result = await _auth.signInAnonymously();

      if (result.user == null) {
        return AuthResult(success: false, error: 'Guest login failed');
      }

      // Save guest session
      await _sessionService.saveSession(
        userType: UserType.user,
        uid: result.user!.uid,
        email: 'guest@anonymous',
        displayName: 'Guest',
      );

      return AuthResult(success: true, user: result.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult(success: false, error: 'Guest login failed: $e');
    }
  }

  // ================================================================
  // Admin Login (Special authentication)
  // ================================================================
  Future<AuthResult> adminLogin({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return AuthResult(success: false, error: 'Admin login failed');
      }

      // Verify admin status
      final userData = await getUserData(credential.user!.uid);
      if (userData == null || userData['userType'] != UserType.admin.index) {
        await _auth.signOut();
        return AuthResult(success: false, error: 'Not authorized as admin');
      }

      // Save admin session
      await _sessionService.saveSession(
        userType: UserType.admin,
        uid: credential.user!.uid,
        email: email,
        displayName: userData['username'] as String?,
        rememberMe: true,
      );

      return AuthResult(success: true, user: credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult(success: false, error: 'Admin login failed: $e');
    }
  }

  // ================================================================
  // Logout
  // ================================================================
  Future<void> logout() async {
    await _sessionService.clearSession();
    await _googleSignIn.signOut();
  }

  // ================================================================
  // Get Current User
  // ================================================================
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // ================================================================
  // Check if Logged In
  // ================================================================
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // ================================================================
  // Private: Save User Data to Firestore
  // ================================================================
  Future<void> _saveUserData({
    required String uid,
    required String email,
    required String username,
    required UserType userType,
    String? phoneNumber,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'username': username,
      'usernameLower': username.toLowerCase(),
      'userType': userType.index,
      'phone': phoneNumber ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'isVerified': userType != UserType.rider,
    });
  }

  // ================================================================
  // Update User Phone Number
  // ================================================================
  Future<void> updateUserPhone(String uid, String phone) async {
    await _firestore.collection('users').doc(uid).update({
      'phone': phone,
    });
  }

  // ================================================================
  // Private: Get User Data from Firestore
  // ================================================================
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      return null;
    }
    return doc.data();
  }

  // ================================================================
  // Private: Get Auth Error Message
  // ================================================================
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'admin-restricted-operation':
        return 'This operation is restricted. Enable Anonymous auth in Firebase Console.';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      default:
        return 'Authentication error: $code';
    }
  }
}
