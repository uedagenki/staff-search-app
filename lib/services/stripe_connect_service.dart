import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stripe Connect統合サービス
/// 
/// スタッフの収益管理・出金機能を提供
/// 実際の実装ではStripe APIと連携
class StripeConnectService {
  static const String _keyConnectedAccounts = 'stripe_connected_accounts';
  static const String _keyPayoutHistory = 'payout_history';
  static const String _keyPendingPayouts = 'pending_payouts';

  /// Stripe Connect アカウント接続ステータスを確認
  Future<ConnectAccountStatus> getAccountStatus(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'stripe_account_$userId';
    final accountJson = prefs.getString(key);

    if (accountJson == null) {
      return ConnectAccountStatus(
        isConnected: false,
        accountId: null,
        isVerified: false,
        canReceivePayouts: false,
        message: 'Stripeアカウントが接続されていません',
      );
    }

    final account = jsonDecode(accountJson);
    final isVerified = account['charges_enabled'] == true;

    return ConnectAccountStatus(
      isConnected: true,
      accountId: account['id'],
      isVerified: isVerified,
      canReceivePayouts: isVerified,
      email: account['email'],
      country: account['country'] ?? 'JP',
      currency: account['default_currency'] ?? 'jpy',
      message: isVerified ? null : '本人確認が必要です',
    );
  }

