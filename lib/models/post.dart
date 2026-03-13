class AuthorInfo {
  final String id;
  final String name;
  final String? avatarUrl;

  const AuthorInfo({required this.id, required this.name, this.avatarUrl});

  factory AuthorInfo.fromJson(Map<String, dynamic> json) => AuthorInfo(
        id: json['id'] as String,
        name: json['name'] as String,
        avatarUrl: json['avatar_url'] as String?,
      );
}

class Post {
  final String id;
  final String authorId;
  final AuthorInfo author;
  final String? content;
  final String? mediaUrl;
  final String? mediaType;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final String? staffCategory;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.authorId,
    required this.author,
    this.content,
    this.mediaUrl,
    this.mediaType,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    this.staffCategory,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] as String,
        authorId: json['author_id'] as String,
        author: AuthorInfo.fromJson(json['author'] as Map<String, dynamic>),
        content: json['content'] as String?,
        mediaUrl: json['media_url'] as String?,
        mediaType: json['media_type'] as String?,
        likesCount: json['likes_count'] as int? ?? 0,
        commentsCount: json['comments_count'] as int? ?? 0,
        isLiked: json['is_liked'] as bool? ?? false,
        staffCategory: json['staff_category'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class FeedResponse {
  final List<Post> posts;
  final String? nextCursor;
  final bool hasMore;

  const FeedResponse({
    required this.posts,
    required this.nextCursor,
    required this.hasMore,
  });

  factory FeedResponse.fromJson(Map<String, dynamic> json) {
    final postsList = (json['posts'] as List<dynamic>? ?? [])
        .map((e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();
    return FeedResponse(
      posts: postsList,
      nextCursor: json['next_cursor'] as String?,
      hasMore: json['has_more'] as bool? ?? false,
    );
  }
}
