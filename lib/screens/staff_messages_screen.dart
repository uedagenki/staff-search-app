import 'package:flutter/material.dart';
import '../models/message.dart';

class StaffMessagesScreen extends StatefulWidget {
  const StaffMessagesScreen({super.key});

  @override
  State<StaffMessagesScreen> createState() => _StaffMessagesScreenState();
}

class _StaffMessagesScreenState extends State<StaffMessagesScreen> {
  // サンプルメッセージデータ
  final List<Message> _messages = [
    Message(
      id: '1',
      senderId: 'user_001',
      senderName: '山田 太郎',
      senderImage: 'https://i.pravatar.cc/150?img=12',
      content: 'こんにちは!明日の予約について相談したいことがあります。',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
    ),
    Message(
      id: '2',
      senderId: 'user_002',
      senderName: '佐藤 花子',
      senderImage: 'https://i.pravatar.cc/150?img=45',
      content: '先日はありがとうございました!とても良かったです。',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    Message(
      id: '3',
      senderId: 'user_003',
      senderName: '鈴木 一郎',
      senderImage: 'https://i.pravatar.cc/150?img=33',
      content: '予約のキャンセルをお願いします。',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
    ),
    Message(
      id: '4',
      senderId: 'user_004',
      senderName: '田中 美咲',
      senderImage: 'https://i.pravatar.cc/150?img=47',
      content: 'ギフトを送りました!喜んでいただけると嬉しいです。',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _unreadCount = _messages.where((m) => !m.isRead).length;
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
        title: const Text('メッセージ'),
        elevation: 0,
        actions: [
          if (_unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_unreadCount件未読',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _messages.isEmpty
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
                    'メッセージがありません',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: _messages.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final message = _messages[index];
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
              backgroundImage: NetworkImage(message.senderImage),
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
          // チャット画面への遷移
          setState(() {
            message.isRead = true;
            _unreadCount = _messages.where((m) => !m.isRead).length;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${message.senderName}とのチャット画面（開発中）'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }
}
