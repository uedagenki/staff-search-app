import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../staff_chat_screen.dart';
import '../../models/chat_message.dart';

class StaffMessagesScreen extends StatefulWidget {
  const StaffMessagesScreen({super.key});

  @override
  State<StaffMessagesScreen> createState() => _StaffMessagesScreenState();
}

class _StaffMessagesScreenState extends State<StaffMessagesScreen> {
  final List<ChatRoom> _chatRooms = [
    ChatRoom(
      id: 'room_001',
      userId: 'user_001',
      userName: '山田 太郎',
      userImage: 'https://i.pravatar.cc/150?img=12',
      lastMessage: 'ありがとうございました！また利用します',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 2,
      isOnline: true,
    ),
    ChatRoom(
      id: 'room_002',
      userId: 'user_002',
      userName: '佐藤 花子',
      userImage: 'https://i.pravatar.cc/150?img=45',
      lastMessage: '予約の変更は可能でしょうか？',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      unreadCount: 0,
      isOnline: false,
    ),
    ChatRoom(
      id: 'room_003',
      userId: 'user_003',
      userName: '鈴木 一郎',
      userImage: 'https://i.pravatar.cc/150?img=33',
      lastMessage: '詳細について教えてください',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
      unreadCount: 1,
      isOnline: true,
    ),
    ChatRoom(
      id: 'room_004',
      userId: 'user_004',
      userName: '田中 美咲',
      userImage: 'https://i.pravatar.cc/150?img=23',
      lastMessage: '承知しました',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      isOnline: false,
    ),
    ChatRoom(
      id: 'room_005',
      userId: 'user_005',
      userName: '伊藤 健太',
      userImage: 'https://i.pravatar.cc/150?img=68',
      lastMessage: 'よろしくお願いします',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
      unreadCount: 0,
      isOnline: false,
    ),
  ];

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

  @override
  Widget build(BuildContext context) {
    final unreadCount = _chatRooms.where((room) => room.unreadCount > 0).length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('メッセージ'),
            if (unreadCount > 0)
              Text(
                '$unreadCount件の未読メッセージ',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        elevation: 0,
      ),
      body: _chatRooms.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'メッセージはまだありません',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _chatRooms.length,
              itemBuilder: (context, index) {
                final room = _chatRooms[index];
                return _buildChatRoomCard(room);
              },
            ),
    );
  }

  Widget _buildChatRoomCard(ChatRoom room) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StaffChatScreen(chatRoom: room),
          ),
        ).then((_) {
          // チャットから戻ってきたら未読カウントをリセット
          if (mounted) {
            setState(() {
              final index = _chatRooms.indexWhere((r) => r.id == room.id);
              if (index != -1) {
                _chatRooms[index] = ChatRoom(
                  id: room.id,
                  userId: room.userId,
                  userName: room.userName,
                  userImage: room.userImage,
                  lastMessage: room.lastMessage,
                  lastMessageTime: room.lastMessageTime,
                  unreadCount: 0,
                  isOnline: room.isOnline,
                );
              }
            });
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: room.unreadCount > 0 ? Colors.blue[50] : null,
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: [
            // プロフィール画像
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: CachedNetworkImage(
                    imageUrl: room.userImage,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                if (room.isOnline)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // メッセージ情報
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        room.userName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: room.unreadCount > 0
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatTime(room.lastMessageTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: room.unreadCount > 0
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[600],
                          fontWeight: room.unreadCount > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.lastMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: room.unreadCount > 0
                                ? Colors.black87
                                : Colors.grey[600],
                            fontWeight: room.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (room.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${room.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
