class GiftItem {
  final String id;
  final String name;
  final String emoji;
  final int price;
  final String category;

  GiftItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
    required this.category,
  });

  static List<GiftItem> getAllGifts() {
    return [
      // 基本ギフト
      GiftItem(id: 'heart', name: 'ハート', emoji: '❤️', price: 100, category: '基本'),
      GiftItem(id: 'rose', name: 'バラ', emoji: '🌹', price: 200, category: '基本'),
      GiftItem(id: 'star', name: 'スター', emoji: '⭐', price: 300, category: '基本'),
      GiftItem(id: 'gift', name: 'プレゼント', emoji: '🎁', price: 500, category: '基本'),
      
      // 食べ物
      GiftItem(id: 'cake', name: 'ケーキ', emoji: '🍰', price: 800, category: '食べ物'),
      GiftItem(id: 'coffee', name: 'コーヒー', emoji: '☕', price: 500, category: '食べ物'),
      GiftItem(id: 'burger', name: 'ハンバーガー', emoji: '🍔', price: 600, category: '食べ物'),
      GiftItem(id: 'pizza', name: 'ピザ', emoji: '🍕', price: 1200, category: '食べ物'),
      
      // 高級ギフト
      GiftItem(id: 'diamond', name: 'ダイヤモンド', emoji: '💎', price: 5000, category: '高級'),
      GiftItem(id: 'crown', name: '王冠', emoji: '👑', price: 8000, category: '高級'),
      GiftItem(id: 'trophy', name: 'トロフィー', emoji: '🏆', price: 10000, category: '高級'),
      GiftItem(id: 'rocket', name: 'ロケット', emoji: '🚀', price: 15000, category: '高級'),
      
      // 乗り物
      GiftItem(id: 'car', name: '車', emoji: '🚗', price: 20000, category: '乗り物'),
      GiftItem(id: 'helicopter', name: 'ヘリコプター', emoji: '🚁', price: 50000, category: '乗り物'),
      GiftItem(id: 'yacht', name: 'ヨット', emoji: '🛥️', price: 100000, category: '乗り物'),
      
      // その他
      GiftItem(id: 'fire', name: '炎', emoji: '🔥', price: 1000, category: 'その他'),
      GiftItem(id: 'rainbow', name: '虹', emoji: '🌈', price: 2000, category: 'その他'),
      GiftItem(id: 'balloon', name: '風船', emoji: '🎈', price: 300, category: 'その他'),
      GiftItem(id: 'firework', name: '花火', emoji: '🎆', price: 3000, category: 'その他'),
    ];
  }

  static List<String> getCategories() {
    return ['すべて', '基本', '食べ物', '高級', '乗り物', 'その他'];
  }
}
