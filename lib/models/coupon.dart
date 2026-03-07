/// クーポンモデル（ホットペッパービューティー風）
class Coupon {
  final String id;
  final String staffId;
  final String staffName;
  final String title; // クーポン名
  final String description; // 説明
  final CouponType type; // 割引タイプ
  final int discountValue; // 割引額または割引率
  final int? minPrice; // 最低利用金額
  final DateTime validFrom; // 有効期限（開始）
  final DateTime validUntil; // 有効期限（終了）
  final int? usageLimit; // 利用上限回数（null=無制限）
  final int usedCount; // 利用回数
  final bool isActive; // 有効/無効
  final DateTime createdAt;
  final List<String>? applicableMenus; // 適用可能メニューID（null=全メニュー）
  
  Coupon({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.title,
    required this.description,
    required this.type,
    required this.discountValue,
    this.minPrice,
    required this.validFrom,
    required this.validUntil,
    this.usageLimit,
    this.usedCount = 0,
    this.isActive = true,
    required this.createdAt,
    this.applicableMenus,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] as String,
      staffId: json['staffId'] as String,
      staffName: json['staffName'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: CouponType.values.firstWhere(
        (t) => t.toString() == 'CouponType.${json['type']}',
      ),
      discountValue: json['discountValue'] as int,
      minPrice: json['minPrice'] as int?,
      validFrom: DateTime.parse(json['validFrom'] as String),
      validUntil: DateTime.parse(json['validUntil'] as String),
      usageLimit: json['usageLimit'] as int?,
      usedCount: json['usedCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      applicableMenus: json['applicableMenus'] != null
          ? List<String>.from(json['applicableMenus'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staffId': staffId,
      'staffName': staffName,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'discountValue': discountValue,
      'minPrice': minPrice,
      'validFrom': validFrom.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'usageLimit': usageLimit,
      'usedCount': usedCount,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'applicableMenus': applicableMenus,
    };
  }

  Coupon copyWith({
    bool? isActive,
    int? usedCount,
  }) {
    return Coupon(
      id: id,
      staffId: staffId,
      staffName: staffName,
      title: title,
      description: description,
      type: type,
      discountValue: discountValue,
      minPrice: minPrice,
      validFrom: validFrom,
      validUntil: validUntil,
      usageLimit: usageLimit,
      usedCount: usedCount ?? this.usedCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      applicableMenus: applicableMenus,
    );
  }

  /// クーポンが有効か確認
  bool isValid() {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(validFrom) &&
        now.isBefore(validUntil) &&
        (usageLimit == null || usedCount < usageLimit!);
  }

  /// 割引額を計算
  int calculateDiscount(int originalPrice) {
    if (!isValid()) return 0;
    
    // 最低利用金額のチェック
    if (minPrice != null && originalPrice < minPrice!) {
      return 0;
    }

    switch (type) {
      case CouponType.fixedAmount:
        // 固定額割引
        return discountValue > originalPrice ? originalPrice : discountValue;
      case CouponType.percentage:
        // パーセント割引
        return (originalPrice * discountValue / 100).round();
    }
  }

  /// 割引後の金額を計算
  int calculateFinalPrice(int originalPrice) {
    return originalPrice - calculateDiscount(originalPrice);
  }
}

/// クーポンタイプ
enum CouponType {
  fixedAmount,  // 固定額割引（例: 1000円OFF）
  percentage,   // パーセント割引（例: 20%OFF）
}

extension CouponTypeExtension on CouponType {
  String get displayName {
    switch (this) {
      case CouponType.fixedAmount:
        return '固定額割引';
      case CouponType.percentage:
        return 'パーセント割引';
    }
  }

  String formatDiscount(int value) {
    switch (this) {
      case CouponType.fixedAmount:
        return '¥$value OFF';
      case CouponType.percentage:
        return '$value% OFF';
    }
  }
}
