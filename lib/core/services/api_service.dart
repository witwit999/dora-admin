import 'dart:async';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../services/token_storage_service.dart';
import '../utils/error_handler.dart';
import '../utils/app_logger.dart';

/// API Service for HTTP requests
/// Handles token management and automatic token refresh
class ApiService {
  late final Dio _dio;
  final TokenStorageService _tokenStorage;
  bool _isRefreshing = false;
  final List<({Completer<void> completer, CancelToken cancelToken})>
  _refreshQueue = [];

  ApiService(this._tokenStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          // Accept status codes from 200 to 299
          return status != null && status >= 200 && status < 300;
        },
      ),
    );

    // Add certificate pinning or SSL handling if needed
    // For now, we'll trust all certificates in debug mode
    // In production, you should use proper certificate pinning

    _setupInterceptors();
  }

  /// Setup request and response interceptors
  void _setupInterceptors() {
    // Request interceptor - Add access token to headers
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip adding token for auth endpoints
          if (!_isAuthEndpoint(options.path)) {
            final token = await _tokenStorage.getAccessToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          AppLogger.d('API Request: ${options.method} ${options.uri}');
          AppLogger.d('Base URL: ${options.baseUrl}');
          AppLogger.d('Path: ${options.path}');
          if (options.data != null) {
            AppLogger.d('Request Body: ${options.data}');
          }
          AppLogger.d('Request Headers: ${options.headers}');

          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.d(
            'API Response: ${response.requestOptions.method} ${response.requestOptions.path} - Status: ${response.statusCode}',
          );
          if (response.data != null) {
            AppLogger.d('Response Data: ${response.data}');
          }
          return handler.next(response);
        },
        onError: (error, handler) async {
          AppLogger.e(
            'API Error: ${error.requestOptions.method} ${error.requestOptions.uri}',
            error.response?.data ?? error.message,
          );

          AppLogger.e('Error Type: ${error.type}');
          AppLogger.e('Error Message: ${error.message}');

          if (error.response != null) {
            AppLogger.e('Response Status: ${error.response?.statusCode}');
            AppLogger.e('Response Data: ${error.response?.data}');
          } else {
            AppLogger.e('No response received - Connection error');
            AppLogger.e('Request URL: ${error.requestOptions.uri}');
            AppLogger.e('Request Headers: ${error.requestOptions.headers}');
          }

          // Handle 401 Unauthorized - Try to refresh token
          if (error.response?.statusCode == 401 &&
              !_isAuthEndpoint(error.requestOptions.path)) {
            AppLogger.w('401 Unauthorized - Attempting token refresh');
            try {
              // Trigger token refresh if not already in progress
              if (!_isRefreshing) {
                await refreshToken();
              } else {
                // Wait for ongoing refresh to complete
                await _waitForTokenRefresh();
              }

              // Retry the original request with new token
              final newToken = await _tokenStorage.getAccessToken();
              if (newToken != null) {
                AppLogger.i('Token refreshed, retrying request');
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newToken';
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              }
            } catch (e) {
              AppLogger.e('Token refresh failed', e);
              // Refresh failed, clear tokens and return original error
              await _tokenStorage.clearTokens();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Check if endpoint is an auth endpoint (doesn't need token)
  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/login') || path.contains('/auth/refresh');
  }

  /// Wait for token refresh if in progress
  Future<void> _waitForTokenRefresh() async {
    if (!_isRefreshing) return;

    final completer = Completer<void>();
    final cancelToken = CancelToken();
    _refreshQueue.add((completer: completer, cancelToken: cancelToken));

    return completer.future;
  }

  /// Refresh access token
  Future<void> refreshToken() async {
    if (_isRefreshing) {
      await _waitForTokenRefresh();
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await _dio.post(
        ApiConfig.refresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        AppLogger.i('Token refresh successful');
        await _tokenStorage.saveTokens(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String,
          adminId: data['adminId'] as int,
        );

        // Notify waiting requests
        for (final item in _refreshQueue) {
          if (!item.cancelToken.isCancelled) {
            item.completer.complete();
          }
        }
        _refreshQueue.clear();
      }
    } catch (e) {
      // Notify waiting requests of failure
      for (final item in _refreshQueue) {
        if (!item.cancelToken.isCancelled) {
          item.completer.completeError(e);
        }
      }
      _refreshQueue.clear();

      // Clear tokens on refresh failure
      await _tokenStorage.clearTokens();
      rethrow;
    } finally {
      _isRefreshing = false;
    }
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandler.getUserFriendlyMessageLegacy(e);
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandler.getUserFriendlyMessageLegacy(e);
    }
  }

  /// POST request (raw)
  /// Unlike [post], this does NOT map errors to legacy strings.
  /// Use this when the caller wants to localize errors via [ErrorHandler.getUserFriendlyMessage].
  Future<Response> postRaw(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandler.getUserFriendlyMessageLegacy(e);
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandler.getUserFriendlyMessageLegacy(e);
    }
  }
}
