import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/payment_models.dart';

/// 決済・ポイント管理サービス（ローカルストレージ版）
/// 本番環境ではStripe APIと連携
class PaymentService {
  static const String _pointBalanceKey = 'user_point_balance';
  static const String _paymentHistoryKey = 'payment_history';
  static const String _checkInRecordsKey = 'check_in_records';
  static const String _adViewRecordsKey = 'ad_view_records';
  static const String _subscriptionKey = 'company_subscription';

  // ========== 料金プラン定義 ==========

  /// ヘッドハンティング料金プラン
  List<PricingPlan> getHeadhuntingPlans() {
    return [
      PricingPlan(
        id: 'free_plan',
        name: '無料プラン',
        description: 'お試しで3回まで',
        price: 0,
        interval: 'once',
        features: [
          'ヘッドハンティング3回まで',
          '基本的なオファー送信機能',
          'スタッフ検索機能',
        ],
      ),
      PricingPlan(
        id: 'unlimited_plan',
        name: '無制限プラン',
        description: 'ヘッドハンティングし放題',
        price: 3000,
        interval: 'monthly',
        features: [
          '✨ ヘッドハンティング無制限',
          '優先サポート',
          '詳細な応募者分析',
          'スタッフ一括管理機能',
        ],
        isPopular: true,
      ),
    ];
  }

  /// コインパッケージ定義（TikTok形式）
  /// Webブラウザ版（お得）： 70コイン＝129円、700コイン＝1,299円、1400コイン＝2,599円、3500コイン＝6,499円、7000コイン＝12,999円、17500コイン＝32,499円
  /// アプリ版（割高）： 70コイン＝約140円〜
  List<PointPackage> getPointPackages({String platform = 'web'}) {
    return [
      PointPackage(
        id: 'coins_70',
        name: '70コイン',
        points: 70,
        webPrice: 129,
        appPrice: 140,
        platform: platform,
      ),
      PointPackage(
        id: 'coins_350',
        name: '350コイン',
        points: 350,
        webPrice: 649,
        appPrice: 700,
        platform: platform,
      ),
      PointPackage(
        id: 'coins_700',
        name: '700コイン',
        points: 700,
        webPrice: 1299,
        appPrice: 1400,
        platform: platform,
        isPopular: true,
      ),
      PointPackage(
        id: 'coins_1400',
        name: '1,400コイン',
        points: 1400,
        webPrice: 2599,
        appPrice: 2800,
        platform: platform,
      ),
      PointPackage(
        id: 'coins_3500',
        name: '3,500コイン',
        points: 3500,
        webPrice: 6499,
        appPrice: 7000,
        platform: platform,
      ),
      PointPackage(
        id: 'coins_7000',
        name: '7,000コイン',
        points: 7000,
        webPrice: 12999,
        appPrice: 14000,
        platform: platform,
      ),
      PointPackage(
        id: 'coins_17500',
        name: '17,500コイン',
        points: 17500,
        webPrice: 32499,
        appPrice: 35000,
        platform: platform,
      ),
    ];
  }

  // ========== ポイント残高管理 ==========

  /// ユーザーのポイント残高を取得
  Future<UserPointBalance> getUserPointBalance(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final balanceJson = prefs.getString('${_pointBalanceKey}_$userId');

    if (balanceJson == null) {
      // 初回はデフォルト残高を作成
      final defaultBalance = UserPointBalance(
        userId: userId,
        totalPoints: 0,
        purchasedPoints: 0,
        bonusPoints: 0,
        usedPoints: 0,
        lastUpdated: DateTime.now(),
      );
      await _savePointBalance(defaultBalance);
      return defaultBalance;
    }

    return UserPointBalance.fromJson(jsonDecode(balanceJson));
  }

