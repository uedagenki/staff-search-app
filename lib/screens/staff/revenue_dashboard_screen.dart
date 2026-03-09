import 'package:flutter/material.dart';
import '../../services/live_revenue_service.dart';
import '../../services/fan_club_service.dart';
import '../../models/fan_club_membership.dart';
import 'package:flutter/foundation.dart';

class RevenueDashboardScreen extends StatefulWidget {
  final String staffId;
  
  const RevenueDashboardScreen({
    super.key,
    required this.staffId,
  });
  
  @override
  State<RevenueDashboardScreen> createState() => _RevenueDashboardScreenState();
}

class _RevenueDashboardScreenState extends State<RevenueDashboardScreen> with SingleTickerProviderStateMixin {
  final LiveRevenueService _revenueService = LiveRevenueService();
  final FanClubService _fanClubService = FanClubService();
  
  late TabController _tabController;
  Map<String, dynamic>? _totalRevenue;
  Map<String, dynamic>? _monthlyRevenue;
  List<Map<String, dynamic>> _revenueHistory = [];
  List<FanClubMembership> _fanMembers = [];
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
      final totalRevenue = await _revenueService.getTotalRevenue(widget.staffId);
      final monthlyRevenue = await _revenueService.getMonthlyRevenue(widget.staffId, DateTime.now());
      final history = await _revenueService.getRevenueHistory(widget.staffId);
      final members = await _fanClubService.getStaffFanMembers(widget.staffId);
      
