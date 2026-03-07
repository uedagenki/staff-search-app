import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 保存済み投稿管理サービス
class SavedPostsService {
  static const String _savedPostsKey = 'saved_posts';

  /// 投稿を保存
  Future<void> savePost(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPosts = await getSavedPostIds();
    
    if (!savedPosts.contains(postId)) {
      savedPosts.add(postId);
      await prefs.setString(_savedPostsKey, json.encode(savedPosts));
    }
  }

  /// 投稿の保存を解除
  Future<void> unsavePost(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPosts = await getSavedPostIds();
    
    savedPosts.remove(postId);
    await prefs.setString(_savedPostsKey, json.encode(savedPosts));
  }

  /// 投稿が保存されているかチェック
  Future<bool> isSaved(String postId) async {
    final savedPosts = await getSavedPostIds();
    return savedPosts.contains(postId);
  }

  /// 保存済み投稿IDリストを取得
  Future<List<String>> getSavedPostIds() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPostsJson = prefs.getString(_savedPostsKey);
    
    if (savedPostsJson == null) {
      return [];
    }

    final List<dynamic> savedPostsList = json.decode(savedPostsJson);
    return savedPostsList.cast<String>();
  }

  /// 保存済み投稿数を取得
  Future<int> getSavedPostsCount() async {
    final savedPosts = await getSavedPostIds();
    return savedPosts.length;
  }

  /// すべての保存を解除
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedPostsKey);
  }
}
