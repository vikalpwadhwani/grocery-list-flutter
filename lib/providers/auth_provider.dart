import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../core/utils/storage_service.dart';
import '../models/user_model.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;

  AuthNotifier(this._apiClient) : super(AuthState());

  Future<void> checkAuthStatus() async {
    final token = StorageService.getToken();
    if (token != null) {
      state = state.copyWith(isLoading: true);
      try {
        final response = await _apiClient.get(ApiConstants.me);
        if (response.data['success']) {
          final user = UserModel.fromJson(response.data['data']['user']);
          state = state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            user: user,
          );
        }
      } catch (e) {
        await StorageService.clearAll();
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          user: null,
        );
      }
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      if (response.data['success']) {
        final user = UserModel.fromJson(response.data['data']['user']);
        final token = response.data['data']['token'];

        await StorageService.saveToken(token);
        await StorageService.saveUserInfo(
          id: user.id,
          name: user.name,
          email: user.email,
        );

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'],
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.data['success']) {
        final user = UserModel.fromJson(response.data['data']['user']);
        final token = response.data['data']['token'];

        await StorageService.saveToken(token);
        await StorageService.saveUserInfo(
          id: user.id,
          name: user.name,
          email: user.email,
        );

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'],
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await StorageService.clearAll();
    state = AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('DioException')) {
      if (error.response?.data != null) {
        return error.response.data['message'] ?? 'Something went wrong';
      }
      return 'Network error. Please check your connection.';
    }
    return error.toString();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ApiClient());
});