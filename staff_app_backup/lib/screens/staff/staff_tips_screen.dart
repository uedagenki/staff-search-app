import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StaffTipsScreen extends StatefulWidget {
  const StaffTipsScreen({super.key});

  @override
  State<StaffTipsScreen> createState() => _StaffTipsScreenState();
}

class _StaffTipsScreenState extends State<StaffTipsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = '今月';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'チップ管理',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    initialValue: _selectedPeriod,
                    onSelected: (value) {
                      setState(() {
                        _selectedPeriod = value;
                      });
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: '今日', child: Text('今日')),
                      const PopupMenuItem(value: '今週', child: Text('今週')),
                      const PopupMenuItem(value: '今月', child: Text('今月')),
                      const PopupMenuItem(value: '全期間', child: Text('全期間')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(_selectedPeriod),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 統計カード
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // 総受取額カード
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '総受取額',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _selectedPeriod,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '¥145,800',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '先月比 +15% (¥19,000)',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 統計サマリー
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          '受取回数',
                          '156回',
                          Icons.card_giftcard,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          '平均金額',
                          '¥935',
                          Icons.show_chart,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          '送信者数',
                          '98人',
                          Icons.people,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // タブバー
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '受取履歴'),
                Tab(text: 'トップ送信者'),
              ],
            ),

            // タブビュー
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTipHistoryList(),
                  _buildTopSendersList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipHistoryList() {
    final tips = _getSampleTips();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tips.length,
      itemBuilder: (context, index) {
        final tip = tips[index];
        return _buildTipCard(tip);
      },
    );
  }

  Widget _buildTopSendersList() {
    final topSenders = _getTopSenders();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: topSenders.length,
      itemBuilder: (context, index) {
        final sender = topSenders[index];
        return _buildTopSenderCard(sender, index);
      },
    );
  }

  Widget _buildTipCard(Map<String, dynamic> tip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showTipDetail(tip),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 送信者アバター
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue[100],
                backgroundImage: tip['senderImage'] != null 
                    ? NetworkImage(tip['senderImage']) 
                    : null,
                child: tip['senderImage'] == null 
                    ? Text(
                        tip['senderName'][0],
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              
              // 送信者情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip['senderName'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (tip['message'] != null) ...[
                      Text(
                        tip['message'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      _formatDateTime(tip['timestamp']),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              
              // チップ金額
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '¥${NumberFormat('#,###').format(tip['amount'])}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.card_giftcard,
                          size: 12,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tip['giftType'],
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSenderCard(Map<String, dynamic> sender, int rank) {
    Color rankColor;
    IconData rankIcon;
    
    if (rank == 0) {
      rankColor = Colors.amber;
      rankIcon = Icons.emoji_events;
    } else if (rank == 1) {
      rankColor = Colors.grey[400]!;
      rankIcon = Icons.workspace_premium;
    } else if (rank == 2) {
      rankColor = Colors.brown[300]!;
      rankIcon = Icons.military_tech;
    } else {
      rankColor = Colors.grey[600]!;
      rankIcon = Icons.star;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // ランキングバッジ
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: rankColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: rank < 3
                    ? Icon(rankIcon, color: rankColor, size: 24)
                    : Text(
                        '${rank + 1}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: rankColor,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            
            // 送信者アバター
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue[100],
              backgroundImage: sender['image'] != null 
                  ? NetworkImage(sender['image']) 
                  : null,
              child: sender['image'] == null 
                  ? Text(
                      sender['name'][0],
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            
            // 送信者情報
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sender['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${sender['count']}回送信',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // 合計金額
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '¥${NumberFormat('#,###').format(sender['totalAmount'])}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '平均 ¥${NumberFormat('#,###').format(sender['avgAmount'])}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTipDetail(Map<String, dynamic> tip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                const Text(
                  'チップ詳細',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // 送信者情報
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.blue[100],
                      backgroundImage: tip['senderImage'] != null 
                          ? NetworkImage(tip['senderImage']) 
                          : null,
                      child: tip['senderImage'] == null 
                          ? Text(
                              tip['senderName'][0],
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip['senderName'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateTime(tip['timestamp']),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const Divider(height: 32),
                
                // チップ金額
                _buildDetailRow(
                  '受取金額',
                  '¥${NumberFormat('#,###').format(tip['amount'])}',
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'ギフト種類',
                  tip['giftType'],
                  Colors.blue,
                ),
                
                if (tip['message'] != null) ...[
                  const Divider(height: 32),
                  const Text(
                    'メッセージ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tip['message'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // アクションボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // お礼メッセージ送信画面へ
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('お礼メッセージを送信しました')),
                      );
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('お礼メッセージを送る'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
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
      return DateFormat('MM/dd HH:mm').format(dateTime);
    }
  }

  List<Map<String, dynamic>> _getSampleTips() {
    return [
      {
        'id': '1',
        'senderName': '山田 太郎',
        'senderImage': null,
        'amount': 5000,
        'giftType': 'ゴールドハート',
        'message': '素晴らしいサービスをありがとうございました！',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      },
      {
        'id': '2',
        'senderName': '佐藤 花子',
        'senderImage': null,
        'amount': 3000,
        'giftType': 'シルバースター',
        'message': 'とても良かったです。また利用します。',
        'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
      },
      {
        'id': '3',
        'senderName': '田中 一郎',
        'senderImage': null,
        'amount': 2000,
        'giftType': 'ブロンズコイン',
        'message': null,
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'id': '4',
        'senderName': '鈴木 美咲',
        'senderImage': null,
        'amount': 10000,
        'giftType': 'プラチナクラウン',
        'message': '期待以上のサービスでした。ありがとうございます！',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'id': '5',
        'senderName': '高橋 健',
        'senderImage': null,
        'amount': 1500,
        'giftType': 'ブロンズコイン',
        'message': null,
        'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      },
    ];
  }

  List<Map<String, dynamic>> _getTopSenders() {
    return [
      {
        'name': '鈴木 美咲',
        'image': null,
        'totalAmount': 25000,
        'count': 8,
        'avgAmount': 3125,
      },
      {
        'name': '山田 太郎',
        'image': null,
        'totalAmount': 18000,
        'count': 6,
        'avgAmount': 3000,
      },
      {
        'name': '佐藤 花子',
        'image': null,
        'totalAmount': 15000,
        'count': 5,
        'avgAmount': 3000,
      },
      {
        'name': '田中 一郎',
        'image': null,
        'totalAmount': 12000,
        'count': 6,
        'avgAmount': 2000,
      },
      {
        'name': '高橋 健',
        'image': null,
        'totalAmount': 9000,
        'count': 4,
        'avgAmount': 2250,
      },
    ];
  }
}
