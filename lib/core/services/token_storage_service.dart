import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for managing secure token storage
class TokenStorageService {
  static final _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _adminIdKey = 'admin_id';

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Save admin ID
  Future<void> saveAdminId(int adminId) async {
    await _storage.write(key: _adminIdKey, value: adminId.toString());
  }

  /// Get admin ID
  Future<int?> getAdminId() async {
    final idString = await _storage.read(key: _adminIdKey);
    return idString != null ? int.tryParse(idString) : null;
  }

  /// Save all tokens and admin ID
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int adminId,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
      saveAdminId(adminId),
    ]);
  }

  /// Clear all tokens
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _adminIdKey),
    ]);
  }

  /// Check if user has tokens (is logged in)
  Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }
}
