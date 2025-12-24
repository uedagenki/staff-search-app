import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html;
import 'dart:convert';
import '../models/staff.dart';
import '../models/staff_story.dart';
import '../data/mock_data.dart';
import '../widgets/staff_card.dart';
import '../services/location_service.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'messages_screen.dart';
import 'notifications_screen.dart';
import 'story_viewer_screen.dart';
import 'filter_settings_screen.dart';
import 'live_feed_screen.dart';
import 'staff_detail_screen.dart';
import 'user_posts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  final LocationService _locationService = LocationService();
  List<Staff> _staffList = MockData.getStaffList();
  int _notificationCount = 0;
  List<Staff> _filteredStaffList = [];
  final List<StaffStory> _stories = _getMockStories();
  Position? _currentPosition;
  
  // フィルター設定
  double _maxDistance = 50.0;
  double _minRating = 0.0;
  bool _onlineOnly = false;
  String _selectedCategory = 'すべて';
  bool _hasActiveFilters = false;

  static List<StaffStory> _getMockStories() {
    return [
      StaffStory(
        id: '1',
        staffId: '2',
        staffName: '田中 美咲',
        staffImage: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
        items: [
          StoryItem(
            id: '1',
            imageUrl: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ],
        lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      StaffStory(
        id: '2',
        staffId: '1',
        staffName: '佐藤 健',
        staffImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        items: [
          StoryItem(
            id: '1',
            imageUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400',
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          ),
        ],
        lastUpdated: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      StaffStory(
        id: '3',
        staffId: '7',
        staffName: '中村 大輔',
        staffImage: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400',
        items: [
          StoryItem(
            id: '1',
            imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400',
            timestamp: DateTime.now().subtract(const Duration(hours: 8)),
          ),
        ],
        lastUpdated: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadFilterSettings();
    _loadLocation();
    _loadNotificationCount();
  }

  Future<void> _loadNotificationCount() async {
    try {
      final notificationsJson = html.window.localStorage['notifications'];
      if (notificationsJson != null && notificationsJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(notificationsJson);
        final unreadCount = decoded.where((n) => n['isRead'] == false).length;
        if (mounted) {
          setState(() {
            _notificationCount = unreadCount;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load notification count: $e');
      }
    }
  }

  Future<void> _loadLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null && mounted) {
      setState(() {
        _currentPosition = position;
      });
      _applyFilters();
    }
  }

  Future<void> _loadFilterSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _maxDistance = prefs.getDouble('filter_max_distance') ?? 50.0;
      _minRating = prefs.getDouble('filter_min_rating') ?? 0.0;
      _onlineOnly = prefs.getBool('filter_online_only') ?? false;
      _selectedCategory = prefs.getString('filter_category') ?? 'すべて';
      _hasActiveFilters = _maxDistance < 100 || _minRating > 0 || _onlineOnly || _selectedCategory != 'すべて';
    });
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredStaffList = _staffList.where((staff) {
        // カテゴリーフィルター
        if (_selectedCategory != 'すべて' && staff.category != _selectedCategory) {
          return false;
        }

        // 評価フィルター
        if (_minRating > 0 && staff.rating < _minRating) {
          return false;
        }

        // オンラインフィルター
        if (_onlineOnly && !staff.isOnline) {
          return false;
        }

        // 距離フィルター
        if (_maxDistance < 100 && _currentPosition != null) {
          if (staff.latitude != null && staff.longitude != null) {
            final distance = _locationService.calculateDistance(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              staff.latitude!,
              staff.longitude!,
            );
            staff.distance = distance;
            if (distance > _maxDistance) {
              return false;
            }
          } else {
            // 位置情報がないスタッフは除外
            return false;
          }
        } else if (_currentPosition != null) {
          // 距離制限なしの場合でも距離を計算
          if (staff.latitude != null && staff.longitude != null) {
            staff.distance = _locationService.calculateDistance(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              staff.latitude!,
              staff.longitude!,
            );
          }
        }

        return true;
      }).toList();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // トップヘッダー
            _buildHeader(),
            // ストーリー
            _buildStories(),
            // TikTok風縦型スクロール
            Expanded(
              child: _filteredStaffList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '条件に合うスタッフが見つかりません',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FilterSettingsScreen(),
                                ),
                              );
                              if (result == true) {
                                _loadFilterSettings();
                              }
                            },
                            child: const Text('絞り込み設定を変更'),
                          ),
                        ],
                      ),
                    )
                  : PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      itemCount: _filteredStaffList.length,
                      itemBuilder: (context, index) {
                        return StaffCard(staff: _filteredStaffList[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      // ボトムナビゲーション
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ロゴ
          Row(
            children: [
              Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'スタッフサーチ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          // 右側のアイコン
          Row(
            children: [
              // ユーザー投稿ボタン
              IconButton(
                icon: const Icon(Icons.people_alt_outlined),
                tooltip: 'みんなの投稿',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserPostsScreen(),
                    ),
                  );
                },
              ),
              // 通知ボタン（バッジ付き）
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                      // 通知画面から戻ってきたら未読数を再読み込み
                      _loadNotificationCount();
                    },
                  ),
                  if (_notificationCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          _notificationCount > 99 ? '99+' : '$_notificationCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              // フィルターボタン
              Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.tune,
                      color: _hasActiveFilters 
                          ? Theme.of(context).colorScheme.primary 
                          : null,
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FilterSettingsScreen(),
                        ),
                      );
                      if (result == true) {
                        _loadFilterSettings();
                      }
                    },
                  ),
                  if (_hasActiveFilters)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStories() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        itemCount: _stories.length,
        itemBuilder: (context, index) {
          final story = _stories[index];
          if (story.isExpired) return const SizedBox.shrink();
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    // プロフィール画像タップでスタッフ詳細画面に遷移
                    // staffIdに一致するスタッフを検索
                    final staff = _staffList.firstWhere(
                      (s) => s.id == story.staffId,
                      orElse: () => _staffList.first, // 見つからない場合は最初のスタッフ
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StaffDetailScreen(staff: staff),
                      ),
                    );
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Colors.purple,
                        ],
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: story.staffImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: 48,
                  child: Text(
                    story.staffName.split(' ')[0],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'ホーム',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: '検索',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.video_library),
          label: 'ライブ',
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
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
          );
        } else if (index == 2) {
          // TikTok風縦スライド式ライブ配信画面に遷移
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LiveFeedScreen()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MessagesScreen()),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        }
      },
    );
  }
}
