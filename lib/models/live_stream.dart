class LiveStream {
  final String id;
  final String staffId;
  final String staffName;
  final String staffProfileImage;
  final String title;
  final String category;
  final DateTime startedAt;
  int viewerCount;
  int likeCount;
  int giftAmount;
  bool isActive;
  final String channelName;
  final String token; // Agora token

  LiveStream({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.staffProfileImage,
    required this.title,
    required this.category,
    required this.startedAt,
    this.viewerCount = 0,
    this.likeCount = 0,
    this.giftAmount = 0,
    this.isActive = true,
    required this.channelName,
    required this.token,
  });

  factory LiveStream.fromJson(Map<String, dynamic> json) {
    return LiveStream(
      id: json['id'] as String,
      staffId: json['staffId'] as String,
      staffName: json['staffName'] as String,
      staffProfileImage: json['staffProfileImage'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      viewerCount: json['viewerCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      giftAmount: json['giftAmount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      channelName: json['channelName'] as String,
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staffId': staffId,
      'staffName': staffName,
      'staffProfileImage': staffProfileImage,
      'title': title,
      'category': category,
      'startedAt': startedAt.toIso8601String(),
      'viewerCount': viewerCount,
      'likeCount': likeCount,
      'giftAmount': giftAmount,
      'isActive': isActive,
      'channelName': channelName,
      'token': token,
    };
  }

  String get duration {
    final diff = DateTime.now().difference(startedAt);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    
    if (hours > 0) {
      return '$hours時間${minutes}分';
    } else {
      return '$minutes分';
    }
  }
}

class LiveComment {
  final String id;
  final String userId;
  final String userName;
  final String userProfileImage;
  final String message;
  final DateTime timestamp;

  LiveComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userProfileImage,
    required this.message,
    required this.timestamp,
  });

  factory LiveComment.fromJson(Map<String, dynamic> json) {
    return LiveComment(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userProfileImage: json['userProfileImage'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userProfileImage': userProfileImage,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class LiveGift {
  final String id;
  final String name;
  final int amount; // 金額（円）
  final String iconUrl;

  LiveGift({
    required this.id,
    required this.name,
    required this.amount,
    required this.iconUrl,
  });

  factory LiveGift.fromJson(Map<String, dynamic> json) {
    return LiveGift(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: json['amount'] as int,
      iconUrl: json['iconUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'iconUrl': iconUrl,
    };
  }

  // サンプルギフトデータ
  static List<LiveGift> getSampleGifts() {
    return [
      LiveGift(id: 'gift_1', name: 'ハート', amount: 100, iconUrl: '❤️'),
      LiveGift(id: 'gift_2', name: 'バラ', amount: 500, iconUrl: '🌹'),
      LiveGift(id: 'gift_3', name: 'ケーキ', amount: 1000, iconUrl: '🎂'),
      LiveGift(id: 'gift_4', name: 'ダイヤ', amount: 5000, iconUrl: '💎'),
      LiveGift(id: 'gift_5', name: '王冠', amount: 10000, iconUrl: '👑'),
    ];
  }
}