  /// ポイント残高を保存
  Future<void> _savePointBalance(UserPointBalance balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_pointBalanceKey}_${balance.userId}',
      jsonEncode(balance.toJson()),
    );
  }

  /// ポイントを追加
  Future<void> addPoints(
    String userId,
    int points, {
    bool isPurchased = false,
  }) async {
    final balance = await getUserPointBalance(userId);

    final updatedBalance = UserPointBalance(
      userId: userId,
      totalPoints: balance.totalPoints + points,
      purchasedPoints: isPurchased
          ? balance.purchasedPoints + points
          : balance.purchasedPoints,
      bonusPoints: !isPurchased
          ? balance.bonusPoints + points
          : balance.bonusPoints,
      usedPoints: balance.usedPoints,
      lastUpdated: DateTime.now(),
    );

    await _savePointBalance(updatedBalance);
  }

  /// ポイントを使用
  Future<bool> usePoints(String userId, int points) async {
    final balance = await getUserPointBalance(userId);

    if (balance.availablePoints < points) {
      return false; // 残高不足
    }

    final updatedBalance = UserPointBalance(
      userId: userId,
      totalPoints: balance.totalPoints,
      purchasedPoints: balance.purchasedPoints,
      bonusPoints: balance.bonusPoints,
      usedPoints: balance.usedPoints + points,
      lastUpdated: DateTime.now(),
    );

    await _savePointBalance(updatedBalance);
    return true;
  }

  // ========== チェックイン機能 ==========

  /// 今日のチェックイン記録を取得
  Future<CheckInRecord?> getTodayCheckIn(String userId) async {
    final records = await getCheckInRecords(userId);
    final today = DateTime.now();

    try {
      return records.firstWhere(
        (r) =>
            r.checkInDate.year == today.year &&
            r.checkInDate.month == today.month &&
            r.checkInDate.day == today.day,
      );
    } catch (e) {
      return null;
    }
  }

  /// チェックイン記録を全て取得
  Future<List<CheckInRecord>> getCheckInRecords(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = prefs.getString('${_checkInRecordsKey}_$userId');

    if (recordsJson == null) return [];

    final List<dynamic> recordsList = jsonDecode(recordsJson);
    return recordsList.map((json) => CheckInRecord.fromJson(json)).toList();
  }

  /// チェックイン実行
  Future<CheckInRecord> checkIn(String userId) async {
    final records = await getCheckInRecords(userId);
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    // 連続日数を計算
    int consecutiveDays = 1;
    if (records.isNotEmpty) {
      final lastCheckIn = records.last;
      if (lastCheckIn.checkInDate.year == yesterday.year &&
          lastCheckIn.checkInDate.month == yesterday.month &&
          lastCheckIn.checkInDate.day == yesterday.day) {
        consecutiveDays = lastCheckIn.consecutiveDays + 1;
      }
    }

    // 報酬ポイント計算（連続日数に応じて増加）
    int rewardPoints = _calculateCheckInReward(consecutiveDays);

    final checkInRecord = CheckInRecord(
      id: 'checkin_${today.millisecondsSinceEpoch}',
      userId: userId,
      checkInDate: today,
      consecutiveDays: consecutiveDays,
      rewardPoints: rewardPoints,
    );

    // 記録を保存
    records.add(checkInRecord);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_checkInRecordsKey}_$userId',
      jsonEncode(records.map((r) => r.toJson()).toList()),
    );

    // ポイント付与
    await addPoints(userId, rewardPoints, isPurchased: false);

    return checkInRecord;
  }

  /// チェックイン報酬計算（TikTok LITE方式）
  int _calculateCheckInReward(int consecutiveDays) {
    if (consecutiveDays == 1) return 10;
    if (consecutiveDays == 2) return 20;
    if (consecutiveDays == 3) return 30;
    if (consecutiveDays == 4) return 40;
    if (consecutiveDays == 5) return 50;
    if (consecutiveDays == 6) return 60;
    if (consecutiveDays >= 7) return 100; // 7日目はボーナス
    return 10;
  }

  // ========== 広告視聴機能 ==========

  /// 広告視聴記録を取得
  Future<List<AdViewRecord>> getAdViewRecords(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = prefs.getString('${_adViewRecordsKey}_$userId');

    if (recordsJson == null) return [];

    final List<dynamic> recordsList = jsonDecode(recordsJson);
    return recordsList.map((json) => AdViewRecord.fromJson(json)).toList();
  }

  /// 今日の広告視聴回数を取得
  Future<int> getTodayAdViewCount(String userId) async {
    final records = await getAdViewRecords(userId);
    final today = DateTime.now();

    return records
        .where((r) =>
            r.viewedAt.year == today.year &&
            r.viewedAt.month == today.month &&
            r.viewedAt.day == today.day &&
            r.completed)
        .length;
  }

  /// 広告視聴完了
  Future<AdViewRecord?> completeAdView(String userId, String adId) async {
    final todayCount = await getTodayAdViewCount(userId);
    const maxAdsPerDay = 10; // 1日の上限

    if (todayCount >= maxAdsPerDay) {
      return null; // 上限達成
    }

    const rewardPoints = 50; // 1広告あたり50ポイント

    final adViewRecord = AdViewRecord(
      id: 'adview_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      adId: adId,
      viewedAt: DateTime.now(),
      rewardPoints: rewardPoints,
      completed: true,
    );

    // 記録を保存
    final records = await getAdViewRecords(userId);
    records.add(adViewRecord);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_adViewRecordsKey}_$userId',
      jsonEncode(records.map((r) => r.toJson()).toList()),
    );

    // ポイント付与
    await addPoints(userId, rewardPoints, isPurchased: false);

    return adViewRecord;
  }

  // ========== 決済履歴 ==========

  /// 決済履歴を取得
  Future<List<PaymentHistory>> getPaymentHistory(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('${_paymentHistoryKey}_$userId');

    if (historyJson == null) return [];

    final List<dynamic> historyList = jsonDecode(historyJson);
    return historyList.map((json) => PaymentHistory.fromJson(json)).toList();
  }

  /// 決済履歴を追加
  Future<void> addPaymentHistory(PaymentHistory payment) async {
    final history = await getPaymentHistory(payment.userId);
    history.add(payment);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_paymentHistoryKey}_${payment.userId}',
      jsonEncode(history.map((h) => h.toJson()).toList()),
    );
  }

  // ========== サブスクリプション管理 ==========

  /// 企業のサブスクリプション状態を取得
  Future<Map<String, dynamic>?> getCompanySubscription(String companyId) async {
    final prefs = await SharedPreferences.getInstance();
    final subJson = prefs.getString('${_subscriptionKey}_$companyId');

    if (subJson == null) return null;
    return jsonDecode(subJson);
  }

  /// サブスクリプションを設定
  Future<void> setCompanySubscription(
    String companyId,
    String planId,
    DateTime expiresAt,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_subscriptionKey}_$companyId',
      jsonEncode({
        'companyId': companyId,
        'planId': planId,
        'expiresAt': expiresAt.toIso8601String(),
        'isActive': true,
      }),
    );
  }

  /// 残りヘッドハンティング回数を取得（無料プラン）
  Future<int> getRemainingHeadhuntingCount(String companyId) async {
    final sub = await getCompanySubscription(companyId);

    if (sub != null && sub['planId'] == 'unlimited_plan') {
      return 999999; // 無制限
    }

    // 無料プランは3回まで
    final prefs = await SharedPreferences.getInstance();
    final usedCount = prefs.getInt('headhunt_used_$companyId') ?? 0;
    return 3 - usedCount;
  }

  /// ヘッドハンティング使用回数を増やす
  Future<bool> incrementHeadhuntingUsage(String companyId) async {
    final remaining = await getRemainingHeadhuntingCount(companyId);
    if (remaining <= 0) return false;

    final prefs = await SharedPreferences.getInstance();
    final usedCount = prefs.getInt('headhunt_used_$companyId') ?? 0;
    await prefs.setInt('headhunt_used_$companyId', usedCount + 1);
    return true;
  }
}
