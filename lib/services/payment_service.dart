import 'package:flutter/foundation.dart';
import '../models/payment.dart';
import '../utils/storage_helper.dart';
import 'dart:convert';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  // Stripe Publishable Key (本番環境では環境変数から取得)
  static const String stripePublishableKey = 'pk_test_YOUR_STRIPE_KEY';

  // ポイントパッケージ
  static List<PointPackage> getPointPackages() {
    return [
      PointPackage(id: 'pkg_100', points: 100, price: 120, bonus: 0),
      PointPackage(id: 'pkg_500', points: 500, price: 600, bonus: 50),
      PointPackage(id: 'pkg_1000', points: 1000, price: 1200, bonus: 100),
      PointPackage(id: 'pkg_3000', points: 3000, price: 3600, bonus: 400),
      PointPackage(id: 'pkg_5000', points: 5000, price: 6000, bonus: 800),
      PointPackage(id: 'pkg_10000', points: 10000, price: 12000, bonus: 2000),
    ];
  }

  // ユーザーポイント取得
  Future<UserPoints> getUserPoints(String userId) async {
    try {
      final pointsJson = await StorageHelper.getString('user_points_$userId');
      if (pointsJson != null) {
        return UserPoints.fromJson(jsonDecode(pointsJson));
      }
      return UserPoints(userId: userId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get user points: $e');
      }
      return UserPoints(userId: userId);
    }
  }

  // ユーザーポイント保存
  Future<void> saveUserPoints(UserPoints userPoints) async {
    try {
      await StorageHelper.setString(
        'user_points_${userPoints.userId}',
        jsonEncode(userPoints.toJson()),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save user points: $e');
      }
    }
  }

  // ポイント購入（デモ版 - 実際はStripe決済処理）
  Future<bool> purchasePoints({
    required String userId,
    required PointPackage package,
  }) async {
    try {
      // 実際の実装では、ここでStripe Payment Intentを作成
      // final paymentIntent = await createPaymentIntent(package.price);
      // await confirmPayment(paymentIntent);

      // デモ版: 直接ポイント追加
      final userPoints = await getUserPoints(userId);
      final totalPoints = package.points + package.bonus;
      userPoints.addPoints(
        totalPoints,
        'ポイント購入: ${package.points}pt + ボーナス${package.bonus}pt',
        TransactionType.purchase,
      );
      await saveUserPoints(userPoints);

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to purchase points: $e');
      }
      return false;
    }
  }

  // ギフト送信
  Future<bool> sendGift({
    required String fromUserId,
    required String fromUserName,
    required String toStaffId,
    required String toStaffName,
    required int giftAmount,
    required String giftName,
  }) async {
    try {
      // ユーザーポイントを消費
      final userPoints = await getUserPoints(fromUserId);
      if (userPoints.points < giftAmount) {
        return false;
      }

      userPoints.spendPoints(
        giftAmount,
        '$toStaffNameさんへ$giftNameを送信',
      );
      await saveUserPoints(userPoints);

      // スタッフ収益に追加
      final staffEarnings = await getStaffEarnings(toStaffId);
      staffEarnings.addEarning(
        giftAmount,
        fromUserId,
        fromUserName,
        '$giftName を受信',
      );
      await saveStaffEarnings(staffEarnings);

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to send gift: $e');
      }
      return false;
    }
  }

  // スタッフ収益取得
  Future<StaffEarnings> getStaffEarnings(String staffId) async {
    try {
      final earningsJson = await StorageHelper.getString('staff_earnings_$staffId');
      if (earningsJson != null) {
        return StaffEarnings.fromJson(jsonDecode(earningsJson));
      }
      return StaffEarnings(staffId: staffId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get staff earnings: $e');
      }
      return StaffEarnings(staffId: staffId);
    }
  }

  // スタッフ収益保存
  Future<void> saveStaffEarnings(StaffEarnings earnings) async {
    try {
      await StorageHelper.setString(
        'staff_earnings_${earnings.staffId}',
        jsonEncode(earnings.toJson()),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save staff earnings: $e');
      }
    }
  }

  // 出金申請
  Future<bool> requestWithdrawal({
    required String staffId,
    required int amount,
    required String bankAccount,
  }) async {
    try {
      final earnings = await getStaffEarnings(staffId);
      if (earnings.pendingEarnings < amount) {
        return false;
      }

      earnings.requestWithdrawal(amount, bankAccount);
      await saveStaffEarnings(earnings);

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to request withdrawal: $e');
      }
      return false;
    }
  }

  // 出金申請処理（管理者用）
  Future<bool> processWithdrawal({
    required String staffId,
    required String withdrawalId,
    required WithdrawalStatus newStatus,
    String? note,
  }) async {
    try {
      final earnings = await getStaffEarnings(staffId);
      final request = earnings.withdrawalRequests.firstWhere(
        (r) => r.id == withdrawalId,
      );

      request.status = newStatus;
      request.processedAt = DateTime.now();
      request.note = note;

      if (newStatus == WithdrawalStatus.completed) {
        earnings.withdrawnEarnings += request.amount;
      } else if (newStatus == WithdrawalStatus.rejected) {
        earnings.pendingEarnings += request.amount;
      }

      await saveStaffEarnings(earnings);

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to process withdrawal: $e');
      }
      return false;
    }
  }

  // 全スタッフの収益統計取得（管理者用）
  Future<Map<String, dynamic>> getAllStaffEarningsStats() async {
    // デモデータ
    return {
      'totalEarnings': 1250000,
      'totalPending': 320000,
      'totalWithdrawn': 930000,
      'topEarners': [
        {'staffId': 'staff_001', 'name': '山田 美容師', 'earnings': 450000},
        {'staffId': 'staff_002', 'name': '佐藤 トレーナー', 'earnings': 380000},
        {'staffId': 'staff_003', 'name': '田中 ネイリスト', 'earnings': 290000},
      ],
    };
  }
}

class PointPackage {
  final String id;
  final int points;
  final int price; // 円
  final int bonus;

  PointPackage({
    required this.id,
    required this.points,
    required this.price,
    required this.bonus,
  });

  int get totalPoints => points + bonus;
  String get displayPrice => '¥${price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )}';
}
