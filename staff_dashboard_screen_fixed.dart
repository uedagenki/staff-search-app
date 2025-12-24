import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'staff_posts_management_screen.dart';
import 'staff_bookings_screen.dart';
import 'staff_tips_screen.dart';
import 'staff_profile_edit_screen.dart';
import '../staff_messages_screen.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  int _currentIndex = 0;
  String _staffName = 'スタッフ';
  String _jobTitle = '';
  String _companyName = '';
  String _storeName = '';
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _loadStaffInfo();
  }

  Future<void> _loadStaffInfo() async {
    final prefs = await SharedPreferences.getInstance();
    
    // LocalStorageからstaff_profileを取得
    final profileJson = html.window.localStorage['staff_profile'];
    if (profileJson != null) {
      try {
        final profileData = json.decode(profileJson);
        setState(() {
          _staffName = profileData['name'] ?? 'スタッフ';
          _jobTitle = profileData['jobTitle'] ?? '';
          _companyName = profileData['companyName'] ?? '';
          _storeName = profileData['storeName'] ?? '';
        });
      } catch (e) {
        // JSONパースエラー
      }
    }
    
    setState(() {
      _isOnline = prefs.getBool('staff_is_online') ?? false;
    });
  }

  Future<void> _toggleOnlineStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isOnline = !_isOnline;
    });
    await prefs.setBool('staff_is_online', _isOnline);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isOnline ? '出勤状態になりました' : '退勤状態になりました'),
          backgroundColor: _isOnline ? Colors.green : Colors.grey,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スタッフ管理画面'),
        actions: [
          // オンライン/オフライン切り替え
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Switch(
              value: _isOnline,
              onChanged: (value) => _toggleOnlineStatus(),
              activeTrackColor: Colors.green,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                _isOnline ? '出勤中' : '退勤中',
                style: TextStyle(
                  color: _isOnline ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'ダッシュボード',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add),
            label: '投稿管理',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '予約管理',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'チップ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'プロフィール',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // プロフィールタブから戻った時にデータを再読み込み
          if (_currentIndex == 0) {
            _loadStaffInfo();
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return const StaffPostsManagementScreen();
      case 2:
        return const StaffBookingsScreen();
      case 3:
        return const StaffTipsScreen();
      case 4:
        return const StaffProfileEditScreen();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ウェルカムメッセージ
          Text(
            'ようこそ、$_staffNameさん',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (_jobTitle.isNotEmpty)
            Text(
              _jobTitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          if (_storeName.isNotEmpty || _companyName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${_storeName.isNotEmpty ? _storeName : _companyName}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            _isOnline ? '出勤中です' : '現在退勤中です',
            style: TextStyle(
              fontSize: 16,
              color: _isOnline ? Colors.green : Colors.grey,
            ),
          ),

          const SizedBox(height: 32),

          // 統計情報カード
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '今日の予約',
                  '5件',
                  Icons.calendar_today,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '今月のチップ',
                  '¥45,000',
                  Icons.monetization_on,
                  Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '総投稿数',
                  '24件',
                  Icons.photo_library,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '評価',
                  '4.8⭐',
                  Icons.star,
                  Colors.amber,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // クイックアクション
          const Text(
            'クイックアクション',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildActionButton(
            '新規投稿',
            Icons.add_a_photo,
            Colors.blue,
            () {
              setState(() {
                _currentIndex = 1;
              });
            },
          ),
          const SizedBox(height: 12),

          _buildActionButton(
            'ライブ配信開始',
            Icons.videocam,
            Colors.red,
            () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('ライブ配信'),
                  content: const Text('ライブ配信を開始しますか？\n\n本番環境では実際のライブストリーミング機能が利用可能です。'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('キャンセル'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ライブ配信を開始しました（デモ）'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      child: const Text('開始'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildActionButton(
            'メッセージ確認',
            Icons.message,
            Colors.blue[700]!,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StaffMessagesScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildActionButton(
            '予約確認',
            Icons.event_available,
            Colors.green,
            () {
              setState(() {
                _currentIndex = 2;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
