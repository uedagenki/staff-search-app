import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'dart:async';
import '../models/staff.dart';
import '../data/mock_data.dart';

class LiveFeedScreen extends StatefulWidget {
  const LiveFeedScreen({super.key});

  @override
  State<LiveFeedScreen> createState() => _LiveFeedScreenState();
}

class _LiveFeedScreenState extends State<LiveFeedScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ライブ配信中のスタッフと動画URLのマッピング（TikTok風ライブ動画）
  final List<Map<String, dynamic>> _liveStreams = [
    {
      'staffId': '9', // 小林さくら（カリスマ美容師）
      'videoUrl': 'https://www.genspark.ai/api/files/s/heyQkmlQ', // TikTok風美容師ライブ
    },
    {
      'staffId': '10', // 中村拓也（ビジネスコンサルタント）
      'videoUrl': 'https://www.genspark.ai/api/files/s/zZWFgZhu', // TikTok風ビジネスライブ
    },
    {
      'staffId': '11', // 山本あやか（パーソナルトレーナー）
      'videoUrl': 'https://www.genspark.ai/api/files/s/RQIWc4Sh', // TikTok風フィットネスライブ
    },
  ];

  late List<Staff> _staffList;

  @override
  void initState() {
    super.initState();
    _staffList = MockData.getStaffList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Staff _getStaffById(String staffId) {
    return _staffList.firstWhere(
      (staff) => staff.id == staffId,
      orElse: () => _staffList.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemCount: _liveStreams.length,
        itemBuilder: (context, index) {
          final liveStream = _liveStreams[index];
          final staff = _getStaffById(liveStream['staffId']);
          return LiveStreamPage(
            staff: staff,
            videoUrl: liveStream['videoUrl'],
            isActive: index == _currentPage,
            key: ValueKey('video_$index'),
          );
        },
      ),
    );
  }
}

class LiveStreamPage extends StatefulWidget {
  final Staff staff;
  final String videoUrl;
  final bool isActive;

  const LiveStreamPage({
    super.key,
    required this.staff,
    required this.videoUrl,
    required this.isActive,
  });

  @override
  State<LiveStreamPage> createState() => _LiveStreamPageState();
}

class _LiveStreamPageState extends State<LiveStreamPage> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _viewerCount = 0;
  final List<String> _comments = [];
  late String _videoViewType;
  Timer? _viewerTimer;
  Timer? _commentTimer;

  @override
  void initState() {
    super.initState();
    _videoViewType = 'video-${widget.videoUrl.hashCode}';
    _initializeAnimation();
    _simulateViewers();
    _simulateComments();
    _registerVideoElement();
  }

  void _registerVideoElement() {
    // HTMLビデオ要素を登録
    ui_web.platformViewRegistry.registerViewFactory(
      _videoViewType,
      (int viewId) {
        final videoElement = html.VideoElement()
          ..src = widget.videoUrl
          ..autoplay = true  // 常に自動再生
          ..loop = true
          ..muted = false
          ..controls = false
          ..preload = 'auto'  // 動画を事前読み込み
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'cover'
          ..style.backgroundColor = '#000000';
        
        // playsinline属性を手動で設定（モバイルブラウザ対応）
        videoElement.setAttribute('playsinline', 'true');
        videoElement.setAttribute('webkit-playsinline', 'true');

        // 動画の読み込みイベントをリッスン
        videoElement.onLoadedData.listen((event) {
          print('✅ 動画読み込み完了: ${widget.videoUrl}');
          // 読み込み完了後、即座に再生を試行
          videoElement.play().catchError((error) {
            print('⚠️ 自動再生失敗、再試行: $error');
          });
        });

        videoElement.onError.listen((event) {
          print('❌ 動画エラー: ${widget.videoUrl}');
        });

        videoElement.onCanPlay.listen((event) {
          print('▶️ 動画再生可能: ${widget.videoUrl}');
          // 再生可能になったら即座に再生
          videoElement.play().catchError((error) {
            print('⚠️ 再生エラー: $error');
          });
        });

        // 動画が一時停止された場合、自動的に再開
        videoElement.onPause.listen((event) {
          if (widget.isActive) {
            print('🔄 動画が一時停止されました。再開します...');
            Future.delayed(const Duration(milliseconds: 100), () {
              videoElement.play();
            });
          }
        });

        return videoElement;
      },
    );
  }

  @override
  void didUpdateWidget(LiveStreamPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // アクティブ状態が変わったら動画の再生/停止を制御
    if (widget.isActive != oldWidget.isActive) {
      _controlVideoPlayback();
    }
  }

  void _controlVideoPlayback() {
    final videoElements = html.document.getElementsByTagName('video');
    for (var element in videoElements) {
      final videoElement = element as html.VideoElement;
      if (videoElement.src == widget.videoUrl) {
        if (widget.isActive) {
          videoElement.play();
        } else {
          videoElement.pause();
        }
      }
    }
  }

  void _initializeAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseController.repeat(reverse: true);
  }

  void _simulateViewers() {
    _viewerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _viewerCount = 1234 + (DateTime.now().millisecond % 500);
        });
      }
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

    _commentTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _comments.insert(0, sampleComments[DateTime.now().millisecond % sampleComments.length]);
          if (_comments.length > 6) {
            _comments.removeLast();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _viewerTimer?.cancel();
    _commentTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // HTMLビデオプレーヤー（Web版で確実に動作）
        Positioned.fill(
          child: HtmlElementView(
            viewType: _videoViewType,
          ),
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

        // UI オーバーレイ
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
                              // LIVEバッジ
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
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(widget.staff.profileImage),
                              ),
                              const SizedBox(width: 12),
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
                        _buildActionButton(Icons.favorite_border, '${widget.staff.followersCount}', Colors.white),
                        const SizedBox(height: 20),
                        _buildActionButton(Icons.chat_bubble_outline, '${_comments.length}', Colors.white),
                        const SizedBox(height: 20),
                        _buildActionButton(Icons.card_giftcard, 'ギフト', Colors.amber),
                        const SizedBox(height: 20),
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
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: const Text(
                          'コメントを追加...',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
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
