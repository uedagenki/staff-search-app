import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/notification.dart';
import 'chat_screen.dart';
import 'bookings_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<AppNotification> _notifications = [
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
      isRead: true,
    ),
    AppNotification(
      id: '4',
      type: NotificationType.review,
      title: '新しいレビュー',
      body: '鈴木 花子さんから5つ星のレビューをいただきました',
      imageUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
    ),
    AppNotification(
      id: '5',
      type: NotificationType.system,
      title: 'アプリの新機能',
      body: 'お気に入り機能が追加されました！気になるスタッフをお気に入り登録しましょう。',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    AppNotification(
      id: '6',
      type: NotificationType.message,
      title: '伊藤 麻衣さんからメッセージ',
      body: '次回のご予約はいかがでしょうか？',
      imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  int get _unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知'),
        elevation: 0,
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('すべて既読'),
            ),
        ],
      ),
      body: _notifications.isEmpty
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
          : ListView.separated(
              itemCount: _notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return _buildNotificationItem(_notifications[index]);
              },
            ),
    );
  }

  Widget _buildNotificationItem(AppNotification notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          _notifications.remove(notification);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('通知を削除しました'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        color: notification.isRead ? Colors.white : Colors.blue[50],
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: notification.imageUrl != null
              ? CircleAvatar(
                  radius: 28,
                  backgroundImage: CachedNetworkImageProvider(
                    notification.imageUrl!,
                  ),
                )
              : CircleAvatar(
                  radius: 28,
                  backgroundColor: _getTypeColor(notification.type),
                  child: Text(
                    notification.getTypeIcon(),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: notification.isRead
                        ? FontWeight.normal
                        : FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(notification.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          onTap: () {
            _markAsRead(notification);
            _handleNotificationTap(notification);
          },
        ),
      ),
    );
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.message:
        return Colors.blue[100]!;
      case NotificationType.booking:
        return Colors.green[100]!;
      case NotificationType.tip:
        return Colors.amber[100]!;
      case NotificationType.review:
        return Colors.orange[100]!;
      case NotificationType.system:
        return Colors.purple[100]!;
    }
  }

  void _markAsRead(AppNotification notification) {
    if (!notification.isRead) {
      setState(() {
        final index = _notifications.indexOf(notification);
        _notifications[index] = AppNotification(
          id: notification.id,
          type: notification.type,
          title: notification.title,
          body: notification.body,
          imageUrl: notification.imageUrl,
          timestamp: notification.timestamp,
          isRead: true,
          data: notification.data,
        );
      });
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = AppNotification(
            id: _notifications[i].id,
            type: _notifications[i].type,
            title: _notifications[i].title,
            body: _notifications[i].body,
            imageUrl: _notifications[i].imageUrl,
            timestamp: _notifications[i].timestamp,
            isRead: true,
            data: _notifications[i].data,
          );
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('すべての通知を既読にしました'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    // 通知を既読にする
    setState(() {
      notification.isRead = true;
    });

    switch (notification.type) {
      case NotificationType.message:
        // メッセージ画面へ遷移
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatScreen(
              staffId: 'sample_staff',
              staffName: 'サンプルスタッフ',
              staffImageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
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
        // システム通知は特にアクションなし
        break;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'たった今';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays == 1) {
      return '昨日';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return '${time.month}/${time.day}';
    }
  }
}
