import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token
  static Future<void> saveToken(String token) async {
    await _prefs?.setString(_tokenKey, token);
  }

  static String? getToken() {
    return _prefs?.getString(_tokenKey);
  }

  static Future<void> removeToken() async {
    await _prefs?.remove(_tokenKey);
  }

  // User Info
  static Future<void> saveUserInfo({
    required String id,
    required String name,
    required String email,
  }) async {
    await _prefs?.setString(_userIdKey, id);
    await _prefs?.setString(_userNameKey, name);
    await _prefs?.setString(_userEmailKey, email);
  }

  static String? getUserId() => _prefs?.getString(_userIdKey);
  static String? getUserName() => _prefs?.getString(_userNameKey);
  static String? getUserEmail() => _prefs?.getString(_userEmailKey);

  // Clear All
  static Future<void> clearAll() async {
    await _prefs?.clear();
  }

  // Check if logged in
  static bool isLoggedIn() {
    return getToken() != null;
  }
}