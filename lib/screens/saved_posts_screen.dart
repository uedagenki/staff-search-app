import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/staff_post.dart';
import '../models/staff.dart';
import '../data/mock_data.dart';
import '../services/saved_posts_service.dart';

/// 保存済み投稿一覧画面
class SavedPostsScreen extends StatefulWidget {
  const SavedPostsScreen({super.key});

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  final SavedPostsService _savedPostsService = SavedPostsService();
  final List<_SavedPostItem> _savedPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPosts();
  }

  Future<void> _loadSavedPosts() async {
    setState(() {
      _isLoading = true;
    });

    final savedPostIds = await _savedPostsService.getSavedPostIds();
    final allStaff = MockData.getStaffList();
    
    // デモ投稿を生成して、保存済みのものをフィルター
    for (var staff in allStaff) {
      for (var i = 0; i < 3; i++) {
        final postId = 'post_${staff.id}_$i';
        
        if (savedPostIds.contains(postId)) {
          final post = StaffPost(
            id: postId,
            staffId: staff.id,
            mediaUrl: staff.profileImages.isNotEmpty
                ? staff.profileImages[i % staff.profileImages.length]
                : staff.profileImage,
            type: PostType.image,
            caption: _generateCaption(staff, i),
            timestamp: DateTime.now().subtract(Duration(days: i)),
            likeCount: 100 + (i * 50),
            commentCount: 10 + (i * 5),
            isSaved: true,
          );
          
          _savedPosts.add(_SavedPostItem(staff: staff, post: post));
        }
      }
    }

    // 新しい順にソート
    _savedPosts.sort((a, b) => b.post.timestamp.compareTo(a.post.timestamp));

    setState(() {
      _isLoading = false;
    });
  }

  String _generateCaption(Staff staff, int index) {
    final captions = [
      '今日も頑張ります！💪',
      '${staff.location}でお待ちしています✨',
      '新しいメニューをご紹介！🎉',
    ];
    return captions[index % captions.length];
  }

  Future<void> _unsavePost(_SavedPostItem item) async {
    await _savedPostsService.unsavePost(item.post.id);
    
    setState(() {
      _savedPosts.remove(item);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('保存を解除しました'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.black87,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('保存済み'),
        actions: [
          if (_savedPosts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                _showClearAllDialog();
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedPosts.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.all(2),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                    childAspectRatio: 1,
                  ),
                  itemCount: _savedPosts.length,
                  itemBuilder: (context, index) {
                    return _buildPostThumbnail(_savedPosts[index]);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            '保存済み投稿がありません',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '気に入った投稿を保存すると\nここに表示されます',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostThumbnail(_SavedPostItem item) {
    return GestureDetector(
      onTap: () {
        _showPostDetail(item);
      },
      onLongPress: () {
        _showPostOptions(item);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: item.post.imageUrl,
            fit: BoxFit.cover,
          ),
          // グラデーション（下部）
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),
          // いいね数（左下）
          Positioned(
            bottom: 4,
            left: 4,
            child: Row(
              children: [
                const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 2),
                Text(
                  _formatCount(item.post.likeCount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // ブックマークアイコン（右上）
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark,
                color: Colors.yellow,
                size: 16,
              ),
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

  void _showPostDetail(_SavedPostItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 画像
              AspectRatio(
                aspectRatio: 1,
                child: CachedNetworkImage(
                  imageUrl: item.post.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              // 情報
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                            item.staff.profileImage,
                          ),
                          radius: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.staff.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                item.staff.jobTitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(item.post.caption),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.favorite, size: 16, color: Colors.red),
                        const SizedBox(width: 4),
                        Text('${item.post.likeCount}'),
                        const SizedBox(width: 16),
                        const Icon(Icons.comment, size: 16),
                        const SizedBox(width: 4),
                        Text('${item.post.commentCount}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPostOptions(_SavedPostItem item) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.bookmark_remove),
                title: const Text('保存を解除'),
                onTap: () {
                  Navigator.pop(context);
                  _unsavePost(item);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('シェア'),
                onTap: () {
                  Navigator.pop(context);
                  // シェア処理
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('すべての保存を解除'),
          content: const Text('保存済みのすべての投稿を解除しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _savedPostsService.clearAll();
                setState(() {
                  _savedPosts.clear();
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('すべての保存を解除しました'),
                      duration: Duration(seconds: 1),
                      backgroundColor: Colors.black87,
                    ),
                  );
                }
              },
              child: const Text(
                '解除',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SavedPostItem {
  final Staff staff;
  final StaffPost post;

  _SavedPostItem({
    required this.staff,
    required this.post,
  });
}
