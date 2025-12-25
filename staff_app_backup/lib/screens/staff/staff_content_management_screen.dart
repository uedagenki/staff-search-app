import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StaffContentManagementScreen extends StatefulWidget {
  const StaffContentManagementScreen({super.key});

  @override
  State<StaffContentManagementScreen> createState() => _StaffContentManagementScreenState();
}

class _StaffContentManagementScreenState extends State<StaffContentManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('コンテンツ管理'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'レビュー承認状況'),
            Tab(text: 'ブロックリスト'),
            Tab(text: 'コンテンツ設定'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReviewStatusTab(),
          _buildBlockListTab(),
          _buildContentSettingsTab(),
        ],
      ),
    );
  }

  // レビュー承認状況タブ
  Widget _buildReviewStatusTab() {
    final reviews = _getSampleReviews();
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 統計カード
        _buildStatsSummary(),
        const SizedBox(height: 20),
        
        // レビューリスト
        ...reviews.map((review) => _buildReviewCard(review)),
      ],
    );
  }

  Widget _buildStatsSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'レビュー統計',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '承認済み',
                    '234',
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '審査中',
                    '5',
                    Colors.orange,
                    Icons.hourglass_empty,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '却下',
                    '12',
                    Colors.red,
                    Icons.cancel,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (review['status']) {
      case 'approved':
        statusColor = Colors.green;
        statusText = '承認済み';
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = '審査中';
        statusIcon = Icons.hourglass_empty;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = '却下';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusText = '不明';
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ステータスヘッダー
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDateTime(review['timestamp']),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // レビュワー情報
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    review['userName'][0],
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review['userName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < review['rating']
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // レビュー内容
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                review['content'],
                style: const TextStyle(fontSize: 14),
              ),
            ),
            
            // 却下理由（却下時のみ）
            if (review['status'] == 'rejected' && review['rejectionReason'] != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '却下理由',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            review['rejectionReason'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ブロックリストタブ
  Widget _buildBlockListTab() {
    final blockedUsers = _getBlockedUsers();
    
    if (blockedUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'ブロックしたユーザーはいません',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: blockedUsers.length,
      itemBuilder: (context, index) {
        return _buildBlockedUserCard(blockedUsers[index]);
      },
    );
  }

  Widget _buildBlockedUserCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red[100],
          child: Icon(Icons.block, color: Colors.red[700]),
        ),
        title: Text(
          user['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ブロック理由: ${user['reason']}'),
            Text(
              'ブロック日: ${DateFormat('yyyy/MM/dd').format(user['blockedAt'])}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'unblock') {
              _showUnblockDialog(user);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'unblock',
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 20),
                  SizedBox(width: 8),
                  Text('ブロック解除'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnblockDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ブロック解除'),
        content: Text('${user['name']}さんのブロックを解除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user['name']}さんのブロックを解除しました'),
                  backgroundColor: Colors.green,
                ),
              );
              setState(() {
                // ここで実際のブロック解除処理
              });
            },
            child: const Text('解除'),
          ),
        ],
      ),
    );
  }

  // コンテンツ設定タブ
  Widget _buildContentSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Column(
            children: [
              _buildSettingTile(
                '自動レビュー公開',
                '承認されたレビューを自動的に公開する',
                true,
                (value) {},
              ),
              const Divider(height: 1),
              _buildSettingTile(
                'レビュー通知',
                '新しいレビューが投稿されたときに通知を受け取る',
                true,
                (value) {},
              ),
              const Divider(height: 1),
              _buildSettingTile(
                'コメント許可',
                'ユーザーがレビューにコメントできるようにする',
                false,
                (value) {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        Card(
          child: ListTile(
            leading: const Icon(Icons.visibility, color: Colors.blue),
            title: const Text('公開レビュー'),
            subtitle: const Text('あなたの公開プロフィールに表示されるレビュー'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // 公開レビュー一覧画面へ
            },
          ),
        ),
        
        Card(
          child: ListTile(
            leading: const Icon(Icons.report, color: Colors.orange),
            title: const Text('報告されたコンテンツ'),
            subtitle: const Text('他のユーザーから報告されたあなたのコンテンツ'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // 報告されたコンテンツ一覧画面へ
            },
          ),
        ),
        
        Card(
          child: ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.green),
            title: const Text('コンテンツガイドライン'),
            subtitle: const Text('適切なコンテンツ投稿のためのガイドライン'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showContentGuidelinesDialog();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      value: value,
      onChanged: onChanged,
    );
  }

  void _showContentGuidelinesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('コンテンツガイドライン'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '適切なコンテンツ投稿のガイドライン',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('✅ 推奨される行動:'),
              SizedBox(height: 8),
              Text('• 正確で有益な情報を提供する'),
              Text('• 礼儀正しく、プロフェッショナルな態度を保つ'),
              Text('• 建設的なフィードバックを提供する'),
              SizedBox(height: 16),
              Text('❌ 禁止される行動:'),
              SizedBox(height: 8),
              Text('• 不適切な言葉や誹謗中傷'),
              Text('• 虚偽の情報や誤解を招く内容'),
              Text('• プライバシーの侵害'),
              Text('• スパムや宣伝行為'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return DateFormat('MM/dd').format(dateTime);
    }
  }

  List<Map<String, dynamic>> _getSampleReviews() {
    return [
      {
        'id': '1',
        'userName': '山田 太郎',
        'rating': 5,
        'content': '素晴らしいサービスでした。また利用したいと思います。',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'status': 'approved',
        'rejectionReason': null,
      },
      {
        'id': '2',
        'userName': '佐藤 花子',
        'rating': 4,
        'content': 'とても良い対応でした。満足しています。',
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
        'status': 'pending',
        'rejectionReason': null,
      },
      {
        'id': '3',
        'userName': '田中 一郎',
        'rating': 1,
        'content': '最悪でした。二度と利用しません。',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'status': 'rejected',
        'rejectionReason': '不適切な表現が含まれているため',
      },
      {
        'id': '4',
        'userName': '鈴木 美咲',
        'rating': 5,
        'content': '期待以上のサービスでした。ありがとうございました。',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)),
        'status': 'approved',
        'rejectionReason': null,
      },
      {
        'id': '5',
        'userName': '高橋 健',
        'rating': 3,
        'content': '普通でした。特に問題はありません。',
        'timestamp': DateTime.now().subtract(const Duration(days: 3)),
        'status': 'pending',
        'rejectionReason': null,
      },
    ];
  }

  List<Map<String, dynamic>> _getBlockedUsers() {
    return [
      {
        'name': '迷惑ユーザー A',
        'reason': '不適切なメッセージ送信',
        'blockedAt': DateTime.now().subtract(const Duration(days: 7)),
      },
      {
        'name': '迷惑ユーザー B',
        'reason': 'ハラスメント行為',
        'blockedAt': DateTime.now().subtract(const Duration(days: 14)),
      },
    ];
  }
}
