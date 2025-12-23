import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import '../models/staff.dart';
import '../data/mock_data.dart';
import '../data/job_categories.dart';
import '../services/location_service.dart';
import 'staff_detail_screen.dart';
import 'ranking_screen.dart';
import 'map_search_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService();
  final List<Staff> _staffList = MockData.getStaffList();
  List<Staff> _filteredList = [];
  String _selectedCategory = 'すべて';
  String _sortBy = 'デフォルト'; // デフォルト、近い順
  Position? _currentPosition;
  bool _isLoadingLocation = false;

  final List<String> _categories = ['すべて'];

  @override
  void initState() {
    super.initState();
    _filteredList = _staffList;
    // すべてのカテゴリーを取得
    _categories.addAll(JobCategories.getCategoryNames());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStaff(String query) {
    setState(() {
      if (query.isEmpty && _selectedCategory == 'すべて') {
        _filteredList = _staffList;
      } else {
        _filteredList = _staffList.where((staff) {
          final matchesQuery = query.isEmpty ||
              staff.name.toLowerCase().contains(query.toLowerCase()) ||
              staff.jobTitle.toLowerCase().contains(query.toLowerCase()) ||
              (staff.storeName?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
              (staff.companyName?.toLowerCase().contains(query.toLowerCase()) ?? false);
          final matchesCategory = _selectedCategory == 'すべて' ||
              staff.category == _selectedCategory;
          return matchesQuery && matchesCategory;
        }).toList();
      }
      _sortStaff();
    });
  }

  void _sortStaff() {
    if (_sortBy == '近い順' && _currentPosition != null) {
      // 距離を計算
      for (var staff in _filteredList) {
        if (staff.latitude != null && staff.longitude != null) {
          staff.distance = _locationService.calculateDistance(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            staff.latitude!,
            staff.longitude!,
          );
        }
      }
      // 近い順にソート
      _filteredList.sort((a, b) {
        if (a.distance == null) return 1;
        if (b.distance == null) return -1;
        return a.distance!.compareTo(b.distance!);
      });
    }
  }

  Future<void> _loadCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    final position = await _locationService.getCurrentLocation();
    
    setState(() {
      _currentPosition = position;
      _isLoadingLocation = false;
      if (position != null) {
        _sortBy = '近い順';
        _sortStaff();
      }
    });

    if (position == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('位置情報の取得に失敗しました。設定を確認してください。'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Text(
          'スタッフ検索',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        actions: [
          // 地図検索ボタン
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.map_outlined, size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MapSearchScreen()),
                    );
                  },
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  tooltip: '地図検索',
                ),
                const Text(
                  '地図検索',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, height: 1.0),
                ),
              ],
            ),
          ),
          // ランキングボタン
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_events, size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RankingScreen()),
                    );
                  },
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  tooltip: 'ランキング',
                ),
                const Text(
                  'ランキング',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, height: 1.0),
                ),
              ],
            ),
          ),
          // GPS位置情報ボタン
          Padding(
            padding: const EdgeInsets.only(left: 6, right: 12),
            child: _isLoadingLocation
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          _sortBy == '近い順' ? Icons.my_location : Icons.location_on_outlined,
                          color: _sortBy == '近い順' ? Theme.of(context).colorScheme.primary : null,
                          size: 20,
                        ),
                        onPressed: () async {
                          // GPS位置情報を取得
                          await _loadCurrentLocation();
                          if (mounted && _currentPosition != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  '現在地を取得しました。近い順で並び替えています。',
                                  style: TextStyle(fontSize: 14),
                                ),
                                duration: const Duration(seconds: 2),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        tooltip: 'GPS位置情報',
                      ),
                      Text(
                        'GPS',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                          color: _sortBy == '近い順' ? Theme.of(context).colorScheme.primary : null,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 検索バー
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '名前、職種、店舗名、会社名で検索',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterStaff('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _filterStaff,
            ),
          ),
          
          // カテゴリーフィルター
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        _filterStaff(_searchController.text);
                      });
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 検索結果
          Expanded(
            child: _filteredList.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '検索結果が見つかりません',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredList.length,
                    itemBuilder: (context, index) {
                      return _buildStaffListItem(_filteredList[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffListItem(Staff staff) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StaffDetailScreen(staff: staff),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // プロフィール画像
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: staff.profileImage,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // スタッフ情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            staff.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (staff.isOnline)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '出勤中',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      staff.jobTitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: staff.rating,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 16.0,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${staff.rating}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            staff.distance != null
                                ? '${_locationService.formatDistance(staff.distance!)} - ${staff.location}'
                                : staff.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: staff.distance != null ? FontWeight.bold : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
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
    );
  }
}
