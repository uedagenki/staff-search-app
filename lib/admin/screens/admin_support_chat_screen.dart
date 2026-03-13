// SCREEN: Admin Support Chat Screen | ADMIN (no spec)
import '../../../utils/screen_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../utils/storage_helper.dart';
import 'dart:convert';

class AdminSupportChatScreen extends StatefulWidget {
  const AdminSupportChatScreen({super.key});

  @override
  State<AdminSupportChatScreen> createState() => _AdminSupportChatScreenState();
}

class _AdminSupportChatScreenState extends State<AdminSupportChatScreen> with ScreenLogMixin {
  @override
  String get screenId => 'Admin Support Chat Screen | ADMIN (no spec)';

  List<ChatTicket> _tickets = [];
  List<ChatTicket> _filteredTickets = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'all'; // all, open, in_progress, resolved

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // サンプルチケットデータを生成
      _tickets = _generateSampleTickets();
      _applyFilters();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load tickets: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<ChatTicket> _generateSampleTickets() {
    return [
      ChatTicket(
        id: 'ticket_001',
        userId: 'user_001',
        userName: '山田太郎',
        subject: 'アカウントにログインできません',
        status: 'open',
        priority: 'high',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        lastMessageAt: DateTime.now().subtract(const Duration(hours: 2)),
        unreadCount: 3,
        messages: [
          ChatMessage(
            id: 'msg_001',
            senderId: 'user_001',
            senderName: '山田太郎',
            senderType: 'user',
            content: 'パスワードを忘れてしまい、アカウントにログインできません。',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          ChatMessage(
            id: 'msg_002',
            senderId: 'admin_001',
            senderName: '管理者',
            senderType: 'admin',
            content: 'パスワードリセットのリンクをメールでお送りしました。ご確認ください。',
            timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
          ),
          ChatMessage(
            id: 'msg_003',
            senderId: 'user_001',
            senderName: '山田太郎',
            senderType: 'user',
            content: 'メールが届いていません。迷惑メールフォルダも確認しましたが見つかりません。',
            timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
          ),
        ],
      ),
      ChatTicket(
        id: 'ticket_002',
        userId: 'user_002',
        userName: '佐藤花子',
        subject: '予約のキャンセル方法',
        status: 'in_progress',
        priority: 'medium',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        lastMessageAt: DateTime.now().subtract(const Duration(hours: 3)),
        unreadCount: 1,
        messages: [
          ChatMessage(
            id: 'msg_004',
            senderId: 'user_002',
            senderName: '佐藤花子',
            senderType: 'user',
            content: '予約をキャンセルしたいのですが、どこから手続きできますか?',
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          ),
          ChatMessage(
            id: 'msg_005',
            senderId: 'admin_001',
            senderName: '管理者',
            senderType: 'admin',
            content: 'マイページ→予約履歴→該当の予約を選択→キャンセルボタンから手続きできます。',
            timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          ),
        ],
      ),
      ChatTicket(
        id: 'ticket_003',
        userId: 'user_003',
        userName: '田中一郎',
        subject: 'スタッフプロフィールの編集',
        status: 'resolved',
        priority: 'low',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 0,
        messages: [
          ChatMessage(
            id: 'msg_006',
            senderId: 'user_003',
            senderName: '田中一郎',
            senderType: 'user',
            content: 'スタッフとして登録したプロフィールを編集したいです。',
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
          ),
          ChatMessage(
            id: 'msg_007',
            senderId: 'admin_001',
            senderName: '管理者',
            senderType: 'admin',
            content: 'スタッフダッシュボード→プロフィール編集から変更できます。',
            timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
          ),
          ChatMessage(
            id: 'msg_008',
            senderId: 'user_003',
            senderName: '田中一郎',
            senderType: 'user',
            content: 'ありがとうございました!編集できました。',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      ),
    ];
  }

  void _applyFilters() {
    List<ChatTicket> filtered = List.from(_tickets);

    // ステータスフィルター
    if (_filterStatus != 'all') {
      filtered = filtered.where((ticket) => ticket.status == _filterStatus).toList();
    }

    // 検索フィルター
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((ticket) {
        return ticket.userName.toLowerCase().contains(query) ||
               ticket.subject.toLowerCase().contains(query);
      }).toList();
    }

    // 最新メッセージ順でソート
    filtered.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));

    setState(() {
      _filteredTickets = filtered;
    });
  }

