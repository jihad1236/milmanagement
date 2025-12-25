import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Constants for preference keys
  static const String _tokenKey = 'token';
  static const String _idKey = 'userId';
  static const String _refreshKey = 'refresh';
  static const String _emailKey = 'email';

  // Singleton instance for SharedPreferences
  static SharedPreferences? _preferences;

  // Initialize SharedPreferences (call this during app startup)
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Check if a token exists in local storage
  static bool hasToken() {
    final token = _preferences?.getString(_tokenKey);
    return token != null;
  }

  // Save the token and user ID to local storage
  /// Save authentication data to local storage.
  /// Expects the access token, user id, refresh token and user email.
  static Future<void> saveToken(
    String token,
    String id, {
    required String refresh,
    required String email,
  }) async {
    await _preferences?.setString(_tokenKey, token);
    await _preferences?.setString(_idKey, id);
    await _preferences?.setString(_refreshKey, refresh);
    await _preferences?.setString(_emailKey, email);
  }

  // Remove the token and user ID from local storage (for logout)
  static Future<void> logoutUser() async {
    await _preferences?.remove(_tokenKey);
    await _preferences?.remove(_idKey);
    await _preferences?.remove(_refreshKey);
    await _preferences?.remove(_emailKey);
    // Navigate to the login screen
    // Get.offAllNamed('/login');
  }

  // Getter for user ID
  static String? get userId => _preferences?.getString(_idKey);

  // Getter for token
  static String? get token => _preferences?.getString(_tokenKey);

  // Getter for refresh token
  static String? get refresh => _preferences?.getString(_refreshKey);

  // Getter for email
  static String? get email => _preferences?.getString(_emailKey);
}
