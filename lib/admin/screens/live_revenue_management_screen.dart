import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../services/live_revenue_service.dart';
import '../../services/fan_club_service.dart';
import '../../models/fan_club_membership.dart';

class LiveRevenueManagementScreen extends StatefulWidget {
  const LiveRevenueManagementScreen({super.key});

  @override
  State<LiveRevenueManagementScreen> createState() => _LiveRevenueManagementScreenState();
}

class _LiveRevenueManagementScreenState extends State<LiveRevenueManagementScreen> with SingleTickerProviderStateMixin {
  final LiveRevenueService _revenueService = LiveRevenueService();
  final FanClubService _fanClubService = FanClubService();
  
  late TabController _tabController;
  Map<String, dynamic> _overallStats = {};
  List<Map<String, dynamic>> _topStaff = [];
  List<FanClubMembership> _topFans = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // TODO: 実際のスタッフIDリストを取得
      final staffIds = ['staff_1', 'staff_2', 'staff_3']; // サンプル
      
      int totalRevenue = 0;
      int totalGiftRevenue = 0;
      int totalViewRevenue = 0;
      int totalViews = 0;
      
      final staffStats = <Map<String, dynamic>>[];
      
      for (var staffId in staffIds) {
        final revenue = await _revenueService.getTotalRevenue(staffId);
        totalRevenue += revenue['totalRevenue'] as int;
        totalGiftRevenue += revenue['giftRevenue'] as int;
        totalViewRevenue += revenue['viewRevenue'] as int;
        totalViews += revenue['totalViews'] as int;
        
        staffStats.add({
          'staffId': staffId,
          'totalRevenue': revenue['totalRevenue'],
          'giftRevenue': revenue['giftRevenue'],
          'viewRevenue': revenue['viewRevenue'],
          'totalViews': revenue['totalViews'],
        });
      }
      
      staffStats.sort((a, b) => (b['totalRevenue'] as int).compareTo(a['totalRevenue'] as int));
      
      setState(() {
        _overallStats = {
          'totalRevenue': totalRevenue,
          'giftRevenue': totalGiftRevenue,
          'viewRevenue': totalViewRevenue,
          'totalViews': totalViews,
          'staffCount': staffIds.length,
        };
        _topStaff = staffStats.take(10).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('データ読み込みエラー: $e');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ライブ配信・収益管理'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: '収益概要', icon: Icon(Icons.analytics)),
            Tab(text: 'スタッフランキング', icon: Icon(Icons.leaderboard)),
            Tab(text: 'ファンクラブ', icon: Icon(Icons.star)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildStaffRankingTab(),
                _buildFanClubTab(),
              ],
            ),
    );
  }
  
  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 総収益カード
            _buildRevenueCard(
              '総収益',
              _overallStats['totalRevenue'] ?? 0,
              Icons.monetization_on,
              Colors.green,
            ),
            const SizedBox(height: 16),
            
            // 収益内訳
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'ギフト収益',
                    '¥${_formatNumber(_overallStats['giftRevenue'] ?? 0)}',
                    Icons.card_giftcard,
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '再生収益',
                    '¥${_formatNumber(_overallStats['viewRevenue'] ?? 0)}',
                    Icons.play_circle,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '総再生数',
                    _formatViewCount(_overallStats['totalViews'] ?? 0),
                    Icons.visibility,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '配信スタッフ',
                    '${_overallStats['staffCount'] ?? 0}人',
                    Icons.people,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 再生単価情報
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      const Text(
                        '再生収益について',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '動画1再生あたり: ¥0.02〜¥0.08',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '平均再生単価: ¥${((_overallStats['totalViews'] ?? 0) > 0 ? (_overallStats['viewRevenue'] ?? 0) / (_overallStats['totalViews'] ?? 1) : 0).toStringAsFixed(3)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStaffRankingTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _topStaff.isEmpty
          ? const Center(child: Text('データがありません'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _topStaff.length,
              itemBuilder: (context, index) {
                final staff = _topStaff[index];
                final rank = index + 1;
                
                Color rankColor;
                IconData rankIcon;
                
                if (rank == 1) {
                  rankColor = Colors.amber;
                  rankIcon = Icons.emoji_events;
                } else if (rank == 2) {
                  rankColor = Colors.grey[400]!;
                  rankIcon = Icons.emoji_events;
                } else if (rank == 3) {
                  rankColor = Colors.brown[300]!;
                  rankIcon = Icons.emoji_events;
                } else {
                  rankColor = Colors.blue[300]!;
                  rankIcon = Icons.star;
                }
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: rankColor.withValues(alpha: 0.2),
                          child: Text(
                            '#$rank',
                            style: TextStyle(
                              color: rankColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (rank <= 3)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Icon(rankIcon, color: rankColor, size: 16),
                          ),
                      ],
                    ),
                    title: Text(
                      'スタッフ ID: ${staff['staffId']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('総収益: ¥${_formatNumber(staff['totalRevenue'])}'),
                        Text('ギフト: ¥${_formatNumber(staff['giftRevenue'])} / 再生: ¥${_formatNumber(staff['viewRevenue'])}'),
                        Text('総再生数: ${_formatViewCount(staff['totalViews'])}'),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
  
  Widget _buildFanClubTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'ファンクラブ統計',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '実装予定',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRevenueCard(String title, int amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '¥${_formatNumber(amount)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatNumber(int number) {
    if (number >= 10000) {
      return '${(number / 10000).toStringAsFixed(1)}万';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
  
  String _formatViewCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万回';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K回';
    }
    return '$count回';
  }
}
