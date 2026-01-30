import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String productionUrl = 'https://grocery-list-backend-adft.onrender.com';

  // Local development URLs
  static const String _webLocalUrl = 'http://localhost:3000';
  static const String _androidLocalUrl = 'http://10.0.2.2:3000';
  static const String _iosLocalUrl = 'http://localhost:3000';

  // 🔧 Set to TRUE to use production, FALSE for local
  static const bool useProduction = true;

  static String get baseUrl {
    if (useProduction) {
      return productionUrl;
    }

    if (kIsWeb) {
      return _webLocalUrl;
    }

    // For mobile, we can't easily detect platform without dart:io
    // Default to Android emulator URL
    return _androidLocalUrl;
  }

  // Auth endpoints
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String me = '/api/auth/me';

  // List endpoints
  static const String lists = '/api/lists';
  static const String joinList = '/api/lists/join';

  // Item endpoints
  static String listItems(String listId) => '/api/lists/$listId/items';
  static String toggleItem(String listId, String itemId) =>
      '/api/lists/$listId/items/$itemId/toggle';
  static String updateItem(String listId, String itemId) =>
      '/api/lists/$listId/items/$itemId';
  static String deleteItem(String listId, String itemId) =>
      '/api/lists/$listId/items/$itemId';
}