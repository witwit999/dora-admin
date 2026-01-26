import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:dora_admin/l10n/app_localizations.dart';

/// Centralized error handler for API errors
/// Converts technical errors to user-friendly messages
class ErrorHandler {
  /// Get user-friendly error message from exception with localization
  static String getUserFriendlyMessage(dynamic error, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (error is DioException) {
      return _handleDioException(error, l10n);
    }

    if (error is String) {
      return error;
    }

    return l10n.errorUnexpected;
  }

  /// Legacy method for backward compatibility (uses English messages)
  /// Deprecated: Use getUserFriendlyMessage(error, context) instead
  @Deprecated(
    'Use getUserFriendlyMessage(error, context) for localized messages',
  )
  static String getUserFriendlyMessageLegacy(dynamic error) {
    if (error is DioException) {
      return _handleDioExceptionLegacy(error);
    }

    if (error is String) {
      return error;
    }

    return 'An unexpected error occurred. Please try again.';
  }

  /// Handle DioException and return user-friendly message with localization
  static String _handleDioException(DioException error, AppLocalizations l10n) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return l10n.errorConnectionTimeout;

      case DioExceptionType.badResponse:
        return _handleResponseError(error, l10n);

      case DioExceptionType.cancel:
        return l10n.errorRequestCancelled;

      case DioExceptionType.connectionError:
        return l10n.errorUnableToConnect;

      case DioExceptionType.badCertificate:
        return l10n.errorCertificate;

      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') == true ||
            error.message?.contains('Network is unreachable') == true) {
          return l10n.errorNoInternet;
        }
        return l10n.errorUnexpected;
    }
  }

  /// Legacy method for backward compatibility
  static String _handleDioExceptionLegacy(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection and try again.';

      case DioExceptionType.badResponse:
        return _handleResponseErrorLegacy(error);

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      case DioExceptionType.connectionError:
        return 'Unable to connect. Please check your internet connection and try again.';

      case DioExceptionType.badCertificate:
        return 'Security certificate error. Please try again later.';

      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') == true ||
            error.message?.contains('Network is unreachable') == true) {
          return 'No internet connection. Please check your network settings.';
        }
        return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Handle HTTP response errors (400, 401, 500, etc.) with localization
  static String _handleResponseError(
    DioException error,
    AppLocalizations l10n,
  ) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    // Try to extract error message from response
    String? serverMessage;
    if (responseData is Map<String, dynamic>) {
      // Handle nested error object
      if (responseData.containsKey('error')) {
        final errorObj = responseData['error'];
        if (errorObj is Map<String, dynamic>) {
          serverMessage = errorObj['message'] as String?;

          // If there are field-specific errors, include them
          if (errorObj.containsKey('fields') &&
              errorObj['fields'] is Map<String, dynamic>) {
            final fields = errorObj['fields'] as Map<String, dynamic>;
            if (fields.isNotEmpty) {
              final fieldErrors = fields.values.whereType<String>().join(', ');
              if (fieldErrors.isNotEmpty) {
                serverMessage = '$serverMessage. $fieldErrors';
              }
            }
          }
        }
      } else if (responseData.containsKey('message')) {
        serverMessage = responseData['message'] as String?;
      }
    }

    // Use server message if available, otherwise use status code defaults
    if (serverMessage != null && serverMessage.isNotEmpty) {
      return serverMessage;
    }

    // Default messages based on status code
    switch (statusCode) {
      case 400:
        return l10n.errorInvalidRequest;
      case 401:
        return l10n.errorSessionExpired;
      case 403:
        return l10n.errorPermissionDenied;
      case 404:
        return l10n.errorNotFound;
      case 429:
        return l10n.errorTooManyRequests;
      case 500:
      case 502:
      case 503:
        return l10n.errorServerError;
      default:
        return l10n.errorGeneric;
    }
  }

  /// Legacy method for backward compatibility
  static String _handleResponseErrorLegacy(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    // Try to extract error message from response
    String? serverMessage;
    if (responseData is Map<String, dynamic>) {
      // Handle nested error object
      if (responseData.containsKey('error')) {
        final errorObj = responseData['error'];
        if (errorObj is Map<String, dynamic>) {
          serverMessage = errorObj['message'] as String?;

          // If there are field-specific errors, include them
          if (errorObj.containsKey('fields') &&
              errorObj['fields'] is Map<String, dynamic>) {
            final fields = errorObj['fields'] as Map<String, dynamic>;
            if (fields.isNotEmpty) {
              final fieldErrors = fields.values.whereType<String>().join(', ');
              if (fieldErrors.isNotEmpty) {
                serverMessage = '$serverMessage. $fieldErrors';
              }
            }
          }
        }
      } else if (responseData.containsKey('message')) {
        serverMessage = responseData['message'] as String?;
      }
    }

    // Use server message if available, otherwise use status code defaults
    if (serverMessage != null && serverMessage.isNotEmpty) {
      return serverMessage;
    }

    // Default messages based on status code
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input and try again.';
      case 401:
        return 'Session expired. Please log in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  /// Extract validation errors from response
  static Map<String, String>? getValidationErrors(dynamic error) {
    if (error is! DioException) return null;

    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('error')) {
      final errorObj = responseData['error'];
      if (errorObj is Map<String, dynamic> &&
          errorObj.containsKey('fields') &&
          errorObj['fields'] is Map<String, dynamic>) {
        final fields = errorObj['fields'] as Map<String, dynamic>;
        return fields.map((key, value) => MapEntry(key, value.toString()));
      }
    }

    return null;
  }
}
