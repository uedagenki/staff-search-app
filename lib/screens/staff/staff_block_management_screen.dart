import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/patrol_service.dart';
import '../../services/local_auth_service.dart';

/// スタッフ用：ブロックユーザー管理画面
class StaffBlockManagementScreen extends StatefulWidget {
  const StaffBlockManagementScreen({super.key});

  @override
  State<StaffBlockManagementScreen> createState() => _StaffBlockManagementScreenState();
}

class _StaffBlockManagementScreenState extends State<StaffBlockManagementScreen> {
  final PatrolService _patrolService = PatrolService();
  final LocalAuthService _authService = LocalAuthService();
  
  List<String> _blockedUserIds = [];
  List<String> _mutedUserIds = [];
  bool _isLoading = true;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    setState(() => _isLoading = true);
    
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        final blocked = await _patrolService.getBlockedUsers(user.id);
        final muted = await _patrolService.getMutedUsers(user.id);
        
        setState(() {
          _blockedUserIds = blocked;
          _mutedUserIds = muted;
        });
      }
    } catch (e) {
      debugPrint('ブロックユーザー読み込みエラー: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _unblockUser(String userId) async {
    final user = await _authService.getCurrentUser();
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ブロック解除'),
        content: const Text('このユーザーのブロックを解除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('解除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _patrolService.unblockUser(user.id, userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ブロックを解除しました'),
            backgroundColor: Colors.green,
          ),
        );
        _loadBlockedUsers();
      }
    }
  }

  Future<void> _unmuteUser(String userId) async {
    final user = await _authService.getCurrentUser();
    if (user == null) return;

    // ミュート解除のロジックを追加
    setState(() {
      _mutedUserIds.remove(userId);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ミュートを解除しました'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ブロック管理'),
        bottom: TabBar(
          tabs: const [
            Tab(text: 'ブロック', icon: Icon(Icons.block)),
            Tab(text: 'ミュート', icon: Icon(Icons.volume_off)),
          ],
          onTap: (index) {
            setState(() {
              _selectedTab = index;
            });
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedTab == 0
              ? _buildBlockedList()
              : _buildMutedList(),
    );
  }

  Widget _buildBlockedList() {
    if (_blockedUserIds.isEmpty) {
      return _buildEmptyState(
        icon: Icons.block,
        title: 'ブロック中のユーザーはいません',
        message: '不快なユーザーをブロックすると、\nそのユーザーからの連絡やコメントが表示されなくなります。',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _blockedUserIds.length,
      itemBuilder: (context, index) {
        final userId = _blockedUserIds[index];
        return _buildUserCard(
          userId: userId,
          isBlocked: true,
          onAction: () => _unblockUser(userId),
        );
      },
    );
  }

  Widget _buildMutedList() {
    if (_mutedUserIds.isEmpty) {
      return _buildEmptyState(
        icon: Icons.volume_off,
        title: 'ミュート中のユーザーはいません',
        message: 'ユーザーをミュートすると、\nそのユーザーからの通知が届かなくなります。',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mutedUserIds.length,
      itemBuilder: (context, index) {
        final userId = _mutedUserIds[index];
        return _buildUserCard(
          userId: userId,
          isBlocked: false,
          onAction: () => _unmuteUser(userId),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard({
    required String userId,
    required bool isBlocked,
    required VoidCallback onAction,
  }) {
    // 実際のアプリではユーザー情報を取得
    final userName = 'ユーザー $userId';
    final userAvatar = 'https://i.pravatar.cc/150?u=$userId';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(userAvatar),
          backgroundColor: Colors.grey.shade300,
        ),
        title: Text(userName),
        subtitle: Text(
          isBlocked ? 'ブロック中' : 'ミュート中',
          style: TextStyle(
            color: isBlocked ? Colors.red : Colors.orange,
            fontSize: 12,
          ),
        ),
        trailing: OutlinedButton(
          onPressed: onAction,
          style: OutlinedButton.styleFrom(
            foregroundColor: isBlocked ? Colors.red : Colors.orange,
            side: BorderSide(
              color: isBlocked ? Colors.red : Colors.orange,
            ),
          ),
          child: Text(isBlocked ? '解除' : 'ミュート解除'),
        ),
      ),
    );
  }
}
