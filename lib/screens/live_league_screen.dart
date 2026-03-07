import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/live_league_system.dart';
import '../services/live_league_service.dart';
import '../services/local_auth_service.dart';

/// ライブ配信リーグ画面（TikTok形式）
class LiveLeagueScreen extends StatefulWidget {
  const LiveLeagueScreen({super.key});

  @override
  State<LiveLeagueScreen> createState() => _LiveLeagueScreenState();
}

class _LiveLeagueScreenState extends State<LiveLeagueScreen>
    with SingleTickerProviderStateMixin {
  final _leagueService = LiveLeagueService();
  final _authService = LocalAuthService();

  late TabController _tabController;
  LiverLeagueInfo? _myLiverInfo;
  GifterLeagueInfo? _myGifterInfo;
  LeagueRanking? _currentRanking;
  LeagueRank _selectedLeague = LeagueRank.gold;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        // 自分のリーグ情報を取得
        final liverInfo =
            await _leagueService.getLiverLeagueInfo(user.id, user.name ?? 'ユーザー');
        final gifterInfo =
            await _leagueService.getGifterLeagueInfo(user.id, user.name ?? 'ユーザー');

        // 週次ランキングを取得
        final ranking = await _leagueService.getWeeklyRanking(_selectedLeague);

        setState(() {
          _myLiverInfo = liverInfo;
          _myGifterInfo = gifterInfo;
          _currentRanking = ranking;
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _changeLeague(LeagueRank league) async {
    setState(() {
      _selectedLeague = league;
      _isLoading = true;
    });

    final ranking = await _leagueService.getWeeklyRanking(league);

    setState(() {
      _currentRanking = ranking;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 ライブリーグ'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'ライバー'),
            Tab(text: 'ギフター'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildLeagueSelector(),
                _buildMyInfo(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLiverRanking(),
                      _buildGifterRanking(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLeagueSelector() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: LeagueRank.values.length,
        itemBuilder: (context, index) {
          final league = LeagueRank.values[index];
          final isSelected = league == _selectedLeague;

          return GestureDetector(
            onTap: () => _changeLeague(league),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.purple : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.purple : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    league.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    league.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMyInfo() {
    final info = _tabController.index == 0 ? _myLiverInfo : _myGifterInfo;
    if (info == null) return const SizedBox.shrink();

    final isLiver = info is LiverLeagueInfo;
    final currentLeague = isLiver
        ? (info as LiverLeagueInfo).currentLeague
        : (info as GifterLeagueInfo).currentLeague;
    final weeklyCoins = isLiver
        ? (info as LiverLeagueInfo).weeklyCoins
        : (info as GifterLeagueInfo).weeklyCoinsSent;
    final totalCoins = isLiver
        ? (info as LiverLeagueInfo).totalCoinsReceived
        : (info as GifterLeagueInfo).totalCoinsSent;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.purple.shade600],
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
          Row(
            children: [
              Text(
                currentLeague.emoji,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentLeague.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '今週: ${NumberFormat('#,###').format(weeklyCoins)} コイン',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '次のリーグまで',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '${NumberFormat('#,###').format(currentLeague.coinsToNextLeague(totalCoins))} コイン',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: isLiver
                      ? (info as LiverLeagueInfo).progressToNextLeague
                      : (info as GifterLeagueInfo).progressToNextLeague,
                  backgroundColor: Colors.white30,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiverRanking() {
    if (_currentRanking == null) {
      return const Center(child: Text('ランキングデータがありません'));
    }

    final rankings = _currentRanking!.liverRankings;
    if (rankings.isEmpty) {
      return const Center(
        child: Text('このリーグにはまだライバーがいません'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rankings.length,
      itemBuilder: (context, index) {
        final info = rankings[index];
        return _buildRankingCard(
          rank: info.rank,
          name: info.staffName,
          emoji: info.currentLeague.emoji,
          coins: info.weeklyCoins,
          isLiver: true,
        );
      },
    );
  }

  Widget _buildGifterRanking() {
    if (_currentRanking == null) {
      return const Center(child: Text('ランキングデータがありません'));
    }

    final rankings = _currentRanking!.gifterRankings;
    if (rankings.isEmpty) {
      return const Center(
        child: Text('このリーグにはまだギフターがいません'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rankings.length,
      itemBuilder: (context, index) {
        final info = rankings[index];
        return _buildRankingCard(
          rank: info.rank,
          name: info.userName,
          emoji: info.currentLeague.emoji,
          coins: info.weeklyCoinsSent,
          isLiver: false,
        );
      },
    );
  }

  Widget _buildRankingCard({
    required int rank,
    required String name,
    required String emoji,
    required int coins,
    required bool isLiver,
  }) {
    Color rankColor;
    String rankEmoji;

    switch (rank) {
      case 1:
        rankColor = Colors.amber;
        rankEmoji = '🥇';
        break;
      case 2:
        rankColor = Colors.grey.shade400;
        rankEmoji = '🥈';
        break;
      case 3:
        rankColor = Colors.orange.shade300;
        rankEmoji = '🥉';
        break;
      default:
        rankColor = Colors.grey.shade300;
        rankEmoji = '$rank位';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: rankColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              rankEmoji,
              style: TextStyle(
                fontSize: rank <= 3 ? 24 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
        subtitle: Text(
          '${NumberFormat('#,###').format(coins)} コイン（今週）',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Icon(
          isLiver ? Icons.live_tv : Icons.card_giftcard,
          color: Colors.purple,
        ),
      ),
    );
  }
}
