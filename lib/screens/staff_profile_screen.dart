import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../models/staff.dart';
import '../models/staff_post.dart';
import '../services/follow_service.dart';
import '../services/post_comment_service.dart';
import 'staff_detail_screen.dart';

/// TikTok形式のスタッフプロフィール画面
/// フォロー数、いいね数、投稿一覧をグリッド表示
class StaffProfileScreen extends StatefulWidget {
  final Staff staff;

  const StaffProfileScreen({
    super.key,
    required this.staff,
  });

  @override
  State<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen>
    with SingleTickerProviderStateMixin {
  final FollowService _followService = FollowService();
  bool _isFollowing = false;
  late TabController _tabController;
  final List<StaffPost> _posts = [];
  final List<StaffPost> _likedPosts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFollowStatus();
    _generateDemoPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadFollowStatus() async {
    final isFollowing = await _followService.isFollowing(widget.staff.id);
    setState(() {
      _isFollowing = isFollowing;
    });
  }

  void _generateDemoPosts() {
    // デモ投稿を生成
    for (var i = 0; i < 12; i++) {
      final post = StaffPost(
        id: 'staff_post_${widget.staff.id}_$i',
        staffId: widget.staff.id,
        mediaUrl: widget.staff.profileImages.isNotEmpty
            ? widget.staff.profileImages[i % widget.staff.profileImages.length]
            : widget.staff.profileImage,
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
    setState(() {});
  }

  String _generateCaption(int index) {
    final captions = [
      '今日も頑張ります！💪',
      '${widget.staff.location}でお待ちしています✨',
      '新しいメニューをご紹介！🎉',
      'いつもありがとうございます😊',
      '週末も営業中です！💕',
    ];
    return captions[index % captions.length];
  }

  Future<void> _toggleFollow() async {
    if (_isFollowing) {
      await _followService.unfollowStaff(widget.staff.id);
    } else {
      await _followService.followStaff(widget.staff.id);
    }

    setState(() {
      _isFollowing = !_isFollowing;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFollowing ? 'フォローしました' : 'フォローを解除しました',
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.black87,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.staff.name,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              _showMoreOptions(context);
            },
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
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
    // 総いいね数を計算
    final totalLikes = _posts.fold<int>(
      0,
      (sum, post) => sum + post.likeCount,
    );

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
                image: CachedNetworkImageProvider(widget.staff.profileImage),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // スタッフ名とID
          Text(
            widget.staff.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@${widget.staff.id}',
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
              _buildStatItem('69', 'フォロー中'),
              Container(
                width: 1,
                height: 16,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(horizontal: 24),
              ),
              _buildStatItem('${widget.staff.followersCount}', 'フォロワー'),
              Container(
                width: 1,
                height: 16,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(horizontal: 24),
              ),
              _buildStatItem(_formatCount(totalLikes), 'いいね'),
            ],
          ),

          const SizedBox(height: 20),

          // フォロー・メッセージボタン
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: _toggleFollow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFollowing ? Colors.white : Colors.red,
                    foregroundColor: _isFollowing ? Colors.black : Colors.white,
                    side: _isFollowing
                        ? BorderSide(color: Colors.grey[300]!)
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    _isFollowing ? 'フォロー中' : 'フォロー',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // メッセージ画面へ遷移
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('メッセージ機能は準備中です'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Icon(Icons.message_outlined, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  _shareProfile();
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                child: const Icon(Icons.person_add_outlined, size: 20),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 自己紹介
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.staff.bio,
              style: const TextStyle(fontSize: 14),
            ),
          ),

          const SizedBox(height: 8),

          // 職種・勤務地
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(Icons.work_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${widget.staff.jobTitle} · ${widget.staff.location}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 評価
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber[700]),
                const SizedBox(width: 4),
                Text(
                  '${widget.staff.rating} (${widget.staff.reviewCount}件のレビュー)',
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
        // 投稿詳細画面へ遷移（将来実装）
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('投稿詳細画面は準備中です'),
            duration: Duration(seconds: 1),
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

  void _shareProfile() {
    final profileUrl = 'https://staff-search.app/staff/${widget.staff.id}';
    Share.share(
      '${widget.staff.name}さんのプロフィールをチェック!\n\n'
      '${widget.staff.jobTitle} · ${widget.staff.location}\n'
      '⭐ ${widget.staff.rating} (${widget.staff.reviewCount}件のレビュー)\n\n'
      '$profileUrl\n\n'
      '#スタッフサーチ #${widget.staff.jobTitle}',
      subject: '${widget.staff.name}さんのプロフィール',
    );
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
                leading: const Icon(Icons.share),
                title: const Text('プロフィールをシェア'),
                onTap: () {
                  Navigator.pop(context);
                  _shareProfile();
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code),
                title: const Text('QRコードを表示'),
                onTap: () {
                  Navigator.pop(context);
                  // QRコード画面へ遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StaffDetailScreen(staff: widget.staff),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('ブロック'),
                onTap: () {
                  Navigator.pop(context);
                  // ブロック処理
                },
              ),
              ListTile(
                leading: const Icon(Icons.report),
                title: const Text('報告'),
                onTap: () {
                  Navigator.pop(context);
                  // 報告処理
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
