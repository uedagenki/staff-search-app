import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// パトロール・安全機能サービス
class PatrolService {
  static const String _keyBlockedUsers = 'blocked_users';
  static const String _keyMutedUsers = 'muted_users';
  static const String _keyReportHistory = 'report_history';
  static const String _keyInteractionLog = 'interaction_log';

  // 禁止ワードリスト（実際はサーバーから取得）
  static const List<String> _bannedWords = [
    // 暴力的な表現
    '殺す', '死ね', '消えろ',
    // 差別的な表現
    '差別', '侮辱',
    // 性的な表現
    '性的', 'アダルト',
    // 個人情報関連
    '住所', '電話番号', '口座',
    // 詐欺関連
    '詐欺', '騙す', '儲かる',
  ];

  /// テキストに禁止ワードが含まれているかチェック
  bool containsBannedWords(String text) {
    final lowerText = text.toLowerCase();
    return _bannedWords.any((word) => lowerText.contains(word.toLowerCase()));
  }

  /// テキストから禁止ワードを検出
  List<String> detectBannedWords(String text) {
    final lowerText = text.toLowerCase();
    return _bannedWords
        .where((word) => lowerText.contains(word.toLowerCase()))
        .toList();
  }

  /// テキストをフィルタリング（禁止ワードを****に置換）
  String filterText(String text) {
    String filtered = text;
    for (final word in _bannedWords) {
      filtered = filtered.replaceAll(
        RegExp(word, caseSensitive: false),
        '*' * word.length,
      );
    }
    return filtered;
  }

  /// ユーザーをブロック
  Future<void> blockUser(String userId, String targetUserId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_keyBlockedUsers}_$userId';
    final blockedList = prefs.getStringList(key) ?? [];
    
    if (!blockedList.contains(targetUserId)) {
      blockedList.add(targetUserId);
      await prefs.setStringList(key, blockedList);
    }

