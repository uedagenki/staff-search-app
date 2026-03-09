import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/staff.dart';
import '../../services/local_booking_service.dart';
import '../../services/local_auth_service.dart';
import '../staff_detail_screen.dart';
import 'staff_posts_management_screen.dart';
import 'staff_tips_screen.dart';
import 'staff_management_profile_screen.dart';
import 'staff_booking_management_screen.dart';
import 'staff_coupon_management_screen.dart';
import 'staff_menu_management_screen.dart';
import 'revenue_dashboard_screen.dart';
import '../staff_messages_screen.dart';
import '../booking_system_debug_screen.dart';
import '../staff_received_offers_screen.dart';
import '../live_league_screen.dart';
import '../live_shard_screen.dart';
import '../create_collab_screen.dart';
import '../../models/live_collab_system.dart';

class StaffDashboardScreen extends StatefulWidget {
  final String? userId; // ユーザーIDを受け取る
  
  const StaffDashboardScreen({super.key, this.userId});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  final _bookingService = LocalBookingService();
  final _authService = LocalAuthService();
  int _currentIndex = 0;
  String _staffName = 'スタッフ';
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _loadStaffInfo();
    _initializeDemoData();
  }

  Future<void> _initializeDemoData() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null && user.role == 'staff') {
        // デモ予約データを作成
        await _bookingService.createDemoBookings(user.id, user.name);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('デモデータ作成エラー: $e');
      }
    }
  }

  Future<void> _loadStaffInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _staffName = prefs.getString('staff_name') ?? 'スタッフ';
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
        return const StaffBookingManagementScreen();
      case 3:
        return const StaffTipsScreen();
      case 4:
        return const StaffManagementProfileScreen();
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateCollabScreen(
                    initialMode: CollabMode.solo,
                    autoStartIfSolo: true,
                  ),
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
            '🎥 コラボ配信開始',
            Icons.live_tv,
            Colors.red,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateCollabScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildActionButton(
            'スタッフプレビュー確認',
            Icons.visibility,
            Colors.purple,
            () {
              _showStaffPreview();
            },
          ),
          const SizedBox(height: 12),

          _buildActionButton(
            '予約確認',
            Icons.event_available,
            Colors.green,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StaffBookingManagementScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildActionButton(
            'クーポン管理',
            Icons.local_offer,
            Colors.orange,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StaffCouponManagementScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildActionButton(
            '収益ダッシュボード',
            Icons.analytics,
            Colors.purple[700]!,
            () async {
              final user = await _authService.getCurrentUser();
              if (user != null && mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RevenueDashboardScreen(staffId: user.id),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 12),

          _buildActionButton(
            '予約管理',
            Icons.calendar_month,
            Colors.blue[600]!,
            () {
              setState(() {
                _currentIndex = 2;
              });
            },
          ),
          const SizedBox(height: 12),

          _buildActionButton(
            'メニュー管理',
            Icons.menu_book,
            Colors.teal,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StaffMenuManagementScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildActionButton(
            '店舗からのオファー',
            Icons.mail,
            Colors.purple,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StaffReceivedOffersScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildActionButton(
            '🏆 ライブリーグ',
            Icons.emoji_events,
            Colors.amber,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LiveLeagueScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildActionButton(
            '✨ かけらコレクション',
            Icons.star,
            Colors.pink,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LiveShardScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildActionButton(
            'データ初期化（デバッグ）',
            Icons.bug_report,
            Colors.red,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookingSystemDebugScreen(),
                ),
              );
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

  void _showStaffPreview() async {
    try {
      // SharedPreferencesから現在のスタッフプロフィールを読み込み
      final prefs = await SharedPreferences.getInstance();
      final staffProfileJson = prefs.getString('current_staff_profile');
      
      if (staffProfileJson == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('プロフィールが保存されていません。先にプロフィール編集から保存してください。'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final profileData = jsonDecode(staffProfileJson);
      
      // カテゴリーマッピング
      final categories = profileData['categories'] != null
          ? List<String>.from(profileData['categories'])
          : ['beauty_health'];
      final categoryMap = {
        'beauty_health': '美容・健康',
        'sales_consulting': '営業・接客',
        'professional': '専門職',
        'creative': 'クリエイティブ',
        'it_tech': 'IT・技術',
        'education': '教育',
        'medical_care': '医療・介護',
        'other': 'その他',
      };
      final category = categoryMap[categories.first] ?? '美容・健康';

      // Staffオブジェクトを作成
      final staff = Staff(
        id: profileData['id'] ?? 'preview_staff',
        name: profileData['name'] ?? 'スタッフ',
        jobTitle: profileData['jobTitle'] ?? '',
        category: category,
        profileImage: (profileData['profileImages'] as List?)?.isNotEmpty == true
            ? profileData['profileImages'][0]
            : 'https://via.placeholder.com/400',
        profileImages: profileData['profileImages'] != null
            ? List<String>.from(profileData['profileImages'])
            : null,
        rating: (profileData['rating'] ?? 4.8).toDouble(),
        reviewCount: profileData['reviewCount'] ?? 0,
        location: profileData['location'] ?? '',
        experience: int.tryParse(profileData['experience']?.toString() ?? '0') ?? 0,
        bio: profileData['bio'] ?? '',
        skills: (profileData['bio'] as String?)?.isNotEmpty == true
            ? [profileData['jobTitle'] ?? '']
            : ['スキル'],
        latitude: profileData['storeLatitude'] != null
            ? double.tryParse(profileData['storeLatitude'].toString())
            : null,
        longitude: profileData['storeLongitude'] != null
            ? double.tryParse(profileData['storeLongitude'].toString())
            : null,
        isOnline: _isOnline,
        isLive: false,
        qrCode: profileData['qrCode'] ?? 'qr_preview',
        storeName: profileData['storeName'],
        companyName: profileData['companyName'],
        followersCount: profileData['followersCount'] ?? 0,
        giftAmount: (profileData['giftAmount'] ?? 0.0).toDouble(),
        categoryRank: profileData['categoryRank'] ?? 1,
        totalStaffInCategory: profileData['totalStaffInCategory'] ?? 100,
      );

      if (kDebugMode) {
        debugPrint('✅ スタッフプレビュー表示: ${staff.name}');
        debugPrint('📷 写真数: ${staff.profileImages.length}');
      }

      // ユーザーアプリと同じStaffDetailScreenで表示
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StaffDetailScreen(staff: staff),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ プレビュー表示エラー: $e');
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('プレビュー表示に失敗しました'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
