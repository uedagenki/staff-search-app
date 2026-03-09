class FanClubMembership {
  final String id;
  final String userId;
  final String staffId;
  final int memberLevel; // 1-10
  final String memberTier; // 'bronze', 'silver', 'gold', 'platinum', 'diamond'
  final int totalGiftValue; // 累計ギフト額
  final int totalHearts; // 累計ハート数
  final DateTime joinedAt;
  final DateTime? lastGiftAt;
  final Map<String, int> benefits; // レベル別特典
  final bool isActive;

  FanClubMembership({
    required this.id,
    required this.userId,
    required this.staffId,
    this.memberLevel = 1,
    this.memberTier = 'bronze',
    this.totalGiftValue = 0,
    this.totalHearts = 0,
    required this.joinedAt,
    this.lastGiftAt,
    Map<String, int>? benefits,
    this.isActive = true,
  }) : benefits = benefits ?? {};

  // メンバーレベルアップの閾値
  static int getLevelThreshold(int level) {
    const thresholds = {
      1: 0,
      2: 1000,
      3: 3000,
      4: 5000,
      5: 10000,
      6: 20000,
      7: 50000,
      8: 100000,
      9: 200000,
      10: 500000,
    };
    return thresholds[level] ?? 0;
  }

  // ティア判定
  static String getTierFromLevel(int level) {
    if (level >= 9) return 'diamond';
    if (level >= 7) return 'platinum';
    if (level >= 5) return 'gold';
    if (level >= 3) return 'silver';
    return 'bronze';
  }

  // レベルアップ可能かチェック
  bool canLevelUp() {
    if (memberLevel >= 10) return false;
    final nextThreshold = getLevelThreshold(memberLevel + 1);
    return totalGiftValue >= nextThreshold;
  }

  // ギフト追加してレベル更新
  FanClubMembership addGift(int giftValue, int hearts) {
    final newTotalGiftValue = totalGiftValue + giftValue;
    final newTotalHearts = totalHearts + hearts;
    
    // 新しいレベル計算
    int newLevel = memberLevel;
    for (int level = 10; level >= 1; level--) {
      if (newTotalGiftValue >= getLevelThreshold(level)) {
        newLevel = level;
        break;
      }
    }

    return FanClubMembership(
      id: id,
      userId: userId,
      staffId: staffId,
      memberLevel: newLevel,
      memberTier: getTierFromLevel(newLevel),
      totalGiftValue: newTotalGiftValue,
      totalHearts: newTotalHearts,
      joinedAt: joinedAt,
      lastGiftAt: DateTime.now(),
      benefits: benefits,
      isActive: isActive,
    );
  }

  // 特典取得
  Map<String, dynamic> getMemberBenefits() {
    return {
      'exclusiveContent': memberLevel >= 3,
      'priorityChat': memberLevel >= 5,
      'customBadge': memberLevel >= 7,
      'privateMessage': memberLevel >= 8,
      'vipLive': memberLevel >= 9,
      'discountRate': memberLevel * 5, // レベルごとに5%割引
    };
  }

  // バッジ取得
  String getBadgeEmoji() {
    switch (memberTier) {
      case 'diamond':
        return '💎';
      case 'platinum':
        return '⭐';
      case 'gold':
        return '🥇';
      case 'silver':
        return '🥈';
      case 'bronze':
      default:
        return '🥉';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'staffId': staffId,
      'memberLevel': memberLevel,
      'memberTier': memberTier,
      'totalGiftValue': totalGiftValue,
      'totalHearts': totalHearts,
      'joinedAt': joinedAt.toIso8601String(),
      'lastGiftAt': lastGiftAt?.toIso8601String(),
      'benefits': benefits,
      'isActive': isActive,
    };
  }

  factory FanClubMembership.fromJson(Map<String, dynamic> json) {
    return FanClubMembership(
      id: json['id'] as String,
      userId: json['userId'] as String,
      staffId: json['staffId'] as String,
      memberLevel: json['memberLevel'] as int? ?? 1,
      memberTier: json['memberTier'] as String? ?? 'bronze',
      totalGiftValue: json['totalGiftValue'] as int? ?? 0,
      totalHearts: json['totalHearts'] as int? ?? 0,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      lastGiftAt: json['lastGiftAt'] != null
          ? DateTime.parse(json['lastGiftAt'] as String)
          : null,
      benefits: json['benefits'] != null
          ? Map<String, int>.from(json['benefits'] as Map)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
