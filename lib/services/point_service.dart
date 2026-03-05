import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../utils/storage_helper.dart';
import '../models/point_transaction.dart';
import '../models/user.dart';

class PointService {
  static const String _transactionsKey = 'point_transactions';
  static const String _userPointsPrefix = 'user_points_';

  // 利用可能なポイントパッケージ
  static final List<PointPackage> packages = [
    PointPackage(
      id: 'pack_100',
      points: 100,
      price: 120,
    ),
    PointPackage(
      id: 'pack_500',
      points: 500,
      price: 600,
      bonusPoints: 50,
      isPopular: true,
    ),
    PointPackage(
      id: 'pack_1000',
      points: 1000,
      price: 1200,
      bonusPoints: 150,
    ),
    PointPackage(
      id: 'pack_3000',
      points: 3000,
      price: 3600,
      bonusPoints: 500,
    ),
    PointPackage(
      id: 'pack_5000',
      points: 5000,
      price: 6000,
      bonusPoints: 1000,
      isPopular: true,
    ),
    PointPackage(
      id: 'pack_10000',
      points: 10000,
      price: 12000,
      bonusPoints: 2500,
    ),
  ];

  // ユーザーの現在のポイント残高を取得
  Future<int> getUserPoints(String userId) async {
    try {
      final pointsStr = await StorageHelper.getString('$_userPointsPrefix$userId');
      return int.tryParse(pointsStr ?? '0') ?? 0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get user points: $e');
      }
      return 0;
    }
  }

  // ユーザーのポイント残高を更新
  Future<void> _updateUserPoints(String userId, int points) async {
    await StorageHelper.setString('$_userPointsPrefix$userId', points.toString());
  }

  // ポイントを追加（購入時）
  Future<bool> addPoints(String userId, int amount, double price, {String? description}) async {
    try {
      final currentPoints = await getUserPoints(userId);
      final newPoints = currentPoints + amount;
      
      final transaction = PointTransaction(
        id: 'pt_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        amount: amount,
        price: price,
        type: 'purchase',
        createdAt: DateTime.now(),
        description: description ?? 'ポイント購入',
      );

      await _updateUserPoints(userId, newPoints);
      await _saveTransaction(transaction);

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to add points: $e');
      }
      return false;
    }
  }

  // ポイントを消費（ギフト送信時）
  Future<bool> consumePoints({
    required String userId,
    required int amount,
    required String recipientId,
    required String recipientName,
    String? description,
  }) async {
    try {
      final currentPoints = await getUserPoints(userId);
      
      if (currentPoints < amount) {
        if (kDebugMode) {
          debugPrint('Not enough points: has $currentPoints, needs $amount');
        }
        return false;
      }

      final newPoints = currentPoints - amount;

      final transaction = PointTransaction(
        id: 'pt_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        amount: -amount,
        price: 0,
        type: 'gift_sent',
        relatedUserId: recipientId,
        relatedUserName: recipientName,
        createdAt: DateTime.now(),
        description: description ?? 'ギフト送信',
      );

      await _updateUserPoints(userId, newPoints);
      await _saveTransaction(transaction);

      // 受信者にポイントを追加
      await _addReceivedGift(
        recipientId: recipientId,
        amount: amount,
        senderId: userId,
        description: description,
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to consume points: $e');
      }
      return false;
    }
  }

  // ギフト受信時の処理
  Future<void> _addReceivedGift({
    required String recipientId,
    required int amount,
    required String senderId,
    String? description,
  }) async {
    try {
      final transaction = PointTransaction(
        id: 'pt_${DateTime.now().millisecondsSinceEpoch}_received',
        userId: recipientId,
        amount: amount,
        price: 0,
        type: 'gift_received',
        relatedUserId: senderId,
        createdAt: DateTime.now(),
        description: description ?? 'ギフト受信',
      );

      await _saveTransaction(transaction);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to add received gift: $e');
      }
    }
  }

  // トランザクションを保存
  Future<void> _saveTransaction(PointTransaction transaction) async {
    try {
      final transactions = await getTransactions(transaction.userId);
      transactions.insert(0, transaction);

      final jsonList = transactions.map((t) => t.toJson()).toList();
      await StorageHelper.setString(
        '${_transactionsKey}_${transaction.userId}',
        jsonEncode(jsonList),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save transaction: $e');
      }
    }
  }

  // ユーザーのトランザクション履歴を取得
  Future<List<PointTransaction>> getTransactions(String userId) async {
    try {
      final jsonStr = await StorageHelper.getString('${_transactionsKey}_$userId');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonStr);
        return jsonList.map((json) => PointTransaction.fromJson(json)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get transactions: $e');
      }
    }
    return [];
  }

  // トランザクション統計を取得
  Future<Map<String, dynamic>> getTransactionStats(String userId) async {
    final transactions = await getTransactions(userId);
    
    int totalPurchased = 0;
    int totalSpent = 0;
    int totalReceived = 0;
    double totalPrice = 0;

    for (final transaction in transactions) {
      switch (transaction.type) {
        case 'purchase':
          totalPurchased += transaction.amount;
          totalPrice += transaction.price;
          break;
        case 'gift_sent':
          totalSpent += transaction.amount.abs();
          break;
        case 'gift_received':
          totalReceived += transaction.amount;
          break;
      }
    }

    return {
      'totalPurchased': totalPurchased,
      'totalSpent': totalSpent,
      'totalReceived': totalReceived,
      'totalPrice': totalPrice,
      'transactionCount': transactions.length,
    };
  }
}
