import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dora_admin/l10n/app_localizations.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/auth_provider.dart';
import './language_picker.dart';

class MainScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const MainScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final routerState = GoRouterState.of(context);
    final currentLocation = routerState.matchedLocation;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              AppConstants.logoTransparent,
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        actions: actions,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // Drawer header
            DrawerHeader(
              decoration: const BoxDecoration(color: AppTheme.primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    AppConstants.logoTransparent,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  if (user != null) ...[
                    Text(
                      user.name ?? l10n.drawerAdminId(user.adminId),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email ?? user.phone ?? l10n.drawerAdmin,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Navigation items
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(l10n.drawerProducts),
              selected: currentLocation == AppConstants.productsRoute,
              onTap: () {
                context.pop();
                if (currentLocation != AppConstants.productsRoute) {
                  context.go(AppConstants.productsRoute);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: Text(l10n.drawerNotifications),
              selected: currentLocation == AppConstants.notificationsRoute,
              onTap: () {
                context.pop();
                if (currentLocation != AppConstants.notificationsRoute) {
                  context.go(AppConstants.notificationsRoute);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_reset_outlined),
              title: Text(l10n.drawerChangePassword),
              selected: currentLocation == AppConstants.changePasswordRoute,
              onTap: () {
                context.pop();
                if (currentLocation != AppConstants.changePasswordRoute) {
                  context.go(AppConstants.changePasswordRoute);
                }
              },
            ),

            const Divider(),

            // Language picker
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.language),
              onTap: () {
                LanguagePicker.show(context);
              },
            ),

            const Divider(),

            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: AppTheme.errorColor),
              title: Text(
                l10n.drawerLogout,
                style: const TextStyle(color: AppTheme.errorColor),
              ),
              onTap: () async {
                context.pop();
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go(AppConstants.loginRoute);
                }
              },
            ),
          ],
        ),
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
