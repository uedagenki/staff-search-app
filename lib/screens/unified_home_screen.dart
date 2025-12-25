import 'package:flutter/material.dart';
import '../services/app_mode_service.dart';
import '../widgets/mode_switcher.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import 'staff/staff_dashboard_screen.dart';
import 'staff/staff_posts_management_screen.dart';
import 'staff/staff_bookings_screen.dart';
import 'staff/staff_messages_screen.dart';

/// 統合ホーム画面（ユーザーモード/スタッフモード切り替え対応）
class UnifiedHomeScreen extends StatefulWidget {
  const UnifiedHomeScreen({super.key});

  @override
  State<UnifiedHomeScreen> createState() => _UnifiedHomeScreenState();
}

class _UnifiedHomeScreenState extends State<UnifiedHomeScreen> {
  final AppModeService _modeService = AppModeService();
  int _currentIndex = 0;

  // ユーザーモードの画面リスト
  final List<Widget> _userScreens = [
    const HomeScreen(),
    const SearchScreen(),
    const MessagesScreen(),
    const ProfileScreen(),
  ];

  // スタッフモードの画面リスト
  final List<Widget> _staffScreens = [
    const StaffDashboardScreen(),
    const StaffPostsManagementScreen(),
    const StaffBookingsScreen(),
    const StaffMessagesScreen(),
    const ProfileScreen(), // プロフィールは共通
  ];

  @override
  void initState() {
    super.initState();
    _modeService.addListener(_onModeChanged);
  }

  @override
  void dispose() {
    _modeService.removeListener(_onModeChanged);
    super.dispose();
  }

  void _onModeChanged() {
    setState(() {
      // モード変更時に最初のタブに戻る
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isUserMode = _modeService.currentMode == AppMode.user;
    final screens = isUserMode ? _userScreens : _staffScreens;

    // インデックスが範囲外の場合は0にリセット
    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: _buildBottomNavigation(isUserMode),
    );
  }

  Widget _buildBottomNavigation(bool isUserMode) {
    if (isUserMode) {
      // ユーザーモード用ナビゲーション
      return BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF667EEA),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: '検索',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'メッセージ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'プロフィール',
          ),
        ],
      );
    } else {
      // スタッフモード用ナビゲーション
      return BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFF093FB),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'ダッシュボード',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            activeIcon: Icon(Icons.article),
            label: '投稿管理',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined),
            activeIcon: Icon(Icons.event_note),
            label: '予約',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'メッセージ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'プロフィール',
          ),
        ],
      );
    }
  }
}
