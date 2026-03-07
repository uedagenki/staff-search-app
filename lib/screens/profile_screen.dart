import '../utils/storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../services/tip_service.dart';
import '../services/gifter_service.dart';
import '../services/local_auth_service.dart';
import '../models/gifter_level.dart';
import 'login_screen.dart';
import 'following_screen.dart';
import 'staff/staff_registration_screen.dart';
import 'staff/staff_dashboard_screen.dart';

import 'tip_history_screen.dart';
import 'my_reviews_screen.dart';
import 'profile_settings_screen.dart';
import 'ranking_screen.dart';
import 'headhunt_screen.dart';
import 'help_support_screen.dart';
import 'saved_posts_screen.dart';
import 'user_block_management_screen.dart';
import 'booking/user_booking_list_screen.dart';
import 'company/company_management_screen.dart';
import 'company/company_staff_management_screen.dart';
import '../services/company_service.dart';
import 'point_purchase_screen.dart';
import 'point_earn_screen.dart';
import '../services/payment_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TipService _tipService = TipService();
  final GifterService _gifterService = GifterService();
  final LocalAuthService _authService = LocalAuthService();
  final CompanyService _companyService = CompanyService();
  final PaymentService _paymentService = PaymentService();
  double _totalTips = 0.0;
  bool _isLoading = true;
  UserGifterInfo? _gifterInfo;
  
  // ユーザー情報
  String _userName = 'ゲストユーザー';
  String _userEmail = 'guest@example.com';
  int? _userAge;
  String? _userAddress;
  String? _userGender;
  List<String> _userCategories = [];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadUserProfile();
    _loadTotalTips();
    _loadGifterInfo();
  }
  
  void _loadGifterInfo() async {
    final info = await _gifterService.getUserGifterInfo();
    setState(() {
      _gifterInfo = info;
    });
    
    // デモデータがない場合はロード
    if (_gifterInfo == null) {
      await _gifterService.loadDemoData();
      final updatedInfo = await _gifterService.getUserGifterInfo();
      setState(() {
        _gifterInfo = updatedInfo;
      });
    }
  }

  void _checkLoginStatus() {
    // アプリ起動時にログイン状態を確認（Firebase Authentication）
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final isLoggedIn = await _authService.isLoggedIn();
      if (!isLoggedIn) {
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
            onPressed: () async {
              Navigator.pop(context);
              // ログイン画面に遷移
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
              
              // ログインが成功したらプロフィールをリロード
              if (result == true) {
                _loadUserProfile();
                _loadTotalTips();
                _loadGifterInfo();
              }
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

  Future<void> _loadUserProfile() async {
    try {
      // まずFirebase Authenticationからユーザー情報を取得
      final currentUser = await _authService.getCurrentUser();
      if (currentUser != null) {
        setState(() {
          _userName = currentUser.name;
          _userEmail = currentUser.email;
          _userAge = currentUser.age;
          _userAddress = currentUser.address;
          _userGender = currentUser.gender;
          _userCategories = currentUser.interests ?? [];
        });
        return;
      }
      
      // Firebaseにユーザーがいない場合はローカルストレージから読み込み
      final profileData = await StorageHelper.getString('user_profile');
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

  // スタッフモード切り替え処理
  Future<void> _handleStaffModeSwitch() async {
    // ログイン確認
    final isLoggedIn = await _authService.isLoggedIn();
    if (!isLoggedIn) {
      _showLoginPrompt();
      return;
    }

    // 現在のユーザー情報を取得
    final user = await _authService.getCurrentUser();
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ユーザー情報の取得に失敗しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('🔄 スタッフモード切り替え: role=${user.role}, isStaffRegistered=${user.isStaffRegistered}');
    }

    // スタッフ登録済みかチェック
    if (user.isStaffRegistered) {
      // スタッフダッシュボードに遷移
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StaffDashboardScreen(userId: user.id),
        ),
      );
    } else {
      // スタッフ登録画面に遷移
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const StaffRegistrationScreen(),
        ),
      );
      
      // 登録完了後、プロフィールを再読み込み
      if (result == true) {
        _loadUserProfile();
      }
    }
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
            
            // ギフターレベルカード
            if (_gifterInfo != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildGifterLevelCard(_gifterInfo!),
              ),
            
            const SizedBox(height: 20),
            
            // スタッフモード切り替えボタン（TikTokスタイル）
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple[400]!,
                      Colors.pink[400]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _handleStaffModeSwitch(),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.work_outline,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'スタッフモードに切り替え',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'スタッフとして収益を得る',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // メニューリスト
            _buildMenuItem(
              context,
              icon: Icons.bookmark,
              title: '保存済み投稿',
              color: Colors.pink,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SavedPostsScreen()),
                );
              },
            ),
            
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
              icon: Icons.business_center,
              title: '企業管理（ヘッドハンティング用）',
              color: Colors.indigo,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CompanyManagementScreen()),
                );
              },
            ),
            
            _buildMenuItem(
              context,
              icon: Icons.store,
              title: '店舗（会社）管理',
              color: Colors.purple,
              onTap: () async {
                // 現在の企業を取得
                final currentCompany = await _companyService.getCurrentCompany();
                
                if (currentCompany == null) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('先に企業を登録してください'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                  return;
                }
                
                if (!currentCompany.isStore) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('企業を「店舗として登録」に設定してください'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                  return;
                }
                
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompanyStaffManagementScreen(
                        company: currentCompany,
                      ),
                    ),
                  );
                }
              },
            ),
            
            _buildMenuItem(
              context,
              icon: Icons.calendar_today,
              title: '予約履歴',
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserBookingListScreen()),
                );
              },
            ),
            
            _buildMenuItem(
              context,
              icon: Icons.account_balance_wallet,
              title: 'ウォレット（コイン残高）',
              color: Colors.green,
              onTap: () async {
                // 現在のポイント残高を取得
                final user = await _authService.getCurrentUser();
                if (user != null) {
                  final balance = await _paymentService.getUserPointBalance(user.id);
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PointPurchaseScreen(
                          currentBalance: balance,
                        ),
                      ),
                    );
                  }
                }
              },
            ),
            
            _buildMenuItem(
              context,
              icon: Icons.card_giftcard,
              title: 'コイン獲得（無料）',
              color: Colors.amber,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PointEarnScreen()),
                );
              },
            ),
            
            /* TODO: 予約履歴画面を再実装
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
            */
            
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
              icon: Icons.block,
              title: 'ブロック管理',
              color: Colors.red,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserBlockManagementScreen()),
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
            onPressed: () async {
              try {
                // Firebase Authentication からログアウト
                await _authService.logout();
                
                // ローカルストレージもクリア
                await StorageHelper.clear();
                
                if (kDebugMode) {
                  debugPrint('✅ ログアウト成功: Firebase Auth + LocalStorage cleared');
                }
                
                // ダイアログを閉じる
                Navigator.pop(dialogContext);
                
                // ログイン画面に遷移し、戻れないようにする
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false, // すべての履歴をクリア
                  );
                }
              } catch (e) {
                if (kDebugMode) {
                  debugPrint('❌ ログアウトエラー: $e');
                }
                Navigator.pop(dialogContext);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('ログアウトに失敗しました: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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
  
  Widget _buildGifterLevelCard(UserGifterInfo gifterInfo) {
    final level = gifterInfo.currentLevel;
    final progress = gifterInfo.levelProgress;
    final expToNext = gifterInfo.expToNextLevel;
    
    // カラーコードをColorに変換
    Color levelColor = Color(int.parse(level.color.substring(1), radix: 16) + 0xFF000000);
    
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              levelColor.withValues(alpha: 0.8),
              levelColor.withValues(alpha: 0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // レベルバッジとタイトル
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    level.badge,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ギフターレベル',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Lv.${level.level} ${level.title}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 経験値プログレスバー
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'EXP: ${gifterInfo.totalExp.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    if (level.level < 6)
                      Text(
                        '次のレベルまで: $expToNext',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 統計情報
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  '総ギフト額',
                  '¥${gifterInfo.totalGiftAmount.toStringAsFixed(0)}',
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                _buildStatItem(
                  'ギフト回数',
                  '${gifterInfo.giftCount}回',
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 特典表示
            const Divider(color: Colors.white),
            const SizedBox(height: 8),
            const Text(
              'レベル特典',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...level.benefits.map((benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    benefit,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
