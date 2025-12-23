import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/staff_post.dart';
import 'create_post_screen.dart';

class StaffPostsManagementScreen extends StatefulWidget {
  const StaffPostsManagementScreen({super.key});

  @override
  State<StaffPostsManagementScreen> createState() => _StaffPostsManagementScreenState();
}

class _StaffPostsManagementScreenState extends State<StaffPostsManagementScreen> {
  // デモ投稿データ
  final List<StaffPost> _posts = [
    StaffPost(
      id: '1',
      staffId: 'current_staff',
      mediaUrl: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
      type: PostType.image,
      caption: '今日のヘアスタイル✨',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      likeCount: 45,
      commentCount: 12,
    ),
    StaffPost(
      id: '2',
      staffId: 'current_staff',
      mediaUrl: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
      type: PostType.video,
      caption: 'カット技術の動画です💇‍♀️',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      likeCount: 89,
      commentCount: 23,
      thumbnailUrl: 'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=400',
      duration: 30,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    '投稿管理',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // 新規投稿ボタン
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreatePostScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('新規投稿'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // 統計情報
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildStatChip('総投稿', '${_posts.length}', Icons.photo_library),
                  const SizedBox(width: 8),
                  _buildStatChip('いいね', '${_posts.fold(0, (sum, post) => sum + post.likeCount)}', Icons.favorite),
                  const SizedBox(width: 8),
                  _buildStatChip('コメント', '${_posts.fold(0, (sum, post) => sum + post.commentCount)}', Icons.comment),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 投稿一覧
            Expanded(
              child: _posts.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        return _buildPostThumbnail(_posts[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.grey[700]),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostThumbnail(StaffPost post) {
    return GestureDetector(
      onTap: () => _showPostOptions(post),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // サムネイル画像
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: post.type == PostType.video && post.thumbnailUrl != null
                ? CachedNetworkImage(
                    imageUrl: post.thumbnailUrl!,
                    fit: BoxFit.cover,
                  )
                : CachedNetworkImage(
                    imageUrl: post.mediaUrl,
                    fit: BoxFit.cover,
                  ),
          ),

          // 動画アイコン
          if (post.type == PostType.video)
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),

          // 統計情報オーバーレイ
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, color: Colors.white, size: 12),
                  const SizedBox(width: 2),
                  Text(
                    '${post.likeCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'まだ投稿がありません',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '新規投稿ボタンから投稿を追加しましょう',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showPostOptions(StaffPost post) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('編集'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('編集機能（開発中）')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('統計を見る'),
                onTap: () {
                  Navigator.pop(context);
                  _showPostStats(post);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('削除', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(post);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPostStats(StaffPost post) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('投稿の統計'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow('いいね数', '${post.likeCount}'),
              _buildStatRow('コメント数', '${post.commentCount}'),
              _buildStatRow('投稿日時', _formatDate(post.timestamp)),
              if (post.type == PostType.video)
                _buildStatRow('動画の長さ', '${post.duration}秒'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _confirmDelete(StaffPost post) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('投稿を削除'),
          content: const Text('この投稿を削除しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _posts.remove(post);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('投稿を削除しました')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('削除'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
