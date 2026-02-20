import '../models/gift.dart';

class GiftData {
  // TikTok風ギフトリスト
  static List<Gift> getGiftList() {
    return [
      // 基本ギフト（10-100ポイント）
      Gift(
        id: 'gift_001',
        name: 'ハート',
        emoji: '❤️',
        price: 10,
        category: '基本',
      ),
      Gift(
        id: 'gift_002',
        name: 'いいね',
        emoji: '👍',
        price: 10,
        category: '基本',
      ),
      Gift(
        id: 'gift_003',
        name: 'バラ',
        emoji: '🌹',
        price: 50,
        category: '基本',
      ),
      Gift(
        id: 'gift_004',
        name: 'コーヒー',
        emoji: '☕',
        price: 100,
        category: '基本',
      ),
      Gift(
        id: 'gift_005',
        name: 'ケーキ',
        emoji: '🎂',
        price: 100,
        category: '基本',
      ),

      // 特別ギフト（500-1000ポイント）
      Gift(
        id: 'gift_006',
        name: '花束',
        emoji: '💐',
        price: 500,
        category: '特別',
        animation: 'flower_burst',
      ),
      Gift(
        id: 'gift_007',
        name: 'シャンパン',
        emoji: '🍾',
        price: 1000,
        category: '特別',
        animation: 'champagne_pop',
      ),
      Gift(
        id: 'gift_008',
        name: 'ダイヤモンド',
        emoji: '💎',
        price: 1000,
        category: '特別',
        animation: 'diamond_sparkle',
      ),
      Gift(
        id: 'gift_009',
        name: 'トロフィー',
        emoji: '🏆',
        price: 800,
        category: '特別',
        animation: 'trophy_shine',
      ),

      // プレミアムギフト（5000-10000ポイント）
      Gift(
        id: 'gift_010',
        name: '王冠',
        emoji: '👑',
        price: 5000,
        category: 'プレミアム',
        animation: 'crown_glory',
      ),
      Gift(
        id: 'gift_011',
        name: 'スポーツカー',
        emoji: '🏎️',
        price: 10000,
        category: 'プレミアム',
        animation: 'car_drive',
      ),
      Gift(
        id: 'gift_012',
        name: 'ヨット',
        emoji: '🛥️',
        price: 20000,
        category: 'プレミアム',
        animation: 'yacht_sail',
      ),
      Gift(
        id: 'gift_013',
        name: 'ロケット',
        emoji: '🚀',
        price: 50000,
        category: 'プレミアム',
        animation: 'rocket_launch',
      ),
    ];
  }

  // カテゴリー別ギフト取得
  static List<Gift> getGiftsByCategory(String category) {
    return getGiftList().where((gift) => gift.category == category).toList();
  }

  // 価格帯別ギフト取得
  static List<Gift> getGiftsByPriceRange(int minPrice, int maxPrice) {
    return getGiftList()
        .where((gift) => gift.price >= minPrice && gift.price <= maxPrice)
        .toList();
  }

  // 人気ギフトTop5
  static List<Gift> getPopularGifts() {
    return [
      getGiftList()[0], // ハート
      getGiftList()[2], // バラ
      getGiftList()[6], // シャンパン
      getGiftList()[7], // ダイヤモンド
      getGiftList()[10], // スポーツカー
    ];
  }
}

// ポイントチャージプラン
class ChargePackage {
  final String id;
  final int points;
  final int priceYen;
  final double bonusRate; // ボーナスポイント率
  final bool isPopular;

  ChargePackage({
    required this.id,
    required this.points,
    required this.priceYen,
    this.bonusRate = 0.0,
    this.isPopular = false,
  });

  int get bonusPoints => (points * bonusRate).round();
  int get totalPoints => points + bonusPoints;
  String get displayPrice => '¥${priceYen.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )}';
}

class ChargeData {
  static List<ChargePackage> getChargePackages() {
    return [
      ChargePackage(
        id: 'charge_001',
        points: 100,
        priceYen: 120,
      ),
      ChargePackage(
        id: 'charge_002',
        points: 500,
        priceYen: 550,
      ),
      ChargePackage(
        id: 'charge_003',
        points: 1000,
        priceYen: 1000,
        bonusRate: 0.05,
      ),
      ChargePackage(
        id: 'charge_004',
        points: 3000,
        priceYen: 3000,
        bonusRate: 0.10,
        isPopular: true,
      ),
      ChargePackage(
        id: 'charge_005',
        points: 5000,
        priceYen: 5000,
        bonusRate: 0.15,
      ),
      ChargePackage(
        id: 'charge_006',
        points: 10000,
        priceYen: 10000,
        bonusRate: 0.20,
      ),
      ChargePackage(
        id: 'charge_007',
        points: 50000,
        priceYen: 50000,
        bonusRate: 0.30,
      ),
    ];
  }
}