  Future<void> _updateTicketStatus(ChatTicket ticket, String newStatus) async {
    try {
      setState(() {
        ticket.status = newStatus;
        _applyFilters();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ステータスを「${_getStatusLabel(newStatus)}」に変更しました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ステータスの更新に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openChatDialog(ChatTicket ticket) {
    final messageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
          child: Column(
            children: [
              // ヘッダー
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ticket.subject,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          child: Text(
                            ticket.userName[0].toUpperCase(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ticket.userName,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const Spacer(),
                        _buildPriorityChip(ticket.priority),
                        const SizedBox(width: 8),
                        _buildStatusChip(ticket.status),
                      ],
                    ),
                  ],
                ),
              ),

              // メッセージリスト
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ticket.messages.length,
                  itemBuilder: (context, index) {
                    final message = ticket.messages[index];
                    final isAdmin = message.senderType == 'admin';
                    
                    return Align(
                      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          crossAxisAlignment: isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${message.senderName} • ${_formatTime(message.timestamp)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isAdmin ? Colors.blue[100] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(message.content),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // メッセージ入力
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        decoration: InputDecoration(
                          hintText: 'メッセージを入力...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        if (messageController.text.trim().isNotEmpty) {
                          setState(() {
                            ticket.messages.add(
                              ChatMessage(
                                id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
                                senderId: 'admin_001',
                                senderName: '管理者',
                                senderType: 'admin',
                                content: messageController.text.trim(),
                                timestamp: DateTime.now(),
                              ),
                            );
                            ticket.lastMessageAt = DateTime.now();
                            ticket.unreadCount = 0;
                          });
                          messageController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('メッセージを送信しました'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              // アクションボタン
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (ticket.status != 'resolved')
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _updateTicketStatus(ticket, 'resolved');
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('解決済みにする'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'open':
        return '未対応';
      case 'in_progress':
        return '対応中';
      case 'resolved':
        return '解決済み';
      default:
        return '不明';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.red;
      case 'in_progress':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'high':
        return '高';
      case 'medium':
        return '中';
      case 'low':
        return '低';
      default:
        return '不明';
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusChip(String status) {
    final color = _getStatusColor(status);
    final label = _getStatusLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    final color = _getPriorityColor(priority);
    final label = _getPriorityLabel(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '優先度: $label',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return '${dateTime.year}/${dateTime.month}/${dateTime.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final openCount = _tickets.where((t) => t.status == 'open').length;
    final inProgressCount = _tickets.where((t) => t.status == 'in_progress').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('問い合わせチャット'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '更新',
            onPressed: _loadTickets,
          ),
        ],
      ),
      body: Column(
        children: [
          // 検索バー
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ユーザー名または件名で検索',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
              ),
              onChanged: (value) => _applyFilters(),
            ),
          ),

          // フィルターチップ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('すべて'),
                    selected: _filterStatus == 'all',
                    onSelected: (selected) {
                      setState(() {
                        _filterStatus = 'all';
                        _applyFilters();
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text('未対応 ($openCount)'),
                    selected: _filterStatus == 'open',
                    onSelected: (selected) {
                      setState(() {
                        _filterStatus = 'open';
                        _applyFilters();
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text('対応中 ($inProgressCount)'),
                    selected: _filterStatus == 'in_progress',
                    onSelected: (selected) {
                      setState(() {
                        _filterStatus = 'in_progress';
                        _applyFilters();
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('解決済み'),
                    selected: _filterStatus == 'resolved',
                    onSelected: (selected) {
                      setState(() {
                        _filterStatus = 'resolved';
                        _applyFilters();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // チケットリスト
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTickets.isEmpty
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
                              '問い合わせが見つかりません',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredTickets.length,
                        itemBuilder: (context, index) {
                          final ticket = _filteredTickets[index];
                          final lastMessage = ticket.messages.last;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Stack(
                                children: [
                                  CircleAvatar(
                                    child: Text(ticket.userName[0].toUpperCase()),
                                  ),
                                  if (ticket.unreadCount > 0)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${ticket.unreadCount}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
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
                                      ticket.subject,
                                      style: TextStyle(
                                        fontWeight: ticket.unreadCount > 0
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  _buildPriorityChip(ticket.priority),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    '${ticket.userName} • ${_formatTime(ticket.lastMessageAt)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    lastMessage.content,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 4),
                                  _buildStatusChip(ticket.status),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _openChatDialog(ticket),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class ChatTicket {
  final String id;
  final String userId;
  final String userName;
  final String subject;
  String status; // open, in_progress, resolved
  final String priority; // low, medium, high
  final DateTime createdAt;
  DateTime lastMessageAt;
  int unreadCount;
  final List<ChatMessage> messages;

  ChatTicket({
    required this.id,
    required this.userId,
    required this.userName,
    required this.subject,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.messages,
  });
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderType; // user, admin
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.content,
    required this.timestamp,
  });
}
