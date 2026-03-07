import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/staff.dart';
import '../models/staff_story.dart';
import '../data/mock_data.dart';
import '../widgets/staff_card.dart';
import '../services/location_service.dart';
import '../services/story_service.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'messages_screen.dart';
import 'notifications_screen.dart';
import 'story_viewer_screen.dart';
import 'filter_settings_screen.dart';
import 'live_feed_screen.dart';
import 'live_stream_list_screen.dart';
import 'staff_feed_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    _loadStaffFromLocalStorage();
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

  void _loadStaffFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // SharedPreferencesからスタッフリストを読み込み
      final staffListJson = prefs.getString('staff_list');
      
      if (staffListJson != null) {
        final List<dynamic> staffData = jsonDecode(staffListJson);
        
        // JSONからStaffオブジェクトに変換
        final registeredStaff = staffData.map((data) {
          // カテゴリーから最初の1つを取得
          final categories = data['categories'] != null
              ? List<String>.from(data['categories'])
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
          
          return Staff(
            id: data['id'] ?? '',
            name: data['name'] ?? '',
            jobTitle: data['jobTitle'] ?? '',
            category: category,
            profileImage: (data['profileImages'] as List?)?.isNotEmpty == true
                ? data['profileImages'][0]
                : 'https://via.placeholder.com/400',
            profileImages: data['profileImages'] != null
                ? List<String>.from(data['profileImages'])
                : null,
            rating: (data['rating'] ?? 4.8).toDouble(),
            reviewCount: data['reviewCount'] ?? 0,
            location: data['location'] ?? '',
            experience: int.tryParse(data['experience']?.toString() ?? '0') ?? 0,
            bio: data['bio'] ?? '',
            skills: (data['bio'] as String?)?.isNotEmpty == true
                ? [data['jobTitle'] ?? '']
                : ['スキル'],
            latitude: data['storeLatitude'] != null
                ? double.tryParse(data['storeLatitude'].toString())
                : null,
            longitude: data['storeLongitude'] != null
                ? double.tryParse(data['storeLongitude'].toString())
                : null,
            isOnline: true,
            isLive: false,
            qrCode: 'qr_${data['id']}',
            storeName: data['storeName'],
            companyName: data['companyName'],
          );
        }).toList();

        if (kDebugMode) {
          debugPrint('✅ LocalStorageからスタッフを読み込みました: ${registeredStaff.length}件');
        }

        // MockDataのスタッフリストと統合
        setState(() {
          _staffList = [
            ...registeredStaff,
            ...MockData.getStaffList(),
          ];
          _applyFilters();
        });
      } else {
        // LocalStorageにデータがない場合はMockDataのみ使用
        setState(() {
          _staffList = MockData.getStaffList();
          _applyFilters();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ スタッフ読み込みエラー: $e');
      }
      // エラー時はMockDataのみ使用
      setState(() {
        _staffList = MockData.getStaffList();
        _applyFilters();
      });
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
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'ホーム',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.video_library),
          label: 'スタッフ配信',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: '検索',
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
          // スタッフ配信タブ（TikTok形式のフィード）
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StaffFeedScreen()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
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
