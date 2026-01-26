class AppConstants {
  // App info
  static const String appName = 'Dora Admin';
  
  // Asset paths
  static const String logoTransparent = 'Assets/logo_rransperant_admin.png';
  static const String logoWhiteBackground = 'Assets/Logo_white_background_admin.png';
  static const String appIcon = 'Assets/app_icon_admin.png';
  
  // Splash screen
  static const int splashDuration = 2; // seconds
  
  // Routes
  static const String splashRoute = '/splash';
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String productsRoute = '/products';
  static const String productNewRoute = '/products/new';
  static const String productEditRoute = '/products/:id/edit';
  static const String notificationsRoute = '/notifications';
  static const String sendNotificationRoute = '/notifications/send';
  static const String changePasswordRoute = '/change-password';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxProductNameLength = 100;
  static const int maxDescriptionLength = 500;
  static const int maxNotificationMessageLength = 500;
}
