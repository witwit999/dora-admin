import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'notifications_service.dart';
import 'products_service.dart';
import 'token_storage_service.dart';

/// Token Storage Service Provider
final tokenStorageServiceProvider = Provider<TokenStorageService>((ref) {
  return TokenStorageService();
});

/// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  final tokenStorage = ref.read(tokenStorageServiceProvider);
  return ApiService(tokenStorage);
});

/// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  final tokenStorage = ref.read(tokenStorageServiceProvider);
  return AuthService(apiService, tokenStorage);
});

/// Products Service Provider
final productsServiceProvider = Provider<ProductsService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return ProductsService(apiService);
});

/// Notifications Service Provider
final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return NotificationsService(apiService);
});
