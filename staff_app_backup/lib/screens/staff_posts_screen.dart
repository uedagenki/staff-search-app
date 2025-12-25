import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/staff.dart';
import '../models/staff_post.dart';
import 'post_detail_screen.dart';

class StaffPostsScreen extends StatelessWidget {
  final Staff staff;

  const StaffPostsScreen({super.key, required this.staff});

  List<StaffPost> _getMockPosts() {
    return [
      StaffPost(
        id: '1',
        staffId: staff.id,
        mediaUrl: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
        type: PostType.image,
        caption: '今日の施術✨ お客様に喜んでいただけました！',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        likeCount: 245,
        commentCount: 18,
      ),
      StaffPost(
        id: '2',
        staffId: staff.id,
        mediaUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400',
        type: PostType.image,
        caption: '新しい技術を習得しました💪',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        likeCount: 189,
        commentCount: 12,
      ),
      StaffPost(
        id: '3',
        staffId: staff.id,
        mediaUrl: 'https://images.unsplash.com/photo-1521737711867-e3b97375f902?w=400',
        type: PostType.image,
        caption: 'お客様からの嬉しいお言葉をいただきました😊',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        likeCount: 312,
        commentCount: 24,
      ),
      StaffPost(
        id: '4',
        staffId: staff.id,
        mediaUrl: 'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=400',
        type: PostType.image,
        caption: 'セミナーに参加してきました📚',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        likeCount: 156,
        commentCount: 8,
      ),
      StaffPost(
        id: '5',
        staffId: staff.id,
        mediaUrl: 'https://images.unsplash.com/photo-1522337660859-02fbefca4702?w=400',
        type: PostType.image,
        caption: '素敵なお客様とのひととき✨',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        likeCount: 428,
        commentCount: 32,
      ),
      StaffPost(
        id: '6',
        staffId: staff.id,
        mediaUrl: 'https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=400',
        type: PostType.image,
        caption: '週末の特別メニューのご案内🎉',
        timestamp: DateTime.now().subtract(const Duration(days: 7)),
        likeCount: 267,
        commentCount: 15,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final posts = _getMockPosts();

    return Scaffold(
      appBar: AppBar(
        title: Text('${staff.name}の投稿'),
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // プロフィールヘッダー
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: CachedNetworkImageProvider(staff.profileImage),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          staff.name,
                          style: const TextStyle(
                            fontSize: 20,
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 統計情報
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem('投稿', '${posts.length}'),
                  _buildStatItem('評価', staff.rating.toStringAsFixed(1)),
                  _buildStatItem('レビュー', '${staff.reviewCount}'),
                ],
              ),
            ),
          ),
          
          // Instagram風グリッド
          SliverPadding(
            padding: const EdgeInsets.all(2),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildGridItem(context, posts[index]);
                },
                childCount: posts.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
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

  Widget _buildGridItem(BuildContext context, StaffPost post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(
              post: post,
              staff: staff,
            ),
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
          // オーバーレイ（統計情報）
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${post.likeCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
