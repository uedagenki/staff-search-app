import 'dart:async';
import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String senderType; // 'user' or 'staff'
  final String message;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'senderName': senderName,
      'senderType': senderType,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      chatRoomId: json['chatRoomId'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderType: json['senderType'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
    );
  }
}

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final StreamController<List<ChatMessage>> _messageStreamController =
      StreamController<List<ChatMessage>>.broadcast();

  Stream<List<ChatMessage>> get messageStream => _messageStreamController.stream;

  Timer? _pollingTimer;

  void startListening(String chatRoomId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkForNewMessages(chatRoomId);
    });
  }

  void stopListening() {
    _pollingTimer?.cancel();
  }

  void _checkForNewMessages(String chatRoomId) {
    final messages = getMessages(chatRoomId);
    _messageStreamController.add(messages);
  }

  // メッセージ送信
  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String senderName,
    required String senderType,
    required String message,
  }) async {
    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatRoomId: chatRoomId,
      senderId: senderId,
      senderName: senderName,
      senderType: senderType,
      message: message,
      timestamp: DateTime.now(),
      isRead: false,
    );

    final messages = getMessages(chatRoomId);
    messages.add(newMessage);
    _saveMessages(chatRoomId, messages);

    // 通知を送信
    _sendNotification(chatRoomId, senderType, senderName, message);

    // ストリームを更新
    _messageStreamController.add(messages);
  }

  // メッセージ取得
  List<ChatMessage> getMessages(String chatRoomId) {
    try {
      final messagesJson = html.window.localStorage['chat_messages_$chatRoomId'];
      if (messagesJson != null) {
        final List<dynamic> messagesList = json.decode(messagesJson);
        return messagesList.map((m) => ChatMessage.fromJson(m)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading messages: $e');
      }
    }
    return [];
  }

  // メッセージ保存
  void _saveMessages(String chatRoomId, List<ChatMessage> messages) {
    try {
      final messagesJson = json.encode(messages.map((m) => m.toJson()).toList());
      html.window.localStorage['chat_messages_$chatRoomId'] = messagesJson;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving messages: $e');
      }
    }
  }

  // 未読メッセージ数取得
  int getUnreadCount(String chatRoomId, String userType) {
    final messages = getMessages(chatRoomId);
    return messages.where((m) => !m.isRead && m.senderType != userType).length;
  }

  // メッセージを既読にする
  void markAsRead(String chatRoomId, String userType) {
    final messages = getMessages(chatRoomId);
    bool hasChanges = false;
    
    for (var message in messages) {
      if (!message.isRead && message.senderType != userType) {
        hasChanges = true;
      }
    }

    if (hasChanges) {
      final updatedMessages = messages.map((m) {
        if (!m.isRead && m.senderType != userType) {
          return ChatMessage(
            id: m.id,
            chatRoomId: m.chatRoomId,
            senderId: m.senderId,
            senderName: m.senderName,
            senderType: m.senderType,
            message: m.message,
            timestamp: m.timestamp,
            isRead: true,
          );
        }
        return m;
      }).toList();
      
      _saveMessages(chatRoomId, updatedMessages);
    }
  }

  // 通知送信
  void _sendNotification(String chatRoomId, String senderType, String senderName, String message) {
    try {
      final notification = {
        'chatRoomId': chatRoomId,
        'senderType': senderType,
        'senderName': senderName,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // 受信者タイプを判定
      final recipientType = senderType == 'user' ? 'staff' : 'user';
      
      // 通知リストを取得
      final notificationsJson = html.window.localStorage['chat_notifications_$recipientType'] ?? '[]';
      final List<dynamic> notifications = json.decode(notificationsJson);
      
      notifications.add(notification);
      
      // 最新50件のみ保持
      if (notifications.length > 50) {
        notifications.removeRange(0, notifications.length - 50);
      }
      
      html.window.localStorage['chat_notifications_$recipientType'] = json.encode(notifications);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error sending notification: $e');
      }
    }
  }

  // 通知取得
  List<Map<String, dynamic>> getNotifications(String userType) {
    try {
      final notificationsJson = html.window.localStorage['chat_notifications_$userType'] ?? '[]';
      final List<dynamic> notifications = json.decode(notificationsJson);
      return notifications.cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading notifications: $e');
      }
      return [];
    }
  }

  // 通知クリア
  void clearNotifications(String userType, String chatRoomId) {
    try {
      final notifications = getNotifications(userType);
      final filtered = notifications.where((n) => n['chatRoomId'] != chatRoomId).toList();
      html.window.localStorage['chat_notifications_$userType'] = json.encode(filtered);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error clearing notifications: $e');
      }
    }
  }

  // チャットルーム作成
  String createChatRoom(String userId, String staffId) {
    return 'chat_${userId}_$staffId';
  }

  void dispose() {
    _pollingTimer?.cancel();
    _messageStreamController.close();
  }
}
