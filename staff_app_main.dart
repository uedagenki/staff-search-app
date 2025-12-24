import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'screens/reviews_screen.dart';
import 'screens/support_chat_screen.dart';
import 'screens/plan_management_screen.dart';
import 'screens/staff/staff_content_management_screen.dart';
import 'screens/staff/staff_tips_screen.dart';

void main() {
  runApp(const StaffApp());
}

class StaffApp extends StatelessWidget {
  const StaffApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Staff Search - スタッフアプリ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0a0a0a),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: const StaffHomePage(),
    );
  }
}

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({super.key});

  @override
  State<StaffHomePage> createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  int _selectedIndex = 0;
  bool _isOnline = false;

  final List<Widget> _pages = const [
    DashboardPage(),
    PostsManagementPage(),
    BookingsPage(),
    MessagesPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スタッフ管理'),
        actions: [
          // オンライン/オフライン切り替え
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Switch(
              value: _isOnline,
              onChanged: (value) {
                setState(() => _isOnline = value);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isOnline ? '出勤状態になりました' : '退勤状態になりました'),
                    backgroundColor: _isOnline ? Colors.green : Colors.grey,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
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
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0a0a0a),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'ダッシュボード',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add),
            label: '投稿',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '予約',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'メッセージ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'プロフィール',
          ),
        ],
      ),
    );
  }
}

