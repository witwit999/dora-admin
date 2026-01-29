import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/notifications_service.dart';
import '../../core/services/service_providers.dart';
import '../models/notification_model.dart';
import '../models/pagination_model.dart';

// Notifications state
class NotificationsState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int totalItems;

  NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
  });

  bool get hasMore => currentPage < totalPages;

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalItems,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
    );
  }
}

// Notifications notifier
class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final NotificationsService _notificationsService;

  NotificationsNotifier(this._notificationsService) : super(NotificationsState());

  /// Load notifications from API (first page)
  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _notificationsService.getNotifications(
        page: 1,
        limit: 20,
      );

      final notifications = _parseNotifications(result);

      state = state.copyWith(
        notifications: notifications,
        isLoading: false,
        currentPage: result.page.page,
        totalPages: result.page.totalPages,
        totalItems: result.page.totalItems,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load more notifications (next page) for infinite scroll
  Future<void> loadMoreNotifications() async {
    if (!state.hasMore || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final nextPage = state.currentPage + 1;
      final result = await _notificationsService.getNotifications(
        page: nextPage,
        limit: 20,
      );

      final newNotifications = _parseNotifications(result);

      state = state.copyWith(
        notifications: [...state.notifications, ...newNotifications],
        isLoadingMore: false,
        currentPage: result.page.page,
        totalPages: result.page.totalPages,
        totalItems: result.page.totalItems,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Send a new notification
  Future<bool> sendNotification({
    required String message,
    DateTime? scheduledAt,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final notification = await _notificationsService.sendNotification(
        message: message,
        scheduledAt: scheduledAt,
      );

      // Add new notification to the beginning of the list
      state = state.copyWith(
        notifications: [notification, ...state.notifications],
        isLoading: false,
        totalItems: state.totalItems + 1,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Parse notifications from API response
  List<NotificationModel> _parseNotifications(PaginatedNotifications result) {
    return result.items
        .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Notifications provider
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  final notificationsService = ref.read(notificationsServiceProvider);
  return NotificationsNotifier(notificationsService);
});
