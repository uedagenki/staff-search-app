class StaffStory {
  final String id;
  final String staffId;
  final String staffName;
  final String staffImage;
  final List<StoryItem> items;
  final DateTime lastUpdated;
  final List<StoryViewer> viewers; // 閲覧者リスト

  StaffStory({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.staffImage,
    required this.items,
    required this.lastUpdated,
    this.viewers = const [],
  });

  bool get isExpired {
    return DateTime.now().difference(lastUpdated).inHours >= 24;
  }

  bool get hasUnviewedStory {
    // ユーザーが未視聴のストーリーがあるか
    return !isExpired;
  }
}

class StoryItem {
  final String id;
  final String imageUrl;
  final DateTime timestamp;
  final String? caption; // キャプション
  final List<StoryViewer> viewers; // このアイテムの閲覧者

  StoryItem({
    required this.id,
    required this.imageUrl,
    required this.timestamp,
    this.caption,
    this.viewers = const [],
  });
}

class StoryViewer {
  final String userId;
  final String userName;
  final String? userImage;
  final DateTime viewedAt;

  StoryViewer({
    required this.userId,
    required this.userName,
    this.userImage,
    required this.viewedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'viewedAt': viewedAt.toIso8601String(),
    };
  }

  factory StoryViewer.fromJson(Map<String, dynamic> json) {
    return StoryViewer(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userImage: json['userImage'] as String?,
      viewedAt: DateTime.parse(json['viewedAt'] as String),
    );
  }
}
