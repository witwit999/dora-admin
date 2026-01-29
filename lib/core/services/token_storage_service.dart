import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/app_logger.dart';

/// Service for managing secure token storage
/// Implements best practices for desktop admin panel (Windows/Linux/macOS)
class TokenStorageService {
  final FlutterSecureStorage _storage;

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _adminIdKey = 'admin_id';

  // Retry configuration
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(milliseconds: 100);
  
  // Desktop-specific verification delay (Windows Credential Manager and Linux libsecret need time to persist)
  static const Duration _desktopVerificationDelay = Duration(milliseconds: 200);
  static const int _verificationRetries = 3;

  // Helper to check if running on desktop platform
  static bool get _isDesktop => Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  TokenStorageService()
      : _storage = FlutterSecureStorage(
          aOptions: const AndroidOptions(
            encryptedSharedPreferences: true,
          ),
          iOptions: const IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
          ),
          // Windows-specific configuration for desktop admin panel
          wOptions: const WindowsOptions(
            useBackwardCompatibility: false,
          ),
          // Linux-specific configuration (uses libsecret)
          lOptions: const LinuxOptions(),
        );

  /// Retry helper for desktop storage operations
  Future<T> _retryOperation<T>(
    Future<T> Function() operation,
    String operationName,
  ) async {
    int attempt = 0;
    Exception? lastException;

    while (attempt < _maxRetries) {
      try {
        final result = await operation();
        
        // For write operations on desktop, verify immediately if possible
        if (_isDesktop && result == null && operationName.contains('Save')) {
          AppLogger.w('⚠ Write operation returned null on desktop, may have failed silently');
        }
        
        if (attempt > 0) {
          AppLogger.i(
            '✓ $operationName succeeded on retry attempt ${attempt + 1}',
          );
        }
        return result;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempt++;

        if (attempt < _maxRetries) {
          final delay = _retryDelay * attempt; // Exponential backoff
          AppLogger.w(
            '⚠ $operationName failed (attempt $attempt/$_maxRetries), retrying in ${delay.inMilliseconds}ms',
          );
          await Future.delayed(delay);
        } else {
          AppLogger.e(
            '✗ $operationName failed after $_maxRetries attempts',
            lastException,
          );
        }
      }
    }

    throw lastException ?? Exception('$operationName failed');
  }

  /// Verify that a value was saved correctly
  /// On desktop platforms, adds delay and retries due to async behavior
  Future<bool> _verifySave(String key, String expectedValue) async {
    // On desktop platforms, wait a bit for secure storage to persist the data
    if (_isDesktop) {
      await Future.delayed(_desktopVerificationDelay);
    }

    // Retry verification multiple times (especially important for Windows)
    for (int attempt = 0; attempt < _verificationRetries; attempt++) {
      try {
        final saved = await _storage.read(key: key);
        final isVerified = saved == expectedValue;
        
        if (isVerified) {
          if (attempt > 0) {
            AppLogger.d(
              '✓ Verification succeeded on attempt ${attempt + 1} for key: $key',
            );
          }
          return true;
        }
        
        // If not verified and not last attempt, wait and retry
        if (attempt < _verificationRetries - 1) {
          final delay = Duration(milliseconds: 100 * (attempt + 1));
          AppLogger.w(
            '⚠ Verification attempt ${attempt + 1} failed for key: $key. Expected: ${expectedValue.length} chars, Got: ${saved?.length ?? 0} chars. Retrying in ${delay.inMilliseconds}ms...',
          );
          await Future.delayed(delay);
        } else {
          AppLogger.w(
            '⚠ Verification failed for key: $key after $_verificationRetries attempts. Expected: ${expectedValue.length} chars, Got: ${saved?.length ?? 0} chars',
          );
        }
      } catch (e) {
        if (attempt < _verificationRetries - 1) {
          final delay = Duration(milliseconds: 100 * (attempt + 1));
          AppLogger.w(
            '⚠ Verification read error on attempt ${attempt + 1} for key: $key. Retrying in ${delay.inMilliseconds}ms...',
          );
          await Future.delayed(delay);
        } else {
          AppLogger.w('Failed to verify save for key: $key after $_verificationRetries attempts', e);
        }
      }
    }
    
    return false;
  }

  /// Save access token with verification
  Future<void> saveAccessToken(String token) async {
    try {
      AppLogger.d('Attempting to save access token (${token.length} chars)');
      
      // On desktop platforms, add a small delay before write to ensure secure storage is ready
      if (_isDesktop) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      
      await _retryOperation(
        () async {
          try {
            await _storage.write(key: _accessTokenKey, value: token);
            AppLogger.d('Write operation completed for access token');
          } catch (e) {
            AppLogger.e('Write operation failed for access token', e);
            rethrow;
          }
        },
        'Save access token',
      );

      // On desktop platforms, wait longer before verification
      if (_isDesktop) {
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // Verify the token was saved correctly
      final verified = await _verifySave(_accessTokenKey, token);
      if (verified) {
        AppLogger.d('✓ Access token saved and verified successfully');
      } else {
        // If verification fails, try reading one more time after a longer delay
        if (_isDesktop) {
          AppLogger.w('Verification failed, waiting longer and retrying...');
          await Future.delayed(const Duration(milliseconds: 500));
          final retryRead = await _storage.read(key: _accessTokenKey);
          if (retryRead == token) {
            AppLogger.d('✓ Access token verified after extended wait');
            return;
          }
          // If still failing, throw exception - the write didn't actually persist
          final platformName = Platform.isWindows 
              ? 'Windows Credential Manager' 
              : Platform.isLinux 
                  ? 'Linux libsecret' 
                  : 'secure storage';
          throw Exception(
            'Access token was not persisted to $platformName. Write operation may have failed silently.',
          );
        } else {
          throw Exception(
            'Access token verification failed. Token may not be persisted correctly.',
          );
        }
      }
    } catch (e) {
      final errorMessage = _isDesktop
          ? 'Failed to save access token to secure storage. Please ensure the app has proper permissions.'
          : 'Failed to save access token';
      AppLogger.e(errorMessage, e);
      rethrow;
    }
  }

  /// Get access token with retry logic
  Future<String?> getAccessToken() async {
    try {
      final token = await _retryOperation(
        () => _storage.read(key: _accessTokenKey),
        'Get access token',
      );

      if (token != null) {
        AppLogger.d('✓ Access token retrieved successfully (${token.length} chars)');
      } else {
        AppLogger.w('⚠ Access token not found in storage');
      }
      return token;
    } catch (e) {
      final errorMessage = _isDesktop
          ? 'Failed to retrieve access token from secure storage. The token may have been cleared or the app may need permissions.'
          : 'Failed to retrieve access token';
      AppLogger.e(errorMessage, e);
      rethrow;
    }
  }

  /// Save refresh token with verification
  Future<void> saveRefreshToken(String token) async {
    try {
      AppLogger.d('Attempting to save refresh token (${token.length} chars)');
      
      // On desktop platforms, add a small delay before write to ensure secure storage is ready
      if (_isDesktop) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      
      await _retryOperation(
        () async {
          try {
            await _storage.write(key: _refreshTokenKey, value: token);
            AppLogger.d('Write operation completed for refresh token');
          } catch (e) {
            AppLogger.e('Write operation failed for refresh token', e);
            rethrow;
          }
        },
        'Save refresh token',
      );

      // On desktop platforms, wait longer before verification
      if (_isDesktop) {
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // Verify the token was saved correctly
      final verified = await _verifySave(_refreshTokenKey, token);
      if (verified) {
        AppLogger.d('✓ Refresh token saved and verified successfully');
      } else {
        // If verification fails, try reading one more time after a longer delay
        if (_isDesktop) {
          AppLogger.w('Verification failed, waiting longer and retrying...');
          await Future.delayed(const Duration(milliseconds: 500));
          final retryRead = await _storage.read(key: _refreshTokenKey);
          if (retryRead == token) {
            AppLogger.d('✓ Refresh token verified after extended wait');
            return;
          }
          // If still failing, throw exception - the write didn't actually persist
          final platformName = Platform.isWindows 
              ? 'Windows Credential Manager' 
              : Platform.isLinux 
                  ? 'Linux libsecret' 
                  : 'secure storage';
          throw Exception(
            'Refresh token was not persisted to $platformName. Write operation may have failed silently.',
          );
        } else {
          throw Exception(
            'Refresh token verification failed. Token may not be persisted correctly.',
          );
        }
      }
    } catch (e) {
      final errorMessage = _isDesktop
          ? 'Failed to save refresh token to secure storage. Please ensure the app has proper permissions.'
          : 'Failed to save refresh token';
      AppLogger.e(errorMessage, e);
      rethrow;
    }
  }

  /// Get refresh token with retry logic
  Future<String?> getRefreshToken() async {
    try {
      final token = await _retryOperation(
        () => _storage.read(key: _refreshTokenKey),
        'Get refresh token',
      );

      if (token != null) {
        AppLogger.d('✓ Refresh token retrieved successfully (${token.length} chars)');
      } else {
        AppLogger.w('⚠ Refresh token not found in storage');
      }
      return token;
    } catch (e) {
      final errorMessage = _isDesktop
          ? 'Failed to retrieve refresh token from secure storage. The token may have been cleared or the app may need permissions.'
          : 'Failed to retrieve refresh token';
      AppLogger.e(errorMessage, e);
      rethrow;
    }
  }

  /// Save admin ID with verification
  Future<void> saveAdminId(int adminId) async {
    try {
      final adminIdString = adminId.toString();
      await _retryOperation(
        () => _storage.write(key: _adminIdKey, value: adminIdString),
        'Save admin ID',
      );

      // Verify the admin ID was saved correctly
      // On desktop platforms, verification failures are logged as warnings but don't fail the operation
      // since the write operation itself succeeded
      final verified = await _verifySave(_adminIdKey, adminIdString);
      if (verified) {
        AppLogger.d('✓ Admin ID saved and verified successfully');
      } else {
        if (_isDesktop) {
          // On desktop platforms, log warning but don't throw - the write succeeded, verification is best-effort
          final platformName = Platform.isWindows 
              ? 'Windows Credential Manager' 
              : Platform.isLinux 
                  ? 'Linux libsecret' 
                  : 'secure storage';
          AppLogger.w(
            '⚠ Admin ID write succeeded but verification failed. This may be a $platformName timing issue. Value should still be available.',
          );
        } else {
          // On mobile platforms, throw exception for verification failures
          throw Exception(
            'Admin ID verification failed. Value may not be persisted correctly.',
          );
        }
      }
    } catch (e) {
      final errorMessage = _isDesktop
          ? 'Failed to save admin ID to secure storage. Please ensure the app has proper permissions.'
          : 'Failed to save admin ID';
      AppLogger.e(errorMessage, e);
      rethrow;
    }
  }

  /// Get admin ID with retry logic
  Future<int?> getAdminId() async {
    try {
      final idString = await _retryOperation(
        () => _storage.read(key: _adminIdKey),
        'Get admin ID',
      );

      final id = idString != null ? int.tryParse(idString) : null;
      if (id != null) {
        AppLogger.d('✓ Admin ID retrieved successfully: $id');
      } else {
        AppLogger.w('⚠ Admin ID not found in storage');
      }
      return id;
    } catch (e) {
      final errorMessage = _isDesktop
          ? 'Failed to retrieve admin ID from secure storage. The value may have been cleared or the app may need permissions.'
          : 'Failed to retrieve admin ID';
      AppLogger.e(errorMessage, e);
      rethrow;
    }
  }

  /// Save all tokens and admin ID
  /// On desktop platforms (Windows/Linux), saves sequentially to avoid secure storage conflicts
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int adminId,
  }) async {
    if (_isDesktop) {
      // On desktop platforms, save sequentially to avoid secure storage issues
      await saveAccessToken(accessToken);
      await saveRefreshToken(refreshToken);
      await saveAdminId(adminId);
    } else {
      // On mobile platforms, can save in parallel
      await Future.wait([
        saveAccessToken(accessToken),
        saveRefreshToken(refreshToken),
        saveAdminId(adminId),
      ]);
    }
  }

  /// Clear all tokens
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _retryOperation(
          () => _storage.delete(key: _accessTokenKey),
          'Delete access token',
        ),
        _retryOperation(
          () => _storage.delete(key: _refreshTokenKey),
          'Delete refresh token',
        ),
        _retryOperation(
          () => _storage.delete(key: _adminIdKey),
          'Delete admin ID',
        ),
      ]);
      AppLogger.d('✓ All tokens cleared successfully');
    } catch (e) {
      AppLogger.e('Failed to clear tokens', e);
      // Don't rethrow - clearing tokens is best effort
    }
  }

  /// Check if user has tokens (is logged in)
  Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    final hasTokens = accessToken != null && refreshToken != null;
    AppLogger.d('Token check: ${hasTokens ? "Tokens exist" : "No tokens found"}');
    return hasTokens;
  }

  /// Verify storage is working properly
  /// Useful for initialization checks
  Future<bool> verifyStorage() async {
    try {
      const testKey = '_storage_test';
      const testValue = 'test_value_123';

      // Try to write
      await _storage.write(key: testKey, value: testValue);

      // Try to read back
      final readValue = await _storage.read(key: testKey);

      // Clean up
      await _storage.delete(key: testKey);

      final isWorking = readValue == testValue;
      if (isWorking) {
        AppLogger.i('✓ Storage verification successful');
      } else {
        AppLogger.e('✗ Storage verification failed: value mismatch');
      }
      return isWorking;
    } catch (e) {
      AppLogger.e('✗ Storage verification failed', e);
      return false;
    }
  }
}
