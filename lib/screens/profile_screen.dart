import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:convert';
import '../services/tip_service.dart';
import '../services/gifter_service.dart';
import '../models/gifter_level.dart';
import 'following_screen.dart';
import 'bookings_screen.dart';
import 'tip_history_screen.dart';
import 'my_reviews_screen.dart';
import 'profile_settings_screen.dart';
import 'staff/staff_dashboard_screen.dart';
import 'ranking_screen.dart';
import 'headhunt_screen.dart';
import 'help_support_screen.dart';
import 'webview_screen.dart';
import 'admin/content_moderation_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TipService _tipService = TipService();
  double _totalTips = 0.0;
  bool _isLoading = true;
  
  // ユーザー情報
  String _userName = 'ゲストユーザー';
  String _userEmail = 'guest@example.com';
  int? _userAge;
  String? _userAddress;
  String? _userGender;
  List<String> _userCategories = [];
  
  // ギフター情報
  late UserGifterInfo _gifterInfo;

  @override
  void initState() {
    super.initState();
    _loadGifterInfo();
    _checkLoginStatus();
    _loadUserProfile();
    _loadTotalTips();
  }
  
  void _loadGifterInfo() {
    setState(() {
      _gifterInfo = GifterService.getGifterInfo();
    });
  }

  void _checkLoginStatus() {
    // アプリ起動時にログイン状態を確認
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isLoggedIn = html.window.localStorage['user_logged_in'];
      if (isLoggedIn == null || isLoggedIn != 'true') {
        _showLoginPrompt();
      }
    });
  }

  void _showLoginPrompt() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            const Text('ログインしてください'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'プロフィール機能を利用するにはログインが必要です。',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'ログイン後、以下の機能が利用できます：',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• プロフィール編集', style: TextStyle(fontSize: 14)),
            Text('• 予約履歴の確認', style: TextStyle(fontSize: 14)),
            Text('• チップ履歴の確認', style: TextStyle(fontSize: 14)),
            Text('• レビューの投稿', style: TextStyle(fontSize: 14)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // ホーム画面に戻る
              Navigator.pop(context);
            },
            child: const Text('後で'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // ログイン画面にリダイレクト
              html.window.location.href = 'user_login.html';
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('ログイン'),
          ),
        ],
      ),
    );
  }

  void _loadUserProfile() {
    try {
      final profileData = html.window.localStorage['user_profile'];
      if (profileData != null) {
        final profile = json.decode(profileData);
        setState(() {
          _userName = profile['name'] ?? 'ゲストユーザー';
          _userEmail = profile['email'] ?? 'guest@example.com';
          _userAge = profile['age'] != null ? int.tryParse(profile['age'].toString()) : null;
          _userAddress = profile['address'];
          _userGender = profile['gender'];
          _userCategories = List<String>.from(profile['categories'] ?? []);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load user profile: $e');
      }
    }
  }

  Future<void> _loadTotalTips() async {
    await _tipService.initializeDemoData();
    final total = await _tipService.getTotalTipsSent();
    setState(() {
      _totalTips = total;
      _isLoading = false;
    });
  }
  
  // 画面再表示時にデータをリロード
  void _refreshData() {
    _loadGifterInfo();
    _loadTotalTips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // プロフィールヘッダー
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Column(
                children: [
                  // プロフィール画像
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _userEmail,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (_userAge != null || _userAddress != null || _userGender != null) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (_userAge != null)
                          Chip(
                            avatar: const Icon(Icons.cake, size: 18),
                            label: Text('$_userAge歳'),
                            backgroundColor: Colors.blue[50],
                          ),
                        if (_userGender != null)
                          Chip(
                            avatar: Icon(
                              _userGender == 'male' ? Icons.male : 
                              _userGender == 'female' ? Icons.female : Icons.person,
                              size: 18,
                            ),
                            label: Text(
                              _userGender == 'male' ? '男性' :
                              _userGender == 'female' ? '女性' : 'その他'
                            ),
                            backgroundColor: Colors.purple[50],
                          ),
                        if (_userAddress != null)
                          Chip(
                            avatar: const Icon(Icons.location_on, size: 18),
                            label: Text(_userAddress!),
                            backgroundColor: Colors.green[50],
                          ),
                      ],
                    ),
                  ],
                  if (_userCategories.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      '興味のあるカテゴリー',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: _userCategories.map((category) {
                        return Chip(
                          label: Text(_getCategoryLabel(category)),
                          backgroundColor: Colors.orange[50],
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // ギフターレベルカード
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildGifterLevelCard(),
            ),
            
            const SizedBox(height: 12),
            
            // チップ総額カード
            if (!_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  elevation: 4,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.payments,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'チップ総送金額',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '¥${_totalTips.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 20),
            
            // メニューリスト
            _buildMenuItem(
              context,
              icon: Icons.people,
              title: 'フォロー中/フォロワー',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FollowingScreen()),
                ).then((_) => _loadTotalTips());
              },
            ),
            
            _buildMenuItem(
              context,
              icon: Icons.emoji_events,
              title: '人気ランキング',
              color: Colors.amber,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RankingScreen()),
                );
              },
            ),
            
            _buildMenuItem(
              context,
              icon: Icons.work,
              title: 'ヘッドハンティング',
              color: Colors.deepPurple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HeadhuntScreen()),
                );
              },
            ),
            
            _buildMenuItem(
              context,
              icon: Icons.calendar_today,
              title: '予約履歴',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BookingsScreen()),
                );
              },
            ),
            
            _buildMenuItem(
              context,
              icon: Icons.payment,
              title: 'チップ送信履歴',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TipHistoryScreen()),
                ).then((_) => _loadTotalTips());
              },
            ),
            
            _buildMenuItem(
              context,
              icon: Icons.rate_review,
              title: 'レビュー管理',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyReviewsScreen()),
                );
              },
            ),
            
            const Divider(height: 32),
            
            // スタッフ管理画面へのアクセス
            _buildMenuItem(
              context,
              icon: Icons.business_center,
              title: 'スタッフ管理画面',
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StaffDashboardScreen()),
                );
              },
            ),
            
            _buildMenuItem(
              context,
              icon: Icons.settings,
              title: 'プロフィール設定',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileSettingsScreen()),
                );
              },
            ),
            
            _buildMenuItem(
              context,
              icon: Icons.admin_panel_settings,
              title: 'コンテンツ管理（管理者）',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContentModerationScreen()),
                );
              },
            ),
            
            _buildMenuItem(
              context,
              icon: Icons.help_outline,
              title: 'ヘルプ・サポート',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpSupportScreen(),
                  ),
                );
              },
            ),
            
            _buildMenuItem(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'プライバシーポリシー',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebViewScreen(
                      url: 'https://5060-ivmmk44rjvkdnze0ep01h-5185f4aa.sandbox.novita.ai/privacy_policy.html',
                      title: 'プライバシーポリシー',
                    ),
                  ),
                );
              },
            ),
            
            _buildMenuItem(
              context,
              icon: Icons.description_outlined,
              title: '利用規約',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebViewScreen(
                      url: 'https://5060-ivmmk44rjvkdnze0ep01h-5185f4aa.sandbox.novita.ai/terms_of_service.html',
                      title: '利用規約',
                    ),
                  ),
                );
              },
            ),
            
            _buildMenuItem(
              context,
              icon: Icons.info_outline,
              title: 'アプリについて',
              onTap: () {
                _showAboutDialog(context);
              },
            ),
            
            const SizedBox(height: 20),
            
            // ログアウトボタン
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (kDebugMode) {
                      debugPrint('Logout button pressed');
                    }
                    _showLogoutDialog(context);
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'ログアウト',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ギフターレベルカード
  Widget _buildGifterLevelCard() {
    final level = _gifterInfo.currentLevel;
    final progress = _gifterInfo.levelProgress;
    final expToNext = _gifterInfo.expToNextLevel;
    
    // 色をColorオブジェクトに変換
    final cardColor = Color(int.parse(level.color.replaceAll('#', '0xFF')));
    
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cardColor,
              cardColor.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // レベルとバッジ
            Row(
              children: [
                Text(
                  level.badge,
                  style: const TextStyle(fontSize: 36),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ギフターレベル ${level.level}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        level.title,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 経験値バー
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'EXP: ${_gifterInfo.totalExp.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (level.level < 6)
                      Text(
                        '次のレベルまで $expToNext EXP',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      )
                    else
                      const Text(
                        '最高レベル達成！',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 統計情報
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '総ギフト額',
                    '¥${_gifterInfo.totalGiftAmount.toStringAsFixed(0)}',
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white30,
                ),
                Expanded(
                  child: _buildStatItem(
                    'ギフト回数',
                    '${_gifterInfo.giftCount}回',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  String _getCategoryLabel(String category) {
    const categoryMap = {
      'beauty_health': '美容・健康',
      'sales_consulting': '営業・接客',
      'professional': '専門職',
      'creative': 'クリエイティブ',
      'it_tech': 'IT・技術',
      'education': '教育',
      'medical_care': '医療・介護',
      'other': 'その他',
    };
    return categoryMap[category] ?? category;
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ログアウト'),
        content: const Text('ログアウトしてもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                // ローカルストレージをクリア
                html.window.localStorage.clear();
                
                if (kDebugMode) {
                  debugPrint('LocalStorage cleared');
                }
                
                // ダイアログを閉じる
                Navigator.pop(dialogContext);
                
                // 少し待ってからリダイレクト
                Future.delayed(const Duration(milliseconds: 100), () {
                  // ログイン画面にリダイレクト（Web）
                  html.window.location.href = 'user_login.html';
                });
              } catch (e) {
                if (kDebugMode) {
                  debugPrint('Logout error: $e');
                }
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ログアウトに失敗しました: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('ログアウト'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('スタッフサーチについて'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'バージョン: 1.0.0',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'TikTok風UI採用の働く人のSNS配信サービス&QRチップ決済アプリ',
            ),
            SizedBox(height: 12),
            Text(
              '投げ銭市場3,106億円をターゲットにした革新的な人材マッチングプラットフォーム',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}
