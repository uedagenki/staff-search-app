import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/staff_post.dart';
import 'staff_profile_edit_screen.dart';
import 'staff_posts_management_screen.dart';

/// TikTok風スタッフ管理プロフィール画面
/// プロフィール表示、投稿グリッド、プロフィール編集へのアクセス
class StaffManagementProfileScreen extends StatefulWidget {
  const StaffManagementProfileScreen({super.key});

  @override
  State<StaffManagementProfileScreen> createState() =>
      _StaffManagementProfileScreenState();
}

class _StaffManagementProfileScreenState
    extends State<StaffManagementProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // プロフィール情報
  String _name = 'スタッフ';
  String _username = 'staff_user';
  String _jobTitle = '職種';
  String _bio = '自己紹介文がここに入ります。';
  String _location = '東京都';
  String _profileImage = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400';
  List<String> _profileImages = [];
  final int _followingCount = 69;
  int _followersCount = 164;
  int _totalLikes = 426;
  
  // 投稿データ
  final List<StaffPost> _posts = [];
  final List<StaffPost> _likedPosts = [];
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfileData();
    _generateDemoPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // スタッフプロフィールを読み込み
      final staffProfileJson = prefs.getString('current_staff_profile');
      if (staffProfileJson != null) {
        final profileData = jsonDecode(staffProfileJson);
        
        setState(() {
          _name = profileData['name'] ?? 'スタッフ';
          _username = profileData['id'] ?? 'staff_user';
          _jobTitle = profileData['jobTitle'] ?? '職種';
          _bio = profileData['bio'] ?? '自己紹介文がここに入ります。';
          _location = profileData['location'] ?? '東京都';
          _profileImages = profileData['profileImages'] != null
              ? List<String>.from(profileData['profileImages'])
              : [];
          _profileImage = _profileImages.isNotEmpty
              ? _profileImages[0]
              : 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400';
          
          _followersCount = profileData['followersCount'] ?? 164;
        });
      }
    } catch (e) {
      debugPrint('プロフィールデータ読み込みエラー: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _generateDemoPosts() {
    // デモ投稿を生成
    for (var i = 0; i < 12; i++) {
      final post = StaffPost(
        id: 'staff_post_$i',
        staffId: _username,
        mediaUrl: _profileImages.isNotEmpty
            ? _profileImages[i % _profileImages.length]
            : _profileImage,
        type: PostType.image,
        caption: _generateCaption(i),
        timestamp: DateTime.now().subtract(Duration(days: i)),
        likeCount: 100 + (i * 50),
        commentCount: 10 + (i * 5),
      );
      _posts.add(post);

      // いいね投稿（一部）
      if (i % 3 == 0) {
        _likedPosts.add(post);
      }
    }
    
    // 総いいね数を計算
    _totalLikes = _posts.fold<int>(
      0,
      (sum, post) => sum + post.likeCount,
    );
  }

  String _generateCaption(int index) {
    final captions = [
      '今日も頑張ります!💪',
      '$_locationでお待ちしています✨',
      '新しいメニューをご紹介!🎉',
      'いつもありがとうございます😊',
      '週末も営業中です!💕',
    ];
    return captions[index % captions.length];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              pinned: true,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      _name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: () {
                      _showMoreOptions(context);
                    },
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: _buildProfileHeader(),
            ),
          ];
        },
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPostsGrid(_posts),
                  _buildPostsGrid(_likedPosts),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // プロフィール画像
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: CachedNetworkImageProvider(_profileImage),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // スタッフ名とID
          Text(
            _name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@$_username',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 20),

          // フォロー数、フォロワー数、いいね数
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem('$_followingCount', 'フォロー中'),
              Container(
                width: 1,
                height: 16,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(horizontal: 24),
              ),
              _buildStatItem('$_followersCount', 'フォロワー'),
              Container(
                width: 1,
                height: 16,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(horizontal: 24),
              ),
              _buildStatItem(_formatCount(_totalLikes), 'いいね'),
            ],
          ),

          const SizedBox(height: 20),

          // プロフィール編集ボタン
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                // プロフィール編集画面へ遷移
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StaffProfileEditScreen(),
                  ),
                );
                
                // 編集後にデータを再読み込み
                if (result == true) {
                  _loadProfileData();
                }
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'プロフィールを編集',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 自己紹介
          if (_bio.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _bio,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // 職種・勤務地
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(Icons.work_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '$_jobTitle · $_location',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.black,
        indicatorWeight: 2,
        tabs: const [
          Tab(icon: Icon(Icons.grid_on)),
          Tab(icon: Icon(Icons.favorite_border)),
        ],
      ),
    );
  }

  Widget _buildPostsGrid(List<StaffPost> posts) {
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.post_add,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '投稿がありません',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return _buildPostThumbnail(posts[index]);
      },
    );
  }

  Widget _buildPostThumbnail(StaffPost post) {
    return GestureDetector(
      onTap: () {
        // 投稿管理画面へ遷移
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const StaffPostsManagementScreen(),
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: post.imageUrl,
            fit: BoxFit.cover,
          ),
          // 再生回数・いいね数（動画の場合）
          if (post.type == PostType.video)
            Positioned(
              bottom: 4,
              left: 4,
              child: Row(
                children: [
                  const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    _formatCount(post.likeCount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('設定'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('設定機能は準備中です'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code),
                title: const Text('QRコード'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('QRコード機能は準備中です'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.archive),
                title: const Text('アーカイブ'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('アーカイブ機能は準備中です'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
