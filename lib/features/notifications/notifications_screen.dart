import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dora_admin/l10n/app_localizations.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/notification_model.dart';
import '../../shared/providers/notifications_provider.dart';
import '../../shared/widgets/main_scaffold.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load notifications when screen is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).loadNotifications();
    });

    // Add scroll listener for infinite scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when near bottom
      ref.read(notificationsProvider.notifier).loadMoreNotifications();
    }
  }

  Color _getStatusColor(NotificationStatus status) {
    switch (status) {
      case NotificationStatus.sent:
        return Colors.green;
      case NotificationStatus.scheduled:
      case NotificationStatus.pending:
        return Colors.orange;
      case NotificationStatus.failed:
        return AppTheme.errorColor;
    }
  }

  String _getStatusText(NotificationStatus status, AppLocalizations l10n) {
    switch (status) {
      case NotificationStatus.sent:
        return l10n.notificationsStatusSent;
      case NotificationStatus.scheduled:
        return l10n.notificationsStatusScheduled;
      case NotificationStatus.pending:
        return l10n.notificationsStatusPending;
      case NotificationStatus.failed:
        return l10n.notificationsStatusFailed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationsState = ref.watch(notificationsProvider);
    final notifications = notificationsState.notifications;
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return MainScaffold(
      title: l10n.notificationsTitle,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppConstants.sendNotificationRoute),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Error banner
          if (notificationsState.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: AppTheme.errorColor.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.errorColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notificationsState.error!,
                      style: const TextStyle(color: AppTheme.errorColor),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(notificationsProvider.notifier).clearError();
                      ref.read(notificationsProvider.notifier).loadNotifications();
                    },
                    child: Text(l10n.commonRetry),
                  ),
                ],
              ),
            ),

          // Main content
          Expanded(
            child: notificationsState.isLoading && notifications.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.notificationsNoNotificationsYet,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.notificationsAddFirst,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade500,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await ref.read(notificationsProvider.notifier).loadNotifications();
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: notifications.length + (notificationsState.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Loading indicator at the bottom
                            if (index == notifications.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

                            final notification = notifications[index];
                            return _NotificationCard(
                              notification: notification,
                              dateFormat: dateFormat,
                              timeFormat: timeFormat,
                              statusColor: _getStatusColor(notification.status),
                              statusText: _getStatusText(notification.status, l10n),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  final NotificationModel notification;
  final DateFormat dateFormat;
  final DateFormat timeFormat;
  final Color statusColor;
  final String statusText;

  const _NotificationCard({
    required this.notification,
    required this.dateFormat,
    required this.timeFormat,
    required this.statusColor,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.message,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      
                      // Scheduled time or sent time
                      if (notification.isScheduled && notification.scheduledAt != null)
                        _buildInfoRow(
                          context,
                          Icons.schedule,
                          l10n.notificationsScheduledFor(
                            dateFormat.format(notification.scheduledAt!),
                            timeFormat.format(notification.scheduledAt!),
                          ),
                        ),
                      
                      if (notification.sentAt != null)
                        _buildInfoRow(
                          context,
                          Icons.send,
                          l10n.notificationsSentOn(
                            dateFormat.format(notification.sentAt!),
                            timeFormat.format(notification.sentAt!),
                          ),
                        ),
                      
                      // Created date
                      _buildInfoRow(
                        context,
                        Icons.access_time,
                        l10n.notificationsCreated(dateFormat.format(notification.createdAt)),
                      ),
                      
                      // Error message for failed notifications
                      if (notification.status == NotificationStatus.failed &&
                          notification.errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppTheme.errorColor,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  notification.errorMessage!,
                                  style: const TextStyle(
                                    color: AppTheme.errorColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
