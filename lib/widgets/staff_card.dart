import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/staff.dart';
import '../screens/staff_detail_screen.dart';
import '../screens/tiktok_gift_screen.dart';
import '../screens/create_message_screen.dart';
import '../screens/live_feed_screen.dart';
import '../services/follow_service.dart';

class StaffCard extends StatefulWidget {
  final Staff staff;

  const StaffCard({super.key, required this.staff});

  @override
  State<StaffCard> createState() => _StaffCardState();
}

class _StaffCardState extends State<StaffCard> {
  final FollowService _followService = FollowService();
  final PageController _imagePageController = PageController();
  bool _isFollowing = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadFollowStatus();
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  Future<void> _loadFollowStatus() async {
    final isFollowing = await _followService.isFollowing(widget.staff.id);
    if (mounted) {
      setState(() {
        _isFollowing = isFollowing;
      });
    }
  }

  Future<void> _toggleFollow() async {
    final newStatus = await _followService.toggleFollow(widget.staff.id);
    if (mounted) {
      setState(() {
        _isFollowing = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus ? 'フォローしました' : 'フォロー解除しました',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _nextImage() {
    if (_currentImageIndex < widget.staff.profileImages.length - 1) {
      _imagePageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousImage() {
    if (_currentImageIndex > 0) {
      _imagePageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // ライブ配信中の場合はTikTok風ライブフィード画面へ、それ以外は詳細画面へ
        if (widget.staff.isLive) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LiveFeedScreen(),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StaffDetailScreen(staff: widget.staff),
            ),
          );
        }
      },
      child: Stack(
        children: [
          // 画像スライダー
          PageView.builder(
            controller: _imagePageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: widget.staff.profileImages.length,
            itemBuilder: (context, index) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      widget.staff.profileImages[index],
                    ),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: 0.3),
                      BlendMode.darken,
                    ),
                  ),
                ),
              );
            },
          ),

          // タップエリア（左右で画像切り替え）
          if (widget.staff.profileImages.length > 1)
            Positioned.fill(
              child: Row(
                children: [
                  // 左側タップで前の画像
                  Expanded(
                    child: GestureDetector(
                      onTap: _previousImage,
                      behavior: HitTestBehavior.opaque,
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  // 右側タップで次の画像
                  Expanded(
                    child: GestureDetector(
                      onTap: _nextImage,
                      behavior: HitTestBehavior.opaque,
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                ],
              ),
            ),

          // Live中バッジ（左上）
          if (widget.staff.isLive)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF0050), Color(0xFFFF4040)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 脈動する赤い点
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1000),
                      builder: (context, double value, child) {
                        return Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.8),
                                blurRadius: value * 4,
                                spreadRadius: value * 2,
                              ),
                            ],
                          ),
                        );
                      },
                      onEnd: () {
                        if (mounted) {
                          setState(() {});
                        }
                      },
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 画像インジケーター
          if (widget.staff.profileImages.length > 1)
            Positioned(
              top: widget.staff.isLive ? 56 : 16, // Liveバッジがある場合は下にずらす
              left: 16,
              right: 16,
              child: Row(
                children: List.generate(
                  widget.staff.profileImages.length,
                  (index) => Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: _currentImageIndex == index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // グラデーションオーバーレイ
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // スタッフ情報（左下）
          Positioned(
              bottom: 160,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 名前
                  Text(
                    widget.staff.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // 職種
                  Text(
                    widget.staff.jobTitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      shadows: const [
                        Shadow(
                          blurRadius: 8.0,
                          color: Colors.black,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // カテゴリーバッジ
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.staff.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // 評価
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: widget.staff.rating,
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 20.0,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.staff.rating} (${widget.staff.reviewCount}件)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          shadows: [
                            Shadow(
                              blurRadius: 8.0,
                              color: Colors.black,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // 料金情報
                  if (widget.staff.pricing != null && widget.staff.pricing!.isNotEmpty) ...[
                    _buildPricingInfo(),
                    const SizedBox(height: 12),
                  ],
                  
                  // クーポン情報
                  if (widget.staff.coupons != null && widget.staff.coupons!.isNotEmpty) ...[
                    _buildCouponInfo(),
                    const SizedBox(height: 12),
                  ],
                  
                  // 場所とオンラインステータス
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.staff.location,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          shadows: [
                            Shadow(
                              blurRadius: 8.0,
                              color: Colors.black,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      if (widget.staff.distance != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '(${widget.staff.distance!.toStringAsFixed(1)}km)',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            shadows: [
                              Shadow(
                                blurRadius: 8.0,
                                color: Colors.black,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(width: 16),
                      if (widget.staff.isOnline) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '出勤中',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      if (widget.staff.isLive) ...[
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.circle,
                                color: Colors.white,
                                size: 8,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // フォロワー数と店舗名
                  Row(
                    children: [
                      const Icon(
                        Icons.people,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.staff.followersCount}人',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              blurRadius: 8.0,
                              color: Colors.black,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      if (widget.staff.storeName != null) ...[
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.store,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            widget.staff.storeName!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              shadows: [
                                Shadow(
                                  blurRadius: 8.0,
                                  color: Colors.black,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // アクションボタン（下部中央）
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // フォローボタン（大きめ）
                    Expanded(
                      flex: 2,
                      child: _buildHorizontalButton(
                        icon: _isFollowing ? Icons.person_remove : Icons.person_add,
                        label: _isFollowing ? 'フォロー中' : 'フォローする',
                        color: _isFollowing 
                          ? Colors.grey[700]! 
                          : Theme.of(context).colorScheme.primary,
                        onTap: _toggleFollow,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ギフトボタン
                    Expanded(
                      child: _buildHorizontalButton(
                        icon: Icons.card_giftcard,
                        label: 'ギフト',
                        color: Colors.amber[700]!,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TikTokGiftScreen(staff: widget.staff),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // メッセージボタン
                    Expanded(
                      child: _buildHorizontalButton(
                        icon: Icons.chat_bubble,
                        label: 'DM',
                        color: Colors.blue[600]!,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateMessageScreen(staff: widget.staff),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 詳細ボタン
                    Expanded(
                      child: _buildHorizontalButton(
                        icon: Icons.info_outline,
                        label: '詳細',
                        color: Colors.grey[700]!,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StaffDetailScreen(staff: widget.staff),
                            ),
                          );
                        },
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

  Widget _buildHorizontalButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 料金情報表示
  Widget _buildPricingInfo() {
    if (widget.staff.pricing == null || widget.staff.pricing!.isEmpty) {
      return const SizedBox.shrink();
    }

    final pricing = widget.staff.pricing!;
    final pricingType = pricing['type'] ?? 'hourly';

    if (pricingType == 'hourly') {
      final hourlyRate = pricing['hourlyRate'] ?? 0;
      if (hourlyRate > 0) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                '¥${hourlyRate.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} / 時間',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }
    } else if (pricingType == 'menu') {
      final menuItems = pricing['menuItems'] as List?;
      if (menuItems != null && menuItems.isNotEmpty) {
        final firstMenu = menuItems.first;
        final price = firstMenu['price'] ?? 0;
        final menuName = firstMenu['name'] ?? 'メニュー';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.restaurant_menu, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                '$menuName ¥${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}〜',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }

  // クーポン情報表示
  Widget _buildCouponInfo() {
    if (widget.staff.coupons == null || widget.staff.coupons!.isEmpty) {
      return const SizedBox.shrink();
    }

    // 有効なクーポンのみをフィルター
    final activeCoupons = widget.staff.coupons!.where((coupon) {
      final isActive = coupon['isActive'] ?? true;
      final expiryDate = coupon['expiryDate'];
      final isExpired = expiryDate != null && DateTime.parse(expiryDate).isBefore(DateTime.now());
      return isActive && !isExpired;
    }).toList();

    if (activeCoupons.isEmpty) {
      return const SizedBox.shrink();
    }

    // 最もお得なクーポンを1つ表示
    final bestCoupon = activeCoupons.first;
    final discountType = bestCoupon['discountType'] ?? 'percentage';
    final discountValue = bestCoupon['discountValue'] ?? 0;
    
    String discountText;
    if (discountType == 'percentage') {
      discountText = '$discountValue%OFF';
    } else {
      discountText = '¥${discountValue}OFF';
    }

    return GestureDetector(
      onTap: () {
        // クーポン一覧ダイアログを表示
        _showCouponsDialog();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_offer, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              discountText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (activeCoupons.length > 1) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+${activeCoupons.length - 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // クーポン一覧ダイアログ
  void _showCouponsDialog() {
    final activeCoupons = widget.staff.coupons!.where((coupon) {
      final isActive = coupon['isActive'] ?? true;
      final expiryDate = coupon['expiryDate'];
      final isExpired = expiryDate != null && DateTime.parse(expiryDate).isBefore(DateTime.now());
      return isActive && !isExpired;
    }).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.local_offer, color: Colors.orange),
            const SizedBox(width: 8),
            Text('${widget.staff.name}のクーポン'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: activeCoupons.length,
            itemBuilder: (context, index) {
              final coupon = activeCoupons[index];
              final discountType = coupon['discountType'] ?? 'percentage';
              final discountValue = coupon['discountValue'] ?? 0;
              final title = coupon['title'] ?? '無題のクーポン';
              final description = coupon['description'] ?? '';
              final minPurchase = coupon['minPurchase'] ?? 0;
              final expiryDate = coupon['expiryDate'];
              
              String discountText;
              if (discountType == 'percentage') {
                discountText = '$discountValue%OFF';
              } else {
                discountText = '¥${discountValue}OFF';
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              discountText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      if (minPurchase > 0) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '最低利用金額: ¥$minPurchase',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                      if (expiryDate != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.event, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '有効期限: ${_formatCouponDate(expiryDate)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
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

  String _formatCouponDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}/${date.month}/${date.day}';
    } catch (e) {
      return dateStr;
    }
  }
}
