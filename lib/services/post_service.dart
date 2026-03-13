import '../data/mock_data.dart';
import '../models/post.dart';
import '../services/api_client.dart';

class PostService {
  static final PostService instance = PostService._();
  PostService._();

  static FeedResponse _mockFeed({String? category}) {
    final staff = MockData.getStaffList();
    final posts = staff.asMap().entries.map((entry) {
      final i = entry.key;
      final s = entry.value;
      final images = s.profileImages ?? [s.profileImage];
      return Post(
        id: 'mock_$i',
        authorId: s.id,
        author: AuthorInfo(id: s.id, name: s.name, avatarUrl: s.profileImage),
        content: s.bio.isNotEmpty ? s.bio : null,
        mediaUrl: images.isNotEmpty ? images[i % images.length] : null,
        mediaType: 'image',
        likesCount: s.followersCount ?? 0,
        commentsCount: s.reviewCount,
        isLiked: false,
        staffCategory: s.category,
        createdAt: DateTime.now().subtract(Duration(hours: i * 3)),
      );
    }).where((p) => category == null || p.staffCategory == category).toList();
    return FeedResponse(posts: posts, nextCursor: null, hasMore: false);
  }

  Future<Post> createPost({
    String? content,
    String? mediaUrl,
    String? mediaType,
  }) async {
    final body = <String, dynamic>{};
    if (content != null && content.isNotEmpty) body['content'] = content;
    if (mediaUrl != null) body['media_url'] = mediaUrl;
    if (mediaType != null) body['media_type'] = mediaType;

    final resp = await ApiClient().post('/api/v1/posts', body);
    if (resp.isSuccess && resp.data != null) {
      return Post.fromJson(resp.data!);
    }
    throw Exception(resp.message ?? 'Failed to create post.');
  }

  Future<FeedResponse> getFeed({
    String? cursor,
    int limit = 20,
    String? category,
  }) async {
    final params = <String, String>{'limit': limit.toString()};
    if (cursor != null) params['cursor'] = cursor;
    if (category != null) params['category'] = category;

    try {
      final resp = await ApiClient().get('/api/v1/posts/feed', queryParams: params);
      if (resp.isSuccess && resp.data != null) {
        return FeedResponse.fromJson(resp.data!);
      }
    } catch (_) {}
    // API not available yet — return mock data
    return _mockFeed(category: category);
  }

  Future<FeedResponse> getMyPosts({String? cursor, int limit = 30}) async {
    final params = <String, String>{'limit': limit.toString()};
    if (cursor != null) params['cursor'] = cursor;

    final resp = await ApiClient().get('/api/v1/posts/mine', queryParams: params);
    if (resp.isSuccess && resp.data != null) {
      return FeedResponse.fromJson(resp.data!);
    }
    throw Exception(resp.message ?? 'Failed to load posts.');
  }

  Future<Post?> getPost(String postID) async {
    final resp = await ApiClient().get('/api/v1/posts/$postID');
    if (resp.isSuccess && resp.data != null) {
      return Post.fromJson(resp.data!);
    }
    if (resp.statusCode == 404) return null;
    throw Exception(resp.message ?? 'Failed to get post.');
  }
}
