// SCREEN: Withdrawal Screen | PAY-12
import '../../../utils/screen_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../services/point_service.dart';
import '../services/auth_service.dart';
import 'dart:convert';
import '../utils/storage_helper.dart';

class WithdrawalRequest {
  final String id;
  final String userId;
  final int amount;
  final String bankName;
  final String accountNumber;
  final String accountHolder;
  final DateTime requestedAt;
  final String status; // 'pending' | 'approved' | 'rejected' | 'completed'
  final String? rejectionReason;

  WithdrawalRequest({
    required this.id,
    required this.userId,
    required this.amount,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
    required this.requestedAt,
    this.status = 'pending',
    this.rejectionReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolder': accountHolder,
      'requestedAt': requestedAt.toIso8601String(),
      'status': status,
      'rejectionReason': rejectionReason,
    };
  }

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: json['amount'] as int,
      bankName: json['bankName'] as String,
      accountNumber: json['accountNumber'] as String,
      accountHolder: json['accountHolder'] as String,
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      status: json['status'] as String? ?? 'pending',
      rejectionReason: json['rejectionReason'] as String?,
    );
  }
}

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> with ScreenLogMixin {
  @override
  String get screenId => 'Withdrawal Screen | PAY-12';

  final _formKey = GlobalKey<FormState>();
  final _pointService = PointService();
  final _authService = AuthService();

  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _amountController = TextEditingController();

  int _availableAmount = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<WithdrawalRequest> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = await _authService.getCurrentUser();
    if (user == null) return;

    final transactions = await _pointService.getTransactions(user.id);
    final receivedTransactions = transactions
        .where((t) => t.type == 'gift_received')
        .toList();

    final totalEarnings = receivedTransactions.fold<int>(
      0,
      (sum, t) => sum + t.amount,
    );

    final available = (totalEarnings * 0.7).toInt();

    final requests = await _loadWithdrawalRequests(user.id);

    setState(() {
      _availableAmount = available;
      _requests = requests;
      _isLoading = false;
    });
  }

  Future<List<WithdrawalRequest>> _loadWithdrawalRequests(String userId) async {
    try {
      final jsonStr = await StorageHelper.getString('withdrawal_requests_$userId');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonStr);
        return jsonList.map((json) => WithdrawalRequest.fromJson(json)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load withdrawal requests: $e');
      }
    }
    return [];
  }

  Future<void> _saveWithdrawalRequest(WithdrawalRequest request) async {
    final user = await _authService.getCurrentUser();
    if (user == null) return;

    _requests.insert(0, request);
    final jsonList = _requests.map((r) => r.toJson()).toList();
    await StorageHelper.setString(
      'withdrawal_requests_${user.id}',
      jsonEncode(jsonList),
    );
  }

  Future<void> _submitWithdrawalRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = int.tryParse(_amountController.text) ?? 0;

    if (amount < 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('出金額は¥1,000以上を指定してください'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (amount > _availableAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('出金可能額を超えています（最大: ¥$_availableAmount）'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;

      final request = WithdrawalRequest(
        id: 'wd_${DateTime.now().millisecondsSinceEpoch}',
        userId: user.id,
        amount: amount,
        bankName: _bankNameController.text,
        accountNumber: _accountNumberController.text,
        accountHolder: _accountHolderController.text,
        requestedAt: DateTime.now(),
      );

      await _saveWithdrawalRequest(request);
      await _loadData();

      _formKey.currentState!.reset();
      _bankNameController.clear();
      _accountNumberController.clear();
      _accountHolderController.clear();
      _amountController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('出金申請を送信しました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to submit withdrawal request: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('出金申請の送信に失敗しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('出金申請'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 出金可能額表示
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '出金可能額',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '¥${_availableAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 出金申請フォーム
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
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

                          TextFormField(
                            controller: _amountController,
                            decoration: const InputDecoration(
                              labelText: '出金額（円）',
                              hintText: '例: 5000',
                              border: OutlineInputBorder(),
                              prefixText: '¥',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '出金額を入力してください';
                              }
                              final amount = int.tryParse(value);
                              if (amount == null || amount < 1000) {
                                return '最低出金額は¥1,000です';
                              }
                              if (amount > _availableAmount) {
                                return '出金可能額を超えています';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _bankNameController,
                            decoration: const InputDecoration(
                              labelText: '銀行名',
                              hintText: '例: 三菱UFJ銀行',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '銀行名を入力してください';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _accountNumberController,
                            decoration: const InputDecoration(
                              labelText: '口座番号',
                              hintText: '例: 1234567',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '口座番号を入力してください';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _accountHolderController,
                            decoration: const InputDecoration(
                              labelText: '口座名義',
                              hintText: '例: ヤマダ タロウ',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '口座名義を入力してください';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitWithdrawalRequest,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      '出金申請を送信',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 申請履歴
                if (_requests.isNotEmpty) ...[
                  const Text(
                    '申請履歴',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._requests.map((request) => _buildRequestCard(request)),
                ],
              ],
            ),
    );
  }

  Widget _buildRequestCard(WithdrawalRequest request) {
    Color statusColor;
    String statusText;

    switch (request.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = '審査中';
        break;
      case 'approved':
        statusColor = Colors.blue;
        statusText = '承認済み';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusText = '完了';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = '却下';
        break;
      default:
        statusColor = Colors.grey;
        statusText = '不明';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.account_balance_wallet,
            color: statusColor,
          ),
        ),
        title: Text(
          '¥${request.amount.toStringAsFixed(0)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${request.bankName} - ${request.accountNumber}'),
            Text(
              _formatDate(request.requestedAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
}
