import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/admin_auth_service.dart';
import '../models/admin_user.dart';
import 'users_management_screen.dart';
import 'staff_management_screen.dart';
import 'content_moderation_screen.dart';
import 'reports_screen.dart';
import 'admin_support_chat_screen.dart';
import 'admin_login_screen.dart';
import '../../utils/storage_helper.dart';
import 'dart:convert';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _adminAuthService = AdminAuthService();
  AdminUser? _currentAdmin;
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
    _loadStatistics();
  }

  Future<void> _loadAdminData() async {
    final admin = await _adminAuthService.getCurrentAdmin();
    if (mounted) {
      setState(() {
        _currentAdmin = admin;
      });
    }
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // ユーザー数を取得
      final usersJson = await StorageHelper.getString('registered_users');
      int userCount = 0;
      if (usersJson != null) {
        final users = jsonDecode(usersJson) as List;
        userCount = users.length;
      }

      // スタッフ数を取得
      final staffJson = await StorageHelper.getString('staff_list');
      int staffCount = 0;
      if (staffJson != null) {
        final staff = jsonDecode(staffJson) as List;
        staffCount = staff.length;
      }

      // 予約数を取得
      final bookingsJson = await StorageHelper.getString('staff_bookings');
      int bookingCount = 0;
      if (bookingsJson != null) {
        final bookings = jsonDecode(bookingsJson) as List;
        bookingCount = bookings.length;
      }

      // メッセージ数を概算（ダミーデータ）
      int messageCount = 150;

      if (mounted) {
        setState(() {
          _stats = {
            'users': userCount,
            'staff': staffCount,
            'bookings': bookingCount,
            'messages': messageCount,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load statistics: $e');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ログアウト'),
        content: const Text('ログアウトしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('ログアウト'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _adminAuthService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AdminLoginScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Finder 管理ダッシュボード'),
        actions: [
          // 管理者情報
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  _currentAdmin?.isSuperAdmin == true
                      ? Icons.admin_panel_settings
                      : Icons.manage_accounts,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _currentAdmin?.name ?? 'Admin',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          // ログアウトボタン
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'ログアウト',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 統計カード
                  _buildStatisticsSection(),
                  const SizedBox(height: 32),

                  // 管理メニュー
                  _buildManagementMenu(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '統計情報',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStatCard(
                  'ユーザー数',
                  _stats['users'] ?? 0,
                  Icons.people,
                  Colors.blue,
                  isWide ? constraints.maxWidth / 4 - 12 : constraints.maxWidth,
                ),
                _buildStatCard(
                  'スタッフ数',
                  _stats['staff'] ?? 0,
                  Icons.work,
                  Colors.green,
                  isWide ? constraints.maxWidth / 4 - 12 : constraints.maxWidth,
                ),
                _buildStatCard(
                  '予約数',
                  _stats['bookings'] ?? 0,
                  Icons.event,
                  Colors.orange,
                  isWide ? constraints.maxWidth / 4 - 12 : constraints.maxWidth,
                ),
                _buildStatCard(
                  'メッセージ数',
                  _stats['messages'] ?? 0,
                  Icons.message,
                  Colors.purple,
                  isWide ? constraints.maxWidth / 4 - 12 : constraints.maxWidth,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    int value,
    IconData icon,
    Color color,
    double width,
  ) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const Spacer(),
                  Text(
                    value.toString(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '管理メニュー',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildMenuCard(
                  'ユーザー管理',
                  'ユーザーの閲覧・編集・削除',
                  Icons.people_alt,
                  Colors.blue,
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const UsersManagementScreen(),
                      ),
                    );
                  },
                  isWide ? constraints.maxWidth / 2 - 8 : constraints.maxWidth,
                ),
                _buildMenuCard(
                  'スタッフ管理',
                  'スタッフの承認・編集・統計',
                  Icons.work_outline,
                  Colors.green,
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const StaffManagementScreen(),
                      ),
                    );
                  },
                  isWide ? constraints.maxWidth / 2 - 8 : constraints.maxWidth,
                ),
                _buildMenuCard(
                  'コンテンツ管理',
                  '投稿の管理・不適切コンテンツ対応',
                  Icons.content_paste,
                  Colors.orange,
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ContentModerationScreen(),
                      ),
                    );
                  },
                  isWide ? constraints.maxWidth / 2 - 8 : constraints.maxWidth,
                ),
                _buildMenuCard(
                  'レポート・統計',
                  'アクセス解析・売上統計',
                  Icons.analytics,
                  Colors.purple,
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ReportsScreen(),
                      ),
                    );
                  },
                  isWide ? constraints.maxWidth / 2 - 8 : constraints.maxWidth,
                ),
                _buildMenuCard(
                  'ユーザーサポート',
                  '問い合わせチャット・サポート',
                  Icons.support_agent,
                  Colors.teal,
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AdminSupportChatScreen(),
                      ),
                    );
                  },
                  isWide ? constraints.maxWidth / 2 - 8 : constraints.maxWidth,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
    double width,
  ) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