// ダッシュボードページ
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? _staffProfile;

  @override
  void initState() {
    super.initState();
    _loadStaffProfile();
  }

  void _loadStaffProfile() {
    try {
      final profileJson = html.window.localStorage['staff_profile'];
      if (profileJson != null && profileJson.isNotEmpty) {
        setState(() {
          _staffProfile = json.decode(profileJson);
        });
      }
    } catch (e) {
      print('Failed to load staff profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffName = _staffProfile?['name'] ?? 'スタッフ';
    final jobTitle = _staffProfile?['jobTitle'] ?? '職種未設定';
    final plan = _staffProfile?['plan'] ?? 'free';
    final profileImages = _staffProfile?['profileImages'] as List<dynamic>? ?? [];
    final hasPhoto = profileImages.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // スタッフ情報カード
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: hasPhoto && profileImages[0]['data'] != null
                        ? MemoryImage(
                            UriData.parse(profileImages[0]['data']).contentAsBytes(),
                          )
                        : null,
                    child: hasPhoto ? null : const Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          staffName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          jobTitle,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'プロフェッショナル',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 統計情報
          const Text(
            '今月の実績',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '予約数',
                  '45',
                  Icons.calendar_today,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '売上',
                  '¥380K',
                  Icons.attach_money,
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
                  'フォロワー',
                  '8,920',
                  Icons.people,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'ギフト',
                  '¥245K',
                  Icons.card_giftcard,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // クイックアクション
          const Text(
            'クイックアクション',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            'プレビューを見る',
            Icons.preview,
            const Color(0xFF667eea),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePreviewPage()),
              );
            },
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            '新規投稿',
            Icons.add_a_photo,
            Colors.blue,
            () {},
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            'ライブ配信開始',
            Icons.videocam,
            Colors.red,
            () {},
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            'メッセージ確認',
            Icons.message,
            const Color(0xFF0a0a0a),
            () {},
          ),
          const SizedBox(height: 20),
          // 本日の予約
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '本日の予約',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('すべて見る'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildBookingCard(
            '田中 美咲',
            '10:00 - 11:30',
            'カット＆カラー',
            '確定',
          ),
          _buildBookingCard(
            '山田 花子',
            '14:00 - 15:00',
            'カット',
            '確定',
          ),
          _buildBookingCard(
            '佐藤 太郎',
            '16:30 - 18:00',
            'パーマ',
            '確定',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(String name, String time, String service, String status) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: Text(name[0]),
        ),
        title: Text(name, style: const TextStyle(fontSize: 14)),
        subtitle: Text('$time\n$service', style: const TextStyle(fontSize: 12)),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            '確定',
            style: TextStyle(
              color: Colors.green,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// 投稿管理ページ
class PostsManagementPage extends StatelessWidget {
  const PostsManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: Color(0xFF0a0a0a),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF0a0a0a),
              tabs: [
                Tab(text: '写真'),
                Tab(text: '動画'),
                Tab(text: 'ストーリーズ'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('新規投稿'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0a0a0a),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildPhotoGrid(),
                _buildVideoGrid(),
                _buildStoryGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 40, color: Colors.grey),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite, color: Colors.white, size: 12),
                      SizedBox(width: 2),
                      Text('234', style: TextStyle(color: Colors.white, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideoGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: Colors.grey[300],
                child: const Icon(Icons.play_circle_outline, size: 50, color: Colors.grey),
              ),
              const Positioned(
                top: 4,
                left: 4,
                child: Icon(Icons.videocam, color: Colors.white, size: 16),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow, color: Colors.white, size: 12),
                      SizedBox(width: 2),
                      Text('1.2K', style: TextStyle(color: Colors.white, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStoryGrid() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.photo_library, color: Colors.grey),
            ),
            title: Text('ストーリーズ ${index + 1}'),
            subtitle: const Text('24時間前 • 閲覧数: 456'),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'view', child: Text('表示')),
                const PopupMenuItem(value: 'delete', child: Text('削除')),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 予約管理ページ
class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildBookingItem(
          '田中 美咲',
          '2024/12/23 10:00',
          'カット＆カラー',
          '¥12,000',
          '確定',
          Colors.green,
        ),
        _buildBookingItem(
          '山田 花子',
          '2024/12/23 14:00',
          'カット',
          '¥5,000',
          '確定',
          Colors.green,
        ),
        _buildBookingItem(
          '佐藤 太郎',
          '2024/12/24 16:30',
          'パーマ',
          '¥15,000',
          '保留中',
          Colors.orange,
        ),
        _buildBookingItem(
          '鈴木 一郎',
          '2024/12/25 11:00',
          'トリートメント',
          '¥8,000',
          '確定',
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildBookingItem(
    String name,
    String datetime,
    String service,
    String price,
    String status,
    Color statusColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              datetime,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              service,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('詳細', style: TextStyle(fontSize: 13)),
                    ),
                    const SizedBox(width: 4),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0a0a0a),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('確認', style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// メッセージページ
class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person),
              ),
              if (index < 3)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            index == 0 ? '田中 美咲' : index == 1 ? '山田 花子' : index == 2 ? '佐藤 太郎' : 'ユーザー ${index + 1}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            index == 0
                ? '明日の予約についてですが...'
                : index == 1
                    ? 'ありがとうございました！'
                    : '料金について確認したいのですが',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                index == 0 ? '10分前' : index == 1 ? '1時間前' : '昨日',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              if (index < 2)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailPage(
                  userName: index == 0 ? '田中 美咲' : index == 1 ? '山田 花子' : '佐藤 太郎',
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// チャット詳細ページ
class ChatDetailPage extends StatelessWidget {
  final String userName;

  const ChatDetailPage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userName),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMessage('こんにちは！', false, '10:30'),
                _buildMessage('明日の予約についてですが、時間を30分遅らせることは可能でしょうか？', false, '10:31'),
                _buildMessage('はい、大丈夫ですよ！14:30からに変更しますね。', true, '10:35'),
                _buildMessage('ありがとうございます！助かります。', false, '10:36'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'メッセージを入力...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF0a0a0a),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(String text, bool isSent, String time) {
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isSent ? const Color(0xFF0a0a0a) : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isSent ? Colors.white : Colors.black,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isSent ? Colors.white70 : Colors.black54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// プロフィールページ
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = '小林 さくら';
  String _jobTitle = 'カリスマ美容師';
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    final loggedIn = html.window.localStorage['staff_logged_in'];
    debugPrint('🔍 Login status check: staff_logged_in = $loggedIn');
    debugPrint('🔍 staff_profile exists: ${html.window.localStorage['staff_profile'] != null}');
    
    if (loggedIn != 'true') {
      // ログインしていない場合、ダイアログを表示
      debugPrint('❌ Not logged in, showing dialog');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLoginRequiredDialog();
      });
    } else {
      debugPrint('✅ Logged in, loading profile data');
      _loadProfileData();
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('ログインが必要です'),
        content: const Text('スタッフアプリの機能を使用するにはログインしてください。'),
        actions: [
          TextButton(
            onPressed: () {
              // スタッフログインページにリダイレクト（同一ポート5061）
              html.window.location.href = 'https://5061-ivmmk44rjvkdnze0ep01h-5185f4aa.sandbox.novita.ai/staff_login.html';
            },
            child: const Text('ログイン'),
          ),
        ],
      ),
    );
  }

  void _loadProfileData() {
    try {
      final profileJson = html.window.localStorage['staff_profile'];
      debugPrint('📄 Profile JSON length: ${profileJson?.length ?? 0}');
      
      if (profileJson != null) {
        final profile = json.decode(profileJson) as Map<String, dynamic>;
        debugPrint('👤 Profile name: ${profile['name']}');
        debugPrint('💼 Profile jobTitle: ${profile['jobTitle']}');
        debugPrint('📷 Profile images count: ${(profile['profileImages'] as List?)?.length ?? 0}');
        
        setState(() {
          _name = profile['name'] ?? '小林 さくら';
          _jobTitle = profile['jobTitle'] ?? 'カリスマ美容師';
          // プロフィール画像の最初の1枚を使用
          if (profile['profileImages'] != null && (profile['profileImages'] as List).isNotEmpty) {
            final firstImage = (profile['profileImages'] as List).first;
            // Base64データの場合とオブジェクトの場合を両方処理
            if (firstImage is String) {
              _profileImageUrl = firstImage;
            } else if (firstImage is Map && firstImage['data'] != null) {
              _profileImageUrl = firstImage['data'];
            }
            debugPrint('🖼️ Profile image URL set: ${_profileImageUrl?.substring(0, 50)}...');
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to load profile data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // プロフィールヘッダー
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: const Color(0xFF0a0a0a),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _profileImageUrl != null 
                    ? NetworkImage(_profileImageUrl!)
                    : null,
                  child: _profileImageUrl == null 
                    ? const Icon(Icons.person, size: 50)
                    : null,
                ),
                const SizedBox(height: 14),
                Text(
                  _name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _jobTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatColumn('8.9K', 'フォロワー'),
                    Container(
                      width: 1,
                      height: 35,
                      color: Colors.white24,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    _buildStatColumn('5.0', '評価'),
                    Container(
                      width: 1,
                      height: 35,
                      color: Colors.white24,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    _buildStatColumn('¥2.45M', 'ギフト総額'),
                  ],
                ),
              ],
            ),
          ),
          // メニュー項目
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildMenuItem(
                context,
                Icons.edit,
                'プロフィール編集',
                () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileEditPage()),
                  );
                  // プロフィール編集から戻ってきたらデータをリロード
                  if (result == true) {
                    _loadProfileData();
                  }
                },
              ),
              _buildMenuItem(context, Icons.image, 'ポートフォリオ', () {}),
              _buildMenuItem(
                context,
                Icons.star,
                'レビュー管理',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReviewsScreen()),
                  );
                },
              ),
              _buildMenuItem(
                context,
                Icons.card_giftcard,
                'チップ管理',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StaffTipsScreen()),
                  );
                },
              ),
              _buildMenuItem(
                context,
                Icons.shield,
                'コンテンツ管理',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StaffContentManagementScreen()),
                  );
                },
              ),
              _buildMenuItem(
                context,
                Icons.workspace_premium,
                'プラン管理',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PlanManagementScreen()),
                  );
                },
              ),
              _buildMenuItem(context, Icons.schedule, '営業時間設定', () {}),
              _buildMenuItem(context, Icons.payments, '料金設定', () {}),
              _buildMenuItem(context, Icons.analytics, '分析', () {}),
              _buildMenuItem(context, Icons.notifications, '通知設定', () {}),
              _buildMenuItem(
                context,
                Icons.support_agent,
                '運営に問い合わせ',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SupportChatScreen()),
                  );
                },
              ),
              _buildMenuItem(context, Icons.help, 'ヘルプ', () {}),
              const Divider(),
              _buildMenuItem(context, Icons.logout, 'ログアウト', () {
                _showLogoutDialog(context);
              }, isDestructive: true),
            ],
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ログアウト'),
        content: const Text('ログアウトしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              // LocalStorageをクリア
              html.window.localStorage.clear();
              
              // スタッフログインページにリダイレクト
              html.window.location.href = 'staff_login.html';
            },
            child: const Text(
              'ログアウト',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}

