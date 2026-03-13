// SCREEN: Live Viewer Screen | LIVE-04
import '../../utils/screen_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../models/live_stream.dart';
import '../services/live_stream_service.dart';
import 'dart:async';

class LiveViewerScreen extends StatefulWidget {
  final LiveStream liveStream;

  const LiveViewerScreen({
    super.key,
    required this.liveStream,
  });

  @override
  State<LiveViewerScreen> createState() => _LiveViewerScreenState();
}

class _LiveViewerScreenState extends State<LiveViewerScreen> with ScreenLogMixin {
  @override
  String get screenId => 'Live Viewer Screen | LIVE-04';

  final _liveStreamService = LiveStreamService();
  final _commentController = TextEditingController();
  
  RtcEngine? _engine;
  bool _isJoined = false;
  int _remoteUid = 0;
  List<LiveComment> _comments = [];
  List<LiveGift> _gifts = [];
  Timer? _commentPollingTimer;

  @override
  void initState() {
    super.initState();
    _gifts = LiveGift.getSampleGifts();
    _initAgora();
    _loadComments();
    _startCommentPolling();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentPollingTimer?.cancel();
    _destroyEngine();
    super.dispose();
  }

  Future<void> _initAgora() async {
    try {
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(const RtcEngineContext(
        appId: LiveStreamService.agoraAppId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));

      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            if (kDebugMode) {
              debugPrint('Viewer joined channel: ${connection.channelId}');
            }
            setState(() {
              _isJoined = true;
            });
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            if (kDebugMode) {
              debugPrint('Remote user joined: $remoteUid');
            }
            setState(() {
              _remoteUid = remoteUid;
            });
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            if (kDebugMode) {
              debugPrint('Remote user offline: $remoteUid');
            }
            setState(() {
              _remoteUid = 0;
            });
          },
        ),
      );

      await _engine!.enableVideo();
      await _engine!.setClientRole(role: ClientRoleType.clientRoleAudience);

      await _engine!.joinChannel(
        token: widget.liveStream.token,
        channelId: widget.liveStream.channelName,
        uid: 0,
        options: const ChannelMediaOptions(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to initialize Agora: $e');
      }
    }
  }

  Future<void> _destroyEngine() async {
    if (_engine != null) {
      await _engine!.leaveChannel();
      await _engine!.release();
    }
  }

  Future<void> _loadComments() async {
    final comments = await _liveStreamService.getComments(widget.liveStream.id);
    if (mounted) {
      setState(() {
        _comments = comments;
      });
    }
  }

  void _startCommentPolling() {
    _commentPollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _loadComments();
    });
  }

  Future<void> _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      await _liveStreamService.addComment(
        streamId: widget.liveStream.id,
        userId: 'current_user_id',
        userName: '現在のユーザー名',
        userProfileImage: 'https://i.pravatar.cc/150?img=20',
        message: _commentController.text.trim(),
      );

      _commentController.clear();
      _loadComments();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to send comment: $e');
      }
    }
  }

  Future<void> _sendLike() async {
    try {
      await _liveStreamService.incrementLikeCount(widget.liveStream.id);
      
      // アニメーションを表示
      _showLikeAnimation();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to send like: $e');
      }
    }
  }

  void _showLikeAnimation() {
    // いいねアニメーションを表示
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        right: 20,
        bottom: 200,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, -100 * value),
              child: Opacity(
                opacity: 1.0 - value,
                child: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            );
          },
          onEnd: () {
            overlayEntry.remove();
          },
        ),
      ),
    );
    overlay.insert(overlayEntry);
  }

  void _showGiftDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'ギフトを送る',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: _gifts.length,
              itemBuilder: (context, index) {
                final gift = _gifts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    _sendGift(gift);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        gift.iconUrl,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        gift.name,
                        style: const TextStyle(fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '¥${gift.amount}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _sendGift(LiveGift gift) async {
    try {
      await _liveStreamService.addGiftAmount(widget.liveStream.id, gift.amount);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${gift.name} (¥${gift.amount}) を送りました'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // ギフトアニメーションを表示
      _showGiftAnimation(gift);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to send gift: $e');
      }
    }
  }

  void _showGiftAnimation(LiveGift gift) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 20,
        bottom: 200,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1200),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, -150 * value),
              child: Transform.scale(
                scale: 1.0 + (value * 0.5),
                child: Opacity(
                  opacity: 1.0 - value,
                  child: Text(
                    gift.iconUrl,
                    style: const TextStyle(fontSize: 60),
                  ),
                ),
              ),
            );
          },
          onEnd: () {
            overlayEntry.remove();
          },
        ),
      ),
    );
    overlay.insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // リモートビデオ表示
          if (_isJoined && _remoteUid != 0)
            SizedBox.expand(
              child: AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: _engine!,
                  canvas: VideoCanvas(uid: _remoteUid),
                  connection: RtcConnection(channelId: widget.liveStream.channelName),
                ),
              ),
            )
          else
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(widget.liveStream.staffProfileImage),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.liveStream.staffName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ],
                ),
              ),
            ),

          // オーバーレイUI
          SafeArea(
            child: Column(
              children: [
                // ヘッダー
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(widget.liveStream.staffProfileImage),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.liveStream.staffName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.liveStream.title,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 視聴者数
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.remove_red_eye,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.liveStream.viewerCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // コメント一覧
                if (_comments.isNotEmpty)
                  Container(
                    height: 200,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.builder(
                      reverse: true,
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final comment = _comments[_comments.length - 1 - index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundImage: NetworkImage(comment.userProfileImage),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comment.userName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      comment.message,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 8),

                // 下部コントロール
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // コメント入力
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'コメントを入力...',
                            hintStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.black45,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onSubmitted: (_) => _sendComment(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 送信ボタン
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendComment,
                        padding: const EdgeInsets.all(12),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // いいねボタン
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.white),
                        onPressed: _sendLike,
                        padding: const EdgeInsets.all(12),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // ギフトボタン
                      IconButton(
                        icon: const Icon(Icons.card_giftcard, color: Colors.white),
                        onPressed: _showGiftDialog,
                        padding: const EdgeInsets.all(12),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.purple,
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
}
