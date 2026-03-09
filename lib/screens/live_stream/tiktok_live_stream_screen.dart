import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/live_stream.dart';
import '../../models/fan_club_membership.dart';
import '../../services/fan_club_service.dart';
import '../../services/live_revenue_service.dart';
import 'package:flutter/foundation.dart';

class TikTokLiveStreamScreen extends StatefulWidget {
  final LiveStream liveStream;
  final String currentUserId;
  
  const TikTokLiveStreamScreen({
    super.key,
    required this.liveStream,
    required this.currentUserId,
  });
  
  @override
  State<TikTokLiveStreamScreen> createState() => _TikTokLiveStreamScreenState();
}

class _TikTokLiveStreamScreenState extends State<TikTokLiveStreamScreen> with TickerProviderStateMixin {
  final FanClubService _fanClubService = FanClubService();
  final LiveRevenueService _revenueService = LiveRevenueService();
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _commentScrollController = ScrollController();
  
  List<LiveComment> _comments = [];
  List<AnimatedGift> _animatedGifts = [];
  FanClubMembership? _membership;
  bool _showGiftPanel = false;
  int _heartCount = 0;
  
  late AnimationController _heartAnimationController;
  Timer? _heartTimer;
  Timer? _viewerUpdateTimer;
  
  @override
  void initState() {
    super.initState();
    _loadMembership();
    _startHeartAnimation();
    _startViewerUpdate();
    _loadSampleComments();
  }
  
  @override
  void dispose() {
    _heartAnimationController.dispose();
    _heartTimer?.cancel();
    _viewerUpdateTimer?.cancel();
    _commentController.dispose();
    _commentScrollController.dispose();
    super.dispose();
  }
  
  void _loadMembership() async {
    final membership = await _fanClubService.getMembership(
      widget.currentUserId,
      widget.liveStream.staffId,
    );
    setState(() {
      _membership = membership;
    });
  }
  
  void _startHeartAnimation() {
    _heartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }
  
