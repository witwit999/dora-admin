import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dora_admin/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'shared/providers/auth_provider.dart';
import 'core/constants/app_constants.dart';
import 'core/providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize shared preferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    // Listen to auth state changes - must be in build method
    ref.listen<AuthState>(authProvider, (previous, next) {
      // Use a post-frame callback to ensure router is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final currentRouter = ref.read(routerProvider);
          final currentLocation =
              currentRouter.routerDelegate.currentConfiguration.uri.path;

          // If user just logged in and is on login screen, navigate to products
          if (next.isAuthenticated &&
              previous?.isAuthenticated != true &&
              (currentLocation == AppConstants.loginRoute ||
                  currentLocation.isEmpty ||
                  currentLocation == '/')) {
            currentRouter.go(AppConstants.productsRoute);
          }

          // If user just logged out and is not on login/splash, navigate to login
          if (!next.isAuthenticated &&
              previous?.isAuthenticated == true &&
              currentLocation != AppConstants.loginRoute &&
              currentLocation != AppConstants.splashRoute) {
            currentRouter.go(AppConstants.loginRoute);
          }
        } catch (e) {
          // Router might not be ready yet, ignore
        }
      });
    });

    return DismissKeyboard(
      child: MaterialApp.router(
        title: 'Dora Admin',
        debugShowCheckedModeBanner: false,

        // Localization configuration
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocales.supported,

        // Theme with locale-specific font
        theme: AppTheme.getThemeForLocale(locale),

        routerConfig: router,
      ),
    );
  }
}

class DismissKeyboard extends StatelessWidget {
  final Widget child;

  const DismissKeyboard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside text fields
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
