import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  static SharedPreferences? _prefs;
  static bool _initialized = false;

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
      if (kDebugMode) {
      }
    } catch (e) {
      if (kDebugMode) {
      }
      _initialized = false;
    }
  }

  static bool get isInitialized => _initialized && _prefs != null;

  static Future<void> _ensureInitialized() async {
    if (!isInitialized) {
      await init();
    }
  }

  static Future<bool> saveToken(String token) async {
    await _ensureInitialized();
    if (_prefs == null) return false;
    return await _prefs!.setString(_tokenKey, token);
  }

  static String? getToken() {
    if (_prefs == null) return null;
    return _prefs!.getString(_tokenKey);
  }

  static Future<bool> removeToken() async {
    await _ensureInitialized();
    if (_prefs == null) return false;
    return await _prefs!.remove(_tokenKey);
  }

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

  static String? getUserId() {
    if (_prefs == null) return null;
    return _prefs!.getString(_userIdKey);
  }

  static String? getUserName() {
    if (_prefs == null) return null;
    return _prefs!.getString(_userNameKey);
  }

  static String? getUserEmail() {
    if (_prefs == null) return null;
    return _prefs!.getString(_userEmailKey);
  }

  static Future<bool> clearAll() async {
    await _ensureInitialized();
    if (_prefs == null) return false;
    return await _prefs!.clear();
  }

  static bool isLoggedIn() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  static Set<String>? getAllKeys() {
    if (_prefs == null) return null;
    return _prefs!.getKeys();
  }

  static void debugPrintAll() {
    if (!kDebugMode) return;
    if (_prefs == null) {
      return;
    }

  }
}