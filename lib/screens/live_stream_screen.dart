// SCREEN: Live Stream Screen (Viewer) | LIVE-04
import '../../utils/screen_logger.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/staff.dart';

class LiveStreamScreen extends StatefulWidget {
  final Staff staff;
  final String videoUrl;

  const LiveStreamScreen({
    super.key,
    required this.staff,
    required this.videoUrl,
  });

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> with ScreenLogMixin, SingleTickerProviderStateMixin {
  @override
  String get screenId => 'Live Stream Screen (Viewer) | LIVE-04';

  late VideoPlayerController _videoController;
  late AnimationController _pulseController;
  bool _isVideoInitialized = false;
  int _viewerCount = 0;
  final List<String> _comments = [];
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _initializeAnimation();
    _simulateViewers();
    _simulateComments();
  }

  void _initializeVideo() {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    )..initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
        });
        _videoController.play();
        _videoController.setLooping(true);
      });
  }

  void _initializeAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseController.repeat(reverse: true);
  }

  void _simulateViewers() {
    // ランダムな視聴者数をシミュレート
    setState(() {
      _viewerCount = 1234 + (DateTime.now().millisecond % 500);
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _simulateViewers();
    });
  }

  void _simulateComments() {
    final sampleComments = [
      '素晴らしい説明ですね！',
      'とても参考になります',
      'いつも見てます😊',
      'すごくわかりやすい✨',
      '質問してもいいですか？',
      'フォローしました！',
      '今日も楽しみにしてました',
      'プロの技術が素晴らしい',
    ];

    Future.delayed(Duration(seconds: 2 + (DateTime.now().millisecond % 3)), () {
      if (mounted) {
        setState(() {
          _comments.insert(0, sampleComments[DateTime.now().millisecond % sampleComments.length]);
          if (_comments.length > 6) {
            _comments.removeLast();
          }
        });
        _simulateComments();
      }
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _pulseController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ビデオプレイヤー
          if (_isVideoInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: VideoPlayer(_videoController),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // グラデーションオーバーレイ
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                  stops: const [0.0, 0.2, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // 上部コントロール
          SafeArea(
            child: Column(
              children: [
                // ヘッダー
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // 閉じるボタン
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      // 視聴者数
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.remove_red_eye, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              _viewerCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // シェアボタン
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.share, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // スタッフ情報とアクションボタン
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 左側：スタッフ情報とコメント
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // コメント一覧
                            ...List.generate(
                              _comments.length > 5 ? 5 : _comments.length,
                              (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _comments[index],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // スタッフ情報
                            Row(
                              children: [
                                // LIVEバッジ（パルスアニメーション）
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(alpha: 0.7 + (_pulseController.value * 0.3)),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'LIVE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 12),
                                // プロフィール画像
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(widget.staff.profileImage),
                                ),
                                const SizedBox(width: 12),
                                // 名前と職種
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.staff.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        widget.staff.jobTitle,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.8),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 右側：アクションボタン
                      Column(
                        children: [
                          // いいねボタン
                          _buildActionButton(
                            Icons.favorite_border,
                            '${widget.staff.followersCount}',
                            Colors.white,
                          ),
                          const SizedBox(height: 20),
                          // コメントボタン
                          _buildActionButton(
                            Icons.chat_bubble_outline,
                            '${_comments.length}',
                            Colors.white,
                          ),
                          const SizedBox(height: 20),
                          // ギフトボタン
                          _buildActionButton(
                            Icons.card_giftcard,
                            'ギフト',
                            Colors.amber,
                          ),
                          const SizedBox(height: 20),
                          // フォローボタン
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: const Icon(Icons.add, color: Colors.white, size: 24),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // コメント入力欄
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.black.withValues(alpha: 0.3),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Text(
                            'コメントを追加...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.send,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
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

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
