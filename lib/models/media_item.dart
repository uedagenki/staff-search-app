class MediaItem {
  final String id;
  final String userId;
  final String type; // 'image' | 'video'
  final String url;
  final String? thumbnailUrl;
  final String? caption;
  final List<String> tags;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata; // サイズ、解像度など

  MediaItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.caption,
    this.tags = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    this.metadata,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      caption: json['caption'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'caption': caption,
      'tags': tags,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  MediaItem copyWith({
    String? id,
    String? userId,
    String? type,
    String? url,
    String? thumbnailUrl,
    String? caption,
    List<String>? tags,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return MediaItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
      tags: tags ?? this.tags,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

class Album {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? coverUrl;
  final List<String> mediaIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Album({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.coverUrl,
    this.mediaIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      coverUrl: json['coverUrl'] as String?,
      mediaIds: (json['mediaIds'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'coverUrl': coverUrl,
      'mediaIds': mediaIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
