import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';
import '../services/chat_service.dart';

class StaffChatScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String userImage;

  const StaffChatScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userImage,
  });

  @override
  State<StaffChatScreen> createState() => _StaffChatScreenState();
}

class _StaffChatScreenState extends State<StaffChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ChatMessage> _messages = [];
  String _staffId = '';
  String _staffName = '';
  String _chatRoomId = '';

  @override
  void initState() {
    super.initState();
    _loadStaffInfo();
    _initializeChat();
  }

  void _loadStaffInfo() {
    try {
      final profileData = html.window.localStorage['staff_profile'];
      if (profileData != null) {
        final profile = json.decode(profileData);
        _staffId = profile['email'] ?? 'staff_${DateTime.now().millisecondsSinceEpoch}';
        _staffName = profile['name'] ?? 'スタッフ';
      } else {
        _staffId = 'staff_${DateTime.now().millisecondsSinceEpoch}';
        _staffName = 'スタッフ';
      }
    } catch (e) {
      _staffId = 'staff_${DateTime.now().millisecondsSinceEpoch}';
      _staffName = 'スタッフ';
    }
  }

  void _initializeChat() {
    _chatRoomId = _chatService.createChatRoom(widget.userId, _staffId);
    _loadMessages();
    _chatService.markAsRead(_chatRoomId, 'staff');
    _chatService.clearNotifications('staff', _chatRoomId);
    
    // リアルタイム更新開始
    _chatService.startListening(_chatRoomId);
    _chatService.messageStream.listen((messages) {
      if (mounted) {
        setState(() {
          _messages = messages;
        });
        _scrollToBottom();
        _chatService.markAsRead(_chatRoomId, 'staff');
      }
    });
  }

  void _loadMessages() {
    setState(() {
      _messages = _chatService.getMessages(_chatRoomId);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    await _chatService.sendMessage(
      chatRoomId: _chatRoomId,
      senderId: _staffId,
      senderName: _staffName,
      senderType: 'staff',
      message: message,
    );

    _messageController.clear();
    _loadMessages();
  }

  void _pickAndSendImage() {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    
    input.onChange.listen((e) {
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        final file = files.first;
        final reader = html.FileReader();
        
        reader.onLoadEnd.listen((e) async {
          final imageData = reader.result as String;
          
          // 画像メッセージを送信
          await _chatService.sendMessage(
            chatRoomId: _chatRoomId,
            senderId: _staffId,
            senderName: _staffName,
            senderType: 'staff',
            message: '[画像]',
            imageUrl: imageData,
          );
          
          _loadMessages();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('画像を送信しました')),
            );
          }
        });
        
        reader.readAsDataUrl(file);
      }
    });
    
    input.click();
  }

  @override
  void dispose() {
    _chatService.stopListening();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              child: Text(widget.userName[0]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Text(
                    'ユーザー',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ビデオ通話機能（開発中）')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('音声通話機能（開発中）')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // メッセージリスト
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'メッセージを送信してチャットを開始',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMyMessage = message.senderType == 'staff';
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: isMyMessage
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isMyMessage) ...[
                              CircleAvatar(
                                radius: 16,
                                child: Text(widget.userName[0]),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isMyMessage
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.message,
                                      style: TextStyle(
                                        color: isMyMessage
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTime(message.timestamp),
                                      style: TextStyle(
                                        color: isMyMessage
                                            ? Colors.white70
                                            : Colors.grey[600],
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isMyMessage) ...[
                              const SizedBox(width: 8),
                              Icon(
                                message.isRead
                                    ? Icons.done_all
                                    : Icons.done,
                                size: 16,
                                color: message.isRead
                                    ? Colors.blue
                                    : Colors.grey[400],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
          
          // メッセージ入力欄
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.photo),
                                title: const Text('写真を送信'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickAndSendImage();
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.attach_file),
                                title: const Text('ファイルを送信'),
                                onTap: () {
                                  Navigator.pop(context);
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('ファイル送信'),
                                      content: const Text('ファイル送信機能は本番環境で利用可能です。'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'メッセージを入力',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'たった今';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }
}
