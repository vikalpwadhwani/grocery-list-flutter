import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../utils/storage_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio _dio;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = StorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            print('REQUEST: ${options.method} ${options.path}');
            if (options.data != null) {
              print('   Body: ${options.data}');
            }
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
          }

          return handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            print(' ERROR: ${error.message}');
            print('   Path: ${error.requestOptions.path}');
            if (error.response?.data != null) {
              print('   Response: ${error.response?.data}');
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;


  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParams,
        Options? options,
      }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParams,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParams,
        Options? options,
      }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParams,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParams,
        Options? options,
      }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParams,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParams,
        Options? options,
      }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParams,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParams,
        Options? options,
      }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParams,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    String message;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Server took too long to respond.';
        break;
      case DioExceptionType.badResponse:
        message = _getErrorFromResponse(error.response);
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection.';
        break;
      case DioExceptionType.unknown:
      default:
        message = 'Something went wrong. Please try again.';
        break;
    }

    return ApiException(message, error.response?.statusCode);
  }

  String _getErrorFromResponse(Response? response) {
    if (response == null) {
      return 'No response from server.';
    }

    try {
      if (response.data is Map) {
        return response.data['message'] ?? 'An error occurred.';
      }
      return 'An error occurred.';
    } catch (e) {
      return 'An error occurred.';
    }
  }


  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}