  void _startViewerUpdate() {
    _viewerUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        // ランダムに視聴者数を変動
        final change = (DateTime.now().millisecond % 10) - 5;
        widget.liveStream.viewerCount = (widget.liveStream.viewerCount + change).clamp(0, 100000);
      });
    });
  }
  
  void _loadSampleComments() {
    // サンプルコメント
    _comments = [
      LiveComment(
        id: 'c1',
        userId: 'user1',
        userName: '太郎',
        userProfileImage: 'https://picsum.photos/100/100?1',
        message: 'こんにちは！',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      LiveComment(
        id: 'c2',
        userId: 'user2',
        userName: '花子',
        userProfileImage: 'https://picsum.photos/100/100?2',
        message: '素敵なライブですね✨',
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    ];
  }
  
  void _sendHeart() {
    setState(() {
      _heartCount++;
      widget.liveStream.likeCount++;
    });
    
    _heartAnimationController.forward(from: 0.0);
    
    // ハートアニメーション
    _showFloatingHeart();
  }
  
  void _showFloatingHeart() {
    // 画面上にハートを表示するアニメーション
    if (kDebugMode) {
      debugPrint('❤️ Heart sent!');
    }
  }
  
  void _sendComment() {
    if (_commentController.text.trim().isEmpty) return;
    
    final comment = LiveComment(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      userId: widget.currentUserId,
      userName: 'あなた',
      userProfileImage: 'https://picsum.photos/100/100',
      message: _commentController.text,
      timestamp: DateTime.now(),
    );
    
    setState(() {
      _comments.add(comment);
      _commentController.clear();
    });
    
    // スクロール
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_commentScrollController.hasClients) {
        _commentScrollController.animateTo(
          _commentScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  void _sendGift(LiveGift gift) async {
    // ギフトアニメーション
    _showGiftAnimation(gift);
    
    // ファンクラブギフトを追加
    final updatedMembership = await _fanClubService.addGift(
      userId: widget.currentUserId,
      staffId: widget.liveStream.staffId,
      giftValue: gift.amount,
      hearts: 1,
    );
    
    setState(() {
      _membership = updatedMembership;
      widget.liveStream.giftAmount += gift.amount;
    });
    
    // 収益を記録
    await _revenueService.recordGiftRevenue(
      staffId: widget.liveStream.staffId,
      giftAmount: gift.amount,
      timestamp: DateTime.now(),
    );
    
    // ファンクラブ入会通知
    if (_membership == null || _membership!.memberLevel == 1) {
      _showFanClubJoinDialog(updatedMembership);
    } else if (updatedMembership.memberLevel > (_membership?.memberLevel ?? 0)) {
      _showLevelUpDialog(updatedMembership);
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${gift.name}を送りました！ (${gift.amount}円)'),
          backgroundColor: Colors.pink,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  
  void _showGiftAnimation(LiveGift gift) {
    final animatedGift = AnimatedGift(
      gift: gift,
      startTime: DateTime.now(),
    );
    
    setState(() {
      _animatedGifts.add(animatedGift);
    });
    
    // 3秒後に削除
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _animatedGifts.remove(animatedGift);
        });
      }
    });
  }
  
  void _showFanClubJoinDialog(FanClubMembership membership) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('ファンクラブ入会！'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.liveStream.staffName}のファンクラブに入会しました！',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple[100]!, Colors.pink[100]!],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        membership.getBadgeEmoji(),
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'レベル ${membership.memberLevel}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '累計ギフト: ¥${membership.totalGiftValue}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
  
  void _showLevelUpDialog(FanClubMembership membership) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('レベルアップ！'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'おめでとうございます！',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple[100]!, Colors.pink[100]!],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    membership.getBadgeEmoji(),
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'レベル ${membership.memberLevel}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '累計ギフト: ¥${membership.totalGiftValue}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '新しい特典が解除されました！',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 背景動画エリア（実際にはAgora等の映像）
          _buildVideoBackground(),
          
          // グラデーションオーバーレイ
          _buildGradientOverlay(),
          
          // トップバー
          _buildTopBar(),
          
          // コメント一覧
          _buildCommentList(),
          
          // ギフトアニメーション
          _buildGiftAnimations(),
          
          // 右側のアクションボタン
          _buildRightActions(),
          
          // ボトムバー（コメント入力）
          _buildBottomBar(),
          
          // ギフトパネル
          if (_showGiftPanel) _buildGiftPanel(),
        ],
      ),
    );
  }
  
  Widget _buildVideoBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.purple.withValues(alpha: 0.3),
            Colors.pink.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.videocam,
          size: 100,
          color: Colors.white30,
        ),
      ),
    );
  }
  
  Widget _buildGradientOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 200,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.6),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // 戻るボタン
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const SizedBox(width: 8),
            
            // スタッフ情報
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(widget.liveStream.staffProfileImage),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.liveStream.staffName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_membership != null)
                            Text(
                              'Lv.${_membership!.memberLevel} ファン',
                              style: TextStyle(
                                color: Colors.amber[300],
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.remove_red_eye, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '${_formatNumber(widget.liveStream.viewerCount)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            
            // シェアボタン
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  // シェア機能
                },
                icon: const Icon(Icons.share, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCommentList() {
    return Positioned(
      left: 16,
      right: 100,
      bottom: 100,
      height: 300,
      child: ListView.builder(
        controller: _commentScrollController,
        itemCount: _comments.length,
        itemBuilder: (context, index) {
          final comment = _comments[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${comment.userName}: ',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    TextSpan(
                      text: comment.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildGiftAnimations() {
    return Stack(
      children: _animatedGifts.map((animatedGift) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(seconds: 3),
          builder: (context, value, child) {
            return Positioned(
              right: 20 + (value * 50),
              bottom: 150 + (value * 300),
              child: Opacity(
                opacity: 1.0 - value,
                child: Transform.scale(
                  scale: 0.5 + (value * 0.5),
                  child: Text(
                    animatedGift.gift.iconUrl,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
  
  Widget _buildRightActions() {
    return Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        children: [
          // ハートボタン
          _buildActionButton(
            icon: Icons.favorite,
            label: _formatNumber(_heartCount),
            color: Colors.red,
            onTap: _sendHeart,
          ),
          const SizedBox(height: 20),
          
          // ギフトボタン
          _buildActionButton(
            icon: Icons.card_giftcard,
            label: '${_formatNumber(widget.liveStream.giftAmount)}円',
            color: Colors.amber,
            onTap: () {
              setState(() {
                _showGiftPanel = !_showGiftPanel;
              });
            },
          ),
          const SizedBox(height: 20),
          
          // コメント数
          _buildActionButton(
            icon: Icons.chat_bubble,
            label: '${_comments.length}',
            color: Colors.white,
            onTap: () {},
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
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
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'コメントを入力...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.5),
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
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink[400]!, Colors.purple[400]!],
                  ),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _sendComment,
                  icon: const Icon(Icons.send, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildGiftPanel() {
    final gifts = LiveGift.getSampleGifts();
    
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // ハンドル
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // タイトル
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ギフトを選択',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // ギフト一覧
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: gifts.length,
                itemBuilder: (context, index) {
                  final gift = gifts[index];
                  return GestureDetector(
                    onTap: () {
                      _sendGift(gift);
                      setState(() {
                        _showGiftPanel = false;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.purple[400]!, Colors.pink[400]!],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              gift.iconUrl,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          gift.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '¥${gift.amount}',
                          style: TextStyle(
                            color: Colors.amber[300],
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatNumber(int number) {
    if (number >= 10000) {
      return '${(number / 10000).toStringAsFixed(1)}万';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class AnimatedGift {
  final LiveGift gift;
  final DateTime startTime;
  
  AnimatedGift({
    required this.gift,
    required this.startTime,
  });
}
