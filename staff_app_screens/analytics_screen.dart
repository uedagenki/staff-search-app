import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, dynamic> _analytics = {};

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  void _loadAnalytics() {
    try {
      // メッセージ数を取得
      final messagesJson = html.window.localStorage['chat_messages'];
      int messageCount = 0;
      if (messagesJson != null && messagesJson.isNotEmpty) {
        final messages = jsonDecode(messagesJson) as List;
        final staffProfile = html.window.localStorage['staff_profile'];
        if (staffProfile != null) {
          final profile = jsonDecode(staffProfile) as Map<String, dynamic>;
          final staffId = profile['id'] ?? profile['email'];
          messageCount = messages.where((m) => m['receiverId'] == staffId).length;
        }
      }

      // プロフィール閲覧数（模擬データ）
      final profileViews = (messageCount * 3.5).round();

      // フォロワー数（LocalStorageから取得、なければ模擬データ）
      final followersJson = html.window.localStorage['staff_followers'];
      int followerCount = 0;
      if (followersJson != null && followersJson.isNotEmpty) {
        final followers = jsonDecode(followersJson) as List;
        followerCount = followers.length;
      } else {
        followerCount = (messageCount * 0.8).round();
      }

      // レビュー数
      final reviewsJson = html.window.localStorage['staff_reviews'];
      int reviewCount = 0;
      double avgRating = 0.0;
      if (reviewsJson != null && reviewsJson.isNotEmpty) {
        final reviews = jsonDecode(reviewsJson) as List;
        reviewCount = reviews.length;
        if (reviewCount > 0) {
          final totalRating = reviews.fold(0.0, (sum, r) => sum + (r['rating'] ?? 0.0));
          avgRating = totalRating / reviewCount;
        }
      }

      setState(() {
        _analytics = {
          'profileViews': profileViews,
          'messageCount': messageCount,
          'followerCount': followerCount,
          'reviewCount': reviewCount,
          'avgRating': avgRating,
          'weeklyGrowth': '+12%', // 模擬データ
          'popularTime': '14:00-18:00', // 模擬データ
        };
      });
    } catch (e) {
      debugPrint('分析データの読み込みエラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('分析'),
        actions: [
          IconButton(
            onPressed: _loadAnalytics,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadAnalytics();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 概要カード
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '概要',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                            Icons.visibility,
                            '閲覧数',
                            _analytics['profileViews']?.toString() ?? '0',
                            Colors.blue,
                          ),
                          _buildStatCard(
                            Icons.message,
                            'メッセージ',
                            _analytics['messageCount']?.toString() ?? '0',
                            Colors.green,
                          ),
                          _buildStatCard(
                            Icons.people,
                            'フォロワー',
                            _analytics['followerCount']?.toString() ?? '0',
                            Colors.purple,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 評価カード
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '評価',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Icon(Icons.star, color: Colors.amber[600], size: 48),
                              const SizedBox(height: 8),
                              Text(
                                _analytics['avgRating']?.toStringAsFixed(1) ?? '0.0',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '平均評価',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(Icons.rate_review, color: Colors.blue[600], size: 48),
                              const SizedBox(height: 8),
                              Text(
                                _analytics['reviewCount']?.toString() ?? '0',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'レビュー数',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 成長率カード
              Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.trending_up, color: Colors.green),
                  ),
                  title: const Text('週間成長率'),
                  trailing: Text(
                    _analytics['weeklyGrowth'] ?? '+0%',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // 人気時間帯カード
              Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.access_time, color: Colors.orange),
                  ),
                  title: const Text('人気時間帯'),
                  trailing: Text(
                    _analytics['popularTime'] ?? '-',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // ヒントセクション
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          '改善のヒント',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildHintItem('プロフィール写真を更新して注目度アップ'),
                    _buildHintItem('ポートフォリオを充実させましょう'),
                    _buildHintItem('人気時間帯にオンライン状態に'),
                    _buildHintItem('定期的に新しい投稿を追加'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildHintItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
