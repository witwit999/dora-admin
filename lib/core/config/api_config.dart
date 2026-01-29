/// API Configuration
/// Contains base URL and all API endpoints
class ApiConfig {
  // Base URL
  static const String baseUrl = 'https://dijajati.shop';

  // API Version
  static const String apiVersion = '/api/v1/';

  // Base API URL
  static const String apiBaseUrl = '$baseUrl$apiVersion';

  // Auth endpoints
  static const String login = 'admin/auth/login';
  static const String refresh = 'admin/auth/refresh';
  static const String logout = 'admin/auth/logout';
  static const String changePassword = 'admin/auth/change-password';

  // Products endpoints
  static const String products = 'admin/products';
  static const String productsSearch = 'admin/products/search';

  // Notifications endpoints
  static const String notifications = 'admin/notifications';

  // Full endpoint URLs - Auth
  static String get loginUrl => '$apiBaseUrl$login';
  static String get refreshUrl => '$apiBaseUrl$refresh';
  static String get logoutUrl => '$apiBaseUrl$logout';
  static String get changePasswordUrl => '$apiBaseUrl$changePassword';

  // Full endpoint URLs - Products
  static String get productsUrl => '$apiBaseUrl$products';
  static String get productsSearchUrl => '$apiBaseUrl$productsSearch';
  static String productByIdUrl(int id) => '$apiBaseUrl$products/$id';
  static String productImageUrl(int id) => '$apiBaseUrl$products/$id/image';
}
