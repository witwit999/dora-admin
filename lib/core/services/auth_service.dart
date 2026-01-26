import '../config/api_config.dart';
import '../services/api_service.dart';
import '../services/token_storage_service.dart';
import '../utils/error_handler.dart';
import '../utils/app_logger.dart';

/// Authentication Service
/// Handles login, logout, and token refresh
class AuthService {
  final ApiService _apiService;
  final TokenStorageService _tokenStorage;

  AuthService(this._apiService, this._tokenStorage);

  /// Login with phone and password
  /// Returns true on success, throws error message on failure
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    try {
      AppLogger.i('Attempting login for phone: $phone');

      final response = await _apiService.post(
        ApiConfig.login,
        data: {'phone': phone, 'password': password},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        AppLogger.i('Login successful - Admin ID: ${data['adminId']}');

        // Save tokens
        await _tokenStorage.saveTokens(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String,
          adminId: data['adminId'] as int,
        );

        AppLogger.i('Tokens saved successfully');
        return data;
      }

      AppLogger.e('Login failed - Invalid response');
      throw 'Login failed. Please try again.';
    } catch (e) {
      AppLogger.e('Login error', e);
      throw ErrorHandler.getUserFriendlyMessageLegacy(e);
    }
  }

  /// Refresh access token
  /// Returns new tokens on success
  Future<Map<String, dynamic>> refresh() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        throw 'No refresh token available. Please login again.';
      }

      final response = await _apiService.post(
        ApiConfig.refresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        // Save new tokens
        await _tokenStorage.saveTokens(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String,
          adminId: data['adminId'] as int,
        );

        return data;
      }

      throw 'Token refresh failed. Please login again.';
    } catch (e) {
      // Clear tokens on refresh failure
      await _tokenStorage.clearTokens();
      throw ErrorHandler.getUserFriendlyMessageLegacy(e);
    }
  }

  /// Logout
  /// Clears tokens and calls logout endpoint
  Future<void> logout() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();

      // Call logout endpoint if we have a refresh token
      if (refreshToken != null) {
        try {
          await _apiService.post(
            ApiConfig.logout,
            data: {'refreshToken': refreshToken},
          );
        } catch (e) {
          // Continue with token clearing even if logout endpoint fails
          // This ensures user can always logout locally
        }
      }

      // Clear tokens regardless of endpoint response
      await _tokenStorage.clearTokens();
    } catch (e) {
      // Clear tokens even if logout fails
      await _tokenStorage.clearTokens();
      rethrow;
    }
  }

  /// Change password
  /// Success: 204 No Content
  /// Errors: 400, 401, 429, 500
  ///
  /// Throws DioException on API failures (caller should localize via ErrorHandler.getUserFriendlyMessage).
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    AppLogger.i('Attempting change password');

    final response = await _apiService.postRaw(
      ApiConfig.changePassword,
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );

    // Dio validateStatus already accepts 2xx, but keep an explicit guard.
    if (response.statusCode != 204) {
      throw 'Failed to change password. Please try again.';
    }
  }

  /// Check if user is logged in (has valid tokens)
  Future<bool> isLoggedIn() async {
    return await _tokenStorage.hasTokens();
  }

  /// Get stored admin ID
  Future<int?> getAdminId() async {
    return await _tokenStorage.getAdminId();
  }
}
