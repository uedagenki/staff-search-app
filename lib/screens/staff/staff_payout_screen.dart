import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/stripe_connect_service.dart';
import '../../services/local_auth_service.dart';

/// スタッフ用：チップ出金管理画面
class StaffPayoutScreen extends StatefulWidget {
  const StaffPayoutScreen({super.key});

  @override
  State<StaffPayoutScreen> createState() => _StaffPayoutScreenState();
}

class _StaffPayoutScreenState extends State<StaffPayoutScreen> with SingleTickerProviderStateMixin {
  final StripeConnectService _stripeService = StripeConnectService();
  final LocalAuthService _authService = LocalAuthService();
  final _amountController = TextEditingController();
  
  late TabController _tabController;
  BalanceInfo? _balance;
  ConnectAccountStatus? _accountStatus;
  List<PayoutRecord> _payoutHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        final balance = await _stripeService.getBalance(user.id);
        final status = await _stripeService.getAccountStatus(user.id);
        final history = await _stripeService.getPayoutHistory(user.id);

        setState(() {
          _balance = balance;
          _accountStatus = status;
          _payoutHistory = history;
        });
      }
    } catch (e) {
      debugPrint('データ読み込みエラー: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _requestPayout() async {
    final user = await _authService.getCurrentUser();
    if (user == null) return;

    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showErrorDialog('有効な金額を入力してください');
      return;
    }

    // 確認ダイアログ
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('出金申請確認'),
        content: Text('${NumberFormat('#,###').format(amount)}円を出金申請しますか？\n\n3営業日後に登録口座に振り込まれます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('申請する'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await _stripeService.requestPayout(
      userId: user.id,
      amount: amount,
    );

    if (mounted) {
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.green,
          ),
        );
        _amountController.clear();
        _loadData();
      } else {
        _showErrorDialog(result.message);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('エラー'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('出金管理'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '出金申請', icon: Icon(Icons.money)),
            Tab(text: '出金履歴', icon: Icon(Icons.history)),
            Tab(text: 'ルール', icon: Icon(Icons.info)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPayoutRequestTab(),
                _buildPayoutHistoryTab(),
                _buildPayoutRulesTab(),
              ],
            ),
    );
  }

  // タブ1: 出金申請
  Widget _buildPayoutRequestTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 残高表示
          _buildBalanceCard(),
          const SizedBox(height: 24),

          // アカウントステータス
          if (_accountStatus != null && !_accountStatus!.canReceivePayouts)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _accountStatus!.message ?? '本人確認が必要です',
                      style: TextStyle(color: Colors.orange.shade700),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // 出金申請フォーム
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '出金申請',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: '出金金額',
                      hintText: '1,000円以上',
                      prefixText: '¥',
                      border: OutlineInputBorder(),
                      helperText: '最低1,000円から出金可能',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // クイック選択ボタン
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildQuickAmountButton(5000),
                      _buildQuickAmountButton(10000),
                      _buildQuickAmountButton(50000),
                      _buildQuickAmountButton(_balance?.available ?? 0, label: '全額'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _accountStatus?.canReceivePayouts == true
                          ? _requestPayout
                          : null,
                      child: const Text(
                        '出金申請',
                        style: TextStyle(fontSize: 16),
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

  Widget _buildBalanceCard() {
    final formatter = NumberFormat('#,###');
    
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              '出金可能残高',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              '¥${formatter.format(_balance?.available ?? 0)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            if ((_balance?.pending ?? 0) > 0) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '処理中: ',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '¥${formatter.format(_balance!.pending)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
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

  Widget _buildQuickAmountButton(int amount, {String? label}) {
    final formatter = NumberFormat('#,###');
    return OutlinedButton(
      onPressed: () {
        _amountController.text = amount.toString();
      },
      child: Text(label ?? '¥${formatter.format(amount)}'),
    );
  }

  // タブ2: 出金履歴
  Widget _buildPayoutHistoryTab() {
    if (_payoutHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '出金履歴がありません',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _payoutHistory.length,
      itemBuilder: (context, index) {
        final payout = _payoutHistory[index];
        return _buildPayoutHistoryCard(payout);
      },
    );
  }

  Widget _buildPayoutHistoryCard(PayoutRecord payout) {
    final formatter = NumberFormat('#,###');
    final dateFormat = DateFormat('yyyy年MM月dd日 HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: payout.statusColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.account_balance_wallet,
            color: payout.statusColor,
          ),
        ),
        title: Text(
          '¥${formatter.format(payout.amount)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('ステータス: ${payout.statusLabel}'),
            Text('申請日: ${dateFormat.format(payout.createdAt)}'),
            if (payout.status == 'pending' || payout.status == 'in_transit')
              Text('着金予定: ${dateFormat.format(payout.arrivalDate)}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: payout.statusColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            payout.statusLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // タブ3: 出金ルール
  Widget _buildPayoutRulesTab() {
    final rules = _stripeService.getPayoutRules();
    final formatter = NumberFormat('#,###');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        '出金ルール',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildRuleItem('最低出金額', '¥${formatter.format(rules.minimumAmount)}'),
                  _buildRuleItem('最大出金額', '¥${formatter.format(rules.maximumAmount)}/回'),
                  _buildRuleItem('出金手数料', rules.fee == 0 ? '無料' : '¥${formatter.format(rules.fee)}'),
                  _buildRuleItem('処理期間', '${rules.processingDays}営業日'),
                  _buildRuleItem('申請受付', '平日${rules.cutoffTime}まで'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                rules.description,
                style: const TextStyle(height: 1.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
