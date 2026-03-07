import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/payment_models.dart';
import '../services/payment_service.dart';
import '../services/local_auth_service.dart';

/// ポイント獲得画面（広告視聴・チェックイン）
class PointEarnScreen extends StatefulWidget {
  const PointEarnScreen({super.key});

  @override
  State<PointEarnScreen> createState() => _PointEarnScreenState();
}

class _PointEarnScreenState extends State<PointEarnScreen> {
  final _paymentService = PaymentService();
  final _authService = LocalAuthService();

  UserPointBalance? _balance;
  CheckInRecord? _todayCheckIn;
  int _todayAdCount = 0;
  int _consecutiveDays = 0;
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
        final balance = await _paymentService.getUserPointBalance(user.id);
        final todayCheckIn = await _paymentService.getTodayCheckIn(user.id);
        final adCount = await _paymentService.getTodayAdViewCount(user.id);
        
        // 連続チェックイン日数を取得
        int consecutive = 0;
        if (todayCheckIn != null) {
          consecutive = todayCheckIn.consecutiveDays;
        } else {
          final records = await _paymentService.getCheckInRecords(user.id);
          if (records.isNotEmpty) {
            consecutive = records.last.consecutiveDays;
          }
        }

        setState(() {
          _balance = balance;
          _todayCheckIn = todayCheckIn;
          _todayAdCount = adCount;
          _consecutiveDays = consecutive;
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCheckIn() async {
    if (_todayCheckIn != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('今日は既にチェックイン済みです'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        final checkIn = await _paymentService.checkIn(user.id);

        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.celebration, color: Colors.orange, size: 32),
                  SizedBox(width: 8),
                  Text('チェックイン完了！'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+${checkIn.rewardPoints}ポイント',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${checkIn.consecutiveDays}日連続チェックイン',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (checkIn.consecutiveDays < 7)
                    Text(
                      'あと${7 - checkIn.consecutiveDays}日でボーナス獲得！',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
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

          await _loadData();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('チェックインに失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _watchAd() async {
    const maxAdsPerDay = 10;
    if (_todayAdCount >= maxAdsPerDay) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('本日の広告視聴上限に達しました'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // デモ用：広告視聴をシミュレート
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('広告を視聴中...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('15秒お待ちください'),
            const SizedBox(height: 8),
            Text(
              '完了後、50ポイント獲得',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );

    // 15秒待機（デモ用は3秒に短縮）
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      Navigator.pop(context);
    }

    // ポイント付与
    setState(() => _isLoading = true);

    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        final adView = await _paymentService.completeAdView(
          user.id,
          'demo_ad_${DateTime.now().millisecondsSinceEpoch}',
        );

        if (adView != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('+${adView.rewardPoints}ポイント獲得しました'),
              backgroundColor: Colors.green,
            ),
          );

          await _loadData();
        }
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ポイント獲得'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildBalanceCard(),
                  const SizedBox(height: 16),
                  _buildCheckInSection(),
                  const SizedBox(height: 16),
                  _buildAdSection(),
                  const SizedBox(height: 16),
                  _buildTipsSection(),
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
          colors: [Colors.green.shade400, Colors.green.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ボーナスポイント',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.stars,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    NumberFormat('#,###').format(_balance!.bonusPoints),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    ' pt',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Icon(
            Icons.card_giftcard,
            color: Colors.white38,
            size: 64,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: Colors.orange.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '毎日チェックイン',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '7日連続で100ポイント獲得！',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // チェックイン進捗
            _buildCheckInProgress(),

            const SizedBox(height: 16),

            // チェックインボタン
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _todayCheckIn == null ? _handleCheckIn : null,
                icon: Icon(
                  _todayCheckIn == null ? Icons.check_circle : Icons.check_circle_outline,
                ),
                label: Text(
                  _todayCheckIn == null ? 'チェックイン' : '本日チェックイン済み',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _todayCheckIn == null ? Colors.orange : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInProgress() {
    final days = List.generate(7, (i) => i + 1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        final isCompleted = _consecutiveDays >= day;
        final isToday = _todayCheckIn != null && _consecutiveDays == day;

        return Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.orange : Colors.grey.shade200,
                shape: BoxShape.circle,
                border: isToday
                    ? Border.all(color: Colors.orange, width: 3)
                    : null,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Text(
                        '$day',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              day == 7 ? '100pt' : '${10 * day}pt',
              style: TextStyle(
                fontSize: 10,
                color: isCompleted ? Colors.orange : Colors.grey,
                fontWeight: day == 7 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildAdSection() {
    const maxAdsPerDay = 10;
    final remaining = maxAdsPerDay - _todayAdCount;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.play_circle,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '広告を見てポイント獲得',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '1広告15秒で50ポイント',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 進捗バー
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: _todayAdCount / maxAdsPerDay,
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.blue,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$_todayAdCount/$maxAdsPerDay',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 広告視聴ボタン
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: remaining > 0 ? _watchAd : null,
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  remaining > 0 ? '広告を視聴（残り$remaining回）' : '本日の上限達成',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: remaining > 0 ? Colors.blue : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber.shade700),
              const SizedBox(width: 8),
              Text(
                'ポイント獲得のコツ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem('毎日チェックインで最大100ポイント'),
          _buildTipItem('7日連続でボーナスポイント獲得'),
          _buildTipItem('1日最大10回の広告視聴で500ポイント'),
          _buildTipItem('チェックイン + 広告で1日最大600ポイント'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✨ ', style: TextStyle(fontSize: 16)),
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
