import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/gifter_level.dart';

class GifterService {
  static const String _storageKey = 'user_gifter_info';

  // ギフター情報を取得
  Future<UserGifterInfo?> getUserGifterInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_storageKey);
      if (data != null) {
        final json = jsonDecode(data);
        return UserGifterInfo(
          userId: json['userId'] as String,
          totalExp: json['totalExp'] as int,
          totalGiftAmount: json['totalGiftAmount'] as int,
          giftCount: json['giftCount'] as int,
          lastGiftDate: DateTime.parse(json['lastGiftDate'] as String),
          staffGiftHistory: Map<String, int>.from(json['staffGiftHistory'] as Map),
        );
      }
    } catch (e) {
      // エラーは無視してnullを返す
    }
    return null;
  }

  // ギフター情報を保存
  Future<void> saveGifterInfo(UserGifterInfo info) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = {
        'userId': info.userId,
        'totalExp': info.totalExp,
        'totalGiftAmount': info.totalGiftAmount,
        'giftCount': info.giftCount,
        'lastGiftDate': info.lastGiftDate.toIso8601String(),
        'staffGiftHistory': info.staffGiftHistory,
      };
      await prefs.setString(_storageKey, jsonEncode(json));
    } catch (e) {
      // エラーは無視
    }
  }

  // ギフト送信時に経験値を追加
  Future<UserGifterInfo> addGiftExperience(String staffId, int giftAmount) async {
    var info = await getUserGifterInfo();
    
    if (info == null) {
      // 初回ギフト送信
      info = UserGifterInfo(
        userId: 'current_user',
        totalExp: giftAmount,
        totalGiftAmount: giftAmount,
        giftCount: 1,
        lastGiftDate: DateTime.now(),
        staffGiftHistory: {staffId: giftAmount},
      );
    } else {
      // 既存情報を更新
      final newStaffHistory = Map<String, int>.from(info.staffGiftHistory);
      newStaffHistory[staffId] = (newStaffHistory[staffId] ?? 0) + giftAmount;
      
      info = UserGifterInfo(
        userId: info.userId,
        totalExp: info.totalExp + giftAmount,
        totalGiftAmount: info.totalGiftAmount + giftAmount,
        giftCount: info.giftCount + 1,
        lastGiftDate: DateTime.now(),
        staffGiftHistory: newStaffHistory,
      );
    }
    
    await saveGifterInfo(info);
    return info;
  }

  // デモデータをロード
  Future<void> loadDemoData() async {
    final demoInfo = UserGifterInfo.demo();
    await saveGifterInfo(demoInfo);
  }

  // ギフター情報をリセット
  Future<void> resetGifterInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
