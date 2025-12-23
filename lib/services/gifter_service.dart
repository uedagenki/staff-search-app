import 'dart:html' as html;
import 'dart:convert';
import '../models/gifter_level.dart';

class GifterService {
  static const String _storageKey = 'user_gifter_info';

  // ギフター情報を取得
  static UserGifterInfo getGifterInfo() {
    try {
      final jsonString = html.window.localStorage[_storageKey];
      if (jsonString != null) {
        final data = json.decode(jsonString) as Map<String, dynamic>;
        return UserGifterInfo(
          userId: data['userId'] ?? 'demo_user',
          totalExp: data['totalExp'] ?? 0,
          totalGiftAmount: data['totalGiftAmount'] ?? 0,
          giftCount: data['giftCount'] ?? 0,
          lastGiftDate: data['lastGiftDate'] != null
              ? DateTime.parse(data['lastGiftDate'])
              : DateTime.now(),
          staffGiftHistory: Map<String, int>.from(data['staffGiftHistory'] ?? {}),
        );
      }
    } catch (e) {
      print('Failed to load gifter info: $e');
    }
    
    // デフォルト値を返す
    return UserGifterInfo(
      userId: 'demo_user',
      totalExp: 0,
      totalGiftAmount: 0,
      giftCount: 0,
      lastGiftDate: DateTime.now(),
      staffGiftHistory: {},
    );
  }

  // ギフター情報を保存
  static void saveGifterInfo(UserGifterInfo info) {
    try {
      final data = {
        'userId': info.userId,
        'totalExp': info.totalExp,
        'totalGiftAmount': info.totalGiftAmount,
        'giftCount': info.giftCount,
        'lastGiftDate': info.lastGiftDate.toIso8601String(),
        'staffGiftHistory': info.staffGiftHistory,
      };
      html.window.localStorage[_storageKey] = json.encode(data);
    } catch (e) {
      print('Failed to save gifter info: $e');
    }
  }

  // ギフト送信時にEXPを追加
  static UserGifterInfo addGiftExp(String staffId, int giftAmount) {
    final currentInfo = getGifterInfo();
    
    // 新しいギフター情報を作成
    final newStaffGiftHistory = Map<String, int>.from(currentInfo.staffGiftHistory);
    newStaffGiftHistory[staffId] = (newStaffGiftHistory[staffId] ?? 0) + giftAmount;
    
    final newInfo = UserGifterInfo(
      userId: currentInfo.userId,
      totalExp: currentInfo.totalExp + GifterLevel.calculateExpFromGiftAmount(giftAmount),
      totalGiftAmount: currentInfo.totalGiftAmount + giftAmount,
      giftCount: currentInfo.giftCount + 1,
      lastGiftDate: DateTime.now(),
      staffGiftHistory: newStaffGiftHistory,
    );
    
    // 保存
    saveGifterInfo(newInfo);
    
    return newInfo;
  }

  // レベルアップチェック
  static bool checkLevelUp(int oldExp, int newExp) {
    final oldLevel = GifterLevel.getLevelFromExp(oldExp);
    final newLevel = GifterLevel.getLevelFromExp(newExp);
    return newLevel.level > oldLevel.level;
  }

  // ギフター情報をリセット（デバッグ用）
  static void resetGifterInfo() {
    html.window.localStorage.remove(_storageKey);
  }
}
