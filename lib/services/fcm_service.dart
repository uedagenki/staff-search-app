import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import '../utils/storage_helper.dart';
import '../models/push_notification.dart';

// トップレベル関数：バックグラウンド メッセージハンドラー
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint('📩 Background message received: ${message.notification?.title}');
  }
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin? _localNotifications;
  
  String? _fcmToken;
  final List<PushNotification> _notifications = [];
  Function(PushNotification)? onNotificationReceived;
  Function(String)? onNotificationTapped;

  // FCM初期化
  Future<void> initialize() async {
    try {
      // バックグラウンド メッセージハンドラーを設定
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 通知権限をリクエスト
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (kDebugMode) {
        debugPrint('🔔 Notification permission status: ${settings.authorizationStatus}');
      }

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // FCMトークンを取得
        _fcmToken = await _firebaseMessaging.getToken();
        if (kDebugMode) {
          debugPrint('🔑 FCM Token: $_fcmToken');
        }

        // トークンを保存
        if (_fcmToken != null) {
          await StorageHelper.setString('fcm_token', _fcmToken!);
        }

        // ローカル通知を初期化
        await _initializeLocalNotifications();

        // フォアグラウンド メッセージリスナー
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // 通知タップリスナー
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTapped);

        // アプリが終了状態から通知タップで起動した場合
        final initialMessage = await _firebaseMessaging.getInitialMessage();
        if (initialMessage != null) {
          _handleNotificationTapped(initialMessage);
        }

        // トークン更新リスナー
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          StorageHelper.setString('fcm_token', newToken);
          if (kDebugMode) {
            debugPrint('🔄 FCM Token refreshed: $newToken');
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to initialize FCM: $e');
      }
    }
  }

  // ローカル通知の初期化
  Future<void> _initializeLocalNotifications() async {
    _localNotifications = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications?.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          onNotificationTapped?.call(details.payload!);
        }
      },
    );

    // Androidの通知チャンネルを作成
    const androidChannel = AndroidNotificationChannel(
      'default_channel',
      'デフォルト通知',
      description: 'アプリの通知を受信します',
      importance: Importance.high,
    );

    await _localNotifications
        ?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  // フォアグラウンド メッセージハンドラー
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      debugPrint('📨 Foreground message received: ${message.notification?.title}');
    }

    // 通知設定を確認
    final settings = await getNotificationSettings();
    if (!settings.enabled) return;

    // PushNotificationオブジェクトを作成
    final notification = PushNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'お知らせ',
      body: message.notification?.body ?? '',
      imageUrl: message.notification?.android?.imageUrl ?? message.notification?.apple?.imageUrl,
      data: message.data,
      receivedAt: DateTime.now(),
      deepLink: message.data['deepLink'] as String?,
    );

    // 通知を保存
    await _saveNotification(notification);

    // コールバックを呼び出し
    onNotificationReceived?.call(notification);

    // ローカル通知を表示
    await _showLocalNotification(notification);
  }

  // 通知タップハンドラー
  void _handleNotificationTapped(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('👆 Notification tapped: ${message.data}');
    }

    final deepLink = message.data['deepLink'] as String?;
    if (deepLink != null) {
      onNotificationTapped?.call(deepLink);
    }
  }

  // ローカル通知を表示
  Future<void> _showLocalNotification(PushNotification notification) async {
    final settings = await getNotificationSettings();

    final androidDetails = AndroidNotificationDetails(
      'default_channel',
      'デフォルト通知',
      channelDescription: 'アプリの通知を受信します',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      playSound: settings.soundEnabled,
      enableVibration: settings.vibrationEnabled,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications?.show(
      notification.id.hashCode,
      notification.title,
      notification.body,
      details,
      payload: notification.deepLink,
    );
  }

  // 通知を保存
  Future<void> _saveNotification(PushNotification notification) async {
    try {
      _notifications.insert(0, notification);
      
      final jsonStr = await StorageHelper.getString('push_notifications');
      List<dynamic> savedNotifications = [];
      
      if (jsonStr != null && jsonStr.isNotEmpty) {
        savedNotifications = jsonDecode(jsonStr);
      }

      savedNotifications.insert(0, notification.toJson());

      // 最新100件のみ保存
      if (savedNotifications.length > 100) {
        savedNotifications = savedNotifications.sublist(0, 100);
      }

      await StorageHelper.setString('push_notifications', jsonEncode(savedNotifications));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save notification: $e');
      }
    }
  }

  // 保存された通知を取得
  Future<List<PushNotification>> getNotifications() async {
    try {
      final jsonStr = await StorageHelper.getString('push_notifications');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonStr);
        return jsonList.map((json) => PushNotification.fromJson(json)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load notifications: $e');
      }
    }
    return [];
  }

  // 通知を既読にする
  Future<void> markAsRead(String notificationId) async {
    try {
      final notifications = await getNotifications();
      final updatedNotifications = notifications.map((n) {
        if (n.id == notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();

      final jsonList = updatedNotifications.map((n) => n.toJson()).toList();
      await StorageHelper.setString('push_notifications', jsonEncode(jsonList));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to mark notification as read: $e');
      }
    }
  }

  // 未読通知数を取得
  Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => !n.isRead).length;
  }

  // 通知設定を取得
  Future<AppNotificationSettings> getNotificationSettings() async {
    try {
      final jsonStr = await StorageHelper.getString('notification_settings');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        return AppNotificationSettings.fromJson(jsonDecode(jsonStr));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load notification settings: $e');
      }
    }
    return AppNotificationSettings();
  }

  // 通知設定を保存
  Future<void> saveNotificationSettings(AppNotificationSettings settings) async {
    await StorageHelper.setString(
      'notification_settings',
      jsonEncode(settings.toJson()),
    );
  }

  // FCMトークンを取得
  String? get fcmToken => _fcmToken;

  // トピックを購読
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      if (kDebugMode) {
        debugPrint('✅ Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to subscribe to topic: $e');
      }
    }
  }

  // トピックの購読を解除
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        debugPrint('✅ Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to unsubscribe from topic: $e');
      }
    }
  }
}
