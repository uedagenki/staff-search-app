import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/live_league_system.dart';
import '../services/live_league_service.dart';
import '../services/local_auth_service.dart';

/// かけらシステム画面（TikTok形式）
class LiveShardScreen extends StatefulWidget {
  const LiveShardScreen({super.key});

  @override
  State<LiveShardScreen> createState() => _LiveShardScreenState();
}

class _LiveShardScreenState extends State<LiveShardScreen> {
  final _leagueService = LiveLeagueService();
  final _authService = LocalAuthService();

  int _totalShards = 0;
  List<LiveShard> _shardHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        final totalShards = await _leagueService.getUserTotalShards(user.id);
        final history = await _leagueService.getShardHistory(userId: user.id);

        setState(() {
          _totalShards = totalShards;
          _shardHistory = history;
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('✨ かけらコレクション'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildShardBalanceCard(),
                  const SizedBox(height: 16),
                  _buildRewardInfo(),
                  const SizedBox(height: 16),
                  _buildShardHistory(),
                ],
              ),
            ),
    );
  }

  Widget _buildShardBalanceCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade400, Colors.purple.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '✨',
                style: TextStyle(fontSize: 32),
              ),
              SizedBox(width: 8),
              Text(
                'かけら残高',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            NumberFormat('#,###').format(_totalShards),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'かけら',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'かけらは投げ銭で獲得できます。\n特典と交換可能です！',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎁 交換可能な特典',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...ShardRewardConfig.shardRewards.entries.map((entry) {
            final requiredShards = entry.key;
            final reward = entry.value;
            final canExchange = _totalShards >= requiredShards;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: canExchange ? Colors.purple.shade50 : Colors.grey.shade100,
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: canExchange ? Colors.purple : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      reward.split(' ')[0],
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                title: Text(
                  reward.substring(reward.indexOf(' ') + 1),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: canExchange ? Colors.black : Colors.grey,
                  ),
                ),
                subtitle: Text(
                  '必要: ${NumberFormat('#,###').format(requiredShards)} かけら',
                  style: TextStyle(
                    fontSize: 12,
                    color: canExchange ? Colors.purple : Colors.grey,
                  ),
                ),
                trailing: canExchange
                    ? ElevatedButton(
                        onPressed: () => _exchangeReward(requiredShards, reward),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('交換'),
                      )
                    : const Icon(Icons.lock, color: Colors.grey),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildShardHistory() {
    if (_shardHistory.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text(
            'かけら獲得履歴はまだありません',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📜 獲得履歴',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _shardHistory.length,
            itemBuilder: (context, index) {
              final shard = _shardHistory[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: Icon(Icons.star, color: Colors.white),
                  ),
                  title: Text(
                    '+${NumberFormat('#,###').format(shard.shardCount)} かけら',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getSourceText(shard.source),
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (shard.giftCoins > 0)
                        Text(
                          '${NumberFormat('#,###').format(shard.giftCoins)} コイン投げ銭',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  trailing: Text(
                    _formatDate(shard.earnedAt),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getSourceText(String source) {
    switch (source) {
      case 'gift':
        return '💝 投げ銭で獲得';
      case 'daily_bonus':
        return '📅 デイリーボーナス';
      case 'event':
        return '🎉 イベント報酬';
      default:
        return '✨ 獲得';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'たった今';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return DateFormat('MM/dd').format(date);
    }
  }

  Future<void> _exchangeReward(int requiredShards, String reward) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('特典交換'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${reward}と交換しますか？'),
            const SizedBox(height: 16),
            Text(
              '消費かけら: ${NumberFormat('#,###').format(requiredShards)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            Text(
              '残り: ${NumberFormat('#,###').format(_totalShards - requiredShards)} かけら',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('交換'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // TODO: 実際の交換処理を実装
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${reward}を獲得しました！'),
          backgroundColor: Colors.green,
        ),
      );

      // データを再読み込み
      await _loadData();
    }
  }
}
