import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/staff.dart';
import '../data/mock_data.dart';
import '../services/follow_service.dart';
import 'staff_detail_screen.dart';

class FollowingScreen extends StatefulWidget {
  const FollowingScreen({super.key});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FollowService _followService = FollowService();
  List<Staff> _followingStaff = [];
  bool _isLoading = true;
  int _followingCount = 0;
  final int _followersCount = 128; // デモ用の固定値

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFollowing();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFollowing() async {
    setState(() {
      _isLoading = true;
    });

    final followingIds = await _followService.getFollowingIds();
    final allStaff = MockData.getStaffList();
    
    setState(() {
      _followingStaff = allStaff
          .where((staff) => followingIds.contains(staff.id))
          .toList();
      _followingCount = _followingStaff.length;
      _isLoading = false;
    });
  }

  Future<void> _unfollow(Staff staff) async {
    await _followService.unfollowStaff(staff.id);
    setState(() {
      _followingStaff.remove(staff);
      _followingCount = _followingStaff.length;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${staff.name}さんのフォローを解除しました'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: '元に戻す',
            onPressed: () async {
              await _followService.followStaff(staff.id);
              _loadFollowing();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('フォロー'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'フォロー中 $_followingCount'),
            Tab(text: 'フォロワー $_followersCount'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFollowingTab(),
          _buildFollowersTab(),
        ],
      ),
    );
  }

  Widget _buildFollowingTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_followingStaff.isEmpty) {
      return _buildEmptyState(
        'まだフォローしていません',
        '気になるスタッフをフォローしましょう',
        Icons.person_add_outlined,
      );
    }

    return _buildStaffList(_followingStaff, true);
  }

  Widget _buildFollowersTab() {
    // デモ用：フォロワーリストを表示
    return _buildEmptyState(
      'フォロワー機能',
      'あなたをフォローしているユーザーが表示されます',
      Icons.people_outline,
    );
  }

  Widget _buildStaffList(List<Staff> staffList, bool showUnfollowButton) {
    return Column(
      children: [
        // 統計情報
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('フォロー中', '$_followingCount', Colors.blue),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              _buildStatItem('フォロワー', '$_followersCount', Colors.green),
            ],
          ),
        ),
        
        // スタッフリスト
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: staffList.length,
            itemBuilder: (context, index) {
              return _buildStaffCard(staffList[index], showUnfollowButton);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStaffCard(Staff staff, bool showUnfollowButton) {
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // プロフィール画像
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: staff.profileImage,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // スタッフ情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      staff.jobTitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: staff.rating,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 14.0,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${staff.rating}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // フォロー解除ボタン
              if (showUnfollowButton)
                OutlinedButton(
                  onPressed: () => _unfollow(staff),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('フォロー中', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
