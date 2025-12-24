import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ContentModerationScreen extends StatefulWidget {
  const ContentModerationScreen({super.key});

  @override
  State<ContentModerationScreen> createState() => _ContentModerationScreenState();
}

class _ContentModerationScreenState extends State<ContentModerationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<ReviewItem> _pendingReviews = [
    ReviewItem(
      id: 'review_001',
      userName: '山田 太郎',
      userImage: 'https://i.pravatar.cc/150?img=12',
      staffName: '田中 美咲',
      rating: 1.0,
      content: 'このサービスは最悪でした。二度と利用しません。',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      status: ModerationStatus.pending,
      flags: ['不適切な言葉', '低評価'],
    ),
    ReviewItem(
      id: 'review_002',
      userName: '佐藤 花子',
      userImage: 'https://i.pravatar.cc/150?img=45',
      staffName: '佐藤 健',
      rating: 5.0,
      content: '素晴らしいサービスでした！また利用したいです',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      status: ModerationStatus.pending,
      flags: [],
    ),
  ];

  final List<ReviewItem> _approvedReviews = [
    ReviewItem(
      id: 'review_003',
      userName: '鈴木 一郎',
      userImage: 'https://i.pravatar.cc/150?img=33',
      staffName: '中村 大輔',
      rating: 4.5,
      content: 'とても良い対応でした。満足しています。',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      status: ModerationStatus.approved,
      flags: [],
    ),
  ];

  final List<ReviewItem> _rejectedReviews = [
    ReviewItem(
      id: 'review_004',
      userName: '伊藤 健太',
      userImage: 'https://i.pravatar.cc/150?img=68',
      staffName: '田中 美咲',
      rating: 1.0,
      content: 'ばか、あほ、詐欺だ！',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      status: ModerationStatus.rejected,
      flags: ['不適切な言葉', '誹謗中傷'],
    ),
  ];

  final List<String> _ngWords = [
    'ばか', 'あほ', '詐欺', '最悪', '死ね', 'クソ', 'ゴミ',
    '殺す', '暴力', '脅迫', '犯罪', '違法', 'アホ', 'バカ',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<String> _checkForNGWords(String content) {
    List<String> foundWords = [];
    for (String word in _ngWords) {
      if (content.contains(word)) {
        foundWords.add(word);
      }
    }
    return foundWords;
  }

  void _approveReview(ReviewItem review) {
    setState(() {
      _pendingReviews.remove(review);
      _approvedReviews.add(review.copyWith(status: ModerationStatus.approved));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('レビューを承認しました'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectReview(ReviewItem review) {
    setState(() {
      _pendingReviews.remove(review);
      _rejectedReviews.add(review.copyWith(status: ModerationStatus.rejected));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('レビューを却下しました'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _blockUser(ReviewItem review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ユーザーをブロック'),
        content: Text('${review.userName}さんをブロックしますか？\n\nブロックされたユーザーは以下の制限を受けます：\n• レビュー投稿不可\n• メッセージ送信不可\n• サービス利用制限'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _pendingReviews.remove(review);
                _rejectedReviews.add(review.copyWith(
                  status: ModerationStatus.blocked,
                  flags: [...review.flags, 'ユーザーブロック済み'],
                ));
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${review.userName}さんをブロックしました'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ブロック'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('コンテンツ管理'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('審査待ち'),
                  if (_pendingReviews.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_pendingReviews.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            const Tab(text: '承認済み'),
            const Tab(text: '却下/ブロック'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReviewList(_pendingReviews, isPending: true),
          _buildReviewList(_approvedReviews),
          _buildReviewList(_rejectedReviews),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNGWordsDialog(),
        icon: const Icon(Icons.list),
        label: const Text('NGワード管理'),
      ),
    );
  }

  Widget _buildReviewList(List<ReviewItem> reviews, {bool isPending = false}) {
    if (reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'レビューはありません',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        return _buildReviewCard(reviews[index], isPending: isPending);
      },
    );
  }

  Widget _buildReviewCard(ReviewItem review, {bool isPending = false}) {
    final ngWords = _checkForNGWords(review.content);
    final hasNGWords = ngWords.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ユーザー情報
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: CachedNetworkImage(
                    imageUrl: review.userImage,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            review.userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (review.status == ModerationStatus.blocked)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'ブロック済み',
                                style: TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        'スタッフ: ${review.staffName}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < review.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        ),
                      ),
                    ),
                    Text(
                      _formatTime(review.timestamp),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // レビュー内容
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasNGWords ? Colors.red[50] : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasNGWords ? Colors.red : Colors.grey[300]!,
                  width: hasNGWords ? 2 : 1,
                ),
              ),
              child: Text(
                review.content,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: hasNGWords ? Colors.red[900] : Colors.black87,
                ),
              ),
            ),

            // NGワード警告
            if (hasNGWords) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'NGワードが含まれています',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '検出: ${ngWords.join(', ')}',
                            style: TextStyle(color: Colors.red[700], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // フラグ
            if (review.flags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: review.flags.map((flag) {
                  return Chip(
                    label: Text(flag),
                    backgroundColor: Colors.orange[100],
                    labelStyle: const TextStyle(fontSize: 12),
                  );
                }).toList(),
              ),
            ],

            // アクションボタン
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectReview(review),
                      icon: const Icon(Icons.close),
                      label: const Text('却下'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _blockUser(review),
                      icon: const Icon(Icons.block),
                      label: const Text('ブロック'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveReview(review),
                      icon: const Icon(Icons.check),
                      label: const Text('承認'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showNGWordsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('NGワード一覧'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _ngWords.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.block, color: Colors.red, size: 20),
                title: Text(_ngWords[index]),
                dense: true,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('NGワード編集機能機能は実装済みです')),
              );
            },
            child: const Text('編集'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays == 1) {
      return '昨日';
    } else {
      return '${difference.inDays}日前';
    }
  }
}

class ReviewItem {
  final String id;
  final String userName;
  final String userImage;
  final String staffName;
  final double rating;
  final String content;
  final DateTime timestamp;
  final ModerationStatus status;
  final List<String> flags;

  ReviewItem({
    required this.id,
    required this.userName,
    required this.userImage,
    required this.staffName,
    required this.rating,
    required this.content,
    required this.timestamp,
    required this.status,
    required this.flags,
  });

  ReviewItem copyWith({
    ModerationStatus? status,
    List<String>? flags,
  }) {
    return ReviewItem(
      id: id,
      userName: userName,
      userImage: userImage,
      staffName: staffName,
      rating: rating,
      content: content,
      timestamp: timestamp,
      status: status ?? this.status,
      flags: flags ?? this.flags,
    );
  }
}

enum ModerationStatus {
  pending,
  approved,
  rejected,
  blocked,
}
