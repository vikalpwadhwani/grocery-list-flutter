import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  static SharedPreferences? _prefs;
  static bool _initialized = false;

  /// Initialize the storage service
  /// Call this in main() before runApp()
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
      if (kDebugMode) {
        print('✅ StorageService initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ StorageService init error: $e');
      }
      _initialized = false;
    }
  }

  /// Check if storage is ready
  static bool get isInitialized => _initialized && _prefs != null;

  /// Ensure storage is initialized before use
  static Future<void> _ensureInitialized() async {
    if (!isInitialized) {
      await init();
    }
  }

  // ============================================
  // TOKEN METHODS
  // ============================================

  /// Save authentication token
  static Future<bool> saveToken(String token) async {
    await _ensureInitialized();
    if (_prefs == null) return false;
    return await _prefs!.setString(_tokenKey, token);
  }

  /// Get authentication token
  static String? getToken() {
    if (_prefs == null) return null;
    return _prefs!.getString(_tokenKey);
  }

  /// Remove authentication token
  static Future<bool> removeToken() async {
    await _ensureInitialized();
    if (_prefs == null) return false;
    return await _prefs!.remove(_tokenKey);
  }

  // ============================================
  // USER INFO METHODS
  // ============================================

  /// Save user information
  static Future<void> saveUserInfo({
    required String id,
    required String name,
    required String email,
  }) async {
    await _ensureInitialized();
    if (_prefs == null) return;

    await Future.wait([
      _prefs!.setString(_userIdKey, id),
      _prefs!.setString(_userNameKey, name),
      _prefs!.setString(_userEmailKey, email),
    ]);
  }

  /// Get user ID
  static String? getUserId() {
    if (_prefs == null) return null;
    return _prefs!.getString(_userIdKey);
  }

  /// Get user name
  static String? getUserName() {
    if (_prefs == null) return null;
    return _prefs!.getString(_userNameKey);
  }

  /// Get user email
  static String? getUserEmail() {
    if (_prefs == null) return null;
    return _prefs!.getString(_userEmailKey);
  }

  // ============================================
  // UTILITY METHODS
  // ============================================

  /// Clear all stored data
  static Future<bool> clearAll() async {
    await _ensureInitialized();
    if (_prefs == null) return false;
    return await _prefs!.clear();
  }

  /// Check if user is logged in
  static bool isLoggedIn() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  /// Get all stored keys (for debugging)
  static Set<String>? getAllKeys() {
    if (_prefs == null) return null;
    return _prefs!.getKeys();
  }

  /// Debug: Print all stored values
  static void debugPrintAll() {
    if (!kDebugMode) return;
    if (_prefs == null) {
      print('StorageService not initialized');
      return;
    }

    print('--- StorageService Debug ---');
    print('Token: ${getToken()?.substring(0, 20) ?? 'null'}...');
    print('User ID: ${getUserId()}');
    print('User Name: ${getUserName()}');
    print('User Email: ${getUserEmail()}');
    print('Is Logged In: ${isLoggedIn()}');
    print('----------------------------');
  }
}