import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fan_club_membership.dart';

class FanClubService {
  static const String _keyPrefix = 'fan_club_';
  
  // ファンクラブメンバーシップを取得
  Future<FanClubMembership?> getMembership(String userId, String staffId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_keyPrefix}${userId}_$staffId';
    final jsonString = prefs.getString(key);
    
    if (jsonString == null) return null;
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return FanClubMembership.fromJson(json);
    } catch (e) {
      return null;
    }
  }
  
  // ファンクラブメンバーシップを保存
  Future<void> saveMembership(FanClubMembership membership) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_keyPrefix}${membership.userId}_${membership.staffId}';
    final jsonString = jsonEncode(membership.toJson());
    await prefs.setString(key, jsonString);
  }
  
  // ファンクラブに入会
  Future<FanClubMembership> joinFanClub({
    required String userId,
    required String staffId,
    required int initialGiftValue,
  }) async {
    final now = DateTime.now();
    final membership = FanClubMembership(
      id: 'fc_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      staffId: staffId,
      memberLevel: 1,
      memberTier: 'bronze',
      totalGiftValue: initialGiftValue,
      totalHearts: 0,
      joinedAt: now,
      lastGiftAt: now,
    );
    
    await saveMembership(membership);
    return membership;
  }
  
  // ギフトを追加してレベルアップを確認
  Future<FanClubMembership> addGift({
    required String userId,
    required String staffId,
    required int giftValue,
    int hearts = 1,
  }) async {
    var membership = await getMembership(userId, staffId);
    
    // まだメンバーでない場合は入会
    if (membership == null) {
      membership = await joinFanClub(
        userId: userId,
        staffId: staffId,
        initialGiftValue: giftValue,
      );
      return membership;
    }
    
    // ギフトを追加してレベル更新
    final updatedMembership = membership.addGift(giftValue, hearts);
    
    await saveMembership(updatedMembership);
    return updatedMembership;
  }
  
  // レベル計算
  int calculateLevel(int totalGiftValue) {
    for (int level = 10; level >= 1; level--) {
      if (totalGiftValue >= FanClubMembership.getLevelThreshold(level)) {
        return level;
      }
    }
    return 1;
  }
  
  // 次のレベルまでに必要な金額
  int getPointsToNextLevel(int currentTotalGiftValue, int currentLevel) {
    if (currentLevel >= 10) return 0;
    
    final nextThreshold = FanClubMembership.getLevelThreshold(currentLevel + 1);
    return nextThreshold - currentTotalGiftValue;
  }
  
  // スタッフの全ファンクラブメンバーを取得
  Future<List<FanClubMembership>> getStaffFanMembers(String staffId) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final members = <FanClubMembership>[];
    
    for (var key in keys) {
      if (key.startsWith(_keyPrefix) && key.endsWith('_$staffId')) {
        final jsonString = prefs.getString(key);
        if (jsonString != null) {
          try {
            final json = jsonDecode(jsonString) as Map<String, dynamic>;
            members.add(FanClubMembership.fromJson(json));
          } catch (e) {
            // Skip invalid entries
          }
        }
      }
    }
    
    // レベルとポイントでソート
    members.sort((a, b) {
      final levelCompare = b.memberLevel.compareTo(a.memberLevel);
      if (levelCompare != 0) return levelCompare;
      return b.totalGiftValue.compareTo(a.totalGiftValue);
    });
    
    return members;
  }
}