// プロフィール編集ページ
class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final List<String> _photos = List.generate(5, (index) => '');
  String _selectedGender = '女性';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール編集'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('プロフィールを保存しました')),
              );
            },
            child: const Text(
              '保存',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 写真セクション
            const Text(
              'プロフィール写真（最大5枚）',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      onTap: () {
                        // 写真追加処理
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: _photos[index].isEmpty
                            ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // 基本情報
            const Text(
              '基本情報',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: '名前',
                border: OutlineInputBorder(),
                hintText: '小林 さくら',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '職種',
                border: OutlineInputBorder(),
                hintText: 'カリスマ美容師',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '年齢',
                border: OutlineInputBorder(),
                hintText: '28',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: '性別',
                border: OutlineInputBorder(),
              ),
              items: ['女性', '男性', 'その他'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '住所',
                border: OutlineInputBorder(),
                hintText: '東京都渋谷区',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '自己紹介',
                border: OutlineInputBorder(),
                hintText: 'トレンド最先端のヘアスタイルをライブ配信中！',
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '経験年数',
                border: OutlineInputBorder(),
                hintText: '7',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// プロフィールプレビューページ
class ProfilePreviewPage extends StatelessWidget {
  const ProfilePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィールプレビュー'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // プロフィール画像スライダー
            SizedBox(
              height: 400,
              child: PageView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.person, size: 100, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '小林 さくら',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'カリスマ美容師',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'プロフェッショナル',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat('8.9K', 'フォロワー'),
                      _buildStat('5.0', '評価'),
                      _buildStat('456', 'レビュー'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '自己紹介',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'トレンド最先端のヘアスタイルをライブ配信中！一緒に可愛くなりましょう💕',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '詳細情報',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.work, '経験年数', '7年'),
                  _buildInfoRow(Icons.location_on, '勤務地', '東京都渋谷区'),
                  _buildInfoRow(Icons.store, '所属店舗', 'Sakura Beauty Studio 渋谷'),
                  const SizedBox(height: 24),
                  const Text(
                    'スキル',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['トレンドカット', 'カラーリスト', 'ヘアアレンジ', 'メイク'].map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          skill,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
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
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
