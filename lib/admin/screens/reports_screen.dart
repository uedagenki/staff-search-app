import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../utils/storage_helper.dart';
import '../../services/export_service.dart';
import 'dart:convert';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _exportService = ExportService();
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _handleExport(String type) async {
    try {
      String? result;
      
      switch (type) {
        case 'users':
          result = await _exportService.exportUsersToCSV();
          break;
        case 'staff':
          result = await _exportService.exportStaffToCSV();
          break;
        case 'bookings':
          result = await _exportService.exportBookingsToCSV();
          break;
        case 'pdf':
          await _exportService.exportStatsToPDF(
            stats: _stats,
            title: 'Staff Finder 統計レポート',
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PDFレポートを生成しました'),
                backgroundColor: Colors.green,
              ),
            );
          }
          return;
      }

      if (mounted) {
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('エクスポートしました${!kIsWeb ? ": $result" : ""}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('エクスポートに失敗しました'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Export error: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラー: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // サンプル統計データを生成
      _stats = {
        'users': {
          'total': 1250,
          'active': 980,
          'new_this_month': 125,
          'growth_rate': 12.5,
        },
        'staff': {
          'total': 185,
          'active': 160,
          'new_this_month': 15,
          'growth_rate': 8.8,
        },
        'bookings': {
          'total': 3420,
          'this_month': 420,
          'pending': 25,
          'completed': 3200,
          'cancelled': 195,
        },
        'revenue': {
          'total': 12500000,
          'this_month': 1850000,
          'average_booking': 3650,
          'growth_rate': 15.2,
        },
        'engagement': {
          'posts': 2340,
          'comments': 5680,
          'likes': 15200,
          'shares': 890,
        },
        'monthly_growth': [
          {'month': '7月', 'users': 920, 'bookings': 280},
          {'month': '8月', 'users': 1050, 'bookings': 310},
          {'month': '9月', 'users': 1180, 'bookings': 360},
          {'month': '10月', 'users': 1250, 'bookings': 420},
        ],
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load statistics: $e');
      }
    } finally {
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
        title: const Text('レポート・統計'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '更新',
            onPressed: _loadStatistics,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'エクスポート',
            onPressed: () {
              ExportService.showExportMenu(
                context: context,
                onExportUsers: () => _handleExport('users'),
                onExportStaff: () => _handleExport('staff'),
                onExportBookings: () => _handleExport('bookings'),
                onExportPDF: () => _handleExport('pdf'),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 概要カード
                  Text(
                    '概要統計',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildOverviewCards(),
                  
                  const SizedBox(height: 32),

                  // 売上統計
                  Text(
                    '売上統計',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildRevenueCards(),

                  const SizedBox(height: 32),

                  // エンゲージメント統計
                  Text(
                    'エンゲージメント統計',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildEngagementCards(),

                  const SizedBox(height: 32),

                  // 月次成長グラフ
                  Text(
                    '月次成長トレンド',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildMonthlyGrowthChart(),

                  const SizedBox(height: 32),

                  // 予約統計
                  Text(
                    '予約統計',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildBookingStats(),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewCards() {
    final users = _stats['users'] as Map<String, dynamic>;
    final staff = _stats['staff'] as Map<String, dynamic>;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'ユーザー数',
            value: '${users['total']}',
            subtitle: '今月 +${users['new_this_month']}',
            icon: Icons.people,
            color: Colors.blue,
            trend: users['growth_rate'],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'スタッフ数',
            value: '${staff['total']}',
            subtitle: '今月 +${staff['new_this_month']}',
            icon: Icons.work,
            color: Colors.green,
            trend: staff['growth_rate'],
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueCards() {
    final revenue = _stats['revenue'] as Map<String, dynamic>;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: '総売上',
                value: '¥${_formatNumber(revenue['total'])}',
                subtitle: '今月 ¥${_formatNumber(revenue['this_month'])}',
                icon: Icons.attach_money,
                color: Colors.purple,
                trend: revenue['growth_rate'],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: '平均単価',
                value: '¥${_formatNumber(revenue['average_booking'])}',
                subtitle: '1予約あたり',
                icon: Icons.receipt,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEngagementCards() {
    final engagement = _stats['engagement'] as Map<String, dynamic>;

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          title: '投稿',
          value: '${engagement['posts']}',
          icon: Icons.article,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'コメント',
          value: '${engagement['comments']}',
          icon: Icons.comment,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'いいね',
          value: '${_formatNumber(engagement['likes'])}',
          icon: Icons.favorite,
          color: Colors.red,
        ),
        _buildStatCard(
          title: 'シェア',
          value: '${engagement['shares']}',
          icon: Icons.share,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildMonthlyGrowthChart() {
    final monthlyData = _stats['monthly_growth'] as List<dynamic>;
    final maxUsers = monthlyData.map((d) => d['users'] as int).reduce((a, b) => a > b ? a : b);
    final maxBookings = monthlyData.map((d) => d['bookings'] as int).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('ユーザー数'),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('予約数'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: monthlyData.map((data) {
                  final users = data['users'] as int;
                  final bookings = data['bookings'] as int;
                  final month = data['month'] as String;
                  
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 30,
                                height: (users / maxUsers * 150),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 30,
                                height: (bookings / maxBookings * 150),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            month,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingStats() {
    final bookings = _stats['bookings'] as Map<String, dynamic>;
    final total = bookings['total'] as int;
    final completed = bookings['completed'] as int;
    final cancelled = bookings['cancelled'] as int;
    final pending = bookings['pending'] as int;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProgressRow(
              '完了',
              completed,
              total,
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildProgressRow(
              'キャンセル',
              cancelled,
              total,
              Colors.red,
            ),
            const SizedBox(height: 16),
            _buildProgressRow(
              '保留中',
              pending,
              total,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRow(String label, int value, int total, Color color) {
    final percentage = (value / total * 100).toStringAsFixed(1);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '$value件 ($percentage%)',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / total,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
    double? trend,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                if (trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: trend >= 0 ? Colors.green[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trend >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 12,
                          color: trend >= 0 ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${trend.abs().toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: trend >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
