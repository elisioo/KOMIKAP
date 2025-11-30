import 'package:firebase_auth/firebase_auth.dart';
import 'package:komikap/services/firebase_service.dart';
import 'package:komikap/services/local_cache_service.dart';
import 'package:komikap/models/firebase_models.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();
  final LocalCacheService _cacheService = LocalCacheService();

  String? get currentUserId => _firebaseAuth.currentUser?.uid;
  bool get isAuthenticated => _firebaseAuth.currentUser != null;
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Email/Password Sign In
  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return AuthResult(success: false, message: 'Please fill all fields');
      }

      if (!email.contains('@')) {
        return AuthResult(success: false, message: 'Invalid email format');
      }

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return AuthResult(success: false, message: 'Login failed');
      }

      // Cache user data locally
      final userProfile = await _firebaseService.getUserProfile(user.uid);
      if (userProfile != null) {
        await _cacheService.saveMangaLocally(
          SavedManga(
            id: user.uid,
            uid: user.uid,
            mangaId: '',
            title: userProfile.username,
            savedAt: DateTime.now(),
            lastReadAt: DateTime.now(),
          ),
        );
      }

      return AuthResult(
        success: true,
        message: 'Login successful',
        userId: user.uid,
        token: await user.getIdToken(),
        email: user.email,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _getFirebaseErrorMessage(e.code),
      );
    } catch (e) {
      return AuthResult(success: false, message: 'Login failed: $e');
    }
  }

  /// Email/Password Sign Up
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        return AuthResult(success: false, message: 'Please fill all fields');
      }

      if (password.length < 6) {
        return AuthResult(
          success: false,
          message: 'Password must be at least 6 characters',
        );
      }

      if (username.length < 3) {
        return AuthResult(
          success: false,
          message: 'Username must be at least 3 characters',
        );
      }

      // Create Firebase user
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return AuthResult(success: false, message: 'Signup failed');
      }

      // Create user profile in Firestore
      await _firebaseService.createUserProfile(
        uid: user.uid,
        username: username.trim(),
        email: email.trim(),
      );

      return AuthResult(
        success: true,
        message: 'Account created successfully',
        userId: user.uid,
        token: await user.getIdToken(),
        email: user.email,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _getFirebaseErrorMessage(e.code),
      );
    } catch (e) {
      return AuthResult(success: false, message: 'Signup failed: $e');
    }
  }

  /// Google Sign In (requires google_sign_in package)
  Future<AuthResult> signInWithGoogle() async {
    try {
      // TODO: Implement Google Sign-In
      // Add to pubspec.yaml: google_sign_in: ^6.1.5
      // Then uncomment the code below:

      /*
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) {
        return AuthResult(success: false, message: 'Google sign in cancelled');
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        return AuthResult(success: false, message: 'Google sign in failed');
      }

      // Create user profile if new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _firebaseService.createUserProfile(
          uid: user.uid,
          username: user.displayName ?? 'User',
          email: user.email ?? '',
        );
      }

      return AuthResult(
        success: true,
        message: 'Google sign in successful',
        userId: user.uid,
        token: await user.getIdToken(),
        email: user.email,
        provider: 'google',
      );
      */

      return AuthResult(
        success: false,
        message: 'Google Sign-In not yet configured. Please use email/password.',
      );
    } catch (e) {
      return AuthResult(success: false, message: 'Google sign in failed: $e');
    }
  }

  /// Forgot Password
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      if (email.isEmpty || !email.contains('@')) {
        return AuthResult(success: false, message: 'Invalid email address');
      }

      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());

      return AuthResult(
        success: true,
        message: 'Password reset email sent. Check your inbox.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _getFirebaseErrorMessage(e.code),
      );
    } catch (e) {
      return AuthResult(success: false, message: 'Failed to send email: $e');
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      // Clear local cache on logout
      await _cacheService.clearAllData();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  /// Check if user is authenticated
  Future<bool> validateToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;

      // Refresh token to ensure it's valid
      await user.getIdToken();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get Firebase error message
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'User account is disabled';
      case 'too-many-requests':
        return 'Too many login attempts. Try again later';
      default:
        return 'Authentication error: $code';
    }
  }
}

class AuthResult {
  final bool success;
  final String message;
  final String? userId;
  final String? token;
  final String? provider;
  final String? email;

  AuthResult({
    required this.success,
    required this.message,
    this.userId,
    this.token,
    this.provider,
    this.email,
  });
}
