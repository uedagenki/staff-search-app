import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:html' as html;
import 'dart:convert';
import '../models/notification.dart';
import 'chat_screen.dart';
import 'bookings_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final notificationsJson = html.window.localStorage['notifications'];
      
      if (notificationsJson != null && notificationsJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(notificationsJson);
        setState(() {
          _notifications = decoded.map((e) {
            return AppNotification(
              id: e['id'],
              type: NotificationType.values.firstWhere(
                (t) => t.toString() == e['type'],
                orElse: () => NotificationType.system,
              ),
              title: e['title'],
              body: e['body'],
              imageUrl: e['imageUrl'],
              timestamp: DateTime.parse(e['timestamp']),
              isRead: e['isRead'] ?? false,
            );
          }).toList();
          _isLoading = false;
        });
      } else {
        // 初回起動時のサンプル通知
        _notifications = [
          AppNotification(
            id: '1',
            type: NotificationType.message,
            title: '佐藤 健さんからメッセージ',
            body: '了解しました。明日の10時でお願いします。',
            imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
            timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
            isRead: false,
          ),
          AppNotification(
            id: '2',
            type: NotificationType.booking,
            title: '予約が確定しました',
            body: '田中 美咲さんとの予約が確定しました。明日14:00〜',
            imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            isRead: false,
          ),
          AppNotification(
            id: '3',
            type: NotificationType.tip,
            title: 'チップを受け取りました',
            body: '山田 太郎さんから1,000円のチップを受け取りました',
            imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
            isRead: false,
          ),
        ];
        _saveNotifications();
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load notifications: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveNotifications() async {
    try {
      final notificationsData = _notifications.map((n) {
        return {
          'id': n.id,
          'type': n.type.toString(),
          'title': n.title,
          'body': n.body,
          'imageUrl': n.imageUrl,
          'timestamp': n.timestamp.toIso8601String(),
          'isRead': n.isRead,
        };
      }).toList();
      
      html.window.localStorage['notifications'] = json.encode(notificationsData);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save notifications: $e');
      }
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });
    _saveNotifications();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('すべての通知を既読にしました'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    // 通知を既読にする
    setState(() {
      notification.isRead = true;
    });
    _saveNotifications();

    switch (notification.type) {
      case NotificationType.message:
        // メッセージ画面へ遷移
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatScreen(
              staffId: 'sample_staff',
              staffName: 'サンプルスタッフ',
              staffImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
            ),
          ),
        );
        break;
      case NotificationType.booking:
        // 予約一覧画面へ遷移
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BookingsScreen(),
          ),
        );
        break;
      case NotificationType.tip:
        // チップ履歴画面（ウォレット機能として実装）
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('チップ履歴はプロフィール → ウォレットから確認できます'),
            duration: Duration(seconds: 3),
          ),
        );
        break;
      case NotificationType.review:
        // レビュー詳細（プロフィールからアクセス可能）
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('レビュー詳細はプロフィール → レビュー管理から確認できます'),
            duration: Duration(seconds: 3),
          ),
        );
        break;
      case NotificationType.system:
        // システム通知は画面遷移なし
        break;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('通知'),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        elevation: 0,
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('すべて既読'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '通知がありません',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.separated(
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return ListTile(
                        onTap: () => _handleNotificationTap(notification),
                        leading: Stack(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: notification.isRead
                                    ? Colors.grey[200]
                                    : Colors.purple[50],
                                shape: BoxShape.circle,
                              ),
                              child: notification.imageUrl != null
                                  ? ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: notification.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) =>
                                            Center(
                                          child: Text(
                                            notification.getTypeIcon(),
                                            style: const TextStyle(fontSize: 24),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        notification.getTypeIcon(),
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                            ),
                            if (!notification.isRead)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              notification.body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: notification.isRead
                                    ? Colors.grey[600]
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTimestamp(notification.timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        trailing: !notification.isRead
                            ? const Icon(
                                Icons.circle,
                                size: 8,
                                color: Colors.blue,
                              )
                            : null,
                      );
                    },
                  ),
                ),
    );
  }
}
