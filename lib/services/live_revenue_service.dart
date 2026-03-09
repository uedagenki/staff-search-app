import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LiveRevenueService {
  static const String _keyPrefix = 'live_revenue_';
  static const String _viewsKey = 'video_views_';
  
  // 再生単価（円/回）- TikTok同様の範囲
  static const double minRevenuePerView = 0.02; // 最小単価
  static const double maxRevenuePerView = 0.08; // 最大単価
  static const double avgRevenuePerView = 0.05; // 平均単価
  
  // ライブギフト収益を記録
  Future<void> recordGiftRevenue({
    required String staffId,
    required int giftAmount,
    required DateTime timestamp,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_keyPrefix}gift_$staffId';
    
    final revenueData = await _getRevenueData(key);
    revenueData['totalGiftRevenue'] = (revenueData['totalGiftRevenue'] as int? ?? 0) + giftAmount;
    
    final history = revenueData['history'] as List? ?? [];
    history.add({
      'type': 'gift',
      'amount': giftAmount,
      'timestamp': timestamp.toIso8601String(),
    });
    revenueData['history'] = history;
    
    await prefs.setString(key, jsonEncode(revenueData));
  }
  
  // 動画再生収益を記録
  Future<void> recordViewRevenue({
    required String staffId,
    required String videoId,
    required int viewCount,
    required double revenuePerView,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_keyPrefix}view_$staffId';
    
    final revenueData = await _getRevenueData(key);
    final revenue = (viewCount * revenuePerView).toInt();
    
    revenueData['totalViewRevenue'] = (revenueData['totalViewRevenue'] as int? ?? 0) + revenue;
    revenueData['totalViews'] = (revenueData['totalViews'] as int? ?? 0) + viewCount;
    
    final history = revenueData['history'] as List? ?? [];
    history.add({
      'type': 'view',
      'videoId': videoId,
      'viewCount': viewCount,
      'revenue': revenue,
      'revenuePerView': revenuePerView,
      'timestamp': DateTime.now().toIso8601String(),
    });
    revenueData['history'] = history;
    
    await prefs.setString(key, jsonEncode(revenueData));
  }
  
  // 総収益を取得
  Future<Map<String, dynamic>> getTotalRevenue(String staffId) async {
    final prefs = await SharedPreferences.getInstance();
    
    final giftKey = '${_keyPrefix}gift_$staffId';
    final viewKey = '${_keyPrefix}view_$staffId';
    
    final giftData = await _getRevenueData(giftKey);
    final viewData = await _getRevenueData(viewKey);
    
    final totalGiftRevenue = giftData['totalGiftRevenue'] as int? ?? 0;
    final totalViewRevenue = viewData['totalViewRevenue'] as int? ?? 0;
    final totalViews = viewData['totalViews'] as int? ?? 0;
    
    return {
      'totalRevenue': totalGiftRevenue + totalViewRevenue,
      'giftRevenue': totalGiftRevenue,
      'viewRevenue': totalViewRevenue,
      'totalViews': totalViews,
      'avgRevenuePerView': totalViews > 0 ? totalViewRevenue / totalViews : 0.0,
    };
  }
  
  // 月次収益を取得
  Future<Map<String, dynamic>> getMonthlyRevenue(String staffId, DateTime month) async {
    final prefs = await SharedPreferences.getInstance();
    
    final giftKey = '${_keyPrefix}gift_$staffId';
    final viewKey = '${_keyPrefix}view_$staffId';
    
    final giftData = await _getRevenueData(giftKey);
    final viewData = await _getRevenueData(viewKey);
    
    final giftHistory = giftData['history'] as List? ?? [];
    final viewHistory = viewData['history'] as List? ?? [];
    
    int monthlyGiftRevenue = 0;
    int monthlyViewRevenue = 0;
    int monthlyViews = 0;
    
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    
    for (var item in giftHistory) {
      final timestamp = DateTime.parse(item['timestamp'] as String);
      if (timestamp.isAfter(startOfMonth) && timestamp.isBefore(endOfMonth)) {
        monthlyGiftRevenue += item['amount'] as int;
      }
    }
    
    for (var item in viewHistory) {
      final timestamp = DateTime.parse(item['timestamp'] as String);
      if (timestamp.isAfter(startOfMonth) && timestamp.isBefore(endOfMonth)) {
        monthlyViewRevenue += item['revenue'] as int;
        monthlyViews += item['viewCount'] as int;
      }
    }
    
    return {
      'month': '${month.year}年${month.month}月',
      'totalRevenue': monthlyGiftRevenue + monthlyViewRevenue,
      'giftRevenue': monthlyGiftRevenue,
      'viewRevenue': monthlyViewRevenue,
      'totalViews': monthlyViews,
    };
  }
  
  // 収益履歴を取得
  Future<List<Map<String, dynamic>>> getRevenueHistory(String staffId, {int limit = 50}) async {
    final prefs = await SharedPreferences.getInstance();
    
    final giftKey = '${_keyPrefix}gift_$staffId';
    final viewKey = '${_keyPrefix}view_$staffId';
    
    final giftData = await _getRevenueData(giftKey);
    final viewData = await _getRevenueData(viewKey);
    
    final giftHistory = giftData['history'] as List? ?? [];
    final viewHistory = viewData['history'] as List? ?? [];
    
    final allHistory = <Map<String, dynamic>>[];
    allHistory.addAll(giftHistory.cast<Map<String, dynamic>>());
    allHistory.addAll(viewHistory.cast<Map<String, dynamic>>());
    
    // タイムスタンプでソート
    allHistory.sort((a, b) {
      final aTime = DateTime.parse(a['timestamp'] as String);
      final bTime = DateTime.parse(b['timestamp'] as String);
      return bTime.compareTo(aTime);
    });
    
    return allHistory.take(limit).toList();
  }
  
  // 動画の再生数を記録
  Future<void> incrementVideoViews(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_viewsKey$videoId';
    final currentViews = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, currentViews + 1);
  }
  
  // 動画の再生数を取得
  Future<int> getVideoViews(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_viewsKey$videoId') ?? 0;
  }
  
  // 収益データを取得（内部用）
  Future<Map<String, dynamic>> _getRevenueData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    
    if (jsonString == null) {
      return {
        'totalGiftRevenue': 0,
        'totalViewRevenue': 0,
        'totalViews': 0,
        'history': [],
      };
    }
    
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return {
        'totalGiftRevenue': 0,
        'totalViewRevenue': 0,
        'totalViews': 0,
        'history': [],
      };
    }
  }
  
  // 再生数に基づく収益を計算
  static Map<String, int> calculateRevenueByViews(int views) {
    return {
      'min': (views * minRevenuePerView).toInt(),
      'avg': (views * avgRevenuePerView).toInt(),
      'max': (views * maxRevenuePerView).toInt(),
    };
  }
}
