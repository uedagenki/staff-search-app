import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/live_stream.dart';
import '../services/live_stream_service.dart';
import '../services/point_service.dart';
import '../services/auth_service.dart';
import 'point_purchase_screen.dart';

class GiftSendingWidget extends StatefulWidget {
  final String recipientId;
  final String recipientName;
  final String? liveStreamId;
  final VoidCallback? onGiftSent;

  const GiftSendingWidget({
    super.key,
    required this.recipientId,
    required this.recipientName,
    this.liveStreamId,
    this.onGiftSent,
  });

  @override
  State<GiftSendingWidget> createState() => _GiftSendingWidgetState();
}

class _GiftSendingWidgetState extends State<GiftSendingWidget> {
  final _pointService = PointService();
  final _authService = AuthService();
  final _liveStreamService = LiveStreamService();

  int _currentPoints = 0;
  bool _isLoading = true;
  bool _isSending = false;

  final List<LiveGift> _gifts = LiveGift.getSampleGifts();

  @override
  void initState() {
    super.initState();
    _loadUserPoints();
  }

  Future<void> _loadUserPoints() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      final points = await _pointService.getUserPoints(user.id);
      setState(() {
        _currentPoints = points;
        _isLoading = false;
      });
    }
  }

  Future<void> _sendGift(LiveGift gift) async {
    if (_isSending) return;

    final user = await _authService.getCurrentUser();
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ログインが必要です'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // ポイント不足チェック
    if (_currentPoints < gift.amount) {
      if (mounted) {
        final shouldPurchase = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('ポイント不足'),
            content: Text('ポイントが不足しています。\n必要: ${gift.amount}P\n現在: ${_currentPoints}P'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('キャンセル'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('ポイント購入'),
              ),
            ],
          ),
        );

        if (shouldPurchase == true && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PointPurchaseScreen()),
          );
        }
      }
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      // ポイント消費
      final success = await _pointService.consumePoints(
        userId: user.id,
        amount: gift.amount,
        recipientId: widget.recipientId,
        recipientName: widget.recipientName,
        description: '${gift.name}を送信',
      );

      if (success) {
        // ライブ配信中の場合は配信にもギフト情報を追加
        if (widget.liveStreamId != null) {
          await _liveStreamService.addGiftAmount(widget.liveStreamId!, gift.amount);
        }

        await _loadUserPoints();

        if (mounted) {
          Navigator.pop(context);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${gift.name} (${gift.amount}P) を送りました!'),
              backgroundColor: Colors.green,
            ),
          );

          widget.onGiftSent?.call();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ギフトの送信に失敗しました'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to send gift: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('エラーが発生しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(48.0),
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
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

                // ヘッダー
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ギフトを送る',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.recipientName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.stars, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '$_currentPoints P',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PointPurchaseScreen(),
                                ),
                              ).then((_) => _loadUserPoints());
                            },
                            child: const Text('チャージ'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ギフト一覧
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
                    final canAfford = _currentPoints >= gift.amount;

                    return GestureDetector(
                      onTap: _isSending || !canAfford
                          ? null
                          : () => _sendGift(gift),
                      child: Opacity(
                        opacity: canAfford ? 1.0 : 0.5,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.stars,
                                  size: 10,
                                  color: canAfford ? Colors.amber : Colors.grey,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${gift.amount}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: canAfford ? Colors.grey[700] : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                if (_isSending)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
    );
  }

  static void show(
    BuildContext context, {
    required String recipientId,
    required String recipientName,
    String? liveStreamId,
    VoidCallback? onGiftSent,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GiftSendingWidget(
        recipientId: recipientId,
        recipientName: recipientName,
        liveStreamId: liveStreamId,
        onGiftSent: onGiftSent,
      ),
    );
  }
}
