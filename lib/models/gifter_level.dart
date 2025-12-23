class GifterLevel {
  final int level;
  final String title;
  final int minExp;
  final int maxExp;
  final String badge;
  final String color;
  final List<String> benefits;

  GifterLevel({
    required this.level,
    required this.title,
    required this.minExp,
    required this.maxExp,
    required this.badge,
    required this.color,
    required this.benefits,
  });

  // レベル定義
  static List<GifterLevel> getLevels() {
    return [
      GifterLevel(
        level: 1,
        title: 'ビギナー',
        minExp: 0,
        maxExp: 999,
        badge: '🌱',
        color: '#A8E6CF',
        benefits: ['基本的なギフト送信'],
      ),
      GifterLevel(
        level: 2,
        title: 'サポーター',
        minExp: 1000,
        maxExp: 4999,
        badge: '⭐',
        color: '#FFD3B6',
        benefits: ['特別ギフトアイテム解放', 'メッセージ優先表示'],
      ),
      GifterLevel(
        level: 3,
        title: 'ファン',
        minExp: 5000,
        maxExp: 14999,
        badge: '💎',
        color: '#FFAAA5',
        benefits: ['限定エフェクト', 'プロフィールバッジ', '優先予約枠'],
      ),
      GifterLevel(
        level: 4,
        title: 'VIPサポーター',
        minExp: 15000,
        maxExp: 49999,
        badge: '👑',
        color: '#FF8B94',
        benefits: ['VIPバッジ', '専用チャットルーム', '月間特典'],
      ),
      GifterLevel(
        level: 5,
        title: 'プレミアムファン',
        minExp: 50000,
        maxExp: 99999,
        badge: '💫',
        color: '#C7CEEA',
        benefits: ['プレミアムバッジ', '優先サポート', '限定イベント招待'],
      ),
      GifterLevel(
        level: 6,
        title: 'レジェンド',
        minExp: 100000,
        maxExp: 999999999,
        badge: '🏆',
        color: '#FFD700',
        benefits: ['レジェンドバッジ', '全特典利用可能', '特別待遇'],
      ),
    ];
  }

  // 経験値からレベルを取得
  static GifterLevel getLevelFromExp(int exp) {
    final levels = getLevels();
    for (var level in levels.reversed) {
      if (exp >= level.minExp) {
        return level;
      }
    }
    return levels.first;
  }

  // 次のレベルまでの経験値
  static int getExpToNextLevel(int currentExp) {
    final currentLevel = getLevelFromExp(currentExp);
    if (currentLevel.level == 6) return 0; // 最大レベル
    return currentLevel.maxExp - currentExp + 1;
  }

  // レベル進捗率（0.0 ~ 1.0）
  static double getLevelProgress(int currentExp) {
    final currentLevel = getLevelFromExp(currentExp);
    if (currentLevel.level == 6) return 1.0; // 最大レベル
    
    final rangeExp = currentLevel.maxExp - currentLevel.minExp + 1;
    final progressExp = currentExp - currentLevel.minExp;
    return progressExp / rangeExp;
  }

  // ギフト金額から経験値を計算（1円 = 1EXP）
  static int calculateExpFromGiftAmount(int amount) {
    return amount;
  }
}

// ユーザーのギフター情報
class UserGifterInfo {
  final String userId;
  final int totalExp;
  final int totalGiftAmount;
  final int giftCount;
  final DateTime lastGiftDate;
  final Map<String, int> staffGiftHistory; // staffId -> total amount

  UserGifterInfo({
    required this.userId,
    required this.totalExp,
    required this.totalGiftAmount,
    required this.giftCount,
    required this.lastGiftDate,
    required this.staffGiftHistory,
  });

  GifterLevel get currentLevel => GifterLevel.getLevelFromExp(totalExp);
  
  int get expToNextLevel => GifterLevel.getExpToNextLevel(totalExp);
  
  double get levelProgress => GifterLevel.getLevelProgress(totalExp);

  // デモデータ
  factory UserGifterInfo.demo() {
    return UserGifterInfo(
      userId: 'demo_user',
      totalExp: 12500, // レベル3（ファン）
      totalGiftAmount: 12500,
      giftCount: 45,
      lastGiftDate: DateTime.now().subtract(const Duration(hours: 2)),
      staffGiftHistory: {
        'staff_001': 5000,
        'staff_002': 3500,
        'staff_003': 2500,
        'staff_004': 1500,
      },
    );
  }
}
