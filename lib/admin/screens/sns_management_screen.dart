// SCREEN: SNS Management Screen | ADMIN (no spec)
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SnsManagementScreen extends StatefulWidget {
  const SnsManagementScreen({super.key});

  @override
  State<SnsManagementScreen> createState() => _SnsManagementScreenState();
}

class _SnsManagementScreenState extends State<SnsManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // 統計データ
  int _totalPosts = 0;
  int _totalStories = 0;
  int _activeLiveStreams = 0;
  int _totalViews = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    // TODO: Firestoreから実際の統計データを取得
    setState(() {
      _totalPosts = 1234;
      _totalStories = 567;
      _activeLiveStreams = 8;
      _totalViews = 45678;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_print
    debugPrint('📱 SCREEN: SNS Management Screen | ADMIN (no spec)'); // debug only

    return Scaffold(
      appBar: AppBar(
        title: const Text('SNS機能管理'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.article), text: '配信投稿'),
            Tab(icon: Icon(Icons.auto_stories), text: 'ストーリーズ'),
            Tab(icon: Icon(Icons.live_tv), text: 'ライブ配信'),
            Tab(icon: Icon(Icons.analytics), text: '統計'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 統計サマリーカード
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '総投稿数',
                    _totalPosts.toString(),
                    Icons.article,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'ストーリーズ',
                    _totalStories.toString(),
                    Icons.auto_stories,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'ライブ配信中',
                    _activeLiveStreams.toString(),
                    Icons.live_tv,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '総視聴数',
                    _totalViews.toString(),
                    Icons.visibility,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ),
          // タブコンテンツ
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                PostsManagementTab(),
                StoriesManagementTab(),
                LiveStreamsManagementTab(),
                StatisticsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// 配信投稿管理タブ
class PostsManagementTab extends StatefulWidget {
  const PostsManagementTab({super.key});

  @override
  State<PostsManagementTab> createState() => _PostsManagementTabState();
}

class _PostsManagementTabState extends State<PostsManagementTab> {
  String _filterStatus = 'all'; // all, reported, hidden

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // フィルターバー
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'all', label: Text('すべて'), icon: Icon(Icons.list)),
                    ButtonSegment(value: 'reported', label: Text('通報済み'), icon: Icon(Icons.flag)),
                    ButtonSegment(value: 'hidden', label: Text('非表示'), icon: Icon(Icons.visibility_off)),
                  ],
                  selected: {_filterStatus},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _filterStatus = newSelection.first;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: エクスポート機能
                },
                icon: const Icon(Icons.download),
                label: const Text('エクスポート'),
              ),
            ],
          ),
        ),
        // 投稿一覧
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 10, // TODO: 実際のデータ数
            itemBuilder: (context, index) {
              return _buildPostCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPostCard(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(Icons.person, color: Colors.blue.shade700),
        ),
        title: Text('スタッフ名 #$index'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            const Text('投稿内容のプレビューテキスト...'),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.favorite, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text('123', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(width: 16),
                Icon(Icons.comment, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text('45', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(width: 16),
                Icon(Icons.visibility, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text('678', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('詳細表示'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'hide',
              child: Row(
                children: [
                  Icon(Icons.visibility_off),
                  SizedBox(width: 8),
                  Text('非表示'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('削除', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handlePostAction(value.toString(), index),
        ),
      ),
    );
  }

  void _handlePostAction(String action, int postIndex) {
    switch (action) {
      case 'view':
        // TODO: 詳細表示
        break;
      case 'hide':
        _hidePost(postIndex);
        break;
      case 'delete':
        _deletePost(postIndex);
        break;
    }
  }

  void _hidePost(int postIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('投稿を非表示'),
        content: const Text('この投稿を非表示にしますか？\nユーザーには表示されなくなります。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 非表示処理
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('投稿を非表示にしました')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('非表示にする'),
          ),
        ],
      ),
    );
  }

  void _deletePost(int postIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('投稿を削除'),
        content: const Text('この投稿を完全に削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 削除処理
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('投稿を削除しました'), backgroundColor: Colors.red),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('削除する'),
          ),
        ],
      ),
    );
  }
}

// ストーリーズ管理タブ
class StoriesManagementTab extends StatefulWidget {
  const StoriesManagementTab({super.key});

  @override
  State<StoriesManagementTab> createState() => _StoriesManagementTabState();
}

