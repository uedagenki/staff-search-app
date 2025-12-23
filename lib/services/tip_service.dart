import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/tip_history.dart';

class TipService {
  static const String _tipsKey = 'tip_history';
  static const String _totalKey = 'total_tips_sent';

  // チップ履歴を取得
  Future<List<TipHistory>> getTipHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final tipsJson = prefs.getStringList(_tipsKey) ?? [];
    
    return tipsJson.map((json) {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return TipHistory(
        id: data['id'] as String,
        staffId: data['staffId'] as String,
        staffName: data['staffName'] as String,
        staffImage: data['staffImage'] as String,
        amount: (data['amount'] as num).toDouble(),
        timestamp: DateTime.parse(data['timestamp'] as String),
        message: data['message'] as String?,
      );
    }).toList();
  }

  // チップを送信（履歴に追加）
  Future<void> sendTip(TipHistory tip) async {
    final prefs = await SharedPreferences.getInstance();
    final tipsJson = prefs.getStringList(_tipsKey) ?? [];
    
    final tipData = {
      'id': tip.id,
      'staffId': tip.staffId,
      'staffName': tip.staffName,
      'staffImage': tip.staffImage,
      'amount': tip.amount,
      'timestamp': tip.timestamp.toIso8601String(),
      'message': tip.message,
    };
    
    tipsJson.add(jsonEncode(tipData));
    await prefs.setStringList(_tipsKey, tipsJson);
    
    // 総額を更新
    final currentTotal = await getTotalTipsSent();
    await prefs.setDouble(_totalKey, currentTotal + tip.amount);
  }

  // チップ総額を取得
  Future<double> getTotalTipsSent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_totalKey) ?? 0.0;
  }

  // 初期データを設定（デモ用）
  Future<void> initializeDemoData() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_tipsKey);
    
    if (existing == null || existing.isEmpty) {
      final demoTips = [
        TipHistory(
          id: '1',
          staffId: '2',
          staffName: '田中 美咲',
          staffImage: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
          amount: 1000,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          message: '素敵なヘアスタイルをありがとうございました！',
        ),
        TipHistory(
          id: '2',
          staffId: '1',
          staffName: '佐藤 健',
          staffImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
          amount: 500,
          timestamp: DateTime.now().subtract(const Duration(days: 5)),
          message: '丁寧な説明ありがとうございました',
        ),
        TipHistory(
          id: '3',
          staffId: '7',
          staffName: '中村 大輔',
          staffImage: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400',
          amount: 2000,
          timestamp: DateTime.now().subtract(const Duration(days: 7)),
          message: 'とても効果的なトレーニングでした！',
        ),
        TipHistory(
          id: '4',
          staffId: '4',
          staffName: '鈴木 花子',
          staffImage: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400',
          amount: 1500,
          timestamp: DateTime.now().subtract(const Duration(days: 10)),
          message: 'リラックスできました',
        ),
      ];

      for (final tip in demoTips) {
        await sendTip(tip);
      }
    }
  }
}
