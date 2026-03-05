class PointTransaction {
  final String id;
  final String userId;
  final int amount; // ポイント数
  final double price; // 実際の金額
  final String type; // 'purchase' | 'gift_sent' | 'gift_received' | 'withdrawal'
  final String? relatedUserId; // ギフトの送信先/送信元
  final String? relatedUserName;
  final DateTime createdAt;
  final String status; // 'pending' | 'completed' | 'failed'
  final String? description;

  PointTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.price,
    required this.type,
    this.relatedUserId,
    this.relatedUserName,
    required this.createdAt,
    this.status = 'completed',
    this.description,
  });

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: json['amount'] as int,
      price: (json['price'] as num).toDouble(),
      type: json['type'] as String,
      relatedUserId: json['relatedUserId'] as String?,
      relatedUserName: json['relatedUserName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String? ?? 'completed',
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'price': price,
      'type': type,
      'relatedUserId': relatedUserId,
      'relatedUserName': relatedUserName,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'description': description,
    };
  }
}

class PointPackage {
  final String id;
  final int points;
  final double price;
  final int? bonusPoints;
  final bool isPopular;

  PointPackage({
    required this.id,
    required this.points,
    required this.price,
    this.bonusPoints,
    this.isPopular = false,
  });

  int get totalPoints => points + (bonusPoints ?? 0);
  
  String get displayPrice => '¥${price.toStringAsFixed(0)}';
  
  String get displayPoints {
    if (bonusPoints != null && bonusPoints! > 0) {
      return '$points + $bonusPoints ボーナス';
    }
    return '$points ポイント';
  }
}