      setState(() {
        _totalRevenue = totalRevenue;
        _monthlyRevenue = monthlyRevenue;
        _revenueHistory = history;
        _fanMembers = members;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading revenue data: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('収益ダッシュボード'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: '収益概要'),
            Tab(text: '収益履歴'),
            Tab(text: 'ファンクラブ'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildHistoryTab(),
                _buildFanClubTab(),
              ],
            ),
    );
  }
  
  Widget _buildOverviewTab() {
    if (_totalRevenue == null) {
      return const Center(child: Text('データがありません'));
    }
    
    final totalRevenue = _totalRevenue!['totalRevenue'] as int;
    final giftRevenue = _totalRevenue!['giftRevenue'] as int;
    final viewRevenue = _totalRevenue!['viewRevenue'] as int;
    final totalViews = _totalRevenue!['totalViews'] as int;
    
    final monthlyTotal = _monthlyRevenue!['totalRevenue'] as int;
    final monthlyGift = _monthlyRevenue!['giftRevenue'] as int;
    final monthlyView = _monthlyRevenue!['viewRevenue'] as int;
    final monthlyViews = _monthlyRevenue!['totalViews'] as int;
    
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 総収益カード
            _buildRevenueCard(
              title: '総収益',
              amount: totalRevenue,
              icon: Icons.attach_money,
              color: Colors.green,
              isTotal: true,
            ),
            const SizedBox(height: 16),
            
            // 今月の収益
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple[400]!, Colors.pink[400]!],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '今月の収益',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '¥${_formatNumber(monthlyTotal)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniStat(
                          label: 'ギフト',
                          value: '¥${_formatNumber(monthlyGift)}',
                        ),
                      ),
                      Expanded(
                        child: _buildMiniStat(
                          label: '再生',
                          value: '¥${_formatNumber(monthlyView)}',
                        ),
                      ),
                      Expanded(
                        child: _buildMiniStat(
                          label: '再生数',
                          value: _formatViewCount(monthlyViews),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // 収益内訳
            const Text(
              '収益内訳',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildRevenueBreakdownCard(
                    title: 'ギフト収益',
                    amount: giftRevenue,
                    icon: Icons.card_giftcard,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRevenueBreakdownCard(
                    title: '再生収益',
                    amount: viewRevenue,
                    icon: Icons.play_circle,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 再生数統計
            _buildViewsStatsCard(totalViews),
            const SizedBox(height: 24),
            
            // 再生単価の説明
            _buildRevenueGuideCard(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHistoryTab() {
    if (_revenueHistory.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '収益履歴がありません',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _revenueHistory.length,
        itemBuilder: (context, index) {
          final item = _revenueHistory[index];
          final type = item['type'] as String;
          final timestamp = DateTime.parse(item['timestamp'] as String);
          
          if (type == 'gift') {
            return _buildGiftHistoryItem(item, timestamp);
          } else {
            return _buildViewHistoryItem(item, timestamp);
          }
        },
      ),
    );
  }
  
  Widget _buildFanClubTab() {
    if (_fanMembers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'ファンクラブメンバーがいません',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _fanMembers.length,
        itemBuilder: (context, index) {
          final member = _fanMembers[index];
          return _buildFanMemberCard(member, index + 1);
        },
      ),
    );
  }
  
  Widget _buildRevenueCard({
    required String title,
    required int amount,
    required IconData icon,
    required Color color,
    bool isTotal = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isTotal ? color : Colors.white,
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
                  color: isTotal ? Colors.white.withValues(alpha: 0.2) : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isTotal ? Colors.white : color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: isTotal ? Colors.white : Colors.grey[700],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '¥${_formatNumber(amount)}',
            style: TextStyle(
              color: isTotal ? Colors.white : Colors.black87,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRevenueBreakdownCard({
    required String title,
    required int amount,
    required IconData icon,
    required Color color,
  }) {
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
          Icon(icon, color: color, size: 28),
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
            '¥${_formatNumber(amount)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildViewsStatsCard(int totalViews) {
    final revenueByViews = LiveRevenueService.calculateRevenueByViews(totalViews);
    
    return Container(
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
              Icon(Icons.play_circle, color: Colors.blue[700], size: 24),
              const SizedBox(width: 8),
              const Text(
                '総再生数',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _formatViewCount(totalViews),
            style: TextStyle(
              color: Colors.blue[900],
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            '再生数に基づく収益目安',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRevenueEstimate('最小', revenueByViews['min']!),
              _buildRevenueEstimate('平均', revenueByViews['avg']!),
              _buildRevenueEstimate('最大', revenueByViews['max']!),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildRevenueEstimate(String label, int amount) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '¥${_formatNumber(amount)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildRevenueGuideCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber[700], size: 24),
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
          Text(
            'TikTok同様、動画の1再生あたりの収益は、プログラムや動画の質により約0.02円〜0.08円程度です。',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildRevenueExample('1万回再生', '200円〜800円'),
          _buildRevenueExample('10万回再生', '2,000円〜8,000円'),
          _buildRevenueExample('100万回再生', '20,000円〜80,000円'),
        ],
      ),
    );
  }
  
  Widget _buildRevenueExample(String views, String revenue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            views,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            revenue,
            style: TextStyle(
              color: Colors.amber[900],
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMiniStat({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildGiftHistoryItem(Map<String, dynamic> item, DateTime timestamp) {
    final amount = item['amount'] as int;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.card_giftcard, color: Colors.amber, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ギフト収益',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(timestamp),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+¥${_formatNumber(amount)}',
            style: const TextStyle(
              color: Colors.green,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildViewHistoryItem(Map<String, dynamic> item, DateTime timestamp) {
    final viewCount = item['viewCount'] as int;
    final revenue = item['revenue'] as int;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.play_circle, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '再生収益',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatViewCount(viewCount)} • ${_formatTimestamp(timestamp)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+¥${_formatNumber(revenue)}',
            style: const TextStyle(
              color: Colors.green,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFanMemberCard(FanClubMembership member, int rank) {
    Color rankColor;
    IconData rankIcon;
    
    if (rank <= 3) {
      rankColor = rank == 1 ? Colors.amber : rank == 2 ? Colors.grey[400]! : Colors.brown[300]!;
      rankIcon = Icons.emoji_events;
    } else {
      rankColor = Colors.blue[300]!;
      rankIcon = Icons.star;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey[300],
                child: Text(
                  member.getBadgeEmoji(),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: rankColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(rankIcon, color: Colors.white, size: 12),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'メンバー #${member.userId.substring(0, 8)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.purple[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Lv.${member.memberLevel} ${member.memberTier}',
                        style: TextStyle(
                          color: Colors.purple[700],
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '累計ギフト: ¥${member.totalGiftValue} • ハート: ${member.totalHearts}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '#$rank',
            style: TextStyle(
              color: rankColor,
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
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inDays > 0) {
      return '${diff.inDays}日前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}時間前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分前';
    } else {
      return 'たった今';
    }
  }
}
