class NotificationModel {
  final int id;
  final String message;
  final DateTime? scheduledAt;
  final DateTime? sentAt;
  final DateTime createdAt;
  final String? errorMessage;
  final NotificationStatus status;

  NotificationModel({
    required this.id,
    required this.message,
    this.scheduledAt,
    this.sentAt,
    required this.createdAt,
    this.errorMessage,
    this.status = NotificationStatus.pending,
  });

  /// Check if notification is scheduled
  bool get isScheduled => scheduledAt != null;

  /// Check if notification is ready to send
  bool get isReadyToSend {
    if (!isScheduled) return true;
    if (scheduledAt == null) return false;
    return DateTime.now().isAfter(scheduledAt!) ||
        DateTime.now().isAtSameMomentAs(scheduledAt!);
  }

  // Copy with method for updates
  NotificationModel copyWith({
    int? id,
    String? message,
    DateTime? scheduledAt,
    DateTime? sentAt,
    DateTime? createdAt,
    String? errorMessage,
    NotificationStatus? status,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      message: message ?? this.message,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      sentAt: sentAt ?? this.sentAt,
      createdAt: createdAt ?? this.createdAt,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
    );
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'sentAt': sentAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'errorMessage': errorMessage,
      'status': status.value,
    };
  }

  // Create from JSON API response
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      message: json['message'] as String,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'] as String)
          : null,
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      errorMessage: json['errorMessage'] as String?,
      status: NotificationStatus.fromValue(json['status'] as String),
    );
  }
}

enum NotificationStatus {
  scheduled('SCHEDULED'),
  sent('SENT'),
  failed('FAILED'),
  pending('PENDING');

  final String value;
  const NotificationStatus(this.value);

  static NotificationStatus fromValue(String value) {
    return NotificationStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationStatus.pending,
    );
  }
}
