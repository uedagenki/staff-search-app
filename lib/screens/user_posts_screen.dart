import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_post.dart';

class UserPostsScreen extends StatefulWidget {
  const UserPostsScreen({super.key});

  @override
  State<UserPostsScreen> createState() => _UserPostsScreenState();
}

class _UserPostsScreenState extends State<UserPostsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<UserPost> _allPosts = UserPost.getDemoData();
  final List<UserPost> _followingPosts = UserPost.getDemoData();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('みんなの投稿'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'すべて'),
            Tab(text: 'フォロー中'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostList(_allPosts),
          _buildPostList(_followingPosts),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // 投稿作成画面へ遷移（今後実装）
          _showCreatePostDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text('投稿する'),
      ),
    );
  }

  Widget _buildPostList(List<UserPost> posts) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return _buildPostCard(posts[index]);
      },
    );
  }

  Widget _buildPostCard(UserPost post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー（ユーザー情報）
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(post.userProfileImage),
            ),
            title: Text(
              post.userName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.staffName != null)
                  Text(
                    '${post.staffName}さんと交流',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                Text(
                  _getTimeAgo(post.createdAt),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                _showPostOptions(post);
              },
            ),
          ),
          
          // コンテンツ
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                post.content,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          
          // 画像
          if (post.imageUrls.isNotEmpty)
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: post.imageUrls.length,
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: post.imageUrls[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
            ),
          
          // アクションボタン
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: post.isLiked ? Colors.red : null,
                  ),
                  onPressed: () {
                    // いいね機能
                  },
                ),
                Text('${post.likeCount}'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () {
                    // コメント画面へ遷移
                  },
                ),
                Text('${post.commentCount}'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    // シェア機能
                  },
                ),
                Text('${post.shareCount}'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {
                    // ブックマーク機能
                  },
                ),
              ],
            ),
          ),
          
          // 位置情報
          if (post.location != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    post.location!,
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
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}日前';
    } else {
      return '${(difference.inDays / 30).floor()}ヶ月前';
    }
  }

  void _showPostOptions(UserPost post) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('リンクをコピー'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_outlined),
              title: const Text('報告する'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('投稿作成'),
        content: const Text(
          '投稿作成機能は準備中です。\n\nスタッフとの思い出や体験を\nシェアできるようになります！',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