class _StoriesManagementTabState extends State<StoriesManagementTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ヘッダー
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.purple.shade50,
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.purple),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'ストーリーズは24時間後に自動削除されます',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: 期限切れストーリーズ削除
                },
                icon: const Icon(Icons.delete_sweep),
                label: const Text('期限切れ削除'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              ),
            ],
          ),
        ),
        // ストーリーズ一覧
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: 12, // TODO: 実際のデータ数
            itemBuilder: (context, index) {
              return _buildStoryCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStoryCard(int index) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // ストーリーサムネイル
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.purple.shade300, Colors.blue.shade300],
              ),
            ),
            child: const Center(
              child: Icon(Icons.image, size: 48, color: Colors.white),
            ),
          ),
          // 情報オーバーレイ
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'スタッフ #$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '残り ${23 - index}時間',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // アクションボタン
          Positioned(
            top: 4,
            right: 4,
            child: PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 8),
                      Text('表示'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('削除', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) => _handleStoryAction(value.toString(), index),
            ),
          ),
        ],
      ),
    );
  }

  void _handleStoryAction(String action, int storyIndex) {
    if (action == 'delete') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('ストーリーズを削除'),
          content: const Text('このストーリーズを削除しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: 削除処理
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ストーリーズを削除しました')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('削除'),
            ),
          ],
        ),
      );
    }
  }
}

// ライブ配信管理タブ
class LiveStreamsManagementTab extends StatefulWidget {
  const LiveStreamsManagementTab({super.key});

  @override
  State<LiveStreamsManagementTab> createState() => _LiveStreamsManagementTabState();
}

class _LiveStreamsManagementTabState extends State<LiveStreamsManagementTab> {
  String _filterStatus = 'active'; // active, ended, all

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // フィルターバー
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.red.shade50,
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'active', label: Text('配信中'), icon: Icon(Icons.circle, color: Colors.red)),
                    ButtonSegment(value: 'ended', label: Text('終了済み'), icon: Icon(Icons.stop_circle)),
                    ButtonSegment(value: 'all', label: Text('すべて'), icon: Icon(Icons.list)),
                  ],
                  selected: {_filterStatus},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _filterStatus = newSelection.first;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        // ライブ配信一覧
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 8, // TODO: 実際のデータ数
            itemBuilder: (context, index) {
              final isActive = index < 3;
              return _buildLiveStreamCard(index, isActive);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLiveStreamCard(int index, bool isActive) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: Colors.red.shade100,
              child: Icon(Icons.person, color: Colors.red.shade700),
            ),
            if (isActive)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Text('スタッフ #$index'),
            const SizedBox(width: 8),
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(isActive ? '配信開始: ${index * 5}分前' : '配信終了: ${index}時間前'),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text('${100 + index * 50}人', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(width: 16),
                Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text('${index * 10 + 15}分', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            if (isActive)
              const PopupMenuItem(
                value: 'monitor',
                child: Row(
                  children: [
                    Icon(Icons.monitor),
                    SizedBox(width: 8),
                    Text('監視'),
                  ],
                ),
              ),
            if (isActive)
              const PopupMenuItem(
                value: 'end',
                child: Row(
                  children: [
                    Icon(Icons.stop, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('配信停止', style: TextStyle(color: Colors.orange)),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('削除', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleLiveStreamAction(value.toString(), index, isActive),
        ),
      ),
    );
  }

  void _handleLiveStreamAction(String action, int streamIndex, bool isActive) {
    switch (action) {
      case 'monitor':
        // TODO: 監視画面
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('配信監視機能は準備中です')),
        );
        break;
      case 'end':
        _endLiveStream(streamIndex);
        break;
      case 'delete':
        _deleteLiveStream(streamIndex);
        break;
    }
  }

  void _endLiveStream(int streamIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('配信を停止'),
        content: const Text('このライブ配信を強制的に停止しますか？\n配信者に通知されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 配信停止処理
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('配信を停止しました'), backgroundColor: Colors.orange),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('停止する'),
          ),
        ],
      ),
    );
  }

  void _deleteLiveStream(int streamIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('配信を削除'),
        content: const Text('この配信記録を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 削除処理
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('配信を削除しました')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}

// 統計タブ
class StatisticsTab extends StatelessWidget {
  const StatisticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 総合統計
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '総合統計',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildStatRow('総投稿数', '1,234件', Icons.article, Colors.blue),
                const Divider(),
                _buildStatRow('ストーリーズ', '567件', Icons.auto_stories, Colors.purple),
                const Divider(),
                _buildStatRow('ライブ配信', '89回', Icons.live_tv, Colors.red),
                const Divider(),
                _buildStatRow('総視聴時間', '12,345時間', Icons.timer, Colors.green),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // エンゲージメント統計
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'エンゲージメント',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildStatRow('いいね', '45,678件', Icons.favorite, Colors.pink),
                const Divider(),
                _buildStatRow('コメント', '12,345件', Icons.comment, Colors.orange),
                const Divider(),
                _buildStatRow('シェア', '3,456件', Icons.share, Colors.cyan),
                const Divider(),
                _buildStatRow('ギフト', '¥123,456', Icons.card_giftcard, Colors.amber),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 月間成長率
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '月間成長率',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildGrowthRow('投稿数', '+15.2%', true),
                const Divider(),
                _buildGrowthRow('視聴数', '+23.5%', true),
                const Divider(),
                _buildGrowthRow('エンゲージメント', '+8.7%', true),
                const Divider(),
                _buildGrowthRow('アクティブユーザー', '-2.3%', false),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthRow(String label, String growth, bool isPositive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: isPositive ? Colors.green : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            growth,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
