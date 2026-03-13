// SCREEN: Admin Push Notification Screen | ADMIN (no spec)
import '../../../utils/screen_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../services/fcm_service.dart';

class AdminPushNotificationScreen extends StatefulWidget {
  const AdminPushNotificationScreen({super.key});

  @override
  State<AdminPushNotificationScreen> createState() => _AdminPushNotificationScreenState();
}

class _AdminPushNotificationScreenState extends State<AdminPushNotificationScreen> with ScreenLogMixin {
  @override
  String get screenId => 'Admin Push Notification Screen | ADMIN (no spec)';

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _deepLinkController = TextEditingController();
  
  String _selectedTarget = 'all';
  String _selectedType = 'general';
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _deepLinkController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSending = true;
    });

    try {
      // 実際の環境では、Firebase Cloud Messaging REST APIまたはFirebase Admin SDKを使用
      // ここではシミュレーション
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('通知を送信しました（対象: $_selectedTarget）'),
            backgroundColor: Colors.green,
          ),
        );

        _formKey.currentState!.reset();
        _titleController.clear();
        _bodyController.clear();
        _deepLinkController.clear();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to send notification: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('通知の送信に失敗しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プッシュ通知送信'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 送信対象選択
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '送信対象',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTargetOption('all', '全ユーザー', Icons.people),
                    _buildTargetOption('users', 'ユーザーのみ', Icons.person),
                    _buildTargetOption('staff', 'スタッフのみ', Icons.work),
                    _buildTargetOption('active', 'アクティブユーザー（7日以内）', Icons.flash_on),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 通知タイプ選択
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '通知タイプ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '通知の種類',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'general', child: Text('お知らせ')),
                        DropdownMenuItem(value: 'update', child: Text('アップデート情報')),
                        DropdownMenuItem(value: 'campaign', child: Text('キャンペーン')),
                        DropdownMenuItem(value: 'maintenance', child: Text('メンテナンス')),
                        DropdownMenuItem(value: 'emergency', child: Text('緊急通知')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 通知内容
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '通知内容',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'タイトル',
                        hintText: '例: 新機能リリースのお知らせ',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'タイトルを入力してください';
                        }
                        return null;
                      },
                      maxLength: 50,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bodyController,
                      decoration: const InputDecoration(
                        labelText: '本文',
                        hintText: '例: ライブ配信機能がリリースされました！',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.message),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '本文を入力してください';
                        }
                        return null;
                      },
                      maxLines: 3,
                      maxLength: 200,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _deepLinkController,
                      decoration: const InputDecoration(
                        labelText: 'ディープリンク（任意）',
                        hintText: '例: /live_streams',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 送信ボタン
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : _sendNotification,
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _isSending ? '送信中...' : '通知を送信',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 注意事項
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '送信前の確認事項',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 送信後は取り消しできません\n'
                    '• 通知はリアルタイムで配信されます\n'
                    '• 緊急通知は最優先で表示されます\n'
                    '• ユーザーの通知設定を尊重します',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 送信履歴
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '最近の送信履歴',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // 送信履歴画面へ遷移
                          },
                          child: const Text('すべて見る'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildHistoryItem(
                      'キャンペーンのお知らせ',
                      '全ユーザー',
                      DateTime.now().subtract(const Duration(hours: 2)),
                      Icons.campaign,
                      Colors.blue,
                    ),
                    _buildHistoryItem(
                      'メンテナンス予告',
                      'アクティブユーザー',
                      DateTime.now().subtract(const Duration(days: 1)),
                      Icons.build,
                      Colors.orange,
                    ),
                    _buildHistoryItem(
                      '新機能リリース',
                      '全ユーザー',
                      DateTime.now().subtract(const Duration(days: 3)),
                      Icons.new_releases,
                      Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetOption(String value, String label, IconData icon) {
    final isSelected = _selectedTarget == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTarget = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.purple : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.purple : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
    String title,
    String target,
    DateTime time,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$target • ${_formatTime(time)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inHours < 1) {
      return '${difference.inMinutes}分前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}時間前';
    } else {
      return '${difference.inDays}日前';
    }
  }
}
