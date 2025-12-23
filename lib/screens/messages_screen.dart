import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/message.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  // サンプルメッセージデータ
  final List<Message> _latestMessages = [
    Message(
      id: '1',
      senderId: '1',
      senderName: '佐藤 健',
      senderImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      content: '了解しました。明日の10時でお願いします。',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
    ),
    Message(
      id: '2',
      senderId: '2',
      senderName: '田中 美咲',
      senderImage: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
      content: 'ありがとうございます！また次回もよろしくお願いします。',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    Message(
      id: '3',
      senderId: '3',
      senderName: '山田 太郎',
      senderImage: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      content: '物件の内覧日程について相談させてください。',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
    ),
    Message(
      id: '4',
      senderId: '6',
      senderName: '伊藤 麻衣',
      senderImage: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
      content: '次回のご予約はいかがでしょうか？',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  int get _unreadCount => _latestMessages.where((m) => !m.isRead).length;

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
        title: const Text('メッセージ'),
        elevation: 0,
      ),
      body: _latestMessages.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.message_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'メッセージはありません',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: _latestMessages.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final message = _latestMessages[index];
                return _buildMessageTile(message);
              },
            ),
    );
  }

  Widget _buildMessageTile(Message message) {
    return Container(
      color: message.isRead ? Colors.white : Colors.blue[50],
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: CachedNetworkImageProvider(message.senderImage),
            ),
            if (!message.isRead)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                message.senderName,
                style: TextStyle(
                  fontWeight: message.isRead ? FontWeight.normal : FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              _formatTimestamp(message.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            message.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: message.isRead ? Colors.grey[600] : Colors.black87,
              fontWeight: message.isRead ? FontWeight.normal : FontWeight.w500,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                staffId: message.senderId,
                staffName: message.senderName,
                staffImage: message.senderImage,
              ),
            ),
          );
        },
      ),
    );
  }
}