  /// Stripe Connect アカウントを作成・接続
  Future<String> createConnectAccount({
    required String userId,
    required String email,
    String country = 'JP',
  }) async {
    // 実際のアプリでは、サーバー側でStripe APIを呼び出す
    // POST /api/stripe/connect/account
    
    final accountId = 'acct_${DateTime.now().millisecondsSinceEpoch}';
    
    final account = {
      'id': accountId,
      'email': email,
      'country': country,
      'default_currency': 'jpy',
      'charges_enabled': false, // 本人確認完了後にtrue
      'payouts_enabled': false,
      'created_at': DateTime.now().toIso8601String(),
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('stripe_account_$userId', jsonEncode(account));

    return accountId;
  }

  /// 利用可能な残高を取得
  Future<BalanceInfo> getBalance(String userId) async {
    // 実際のアプリでは、サーバー経由でStripe APIから残高を取得
    // GET /api/stripe/balance?user_id=xxx
    
    final prefs = await SharedPreferences.getInstance();
    final balanceKey = 'balance_$userId';
    final balanceJson = prefs.getString(balanceKey);

    if (balanceJson == null) {
      return BalanceInfo(
        available: 0,
        pending: 0,
        currency: 'jpy',
      );
    }

    final balance = jsonDecode(balanceJson);
    return BalanceInfo(
      available: balance['available'] ?? 0,
      pending: balance['pending'] ?? 0,
      currency: balance['currency'] ?? 'jpy',
    );
  }

  /// 残高を更新（チップ受取時）
  Future<void> addBalance(String userId, int amount) async {
    final balance = await getBalance(userId);
    final newBalance = {
      'available': balance.available + amount,
      'pending': balance.pending,
      'currency': 'jpy',
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('balance_$userId', jsonEncode(newBalance));
  }

  /// 出金申請
  Future<PayoutResult> requestPayout({
    required String userId,
    required int amount,
    String? bankAccountId,
  }) async {
    // バリデーション
    final status = await getAccountStatus(userId);
    if (!status.canReceivePayouts) {
      return PayoutResult(
        success: false,
        message: 'Stripeアカウントの本人確認が完了していません',
      );
    }

    final balance = await getBalance(userId);
    if (balance.available < amount) {
      return PayoutResult(
        success: false,
        message: '利用可能残高が不足しています',
      );
    }

    // 最低出金額チェック
    if (amount < 1000) {
      return PayoutResult(
        success: false,
        message: '最低出金額は1,000円です',
      );
    }

    // 実際のアプリでは、サーバー経由でStripe APIで出金処理
    // POST /api/stripe/payouts
    
    final payoutId = 'po_${DateTime.now().millisecondsSinceEpoch}';
    final payout = {
      'id': payoutId,
      'user_id': userId,
      'amount': amount,
      'currency': 'jpy',
      'status': 'pending', // pending -> in_transit -> paid
      'arrival_date': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'description': '出金申請',
    };

    // 出金履歴に追加
    final prefs = await SharedPreferences.getInstance();
    final historyKey = '${_keyPayoutHistory}_$userId';
    final historyJson = prefs.getString(historyKey) ?? '[]';
    final history = List<Map<String, dynamic>>.from(jsonDecode(historyJson));
    history.insert(0, payout);
    await prefs.setString(historyKey, jsonEncode(history));

    // 残高から差し引く
    final newBalance = {
      'available': balance.available - amount,
      'pending': balance.pending + amount,
      'currency': 'jpy',
    };
    await prefs.setString('balance_$userId', jsonEncode(newBalance));

    return PayoutResult(
      success: true,
      payoutId: payoutId,
      message: '出金申請を受け付けました。3営業日後に振込予定です。',
    );
  }

  /// 出金履歴を取得
  Future<List<PayoutRecord>> getPayoutHistory(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final historyKey = '${_keyPayoutHistory}_$userId';
    final historyJson = prefs.getString(historyKey) ?? '[]';
    final history = List<Map<String, dynamic>>.from(jsonDecode(historyJson));

    return history.map((json) => PayoutRecord.fromJson(json)).toList();
  }

  /// 出金ルールを取得
  PayoutRules getPayoutRules() {
    return PayoutRules(
      minimumAmount: 1000, // 最低出金額: 1,000円
      maximumAmount: 1000000, // 最大出金額: 1,000,000円
      processingDays: 3, // 処理日数: 3営業日
      fee: 0, // 出金手数料: 無料（Stripeが負担）
      currency: 'JPY',
      availableDays: [1, 2, 3, 4, 5], // 月〜金曜日のみ
      cutoffTime: '15:00', // 当日処理の締め切り時刻
      description: '''
出金ルール：
• 最低出金額: 1,000円
• 最大出金額: 1,000,000円/回
• 出金手数料: 無料
• 処理期間: 3営業日
• 申請受付: 平日15時まで（当日処理）
• 振込先: 登録済みの銀行口座

注意事項：
• 土日祝日の申請は翌営業日処理
• 本人確認完了後に出金可能
• 店舗所属の場合、還元率に応じた金額が振込
''',
    );
  }

  /// 手数料計算（店舗還元率を考慮）
  int calculateNetAmount(int grossAmount, double storeCommissionRate) {
    // storeCommissionRate: 0.0〜1.0（店舗が受け取る割合）
    // スタッフが受け取る金額 = 総額 × (1 - 店舗還元率)
    final netAmount = (grossAmount * (1.0 - storeCommissionRate)).round();
    return netAmount;
  }

  /// 銀行口座を追加
  Future<bool> addBankAccount({
    required String userId,
    required String accountHolderName,
    required String bankName,
    required String branchName,
    required String accountType, // 'checking' or 'savings'
    required String accountNumber,
  }) async {
    // 実際のアプリでは、サーバー経由でStripe APIで銀行口座を登録
    // POST /api/stripe/bank_accounts
    
    final bankAccount = {
      'id': 'ba_${DateTime.now().millisecondsSinceEpoch}',
      'account_holder_name': accountHolderName,
      'bank_name': bankName,
      'branch_name': branchName,
      'account_type': accountType,
      'last4': accountNumber.substring(accountNumber.length - 4),
      'created_at': DateTime.now().toIso8601String(),
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bank_account_$userId', jsonEncode(bankAccount));

    return true;
  }

  /// 銀行口座情報を取得
  Future<Map<String, dynamic>?> getBankAccount(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final bankAccountJson = prefs.getString('bank_account_$userId');
    
    if (bankAccountJson == null) return null;
    
    return jsonDecode(bankAccountJson);
  }
}

/// Stripe Connect アカウントステータス
class ConnectAccountStatus {
  final bool isConnected;
  final String? accountId;
  final bool isVerified;
  final bool canReceivePayouts;
  final String? email;
  final String? country;
  final String? currency;
  final String? message;

  ConnectAccountStatus({
    required this.isConnected,
    required this.accountId,
    required this.isVerified,
    required this.canReceivePayouts,
    this.email,
    this.country,
    this.currency,
    this.message,
  });
}

/// 残高情報
class BalanceInfo {
  final int available; // 出金可能額（円）
  final int pending; // 処理中の金額（円）
  final String currency;

  BalanceInfo({
    required this.available,
    required this.pending,
    required this.currency,
  });

  int get total => available + pending;
}

/// 出金結果
class PayoutResult {
  final bool success;
  final String? payoutId;
  final String message;

  PayoutResult({
    required this.success,
    this.payoutId,
    required this.message,
  });
}

/// 出金記録
class PayoutRecord {
  final String id;
  final String userId;
  final int amount;
  final String currency;
  final String status; // pending, in_transit, paid, failed
  final DateTime arrivalDate;
  final DateTime createdAt;
  final String description;

  PayoutRecord({
    required this.id,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.arrivalDate,
    required this.createdAt,
    required this.description,
  });

  factory PayoutRecord.fromJson(Map<String, dynamic> json) {
    return PayoutRecord(
      id: json['id'],
      userId: json['user_id'],
      amount: json['amount'],
      currency: json['currency'] ?? 'jpy',
      status: json['status'],
      arrivalDate: DateTime.parse(json['arrival_date']),
      createdAt: DateTime.parse(json['created_at']),
      description: json['description'] ?? '',
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return '処理中';
      case 'in_transit':
        return '送金中';
      case 'paid':
        return '完了';
      case 'failed':
        return '失敗';
      default:
        return '不明';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_transit':
        return Colors.blue;
      case 'paid':
        return Colors.green;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// 出金ルール
class PayoutRules {
  final int minimumAmount;
  final int maximumAmount;
  final int processingDays;
  final int fee;
  final String currency;
  final List<int> availableDays;
  final String cutoffTime;
  final String description;

  PayoutRules({
    required this.minimumAmount,
    required this.maximumAmount,
    required this.processingDays,
    required this.fee,
    required this.currency,
    required this.availableDays,
    required this.cutoffTime,
    required this.description,
  });
}
