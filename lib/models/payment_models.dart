/// Stripe決済関連のモデル

/// 料金プラン
class PricingPlan {
  final String id;
  final String name;
  final String description;
  final int price; // 円単位
  final String interval; // 'monthly', 'yearly', 'once'
  final List<String> features;
  final bool isPopular;

  PricingPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.interval,
    required this.features,
    this.isPopular = false,
  });

  factory PricingPlan.fromJson(Map<String, dynamic> json) {
    return PricingPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
      interval: json['interval'] as String,
      features: List<String>.from(json['features'] as List),
      isPopular: json['isPopular'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'interval': interval,
      'features': features,
      'isPopular': isPopular,
    };
  }
}

/// コインパッケージ（投げ銭チャージ用）TikTok同様のシステム
class PointPackage {
  final String id;
  final String name;
  final int points; // コイン数（TikTok表記に合わせて内部的にはpoints）
  final int webPrice; // Web版価格（円）- お得
  final int appPrice; // アプリ版価格（円）- 割高
  final String platform; // 'web' or 'app'
  final bool isPopular;

  PointPackage({
    required this.id,
    required this.name,
    required this.points,
    required this.webPrice,
    required this.appPrice,
    this.platform = 'web', // デフォルトはWeb版（お得な価格）
    this.isPopular = false,
  });

  // 現在のプラットフォームに応じた価格を返す
  int get price => platform == 'web' ? webPrice : appPrice;
  
  // 実際に獲得できるコイン数（bonusを含まない）
  int get totalPoints => points;
  
  // コインあたりの単価
  double get pricePerCoin => price / points;

  factory PointPackage.fromJson(Map<String, dynamic> json) {
    return PointPackage(
      id: json['id'] as String,
      name: json['name'] as String,
      points: json['points'] as int,
      webPrice: json['webPrice'] as int,
      appPrice: json['appPrice'] as int,
      platform: json['platform'] as String? ?? 'web',
      isPopular: json['isPopular'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'points': points,
      'webPrice': webPrice,
      'appPrice': appPrice,
      'platform': platform,
      'isPopular': isPopular,
    };
  }
}

/// 決済履歴
class PaymentHistory {
  final String id;
  final String userId;
  final String type; // 'point_purchase', 'subscription', 'tip'
  final int amount; // 金額（円）
  final int? points; // ポイント数（ポイント購入の場合）
  final String status; // 'pending', 'completed', 'failed', 'refunded'
  final String? stripePaymentIntentId;
  final DateTime createdAt;
  final DateTime? completedAt;

  PaymentHistory({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    this.points,
    required this.status,
    this.stripePaymentIntentId,
    required this.createdAt,
    this.completedAt,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      amount: json['amount'] as int,
      points: json['points'] as int?,
      status: json['status'] as String,
      stripePaymentIntentId: json['stripePaymentIntentId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'amount': amount,
      'points': points,
      'status': status,
      'stripePaymentIntentId': stripePaymentIntentId,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

/// ユーザーコイン残高（TikTok形式）
class UserPointBalance {
  final String userId;
  final int totalPoints; // 総コイン数
  final int purchasedPoints; // 購入コイン数
  final int bonusPoints; // ボーナスコイン数（広告視聴、チェックイン等）
  final int usedPoints; // 使用済みコイン数
  final DateTime lastUpdated;

  UserPointBalance({
    required this.userId,
    required this.totalPoints,
    required this.purchasedPoints,
    required this.bonusPoints,
    required this.usedPoints,
    required this.lastUpdated,
  });

  int get availablePoints => totalPoints - usedPoints;

  factory UserPointBalance.fromJson(Map<String, dynamic> json) {
    return UserPointBalance(
      userId: json['userId'] as String,
      totalPoints: json['totalPoints'] as int,
      purchasedPoints: json['purchasedPoints'] as int,
      bonusPoints: json['bonusPoints'] as int,
      usedPoints: json['usedPoints'] as int,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalPoints': totalPoints,
      'purchasedPoints': purchasedPoints,
      'bonusPoints': bonusPoints,
      'usedPoints': usedPoints,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

/// チェックイン記録
class CheckInRecord {
  final String id;
  final String userId;
  final DateTime checkInDate;
  final int consecutiveDays; // 連続日数
  final int rewardPoints; // 獲得ポイント

  CheckInRecord({
    required this.id,
    required this.userId,
    required this.checkInDate,
    required this.consecutiveDays,
    required this.rewardPoints,
  });

  factory CheckInRecord.fromJson(Map<String, dynamic> json) {
    return CheckInRecord(
      id: json['id'] as String,
      userId: json['userId'] as String,
      checkInDate: DateTime.parse(json['checkInDate'] as String),
      consecutiveDays: json['consecutiveDays'] as int,
      rewardPoints: json['rewardPoints'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'checkInDate': checkInDate.toIso8601String(),
      'consecutiveDays': consecutiveDays,
      'rewardPoints': rewardPoints,
    };
  }
}

/// 広告視聴記録
class AdViewRecord {
  final String id;
  final String userId;
  final String adId;
  final DateTime viewedAt;
  final int rewardPoints;
  final bool completed; // 広告を最後まで視聴したか

  AdViewRecord({
    required this.id,
    required this.userId,
    required this.adId,
    required this.viewedAt,
    required this.rewardPoints,
    required this.completed,
  });

  factory AdViewRecord.fromJson(Map<String, dynamic> json) {
    return AdViewRecord(
      id: json['id'] as String,
      userId: json['userId'] as String,
      adId: json['adId'] as String,
      viewedAt: DateTime.parse(json['viewedAt'] as String),
      rewardPoints: json['rewardPoints'] as int,
      completed: json['completed'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'adId': adId,
      'viewedAt': viewedAt.toIso8601String(),
      'rewardPoints': rewardPoints,
      'completed': completed,
    };
  }
}

/// 投げ銭手数料設定
class TipFeeStructure {
  final double creatorRate; // クリエーター（スタッフライバー）還元率 0.5-0.7 (50%-70%)
  final double storeRate; // 店舗（会社）還元率 0.0-0.1 (0%-10%)
  final double platformRate; // プラットフォーム手数料

  TipFeeStructure({
    required this.creatorRate,
    required this.storeRate,
  }) : platformRate = 1.0 - creatorRate - storeRate;

  // 投げ銭金額から各配分を計算
  Map<String, int> calculateDistribution(int tipAmount) {
    return {
      'creator': (tipAmount * creatorRate).round(),
      'store': (tipAmount * storeRate).round(),
      'platform': (tipAmount * platformRate).round(),
    };
  }

  factory TipFeeStructure.fromJson(Map<String, dynamic> json) {
    return TipFeeStructure(
      creatorRate: (json['creatorRate'] as num).toDouble(),
      storeRate: (json['storeRate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'creatorRate': creatorRate,
      'storeRate': storeRate,
      'platformRate': platformRate,
    };
  }
}
