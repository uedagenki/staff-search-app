class PushNotification {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  final DateTime receivedAt;
  final bool isRead;
  final String? deepLink; // アプリ内の特定画面へのリンク

  PushNotification({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.data,
    required this.receivedAt,
    this.isRead = false,
    this.deepLink,
  });

  factory PushNotification.fromJson(Map<String, dynamic> json) {
    return PushNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      imageUrl: json['imageUrl'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      receivedAt: DateTime.parse(json['receivedAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      deepLink: json['deepLink'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'data': data,
      'receivedAt': receivedAt.toIso8601String(),
      'isRead': isRead,
      'deepLink': deepLink,
    };
  }

  PushNotification copyWith({
    String? id,
    String? title,
    String? body,
    String? imageUrl,
    Map<String, dynamic>? data,
    DateTime? receivedAt,
    bool? isRead,
    String? deepLink,
  }) {
    return PushNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
      receivedAt: receivedAt ?? this.receivedAt,
      isRead: isRead ?? this.isRead,
      deepLink: deepLink ?? this.deepLink,
    );
  }
}

class AppNotificationSettings {
  final bool enabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool newFollowerEnabled;
  final bool newMessageEnabled;
  final bool newGiftEnabled;
  final bool liveStartEnabled;
  final bool bookingReminderEnabled;

  AppNotificationSettings({
    this.enabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.newFollowerEnabled = true,
    this.newMessageEnabled = true,
    this.newGiftEnabled = true,
    this.liveStartEnabled = true,
    this.bookingReminderEnabled = true,
  });

  factory AppNotificationSettings.fromJson(Map<String, dynamic> json) {
    return AppNotificationSettings(
      enabled: json['enabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      newFollowerEnabled: json['newFollowerEnabled'] as bool? ?? true,
      newMessageEnabled: json['newMessageEnabled'] as bool? ?? true,
      newGiftEnabled: json['newGiftEnabled'] as bool? ?? true,
      liveStartEnabled: json['liveStartEnabled'] as bool? ?? true,
      bookingReminderEnabled: json['bookingReminderEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'newFollowerEnabled': newFollowerEnabled,
      'newMessageEnabled': newMessageEnabled,
      'newGiftEnabled': newGiftEnabled,
      'liveStartEnabled': liveStartEnabled,
      'bookingReminderEnabled': bookingReminderEnabled,
    };
  }

  AppNotificationSettings copyWith({
    bool? enabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? newFollowerEnabled,
    bool? newMessageEnabled,
    bool? newGiftEnabled,
    bool? liveStartEnabled,
    bool? bookingReminderEnabled,
  }) {
    return AppNotificationSettings(
      enabled: enabled ?? this.enabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      newFollowerEnabled: newFollowerEnabled ?? this.newFollowerEnabled,
      newMessageEnabled: newMessageEnabled ?? this.newMessageEnabled,
      newGiftEnabled: newGiftEnabled ?? this.newGiftEnabled,
      liveStartEnabled: liveStartEnabled ?? this.liveStartEnabled,
      bookingReminderEnabled: bookingReminderEnabled ?? this.bookingReminderEnabled,
    );
  }
}
