import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/change_password_screen.dart';
import '../features/products/products_list_screen.dart';
import '../features/products/product_form_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/notifications/send_notification_screen.dart';
import '../shared/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppConstants.splashRoute,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isOnSplash = state.matchedLocation == AppConstants.splashRoute;
      final isOnLogin = state.matchedLocation == AppConstants.loginRoute;

      // If on splash, allow it
      if (isOnSplash) return null;

      // If not authenticated and not on login, redirect to login
      if (!isAuthenticated && !isOnLogin) {
        return AppConstants.loginRoute;
      }

      // If authenticated and on login, redirect to home
      if (isAuthenticated && isOnLogin) {
        return AppConstants.productsRoute;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppConstants.splashRoute,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppConstants.loginRoute,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.productsRoute,
        name: 'products',
        builder: (context, state) => const ProductsListScreen(),
      ),
      GoRoute(
        path: AppConstants.productNewRoute,
        name: 'product-new',
        builder: (context, state) => const ProductFormScreen(),
      ),
      GoRoute(
        path: AppConstants.productEditRoute,
        name: 'product-edit',
        builder: (context, state) {
          final idString = state.pathParameters['id']!;
          final id = int.tryParse(idString);
          return ProductFormScreen(productId: id);
        },
      ),
      GoRoute(
        path: AppConstants.notificationsRoute,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppConstants.sendNotificationRoute,
        name: 'send-notification',
        builder: (context, state) => const SendNotificationScreen(),
      ),
      GoRoute(
        path: AppConstants.changePasswordRoute,
        name: 'change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
    ],
  );
});
