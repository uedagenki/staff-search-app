import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:html' as html;
import 'dart:convert';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final String staffId;
  final String staffName;
  final String staffImage;

  const ChatScreen({
    super.key,
    required this.staffId,
    required this.staffName,
    required this.staffImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _updateConversation();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final messagesKey = 'messages_${widget.staffId}';
      final messagesJson = html.window.localStorage[messagesKey];
      
      if (messagesJson != null && messagesJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(messagesJson);
        setState(() {
          _messages = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          _isLoading = false;
        });
      } else {
        // 初回起動時のサンプルメッセージ
        _messages = [
          {
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'senderId': widget.staffId,
            'senderName': widget.staffName,
            'content': 'こんにちは！お問い合わせありがとうございます。',
            'timestamp': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
            'isFromMe': false,
          },
        ];
        _saveMessages();
        setState(() {
          _isLoading = false;
        });
      }

      // スクロールを一番下へ
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load messages: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveMessages() async {
    try {
      final messagesKey = 'messages_${widget.staffId}';
      html.window.localStorage[messagesKey] = json.encode(_messages);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save messages: $e');
      }
    }
  }

  Future<void> _updateConversation() async {
    try {
      final conversationsJson = html.window.localStorage['conversations'];
      List<Map<String, dynamic>> conversations = [];
      
      if (conversationsJson != null && conversationsJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(conversationsJson);
        conversations = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      // この会話を更新または追加
      final index = conversations.indexWhere((c) => c['staffId'] == widget.staffId);
      final lastMessage = _messages.isNotEmpty ? _messages.last['content'] : '';
      final timestamp = _messages.isNotEmpty ? _messages.last['timestamp'] : DateTime.now().toIso8601String();

      final conversationData = {
        'staffId': widget.staffId,
        'staffName': widget.staffName,
        'staffImage': widget.staffImage,
        'lastMessage': lastMessage,
        'timestamp': timestamp,
        'unreadCount': 0, // チャット画面を開いたので未読は0
      };

      if (index >= 0) {
        conversations[index] = conversationData;
      } else {
        conversations.insert(0, conversationData);
      }

      html.window.localStorage['conversations'] = json.encode(conversations);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to update conversation: $e');
      }
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'senderId': 'current_user',
      'senderName': 'あなた',
      'content': _messageController.text.trim(),
      'timestamp': DateTime.now().toIso8601String(),
      'isFromMe': true,
    };

    setState(() {
      _messages.add(newMessage);
    });

    _messageController.clear();
    _saveMessages();

    // スクロールを一番下へ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // 自動返信シミュレーション
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final autoReply = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'senderId': widget.staffId,
          'senderName': widget.staffName,
          'content': 'メッセージを受信しました。確認次第ご返信させていただきます。',
          'timestamp': DateTime.now().toIso8601String(),
          'isFromMe': false,
        };

        setState(() {
          _messages.add(autoReply);
        });
        _saveMessages();
        _updateConversationWithUnread();

        // スクロールを一番下へ
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  Future<void> _updateConversationWithUnread() async {
    try {
      final conversationsJson = html.window.localStorage['conversations'];
      if (conversationsJson == null) return;

      final List<dynamic> decoded = json.decode(conversationsJson);
      final conversations = decoded.map((e) => Map<String, dynamic>.from(e)).toList();

      final index = conversations.indexWhere((c) => c['staffId'] == widget.staffId);
      if (index >= 0) {
        conversations[index]['unreadCount'] = (conversations[index]['unreadCount'] as int? ?? 0) + 1;
        conversations[index]['lastMessage'] = _messages.last['content'];
        conversations[index]['timestamp'] = _messages.last['timestamp'];
        html.window.localStorage['conversations'] = json.encode(conversations);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to update conversation unread: $e');
      }
    }
  }

  void _handleCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.phone, color: Colors.green),
            SizedBox(width: 12),
            Text('音声通話'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.staffName}さんに発信しますか?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '💡 ヒント: 音声通話機能は実装済みです。\n実際のアプリでは音声通話が利用可能になります。',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('通話機能は本番環境で利用可能です'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.phone),
            label: const Text('発信'),
          ),
        ],
      ),
    );
  }

  void _handleImagePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('写真を送信'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('ギャラリーから選択'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('カメラで撮影'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _pickImageFromGallery() {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${file.name}を選択しました')),
        );
        // 実際のアプリでは画像をアップロードしてメッセージとして送信
      }
    });
  }

  void _pickImageFromCamera() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('カメラ機能は実機でのみ利用可能です'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _formatTimestamp(String timestampStr) {
    try {
      final timestamp = DateTime.parse(timestampStr);
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: CachedNetworkImageProvider(widget.staffImage),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.staffName,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Text(
                    'オンライン',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: _handleCall,
            tooltip: '音声通話',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // メニューオプション
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isFromMe = message['isFromMe'] as bool;

                      return Align(
                        alignment: isFromMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          child: Column(
                            crossAxisAlignment: isFromMe 
                                ? CrossAxisAlignment.end 
                                : CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isFromMe 
                                      ? Colors.purple[600] 
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  message['content'],
                                  style: TextStyle(
                                    color: isFromMe ? Colors.white : Colors.black87,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTimestamp(message['timestamp']),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: _handleImagePicker,
                          color: Colors.purple,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'メッセージを入力...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: Colors.purple,
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
}
