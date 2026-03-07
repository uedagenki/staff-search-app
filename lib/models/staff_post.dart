enum PostType {
  image,
  video,
}

class StaffPost {
  final String id;
  final String staffId;
  final String mediaUrl; // 画像または動画のURL
  final PostType type; // 投稿タイプ
  final String caption;
  final DateTime timestamp;
  int likeCount;
  int commentCount;
  final String? thumbnailUrl; // 動画のサムネイル（動画の場合のみ）
  final int? duration; // 動画の長さ（秒）
  
  // UI状態（ユーザーごとに異なる）
  bool isLiked;
  bool isSaved;

  StaffPost({
    required this.id,
    required this.staffId,
    required this.mediaUrl,
    required this.type,
    required this.caption,
    required this.timestamp,
    required this.likeCount,
    required this.commentCount,
    this.thumbnailUrl,
    this.duration,
    this.isLiked = false,
    this.isSaved = false,
  });

  // 画像URLの後方互換性のためのゲッター
  String get imageUrl => mediaUrl;
  
  // 投稿日時（後方互換性）
  DateTime get createdAt => timestamp;
}
