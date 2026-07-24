import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_models.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../storage/storage_service.dart';

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserResponse?>>((ref) {
  final apiClient = ref.watch(dioProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthNotifier(apiClient, storageService);
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value != null;
});

class AuthNotifier extends StateNotifier<AsyncValue<UserResponse?>> {
  final DioApiClient _apiClient;
  final StorageService _storageService;

  AuthNotifier(this._apiClient, this._storageService) : super(const AsyncValue.loading()) {
    loadCurrentUser();
  }

  Future<void> loadCurrentUser() async {
    try {
      final hasToken = await _storageService.hasToken();
      if (!hasToken) {
        state = const AsyncValue.data(null);
        return;
      }
      
      final response = await _apiClient.get(
        ApiEndpoints.me,
        parser: (data) => UserResponse.fromJson(data),
      );
      
      if (response.success && response.data != null) {
        state = AsyncValue.data(response.data);
      } else {
        await _storageService.deleteToken();
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      final request = LoginRequest(email: email, password: password);
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: request.toJson(),
        parser: (data) => Token.fromJson(data),
      );
      
      if (response.success && response.data != null) {
        await _storageService.saveToken(response.data!.accessToken);
        await loadCurrentUser();
        return true;
      } else {
        state = AsyncValue.error(response.error ?? 'Login failed', StackTrace.current);
        return false;
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> register(String email, String password, String fullName) async {
    try {
      state = const AsyncValue.loading();
      final request = UserCreate(email: email, password: password, fullName: fullName);
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: request.toJson(),
        parser: (data) => UserResponse.fromJson(data),
      );
      
      if (response.success && response.data != null) {
        return await login(email, password);
      } else {
        state = AsyncValue.error(response.error ?? 'Registration failed', StackTrace.current);
        return false;
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> logout() async {
    await _storageService.deleteToken();
    state = const AsyncValue.data(null);
  }
}
