import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/staff.dart';
import '../models/gift_item.dart';
import '../models/tip_history.dart';
import '../models/gifter_level.dart';
import '../services/tip_service.dart';
import '../services/gifter_service.dart';

class TikTokGiftScreen extends StatefulWidget {
  final Staff staff;

  const TikTokGiftScreen({super.key, required this.staff});

  @override
  State<TikTokGiftScreen> createState() => _TikTokGiftScreenState();
}

class _TikTokGiftScreenState extends State<TikTokGiftScreen> with SingleTickerProviderStateMixin {
  final TipService _tipService = TipService();
  late TabController _tabController;
  final List<String> _categories = GiftItem.getCategories();
  final List<GiftItem> _allGifts = GiftItem.getAllGifts();
  GiftItem? _selectedGift;
  int _quantity = 1;
  int _balance = 50000; // デモ用の残高
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<GiftItem> _getFilteredGifts(String category) {
    if (category == 'すべて') {
      return _allGifts;
    }
    return _allGifts.where((gift) => gift.category == category).toList();
  }

  void _showQRCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.qr_code,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('QRコードでチャージ'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: const Center(
                child: Icon(
                  Icons.qr_code_2,
                  size: 200,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'QRコードをスキャンして\nコインをチャージ',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _balance += 10000; // デモ: 10000コイン追加
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('10,000コインをチャージしました！')),
              );
            },
            child: const Text('チャージ'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendGift() async {
    if (_selectedGift == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ギフトを選択してください')),
      );
      return;
    }

    final totalPrice = _selectedGift!.price * _quantity;
    
    if (totalPrice > _balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('残高が不足しています。チャージしてください。')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    // チップ履歴に記録
    final tip = TipHistory(
      id: DateTime.now().toString(),
      staffId: widget.staff.id,
      staffName: widget.staff.name,
      staffImage: widget.staff.profileImage,
      amount: totalPrice.toDouble(),
      timestamp: DateTime.now(),
      message: '${_selectedGift!.emoji} ${_selectedGift!.name} x$_quantity',
    );

    await _tipService.sendTip(tip);
    
    // ギフター情報を更新（EXPを追加）
    final oldInfo = GifterService.getGifterInfo();
    final oldExp = oldInfo.totalExp;
    final newInfo = GifterService.addGiftExp(widget.staff.id, totalPrice);
    
    // レベルアップチェック
    final didLevelUp = GifterService.checkLevelUp(oldExp, newInfo.totalExp);

    setState(() {
      _balance -= totalPrice;
      _isSending = false;
    });

    if (mounted) {
      // アニメーション効果を表示
      _showGiftAnimation();
      
      // 送信完了通知
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${_selectedGift!.emoji} ${_selectedGift!.name} x$_quantity を送りました！'),
              if (didLevelUp)
                Text(
                  '🎉 レベルアップ！ レベル${newInfo.currentLevel.level} (${newInfo.currentLevel.title})',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow),
                ),
              Text(
                '+$totalPrice EXP獲得！',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );

      // 少し待ってから画面を閉じる
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _showGiftAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedGift!.emoji,
                          style: const TextStyle(fontSize: 100),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${_selectedGift!.name} x$_quantity',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            onEnd: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: widget.staff.profileImage,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.staff.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.staff.jobTitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // QRコードボタン（右上）
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, size: 28),
            onPressed: _showQRCodeDialog,
            tooltip: 'QRコードでチャージ',
          ),
        ],
      ),
      body: Column(
        children: [
          // 残高表示
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, color: Colors.amber, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '残高: $_balance コイン',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _showQRCodeDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('チャージ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),

          // カテゴリータブ
          Container(
            color: Colors.black,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.amber,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: _categories.map((category) => Tab(text: category)).toList(),
            ),
          ),

          // ギフトグリッド
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                final gifts = _getFilteredGifts(category);
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: gifts.length,
                  itemBuilder: (context, index) {
                    final gift = gifts[index];
                    final isSelected = _selectedGift?.id == gift.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGift = gift;
                          _quantity = 1;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.amber.withValues(alpha: 0.3) : Colors.grey[850],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.amber : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              gift.emoji,
                              style: const TextStyle(fontSize: 40),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              gift.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.monetization_on,
                                  color: Colors.amber,
                                  size: 14,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${gift.price}',
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontSize: 12,
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
                );
              }).toList(),
            ),
          ),

          // 送信パネル
          if (_selectedGift != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // 選択中のギフト表示
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _selectedGift!.emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedGift!.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.monetization_on,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_selectedGift!.price} × $_quantity = ${_selectedGift!.price * _quantity}',
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // 数量調整
                        Row(
                          children: [
                            IconButton(
                              onPressed: _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                              color: Colors.white,
                            ),
                            Text(
                              '$_quantity',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: _quantity < 99
                                  ? () => setState(() => _quantity++)
                                  : null,
                              icon: const Icon(Icons.add_circle_outline),
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 送信ボタン
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSending ? null : _sendGift,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSending
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                ),
                              )
                            : const Text(
                                '送信',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
