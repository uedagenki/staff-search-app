// SCREEN: User Profile Screen | AUTH-01 / DB-02
import '../../utils/screen_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/tip_service.dart';
import '../services/gifter_service.dart';
import '../models/gifter_level.dart';
import 'following_screen.dart';
import 'staff/staff_registration_screen.dart';
import 'staff/staff_dashboard_screen.dart';

import 'tip_history_screen.dart';
import 'my_reviews_screen.dart';
import 'profile_settings_screen.dart';
import 'ranking_screen.dart';
import 'headhunt_screen.dart';
import 'help_support_screen.dart';
import 'user_block_management_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with ScreenLogMixin {
  @override
  String get screenId => 'User Profile Screen | AUTH-01 / DB-02';

  final TipService _tipService = TipService();
  final GifterService _gifterService = GifterService();
  double _totalTips = 0.0;
  bool _isLoading = true;
  UserGifterInfo? _gifterInfo;

  @override
  void initState() {
    super.initState();
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


  Future<void> _loadTotalTips() async {
    await _tipService.initializeDemoData();
    final total = await _tipService.getTotalTipsSent();
    setState(() {
      _totalTips = total;
      _isLoading = false;
    });
  }

  // スタッフモード切り替え処理
  void _handleStaffModeSwitch() {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    if (kDebugMode) {
      debugPrint('🔄 スタッフモード切り替え: role=${user.role}, isStaffRegistered=${user.isStaffRegistered}');
    }

    if (user.isStaffRegistered) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StaffDashboardScreen(userId: user.id),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const StaffRegistrationScreen(),
        ),
      );
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
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final user = auth.currentUser;
                final name = user?.name ?? 'ゲストユーザー';
                final email = user?.email ?? '';
                final avatarUrl = user?.profileImage;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                        child: avatarUrl == null
                            ? const Icon(Icons.person, size: 50, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        email,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              },
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
              Navigator.pop(dialogContext);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
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
