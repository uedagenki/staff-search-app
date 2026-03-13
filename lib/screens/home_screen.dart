// SCREEN: Home Feed Screen | FEED-02
import '../../utils/screen_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/staff.dart';
import '../models/staff_story.dart';
import '../data/mock_data.dart';
import '../services/location_service.dart';
import '../services/staff_service.dart';
import '../services/story_service.dart';
import '../widgets/staff_card.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'messages_screen.dart';
import 'notifications_screen.dart';
import 'story_viewer_screen.dart';
import 'filter_settings_screen.dart';
import 'live_feed_screen.dart';
import 'live_stream_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with ScreenLogMixin {
  @override
  String get screenId => 'Home Feed Screen | FEED-02';

  final PageController _pageController = PageController();
  final LocationService _locationService = LocationService();
  final StoryService _storyService = StoryService();
  List<Staff> _staffList = MockData.getStaffList();
  List<Staff> _filteredStaffList = [];
  List<StaffStory> _stories = [];
  Position? _currentPosition;
  bool _isLoadingStories = true;
  
  // フィルター設定
  double _maxDistance = 50.0;
  double _minRating = 0.0;
  bool _onlineOnly = false;
  String _selectedCategory = 'すべて';
  bool _hasActiveFilters = false;

  @override
  void initState() {
    super.initState();
    _loadStaffFromAPI();
    _loadFilterSettings();
    _loadLocation();
    _loadStories();
  }

  Future<void> _loadStories() async {
    final stories = await _storyService.getStaffStories();
    final activeStories = _storyService.filterActiveStories(stories);
    setState(() {
      _stories = activeStories;
      _isLoadingStories = false;
    });
  }

  Future<void> _loadStaffFromAPI() async {
    try {
      final apiStaff = await StaffService.instance.getStaffList(limit: 50);
      if (mounted) {
        setState(() {
          _staffList = apiStaff.isNotEmpty ? apiStaff : MockData.getStaffList();
          _applyFilters();
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Staff API unavailable, using mock data: $e');
      if (mounted) {
        setState(() {
          _staffList = MockData.getStaffList();
          _applyFilters();
        });
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
            // 位置情報がないスタッフは距離フィルターをスキップ
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
                          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            '条件に合うスタッフが見つかりません',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const FilterSettingsScreen()),
                              );
                              if (result == true) _loadFilterSettings();
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
              // 通知ボタン（バッジ付き）
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
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
                      child: const Text(
                        '2',
                        style: TextStyle(
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
    if (_isLoadingStories) {
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
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_stories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 100,
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        itemCount: _stories.length,
        itemBuilder: (context, index) {
          final story = _stories[index];
          if (story.isExpired) return const SizedBox.shrink();
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () {
                // ストーリービューアを開く
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StoryViewerScreen(
                      stories: _stories,
                      initialIndex: index,
                    ),
                  ),
                ).then((_) {
                  // ストーリーから戻ってきたらリロード
                  _loadStories();
                });
              },
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: story.hasUnviewedStory
                            ? [
                                Colors.purple,
                                Colors.pink,
                                Colors.orange,
                              ]
                            : [Colors.grey, Colors.grey],
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: story.staffImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 60,
                    child: Text(
                      story.staffName.split(' ')[0],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
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
          // ライブ配信一覧画面に遷移 (モバイルのみ)
          if (kIsWeb) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ライブ配信機能はモバイルアプリでのみ利用できます'),
                backgroundColor: Colors.orange,
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LiveStreamListScreen()),
            );
          }
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
