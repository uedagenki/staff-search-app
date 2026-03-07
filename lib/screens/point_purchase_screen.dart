import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/payment_models.dart';
import '../services/payment_service.dart';
import '../services/local_auth_service.dart';

/// コイン購入画面（TikTok形式）
class PointPurchaseScreen extends StatefulWidget {
  final UserPointBalance? currentBalance;
  
  const PointPurchaseScreen({super.key, this.currentBalance});

  @override
  State<PointPurchaseScreen> createState() => _PointPurchaseScreenState();
}

class _PointPurchaseScreenState extends State<PointPurchaseScreen> {
  final _paymentService = PaymentService();
  final _authService = LocalAuthService();

  UserPointBalance? _balance;
  List<PointPackage> _packages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        // currentBalanceが渡されていればそれを使用、なければ取得
        final balance = widget.currentBalance ?? await _paymentService.getUserPointBalance(user.id);
        final packages = _paymentService.getPointPackages();

        setState(() {
          _balance = balance;
          _packages = packages;
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _purchasePoints(PointPackage package) async {
    // デモ用：実際のStripe決済をシミュレート
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('コイン購入'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${package.name}を購入しますか？'),
            const SizedBox(height: 16),
            Text(
              '金額: ¥${NumberFormat('#,###').format(package.price)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text('コイン: ${NumberFormat('#,###').format(package.totalPoints)}'),
            const SizedBox(height: 8),
            Text(
              '💰 ${package.platform == 'web' ? 'Web版（お得な価格）' : 'アプリ版価格'}',
              style: TextStyle(
                color: package.platform == 'web' ? Colors.green : Colors.orange,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('購入'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _processPurchase(package);
    }
  }

  Future<void> _processPurchase(PointPackage package) async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;

      // ポイント追加
      await _paymentService.addPoints(
        user.id,
        package.totalPoints,
        isPurchased: true,
      );

      // 決済履歴を追加
      final payment = PaymentHistory(
        id: 'payment_${DateTime.now().millisecondsSinceEpoch}',
        userId: user.id,
        type: 'point_purchase',
        amount: package.price,
        points: package.totalPoints,
        status: 'completed',
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );
      await _paymentService.addPaymentHistory(payment);

      // データ再読み込み
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${NumberFormat('#,###').format(package.totalPoints)}コインを購入しました',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('購入に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 コイン購入'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildBalanceCard(),
                  const SizedBox(height: 24),
                  _buildPackageList(),
                  const SizedBox(height: 16),
                  _buildInfoSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildBalanceCard() {
    if (_balance == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.purple.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '現在の残高',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.card_giftcard,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                NumberFormat('#,###').format(_balance!.availablePoints),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                ' コイン',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBalanceDetail(
                '購入',
                _balance!.purchasedPoints,
                Icons.shopping_cart,
              ),
              _buildBalanceDetail(
                'ボーナス',
                _balance!.bonusPoints,
                Icons.stars,
              ),
              _buildBalanceDetail(
                '使用済み',
                _balance!.usedPoints,
                Icons.check_circle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceDetail(String label, int value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        Text(
          NumberFormat('#,###').format(value),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPackageList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💰 コインパッケージ（Web版 - お得）',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _packages.length,
            itemBuilder: (context, index) {
              return _buildPackageCard(_packages[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(PointPackage package) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: package.isPopular ? 6 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: package.isPopular
            ? const BorderSide(color: Colors.purple, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _purchasePoints(package),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // アイコン
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: package.isPopular
                        ? [Colors.purple.shade300, Colors.purple.shade500]
                        : [Colors.grey.shade300, Colors.grey.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),

              // 詳細
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          package.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (package.isPopular) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '人気',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${NumberFormat('#,###').format(package.totalPoints)}コイン',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // 価格
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '¥${NumberFormat('#,###').format(package.price)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  Text(
                    '${package.pricePerCoin.toStringAsFixed(2)}円/コイン',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'コインについて',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem('💰 Web版価格で最大約20%お得に購入できます'),
          _buildInfoItem('1コイン = 約1.8円〜で投げ銭に使用できます'),
          _buildInfoItem('ボーナスコインは広告視聴やチェックインで獲得'),
          _buildInfoItem('コインに有効期限はありません'),
          _buildInfoItem('払い戻しはできません'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