    // ブロックログを記録
    await _logAction(userId, 'block', targetUserId);
  }

  /// ユーザーのブロックを解除
  Future<void> unblockUser(String userId, String targetUserId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_keyBlockedUsers}_$userId';
    final blockedList = prefs.getStringList(key) ?? [];
    
    blockedList.remove(targetUserId);
    await prefs.setStringList(key, blockedList);

    await _logAction(userId, 'unblock', targetUserId);
  }

  /// ブロック済みユーザーリストを取得
  Future<List<String>> getBlockedUsers(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_keyBlockedUsers}_$userId';
    return prefs.getStringList(key) ?? [];
  }

  /// ユーザーがブロック済みかチェック
  Future<bool> isBlocked(String userId, String targetUserId) async {
    final blockedList = await getBlockedUsers(userId);
    return blockedList.contains(targetUserId);
  }

  /// ユーザーをミュート（通知のみオフ）
  Future<void> muteUser(String userId, String targetUserId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_keyMutedUsers}_$userId';
    final mutedList = prefs.getStringList(key) ?? [];
    
    if (!mutedList.contains(targetUserId)) {
      mutedList.add(targetUserId);
      await prefs.setStringList(key, mutedList);
    }
  }

  /// ミュート済みユーザーリストを取得
  Future<List<String>> getMutedUsers(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_keyMutedUsers}_$userId';
    return prefs.getStringList(key) ?? [];
  }

  /// ユーザーを通報
  Future<void> reportUser({
    required String reporterId,
    required String targetUserId,
    required ReportReason reason,
    required String description,
    String? contentId,
  }) async {
    final report = {
      'reporter_id': reporterId,
      'target_user_id': targetUserId,
      'reason': reason.toString(),
      'description': description,
      'content_id': contentId,
      'reported_at': DateTime.now().toIso8601String(),
      'status': 'pending',
    };

    final prefs = await SharedPreferences.getInstance();
    final key = '${_keyReportHistory}_$reporterId';
    final reportsJson = prefs.getString(key) ?? '[]';
    final reports = List<Map<String, dynamic>>.from(jsonDecode(reportsJson));
    reports.add(report);
    
    await prefs.setString(key, jsonEncode(reports));
    await _logAction(reporterId, 'report', targetUserId);
  }

  /// ストーカー行為を検知
  Future<StalkerDetectionResult> detectStalkerBehavior(
    String userId,
    String targetUserId,
  ) async {
    // 最近24時間の相互作用を取得
    final recentInteractions = await _getRecentInteractions(
      userId,
      targetUserId,
      Duration(hours: 24),
    );

    // ストーカー判定基準
    final viewCount = recentInteractions['view'] ?? 0;
    final commentCount = recentInteractions['comment'] ?? 0;
    final dmCount = recentInteractions['dm'] ?? 0;
    final followCount = recentInteractions['follow'] ?? 0;

    // スコア計算
    final score = (viewCount * 1) +
        (commentCount * 3) +
        (dmCount * 5) +
        (followCount * 2);

    final isStalker = score > 50; // 閾値
    final warningLevel = score > 30
        ? StalkerWarningLevel.high
        : score > 15
            ? StalkerWarningLevel.medium
            : StalkerWarningLevel.low;

    return StalkerDetectionResult(
      isStalker: isStalker,
      warningLevel: warningLevel,
      score: score,
      details: {
        'views': viewCount,
        'comments': commentCount,
        'dms': dmCount,
        'follows': followCount,
      },
      recommendation: isStalker
          ? 'このユーザーをブロックすることを推奨します'
          : warningLevel == StalkerWarningLevel.medium
              ? '注意が必要です。不快な場合はブロックを検討してください'
              : null,
    );
  }

  /// 相互作用を記録
  Future<void> logInteraction(
    String userId,
    String targetUserId,
    String interactionType, // 'view', 'comment', 'dm', 'follow', 'like'
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_keyInteractionLog}_$userId';
    final logsJson = prefs.getString(key) ?? '[]';
    final logs = List<Map<String, dynamic>>.from(jsonDecode(logsJson));

    logs.add({
      'target_user_id': targetUserId,
      'type': interactionType,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // 最新1000件のみ保持
    if (logs.length > 1000) {
      logs.removeRange(0, logs.length - 1000);
    }

    await prefs.setString(key, jsonEncode(logs));
  }

  /// 最近の相互作用を取得
  Future<Map<String, int>> _getRecentInteractions(
    String userId,
    String targetUserId,
    Duration duration,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_keyInteractionLog}_$userId';
    final logsJson = prefs.getString(key) ?? '[]';
    final logs = List<Map<String, dynamic>>.from(jsonDecode(logsJson));

    final cutoffTime = DateTime.now().subtract(duration);
    final recentLogs = logs.where((log) {
      final timestamp = DateTime.parse(log['timestamp'] as String);
      return log['target_user_id'] == targetUserId &&
          timestamp.isAfter(cutoffTime);
    }).toList();

    final counts = <String, int>{};
    for (final log in recentLogs) {
      final type = log['type'] as String;
      counts[type] = (counts[type] ?? 0) + 1;
    }

    return counts;
  }

  /// アクションログを記録
  Future<void> _logAction(String userId, String action, String targetId) async {
    // 実際のアプリでは、サーバーにログを送信
    final prefs = await SharedPreferences.getInstance();
    final key = 'action_log_$userId';
    final logsJson = prefs.getString(key) ?? '[]';
    final logs = List<Map<String, dynamic>>.from(jsonDecode(logsJson));

    logs.add({
      'action': action,
      'target_id': targetId,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (logs.length > 100) {
      logs.removeRange(0, logs.length - 100);
    }

    await prefs.setString(key, jsonEncode(logs));
  }

  /// 通報履歴を取得
  Future<List<Map<String, dynamic>>> getReportHistory(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_keyReportHistory}_$userId';
    final reportsJson = prefs.getString(key) ?? '[]';
    return List<Map<String, dynamic>>.from(jsonDecode(reportsJson));
  }
}

/// 通報理由
enum ReportReason {
  spam, // スパム
  harassment, // ハラスメント
  hate, // ヘイトスピーチ
  violence, // 暴力的コンテンツ
  nudity, // ヌード・性的コンテンツ
  falseInfo, // 虚偽情報
  copyright, // 著作権侵害
  privacy, // プライバシー侵害
  underage, // 未成年者の不適切な利用
  other, // その他
}

/// ストーカー警告レベル
enum StalkerWarningLevel {
  low,
  medium,
  high,
}

/// ストーカー検知結果
class StalkerDetectionResult {
  final bool isStalker;
  final StalkerWarningLevel warningLevel;
  final int score;
  final Map<String, int> details;
  final String? recommendation;

  StalkerDetectionResult({
    required this.isStalker,
    required this.warningLevel,
    required this.score,
    required this.details,
    this.recommendation,
  });

  Map<String, dynamic> toJson() {
    return {
      'is_stalker': isStalker,
      'warning_level': warningLevel.toString(),
      'score': score,
      'details': details,
      'recommendation': recommendation,
    };
  }
}
