import '../config/api_config.dart';
import '../../shared/models/notification_model.dart';
import '../../shared/models/pagination_model.dart';
import 'api_service.dart';

/// Notifications Service for notification-related API operations
class NotificationsService {
  final ApiService _apiService;

  NotificationsService(this._apiService);

  /// Get paginated list of notifications
  Future<PaginatedNotifications> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiService.get(
      ApiConfig.notifications,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    return PaginatedNotifications.fromJson(response.data as Map<String, dynamic>);
  }

  /// Send a new notification
  /// If scheduledAt is provided, the notification will be scheduled for that time
  /// Otherwise, it will be sent immediately
  Future<NotificationModel> sendNotification({
    required String message,
    DateTime? scheduledAt,
  }) async {
    final data = <String, dynamic>{
      'message': message,
    };

    if (scheduledAt != null) {
      data['scheduledAt'] = scheduledAt.toIso8601String();
    }

    final response = await _apiService.post(
      ApiConfig.notifications,
      data: data,
    );

    return NotificationModel.fromJson(response.data as Map<String, dynamic>);
  }
}
