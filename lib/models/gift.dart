// ギフトアイテムモデル（TikTok風）
class Gift {
  final String id;
  final String name;
  final String emoji;
  final int price; // ポイント単位
  final String? animation; // アニメーションタイプ
  final String category; // カテゴリー（基本、特別、プレミアムなど）

  Gift({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
    this.animation,
    required this.category,
  });

  // 円換算（1ポイント = 1円）
  int get priceInYen => price;

  factory Gift.fromJson(Map<String, dynamic> json) {
    return Gift(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      price: json['price'] as int,
      animation: json['animation'] as String?,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'price': price,
      'animation': animation,
      'category': category,
    };
  }
}

// ギフト送信履歴
class GiftTransaction {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final Gift gift;
  final int quantity;
  final DateTime timestamp;
  final String? message;

  GiftTransaction({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.gift,
    required this.quantity,
    required this.timestamp,
    this.message,
  });

  int get totalPrice => gift.price * quantity;

  factory GiftTransaction.fromJson(Map<String, dynamic> json) {
    return GiftTransaction(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      receiverId: json['receiverId'] as String,
      receiverName: json['receiverName'] as String,
      gift: Gift.fromJson(json['gift'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'gift': gift.toJson(),
      'quantity': quantity,
      'timestamp': timestamp.toIso8601String(),
      'message': message,
    };
  }
}

// ユーザーポイント残高
class UserWallet {
  final String userId;
  int points;
  final List<PointTransaction> transactions;

  UserWallet({
    required this.userId,
    this.points = 0,
    List<PointTransaction>? transactions,
  }) : transactions = transactions ?? [];

  void addPoints(int amount, String description) {
    points += amount;
    transactions.add(PointTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      type: TransactionType.charge,
      description: description,
      timestamp: DateTime.now(),
    ));
  }

  bool deductPoints(int amount, String description) {
    if (points >= amount) {
      points -= amount;
      transactions.add(PointTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: -amount,
        type: TransactionType.gift,
        description: description,
        timestamp: DateTime.now(),
      ));
      return true;
    }
    return false;
  }
}

// ポイント取引履歴
class PointTransaction {
  final String id;
  final int amount;
  final TransactionType type;
  final String description;
  final DateTime timestamp;

  PointTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.timestamp,
  });
}

enum TransactionType {
  charge, // チャージ
  gift,   // ギフト送信
  refund, // 返金
}

// ギフターランキング
class GifterRanking {
  final String userId;
  final String userName;
  final String? userImage;
  final int totalGiftAmount;
  final int giftCount;
  final int rank;

  GifterRanking({
    required this.userId,
    required this.userName,
    this.userImage,
    required this.totalGiftAmount,
    required this.giftCount,
    required this.rank,
  });
}

// スタッフ受取ランキング
class StaffGiftRanking {
  final String staffId;
  final String staffName;
  final String staffImage;
  final int totalReceivedAmount;
  final int giftCount;
  final int rank;
  final String category;

  StaffGiftRanking({
    required this.staffId,
    required this.staffName,
    required this.staffImage,
    required this.totalReceivedAmount,
    required this.giftCount,
    required this.rank,
    required this.category,
  });
}
