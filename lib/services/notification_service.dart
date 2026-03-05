import 'package:flutter/foundation.dart';
import '../utils/storage_helper.dart';
import 'dart:convert';

// Note: Firebase Cloud Messaging パッケージのバージョン互換性の問題により、
// このファイルは基本構造のみを実装しています。
// 実際の本番環境では firebase_messaging パッケージを追加してください。

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // 通知の種類
  static const String TYPE_NEW_MESSAGE = 'new_message';
  static const String TYPE_LIVE_START = 'live_start';
  static const String TYPE_GIFT_RECEIVED = 'gift_received';
  static const String TYPE_BOOKING_CONFIRMED = 'booking_confirmed';
  static const String TYPE_REVIEW_RECEIVED = 'review_received';

  // 通知設定を取得
  Future<NotificationSettings> getSettings(String userId) async {
    try {
      final settingsJson = await StorageHelper.getString('notification_settings_$userId');
      if (settingsJson != null) {
        return NotificationSettings.fromJson(jsonDecode(settingsJson));
      }
      return NotificationSettings(userId: userId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get notification settings: $e');
      }
      return NotificationSettings(userId: userId);
    }
  }

  // 通知設定を保存
  Future<void> saveSettings(NotificationSettings settings) async {
    try {
      await StorageHelper.setString(
        'notification_settings_${settings.userId}',
        jsonEncode(settings.toJson()),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save notification settings: $e');
      }
    }
  }

  // 通知を送信（デモ版）
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      // 通知設定を確認
      final settings = await getSettings(userId);
      if (!settings.isEnabled) return;
      if (!settings.isTypeEnabled(type)) return;

      // 通知履歴に保存
      final notification = AppNotification(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        title: title,
        body: body,
        type: type,
        data: data,
        timestamp: DateTime.now(),
        isRead: false,
      );

      final notificationsJson = await StorageHelper.getString('notifications_$userId');
      List<AppNotification> notifications = [];
      
      if (notificationsJson != null) {
        final List<dynamic> notificationsData = jsonDecode(notificationsJson);
        notifications = notificationsData
            .map((json) => AppNotification.fromJson(json))
            .toList();
      }

      notifications.insert(0, notification);

      // 最新100件のみ保持
      if (notifications.length > 100) {
        notifications = notifications.sublist(0, 100);
      }

      await StorageHelper.setString(
        'notifications_$userId',
        jsonEncode(notifications.map((n) => n.toJson()).toList()),
      );

      // 実際の本番環境では、ここでFirebase Cloud Messagingを使用して
      // プッシュ通知を送信します
      if (kDebugMode) {
        debugPrint('Notification sent: $title - $body');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to send notification: $e');
      }
    }
  }

  // 通知一覧を取得
  Future<List<AppNotification>> getNotifications(String userId) async {
    try {
      final notificationsJson = await StorageHelper.getString('notifications_$userId');
      if (notificationsJson == null) return [];

      final List<dynamic> notificationsData = jsonDecode(notificationsJson);
      return notificationsData
          .map((json) => AppNotification.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get notifications: $e');
      }
      return [];
    }
  }

  // 通知を既読にする
  Future<void> markAsRead(String userId, String notificationId) async {
    try {
      final notifications = await getNotifications(userId);
      final notification = notifications.firstWhere((n) => n.id == notificationId);
      notification.isRead = true;

      await StorageHelper.setString(
        'notifications_$userId',
        jsonEncode(notifications.map((n) => n.toJson()).toList()),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to mark notification as read: $e');
      }
    }
  }

  // 未読通知数を取得
  Future<int> getUnreadCount(String userId) async {
    try {
      final notifications = await getNotifications(userId);
      return notifications.where((n) => !n.isRead).length;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get unread count: $e');
      }
      return 0;
    }
  }
}

class NotificationSettings {
  final String userId;
  bool isEnabled;
  bool newMessages;
  bool liveStart;
  bool giftReceived;
  bool bookingConfirmed;
  bool reviewReceived;

  NotificationSettings({
    required this.userId,
    this.isEnabled = true,
    this.newMessages = true,
    this.liveStart = true,
    this.giftReceived = true,
    this.bookingConfirmed = true,
    this.reviewReceived = true,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      userId: json['userId'] as String,
      isEnabled: json['isEnabled'] as bool? ?? true,
      newMessages: json['newMessages'] as bool? ?? true,
      liveStart: json['liveStart'] as bool? ?? true,
      giftReceived: json['giftReceived'] as bool? ?? true,
      bookingConfirmed: json['bookingConfirmed'] as bool? ?? true,
      reviewReceived: json['reviewReceived'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'isEnabled': isEnabled,
      'newMessages': newMessages,
      'liveStart': liveStart,
      'giftReceived': giftReceived,
      'bookingConfirmed': bookingConfirmed,
      'reviewReceived': reviewReceived,
    };
  }

  bool isTypeEnabled(String type) {
    switch (type) {
      case NotificationService.TYPE_NEW_MESSAGE:
        return newMessages;
      case NotificationService.TYPE_LIVE_START:
        return liveStart;
      case NotificationService.TYPE_GIFT_RECEIVED:
        return giftReceived;
      case NotificationService.TYPE_BOOKING_CONFIRMED:
        return bookingConfirmed;
      case NotificationService.TYPE_REVIEW_RECEIVED:
        return reviewReceived;
      default:
        return true;
    }
  }
}

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  bool isRead;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    required this.timestamp,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  IconData get icon {
    switch (type) {
      case NotificationService.TYPE_NEW_MESSAGE:
        return Icons.message;
      case NotificationService.TYPE_LIVE_START:
        return Icons.live_tv;
      case NotificationService.TYPE_GIFT_RECEIVED:
        return Icons.card_giftcard;
      case NotificationService.TYPE_BOOKING_CONFIRMED:
        return Icons.calendar_today;
      case NotificationService.TYPE_REVIEW_RECEIVED:
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }
}
