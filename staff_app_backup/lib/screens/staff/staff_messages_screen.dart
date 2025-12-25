import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:html' as html;
import 'dart:convert';
import '../staff_chat_screen.dart';
import '../../models/chat_message.dart';
import '../../services/chat_service.dart';

class StaffMessagesScreen extends StatefulWidget {
  const StaffMessagesScreen({super.key});

  @override
  State<StaffMessagesScreen> createState() => _StaffMessagesScreenState();
}

class _StaffMessagesScreenState extends State<StaffMessagesScreen> {
  final ChatService _chatService = ChatService();
  List<ChatRoom> _chatRooms = [];
  String _staffId = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStaffInfo();
    _loadChatRooms();
  }

  void _loadStaffInfo() {
    try {
      final profileData = html.window.localStorage['staff_profile'];
      if (profileData != null) {
        final profile = json.decode(profileData);
        _staffId = profile['email'] ?? 'staff_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        _staffId = 'staff_${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e) {
      _staffId = 'staff_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<void> _loadChatRooms() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // LocalStorageから全てのチャットメッセージを読み込む
      final allKeys = html.window.localStorage.keys?.toList() ?? [];
      final chatKeys = allKeys.where((key) => key.startsWith('chat_messages_')).toList();
      
      final List<ChatRoom> rooms = [];
      
      for (var key in chatKeys) {
        final messagesJson = html.window.localStorage[key];
        if (messagesJson != null && messagesJson.isNotEmpty) {
          try {
            final List<dynamic> messages = json.decode(messagesJson);
            
            if (messages.isNotEmpty) {
              // スタッフ宛のメッセージのみを抽出
              final staffMessages = messages.where((m) => 
                m['recipientType'] == 'staff' || m['senderType'] == 'staff'
              ).toList();
              
              if (staffMessages.isNotEmpty) {
                // 最新メッセージを取得
                final lastMessage = staffMessages.last;
                final timestamp = DateTime.parse(lastMessage['timestamp']);
                
                // ユーザー情報を取得
                String userId = '';
                String userName = '';
                String userImage = '';
                
                if (lastMessage['senderType'] == 'user') {
                  userId = lastMessage['senderId'];
                  userName = lastMessage['senderName'];
                  userImage = 'https://i.pravatar.cc/150?img=12';
                } else {
                  userId = lastMessage['recipientId'] ?? 'user_unknown';
                  userName = lastMessage['recipientName'] ?? 'ユーザー';
                  userImage = 'https://i.pravatar.cc/150?img=12';
                }
                
                // 未読メッセージ数をカウント
                final unreadCount = staffMessages.where((m) => 
                  m['senderType'] == 'user' && m['isRead'] != true
                ).length;
                
                rooms.add(ChatRoom(
                  id: key.replaceAll('chat_messages_', ''),
                  userId: userId,
                  userName: userName,
                  userImage: userImage,
                  lastMessage: lastMessage['message'] ?? '',
                  lastMessageTime: timestamp,
                  unreadCount: unreadCount,
                  isOnline: false,
                ));
              }
            }
          } catch (e) {
            debugPrint('Error parsing chat room: $e');
          }
        }
      }
      
      // 最終メッセージ時間でソート（新しい順）
      rooms.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      
      if (mounted) {
        setState(() {
          _chatRooms = rooms;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading chat rooms: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChatRooms,
            tooltip: '更新',
          ),
        ],
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chatRooms.isEmpty
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
                      const SizedBox(height: 8),
                      Text(
                        'ユーザーからメッセージが届くと\nここに表示されます',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadChatRooms,
                  child: ListView.builder(
                    itemCount: _chatRooms.length,
                    itemBuilder: (context, index) {
                      final room = _chatRooms[index];
                      return _buildChatRoomCard(room);
                    },
                  ),
                ),
    );
  }

  Widget _buildChatRoomCard(ChatRoom room) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StaffChatScreen(
              userId: room.userId,
              userName: room.userName,
              userImage: room.userImage,
            ),
          ),
        ).then((_) {
          // チャットから戻ってきたら未読カウントをリセットしてリロード
          _loadChatRooms();
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
