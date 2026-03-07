import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../models/staff_post.dart';
import '../models/staff.dart';
import '../models/post_comment.dart';
import '../models/live_stream.dart';
import '../data/mock_data.dart';
import '../services/follow_service.dart';
import '../services/post_comment_service.dart';
import 'staff_detail_screen.dart';
// import 'live_viewer_screen.dart'; // Webビルドの問題を回避

/// TikTok形式のスタッフ投稿フィード画面
/// フォロー、コメント投稿、シェア、ライブ中UI表示機能付き
class StaffFeedScreen extends StatefulWidget {
  const StaffFeedScreen({super.key});

  @override
  State<StaffFeedScreen> createState() => _StaffFeedScreenState();
}

class _StaffFeedScreenState extends State<StaffFeedScreen> {
  final PageController _pageController = PageController();
  final FollowService _followService = FollowService();
  final PostCommentService _commentService = PostCommentService();
  final List<_FeedItem> _feedItems = [];
  final Map<String, bool> _followStatus = {};

  @override
  void initState() {
    super.initState();
    _loadFeedItems();
    _loadFollowStatus();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadFeedItems() {
    // 全スタッフの投稿を生成（デモデータ）
    final allStaff = MockData.getStaffList();
    for (var i = 0; i < allStaff.length; i++) {
      final staff = allStaff[i];
      
      // 各スタッフに2〜3個の投稿を生成
      final postCount = 2 + (i % 2);
      for (var j = 0; j < postCount; j++) {
        final post = StaffPost(
          id: 'post_${staff.id}_$j',
          staffId: staff.id,
          mediaUrl: staff.profileImages.isNotEmpty 
              ? staff.profileImages[j % staff.profileImages.length]
              : staff.profileImage,
          type: PostType.image,
          caption: _generateCaption(staff, j),
          timestamp: DateTime.now().subtract(Duration(hours: i * 3 + j)),
          likeCount: 100 + (i * 50) + (j * 20),
          commentCount: 10 + (i * 5) + (j * 2),
        );
        _feedItems.add(_FeedItem(staff: staff, post: post));
        
        // デモコメント生成
        _commentService.generateDemoComments(post.id);
      }
    }
    
    // 投稿日時順にソート（新しい順）
    _feedItems.sort((a, b) => b.post.createdAt.compareTo(a.post.createdAt));
    
    setState(() {});
  }
  
  String _generateCaption(Staff staff, int index) {
    final captions = [
      '今日も頑張ります！💪 #${staff.jobTitle}',
      '${staff.location}でお待ちしています✨',
      '新しいメニューをご紹介！ぜひご来店ください🎉',
      'いつもありがとうございます😊',
      '週末も営業中です！お気軽にどうぞ💕',
    ];
    return captions[index % captions.length];
  }

  void _loadFollowStatus() async {
    for (var item in _feedItems) {
      final isFollowing = await _followService.isFollowing(item.staff.id);
      setState(() {
        _followStatus[item.staff.id] = isFollowing;
      });
    }
  }

  Future<void> _toggleFollow(String staffId) async {
    final currentStatus = _followStatus[staffId] ?? false;
    
    if (currentStatus) {
      await _followService.unfollowStaff(staffId);
    } else {
      await _followService.followStaff(staffId);
    }
    
    setState(() {
      _followStatus[staffId] = !currentStatus;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentStatus ? 'フォローを解除しました' : 'フォローしました',
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.black87,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_feedItems.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.post_add,
                size: 64,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                '投稿がありません',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'スタッフ配信',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _feedItems.length,
        itemBuilder: (context, index) {
          return _buildFeedItem(_feedItems[index]);
        },
      ),
    );
  }

  Widget _buildFeedItem(_FeedItem item) {
    final isFollowing = _followStatus[item.staff.id] ?? false;
    final isLive = item.staff.isLive;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 背景画像（全画面）
        CachedNetworkImage(
          imageUrl: item.post.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[900],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[900],
            child: const Center(
              child: Icon(Icons.error, color: Colors.white),
            ),
          ),
        ),

        // グラデーション（下部）
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
        ),

        // ライブ中バッジ（左上）
        if (isLive)
          Positioned(
            top: 100,
            left: 12,
            child: _buildLiveBadge(item),
          ),

        // 右側のアクションボタン（TikTok風）
        Positioned(
          right: 12,
          bottom: 100,
          child: _buildActionButtons(item),
        ),

