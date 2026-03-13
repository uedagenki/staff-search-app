import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../services/post_service.dart';

class FeedProvider extends ChangeNotifier {
  List<Post> posts = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  String? nextCursor;
  String? selectedCategory;
  String? error;

  Future<void> loadFeed() async {
    isLoading = true;
    error = null;
    posts = [];
    nextCursor = null;
    hasMore = true;
    notifyListeners();

    try {
      final result = await PostService.instance.getFeed(
        limit: 10,
        category: selectedCategory,
      );
      posts = result.posts;
      nextCursor = result.nextCursor;
      hasMore = result.hasMore;
    } catch (e) {
      error = 'Unable to load feed. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore || isLoading) return;
    isLoadingMore = true;
    notifyListeners();

    try {
      final result = await PostService.instance.getFeed(
        cursor: nextCursor,
        limit: 10,
        category: selectedCategory,
      );
      posts = [...posts, ...result.posts];
      nextCursor = result.nextCursor;
      hasMore = result.hasMore;
    } catch (_) {
      // silently fail loadMore — user can swipe to retry
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  void setCategory(String? category) {
    selectedCategory = category;
    loadFeed();
  }
}
