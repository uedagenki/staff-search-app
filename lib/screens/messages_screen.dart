import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:html' as html;
import 'dart:convert';
import '../models/message.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      final conversationsJson = html.window.localStorage['conversations'];
      if (conversationsJson != null && conversationsJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(conversationsJson);
        setState(() {
          _conversations = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          _isLoading = false;
        });
      } else {
        // 初回起動時のサンプルデータ
        _conversations = [
          {
            'staffId': 'staff_1',
            'staffName': '佐藤 健',
            'staffImage': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
            'lastMessage': 'こんにちは！お問い合わせありがとうございます。',
            'timestamp': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
            'unreadCount': 1,
          },
          {
            'staffId': 'staff_2',
            'staffName': '田中 美咲',
            'staffImage': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
            'lastMessage': 'ありがとうございます！',
            'timestamp': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
            'unreadCount': 0,
          },
        ];
        _saveConversations();
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load conversations: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveConversations() async {
    try {
      html.window.localStorage['conversations'] = json.encode(_conversations);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save conversations: $e');
      }
    }
  }

  int get _totalUnreadCount {
    return _conversations.fold(0, (sum, conv) => sum + (conv['unreadCount'] as int? ?? 0));
  }

  String _formatTimestamp(String timestampStr) {
    try {
      final timestamp = DateTime.parse(timestampStr);
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
    } catch (e) {
      return '';
    }
  }

  void _openChat(Map<String, dynamic> conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          staffId: conversation['staffId'],
          staffName: conversation['staffName'],
          staffImage: conversation['staffImage'],
        ),
      ),
    ).then((_) {
      // チャットから戻ってきたら会話リストを再読み込み
      _loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('メッセージ'),
            if (_totalUnreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_totalUnreadCount',
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
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
              : RefreshIndicator(
                  onRefresh: _loadConversations,
                  child: ListView.separated(
                    itemCount: _conversations.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final conversation = _conversations[index];
                      final unreadCount = conversation['unreadCount'] as int? ?? 0;

                      return ListTile(
                        onTap: () => _openChat(conversation),
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage: CachedNetworkImageProvider(
                                conversation['staffImage'],
                              ),
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                  child: Center(
                                    child: Text(
                                      unreadCount > 99 ? '99+' : '$unreadCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                conversation['staffName'],
                                style: TextStyle(
                                  fontWeight: unreadCount > 0 
                                      ? FontWeight.bold 
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            Text(
                              _formatTimestamp(conversation['timestamp']),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          conversation['lastMessage'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: unreadCount > 0 
                                ? Colors.black87 
                                : Colors.grey[600],
                            fontWeight: unreadCount > 0 
                                ? FontWeight.w500 
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