        // 下部の情報エリア
        Positioned(
          left: 12,
          right: 80,
          bottom: 80,
          child: _buildInfoSection(item, isFollowing),
        ),
      ],
    );
  }

  Widget _buildLiveBadge(_FeedItem item) {
    return GestureDetector(
      onTap: () {
        // ライブ配信画面へ遷移（Webでは一時的に無効）
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ライブ配信視聴は現在準備中です'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
        /* // Webビルドの問題を回避するため一時的にコメントアウト
        final liveStream = LiveStream(
          id: 'live_${item.staff.id}',
          staffId: item.staff.id,
          staffName: item.staff.name,
          staffProfileImage: item.staff.profileImage,
          title: '${item.staff.name}のライブ配信',
          category: item.staff.category,
          startedAt: DateTime.now(),
          viewerCount: item.staff.followersCount,
          channelName: 'live_${item.staff.id}',
          token: 'demo_token_${item.staff.id}',
        );
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LiveViewerScreen(liveStream: liveStream),
          ),
        );
        */
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'LIVE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.remove_red_eye,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              '${item.staff.followersCount > 1000 ? '${(item.staff.followersCount / 1000).toStringAsFixed(1)}K' : item.staff.followersCount}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(_FeedItem item) {
    return Column(
      children: [
        // プロフィールアイコン
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StaffDetailScreen(staff: item.staff),
              ),
            );
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              image: DecorationImage(
                image: CachedNetworkImageProvider(item.staff.profileImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // いいねボタン
        _ActionButton(
          icon: item.post.isLiked ? Icons.favorite : Icons.favorite_border,
          count: item.post.likeCount,
          color: item.post.isLiked ? Colors.red : Colors.white,
          onTap: () {
            setState(() {
              item.post.isLiked = !item.post.isLiked;
              item.post.likeCount += item.post.isLiked ? 1 : -1;
            });
          },
        ),

        const SizedBox(height: 24),

        // コメントボタン
        _ActionButton(
          icon: Icons.comment,
          count: item.post.commentCount,
          color: Colors.white,
          onTap: () {
            _showCommentsBottomSheet(context, item);
          },
        ),

        const SizedBox(height: 24),

        // 保存ボタン
        _ActionButton(
          icon: item.post.isSaved ? Icons.bookmark : Icons.bookmark_border,
          count: null,
          color: item.post.isSaved ? Colors.yellow : Colors.white,
          onTap: () {
            setState(() {
              item.post.isSaved = !item.post.isSaved;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(item.post.isSaved ? '保存しました' : '保存を解除しました'),
                duration: const Duration(seconds: 1),
                backgroundColor: Colors.black87,
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // シェアボタン
        _ActionButton(
          icon: Icons.share,
          count: null,
          color: Colors.white,
          onTap: () {
            _sharePost(item);
          },
        ),
      ],
    );
  }

  Widget _buildInfoSection(_FeedItem item, bool isFollowing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // スタッフ名
        Row(
          children: [
            Text(
              '@${item.staff.name}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            // フォローボタン
            GestureDetector(
              onTap: () => _toggleFollow(item.staff.id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isFollowing ? Colors.grey[800] : Colors.red,
                  borderRadius: BorderRadius.circular(4),
                  border: isFollowing 
                      ? Border.all(color: Colors.white, width: 1.5)
                      : null,
                ),
                child: Text(
                  isFollowing ? 'フォロー中' : 'フォロー',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // キャプション
        Text(
          item.post.caption,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 8),

        // 職種・勤務地
        Row(
          children: [
            Icon(
              Icons.work_outline,
              size: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 4),
            Text(
              '${item.staff.jobTitle} · ${item.staff.location}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _sharePost(_FeedItem item) {
    // 投稿のURL生成（デモ用）
    final postUrl = 'https://staff-search.app/posts/${item.post.id}';
    
    Share.share(
      '${item.staff.name}さんの投稿をチェック!\n\n'
      '${item.post.caption}\n\n'
      '$postUrl\n\n'
      '#スタッフサーチ #${item.staff.jobTitle}',
      subject: '${item.staff.name}さんの投稿',
    );
  }

  void _showCommentsBottomSheet(BuildContext context, _FeedItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _CommentsBottomSheet(
          postId: item.post.id,
          staffName: item.staff.name,
          commentService: _commentService,
          onCommentAdded: () {
            setState(() {
              item.post.commentCount++;
            });
          },
        );
      },
    );
  }
}

/// コメントボトムシート
class _CommentsBottomSheet extends StatefulWidget {
  final String postId;
  final String staffName;
  final PostCommentService commentService;
  final VoidCallback onCommentAdded;

  const _CommentsBottomSheet({
    required this.postId,
    required this.staffName,
    required this.commentService,
    required this.onCommentAdded,
  });

  @override
  State<_CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<_CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  List<PostComment> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final comments = await widget.commentService.getComments(widget.postId);
    setState(() {
      _comments = comments;
      _isLoading = false;
    });
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final comment = await widget.commentService.addComment(
      postId: widget.postId,
      content: _commentController.text.trim(),
    );

    setState(() {
      _comments.insert(0, comment);
      _commentController.clear();
    });

    widget.onCommentAdded();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('コメントを投稿しました'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.black87,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // ハンドル
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // タイトル
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_comments.length}件のコメント',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // コメント一覧
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _comments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.comment_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'まだコメントがありません',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: _comments.length,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemBuilder: (context, index) {
                              return _buildCommentItem(_comments[index]);
                            },
                          ),
              ),

              const Divider(height: 1),

              // コメント入力欄
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: 12,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'コメントを追加...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _addComment(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: _addComment,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentItem(PostComment comment) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        backgroundImage: comment.userAvatar != null
            ? CachedNetworkImageProvider(comment.userAvatar!)
            : null,
        child: comment.userAvatar == null
            ? Text(
                comment.userName[0],
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : null,
      ),
      title: Row(
        children: [
          Text(
            comment.userName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatTimestamp(comment.createdAt),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(comment.content),
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              comment.isLiked ? Icons.favorite : Icons.favorite_border,
              size: 18,
              color: comment.isLiked ? Colors.red : Colors.grey,
            ),
            onPressed: () async {
              await widget.commentService.toggleCommentLike(comment.id);
              _loadComments();
            },
          ),
          if (comment.likeCount > 0)
            Text(
              '${comment.likeCount}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'たった今';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }
}

/// アクションボタンウィジェット
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final int? count;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.3),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          if (count != null) ...[
            const SizedBox(height: 4),
            Text(
              _formatCount(count!),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
}

/// フィードアイテム
class _FeedItem {
  final Staff staff;
  final StaffPost post;

  _FeedItem({
    required this.staff,
    required this.post,
  });
}
