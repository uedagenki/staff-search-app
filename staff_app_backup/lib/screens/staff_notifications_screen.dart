import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';

class StaffNotificationsScreen extends StatefulWidget {
  const StaffNotificationsScreen({super.key});

  @override
  State<StaffNotificationsScreen> createState() => _StaffNotificationsScreenState();
}

class _StaffNotificationsScreenState extends State<StaffNotificationsScreen> {
  List<StaffNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notificationsJson = html.window.localStorage['staff_notifications'];
      if (notificationsJson != null && notificationsJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(notificationsJson);
        final notifications = decoded.map((data) {
          return StaffNotification(
            id: data['id'] ?? '',
            type: data['type'] ?? 'message',
            title: data['title'] ?? '',
            message: data['message'] ?? '',
            fromUserId: data['fromUserId'] ?? '',
            fromUserName: data['fromUserName'] ?? '',
            timestamp: DateTime.parse(data['timestamp']),
            isRead: data['isRead'] ?? false,
            actionData: data['actionData'],
          );
        }).toList();

        if (mounted) {
          setState(() {
            _notifications = notifications;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index >= 0) {
        _notifications[index] = StaffNotification(
          id: _notifications[index].id,
          type: _notifications[index].type,
          title: _notifications[index].title,
          message: _notifications[index].message,
          fromUserId: _notifications[index].fromUserId,
          fromUserName: _notifications[index].fromUserName,
          timestamp: _notifications[index].timestamp,
          isRead: true,
          actionData: _notifications[index].actionData,
        );

        final notificationsData = _notifications.map((n) => {
          'id': n.id,
          'type': n.type,
          'title': n.title,
          'message': n.message,
          'fromUserId': n.fromUserId,
          'fromUserName': n.fromUserName,
          'timestamp': n.timestamp.toIso8601String(),
          'isRead': n.isRead,
          'actionData': n.actionData,
        }).toList();

        html.window.localStorage['staff_notifications'] = json.encode(notificationsData);
        
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = StaffNotification(
          id: _notifications[i].id,
          type: _notifications[i].type,
          title: _notifications[i].title,
          message: _notifications[i].message,
          fromUserId: _notifications[i].fromUserId,
          fromUserName: _notifications[i].fromUserName,
          timestamp: _notifications[i].timestamp,
          isRead: true,
          actionData: _notifications[i].actionData,
        );
      }

      final notificationsData = _notifications.map((n) => {
        'id': n.id,
        'type': n.type,
        'title': n.title,
        'message': n.message,
        'fromUserId': n.fromUserId,
        'fromUserName': n.fromUserName,
        'timestamp': n.timestamp.toIso8601String(),
        'isRead': n.isRead,
        'actionData': n.actionData,
      }).toList();

      html.window.localStorage['staff_notifications'] = json.encode(notificationsData);
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
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

  IconData _getIconForType(String type) {
    switch (type) {
      case 'message':
        return Icons.message;
      case 'review':
        return Icons.star;
      case 'follow':
        return Icons.person_add;
      case 'booking':
        return Icons.calendar_today;
      case 'tip':
        return Icons.monetization_on;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'message':
        return Colors.blue;
      case 'review':
        return Colors.amber;
      case 'follow':
        return Colors.green;
      case 'booking':
        return Colors.purple;
      case 'tip':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('通知'),
            if (unreadCount > 0)
              Text(
                '$unreadCount件の未読通知',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('すべて既読'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '通知はまだありません',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
                ),
    );
  }

  Widget _buildNotificationCard(StaffNotification notification) {
    return InkWell(
      onTap: () {
        _markAsRead(notification.id);
        // TODO: Navigate to relevant screen based on notification type
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? null : Colors.blue[50],
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getColorForType(notification.type).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForType(notification.type),
                color: _getColorForType(notification.type),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: notification.isRead 
                                ? FontWeight.w500 
                                : FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(notification.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (notification.fromUserName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'from ${notification.fromUserName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 8, top: 8),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class StaffNotification {
  final String id;
  final String type; // message, review, follow, booking, tip
  final String title;
  final String message;
  final String fromUserId;
  final String fromUserName;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? actionData;

  StaffNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.fromUserId,
    required this.fromUserName,
    required this.timestamp,
    required this.isRead,
    this.actionData,
  });
}
