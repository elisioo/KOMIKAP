class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _currentUserId;
  String? _authToken;

  bool get isAuthenticated => _authToken != null;
  String? get currentUserId => _currentUserId;

  /// Email/Password Sign In
  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      // TODO: Replace with actual API call
      // final response = await http.post(
      //   Uri.parse('https://api.example.com/auth/login'),
      //   body: jsonEncode({'email': email, 'password': password}),
      // );

      await Future.delayed(const Duration(seconds: 1)); // Simulate network

      // Mock validation
      if (email.isEmpty || password.isEmpty) {
        return AuthResult(success: false, message: 'Please fill all fields');
      }

      if (!email.contains('@')) {
        return AuthResult(success: false, message: 'Invalid email format');
      }

      // Mock success
      _authToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      _currentUserId = 'user_123';

      return AuthResult(
        success: true,
        message: 'Login successful',
        userId: _currentUserId,
        token: _authToken,
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
      // TODO: Replace with actual API call
      // final response = await http.post(
      //   Uri.parse('https://api.example.com/auth/signup'),
      //   body: jsonEncode({
      //     'email': email,
      //     'password': password,
      //     'username': username,
      //   }),
      // );

      await Future.delayed(const Duration(seconds: 1));

      // Mock validation
      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        return AuthResult(success: false, message: 'Please fill all fields');
      }

      if (password.length < 6) {
        return AuthResult(
          success: false,
          message: 'Password must be at least 6 characters',
        );
      }

      // Mock success
      _authToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      _currentUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';

      return AuthResult(
        success: true,
        message: 'Account created successfully',
        userId: _currentUserId,
        token: _authToken,
      );
    } catch (e) {
      return AuthResult(success: false, message: 'Signup failed: $e');
    }
  }

  /// Google Sign In
  Future<AuthResult> signInWithGoogle() async {
    try {
      // TODO: Replace with actual Google Sign-In
      // Import: google_sign_in: ^6.1.5

      // final GoogleSignIn googleSignIn = GoogleSignIn(
      //   scopes: ['email', 'profile'],
      // );

      // final GoogleSignInAccount? account = await googleSignIn.signIn();
      // if (account == null) {
      //   return AuthResult(success: false, message: 'Google sign in cancelled');
      // }

      // final GoogleSignInAuthentication auth = await account.authentication;
      // final String? idToken = auth.idToken;

      // Send idToken to your backend
      // final response = await http.post(
      //   Uri.parse('https://api.example.com/auth/google'),
      //   body: jsonEncode({'idToken': idToken}),
      // );

      await Future.delayed(const Duration(seconds: 2)); // Simulate Google flow

      // Mock success
      _authToken = 'google_token_${DateTime.now().millisecondsSinceEpoch}';
      _currentUserId = 'google_user_123';

      return AuthResult(
        success: true,
        message: 'Google sign in successful',
        userId: _currentUserId,
        token: _authToken,
        provider: 'google',
      );
    } catch (e) {
      return AuthResult(success: false, message: 'Google sign in failed: $e');
    }
  }

  /// Forgot Password
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      if (email.isEmpty || !email.contains('@')) {
        return AuthResult(success: false, message: 'Invalid email address');
      }

      return AuthResult(success: true, message: 'Password reset email sent');
    } catch (e) {
      return AuthResult(success: false, message: 'Failed to send email: $e');
    }
  }

  /// Logout
  Future<void> logout() async {
    // TODO: Call backend to invalidate token
    // await http.post(Uri.parse('https://api.example.com/auth/logout'));

    _authToken = null;
    _currentUserId = null;
  }

  /// Check if token is valid
  Future<bool> validateToken() async {
    if (_authToken == null) return false;

    // TODO: Validate with backend
    // final response = await http.get(
    //   Uri.parse('https://api.example.com/auth/validate'),
    //   headers: {'Authorization': 'Bearer $_authToken'},
    // );
    // return response.statusCode == 200;

    return true;
  }
}

class AuthResult {
  final bool success;
  final String message;
  final String? userId;
  final String? token;
  final String? provider;

  AuthResult({
    required this.success,
    required this.message,
    this.userId,
    this.token,
    this.provider,
  });
}
