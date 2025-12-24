enum NotificationType {
  message,
  booking,
  tip,
  review,
  system,
}

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? imageUrl;
  final DateTime timestamp;
  bool isRead;  // 変更可能にする
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.timestamp,
    required this.isRead,
    this.data,
  });

  String getTypeIcon() {
    switch (type) {
      case NotificationType.message:
        return '💬';
      case NotificationType.booking:
        return '📅';
      case NotificationType.tip:
        return '💰';
      case NotificationType.review:
        return '⭐';
      case NotificationType.system:
        return '🔔';
    }
  }
}
