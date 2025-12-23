import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FollowService {
  static const String _followingKey = 'following_staff_ids';

  // フォロー中のスタッフIDリストを取得
  Future<List<String>> getFollowingIds() async {
    final prefs = await SharedPreferences.getInstance();
    final followingJson = prefs.getString(_followingKey);
    
    if (followingJson == null) {
      return [];
    }
    
    final List<dynamic> decoded = jsonDecode(followingJson);
    return decoded.cast<String>();
  }

  // スタッフをフォロー
  Future<void> followStaff(String staffId) async {
    final prefs = await SharedPreferences.getInstance();
    final following = await getFollowingIds();
    
    if (!following.contains(staffId)) {
      following.add(staffId);
      await prefs.setString(_followingKey, jsonEncode(following));
    }
  }

  // スタッフのフォローを解除
  Future<void> unfollowStaff(String staffId) async {
    final prefs = await SharedPreferences.getInstance();
    final following = await getFollowingIds();
    
    following.remove(staffId);
    await prefs.setString(_followingKey, jsonEncode(following));
  }

  // 指定したスタッフをフォローしているか確認
  Future<bool> isFollowing(String staffId) async {
    final following = await getFollowingIds();
    return following.contains(staffId);
  }

  // フォロー中のスタッフ数を取得
  Future<int> getFollowingCount() async {
    final following = await getFollowingIds();
    return following.length;
  }

  // フォロワー数を取得（デモ用：実際はサーバーから取得）
  Future<int> getFollowersCount(String staffId) async {
    // デモ用のランダムなフォロワー数を返す
    final prefs = await SharedPreferences.getInstance();
    final key = 'followers_$staffId';
    int? followers = prefs.getInt(key);
    
    if (followers == null) {
      // 初回はランダムな値を設定
      followers = (staffId.hashCode % 1000).abs() + 50;
      await prefs.setInt(key, followers);
    }
    
    return followers;
  }

  // フォロートグル（フォロー/アンフォロー切り替え）
  Future<bool> toggleFollow(String staffId) async {
    final isCurrentlyFollowing = await isFollowing(staffId);
    
    if (isCurrentlyFollowing) {
      await unfollowStaff(staffId);
      return false;
    } else {
      await followStaff(staffId);
      return true;
    }
  }
}
