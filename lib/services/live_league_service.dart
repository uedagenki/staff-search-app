import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/live_league_system.dart';

/// ライブ配信リーグシステム管理サービス
class LiveLeagueService {
  static const String _liverLeagueKey = 'liver_league_info';
  static const String _gifterLeagueKey = 'gifter_league_info';
  static const String _shardRecordsKey = 'live_shard_records';
  static const String _leagueRankingsKey = 'league_rankings';

  // ========== ライバー（受け取る側）リーグ管理 ==========

  /// ライバーのリーグ情報を取得
  Future<LiverLeagueInfo> getLiverLeagueInfo(String staffId, String staffName) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('${_liverLeagueKey}_$staffId');

    if (json == null) {
      // 初回はデフォルト情報を作成
      final defaultInfo = LiverLeagueInfo(
        staffId: staffId,
        staffName: staffName,
        currentLeague: LeagueRank.bronze,
        totalCoinsReceived: 0,
        weeklyCoins: 0,
        monthlyCoins: 0,
        rank: 0,
        totalShards: 0,
        lastUpdated: DateTime.now(),
      );
      await _saveLiverLeagueInfo(defaultInfo);
      return defaultInfo;
    }

    return LiverLeagueInfo.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// ライバーのリーグ情報を保存
  Future<void> _saveLiverLeagueInfo(LiverLeagueInfo info) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_liverLeagueKey}_${info.staffId}',
      jsonEncode(info.toJson()),
    );
  }

  /// ライバーが投げ銭を受け取った際の処理
  Future<LiverLeagueInfo> onLiverReceivedGift({
    required String staffId,
    required String staffName,
    required int coins,
  }) async {
    final info = await getLiverLeagueInfo(staffId, staffName);

    final updatedInfo = LiverLeagueInfo(
      staffId: info.staffId,
      staffName: info.staffName,
      currentLeague: LeagueRank.fromCoins(info.totalCoinsReceived + coins),
      totalCoinsReceived: info.totalCoinsReceived + coins,
      weeklyCoins: info.weeklyCoins + coins,
      monthlyCoins: info.monthlyCoins + coins,
      rank: info.rank,
      totalShards: info.totalShards,
      lastUpdated: DateTime.now(),
    );

    await _saveLiverLeagueInfo(updatedInfo);
    return updatedInfo;
  }

  // ========== ギフター（送る側）リーグ管理 ==========

  /// ギフターのリーグ情報を取得
  Future<GifterLeagueInfo> getGifterLeagueInfo(String userId, String userName) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('${_gifterLeagueKey}_$userId');

    if (json == null) {
      final defaultInfo = GifterLeagueInfo(
        userId: userId,
        userName: userName,
        currentLeague: LeagueRank.bronze,
        totalCoinsSent: 0,
        weeklyCoinsSent: 0,
        monthlyCoinsSent: 0,
        rank: 0,
        favoriteStaffs: {},
        lastUpdated: DateTime.now(),
      );
      await _saveGifterLeagueInfo(defaultInfo);
      return defaultInfo;
    }

    return GifterLeagueInfo.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  /// ギフターのリーグ情報を保存
  Future<void> _saveGifterLeagueInfo(GifterLeagueInfo info) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_gifterLeagueKey}_${info.userId}',
      jsonEncode(info.toJson()),
    );
  }

  /// ギフターが投げ銭を送った際の処理
  Future<GifterLeagueInfo> onGifterSentGift({
    required String userId,
    required String userName,
    required String staffId,
    required int coins,
  }) async {
    final info = await getGifterLeagueInfo(userId, userName);

    // お気に入りスタッフの更新
    final updatedFavoriteStaffs = Map<String, int>.from(info.favoriteStaffs);
    updatedFavoriteStaffs[staffId] =
        (updatedFavoriteStaffs[staffId] ?? 0) + coins;

    final updatedInfo = GifterLeagueInfo(
      userId: info.userId,
      userName: info.userName,
      currentLeague: LeagueRank.fromCoins(info.totalCoinsSent + coins),
      totalCoinsSent: info.totalCoinsSent + coins,
      weeklyCoinsSent: info.weeklyCoinsSent + coins,
      monthlyCoinsSent: info.monthlyCoinsSent + coins,
      rank: info.rank,
      favoriteStaffs: updatedFavoriteStaffs,
      lastUpdated: DateTime.now(),
    );

    await _saveGifterLeagueInfo(updatedInfo);
    return updatedInfo;
  }

  // ========== かけらシステム ==========

  /// かけらを獲得（投げ銭時）
  Future<LiveShard> earnShardFromGift({
    required String userId,
    required String staffId,
    required int giftCoins,
  }) async {
    final shardCount = ShardRewardConfig.calculateShards(giftCoins);

    final shard = LiveShard(
      id: 'shard_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      staffId: staffId,
      shardCount: shardCount,
      earnedAt: DateTime.now(),
      source: 'gift',
      giftCoins: giftCoins,
    );

    await _saveShard(shard);
    return shard;
  }

  /// かけらを保存
  Future<void> _saveShard(LiveShard shard) async {
    final prefs = await SharedPreferences.getInstance();
    final allShards = await _getAllShards();
    allShards.add(shard);

    final jsonList = allShards.map((s) => s.toJson()).toList();
    await prefs.setString(_shardRecordsKey, jsonEncode(jsonList));
  }

  /// 全てのかけら記録を取得
  Future<List<LiveShard>> _getAllShards() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_shardRecordsKey);

    if (json == null) return [];

    final List<dynamic> list = jsonDecode(json) as List;
    return list
        .map((e) => LiveShard.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// ユーザーのかけら総数を取得
  Future<int> getUserTotalShards(String userId) async {
    final allShards = await _getAllShards();
    final userShards = allShards.where((s) => s.userId == userId);
    return userShards.fold<int>(0, (sum, shard) => sum + shard.shardCount);
  }

  /// スタッフへのかけら総数を取得
  Future<int> getStaffTotalShards(String staffId) async {
    final allShards = await _getAllShards();
    final staffShards = allShards.where((s) => s.staffId == staffId);
    return staffShards.fold<int>(0, (sum, shard) => sum + shard.shardCount);
  }

  /// かけらの履歴を取得
  Future<List<LiveShard>> getShardHistory({
    String? userId,
    String? staffId,
    int limit = 50,
  }) async {
    final allShards = await _getAllShards();
    var filtered = allShards;

    if (userId != null) {
      filtered = filtered.where((s) => s.userId == userId).toList();
    }
    if (staffId != null) {
      filtered = filtered.where((s) => s.staffId == staffId).toList();
    }

    filtered.sort((a, b) => b.earnedAt.compareTo(a.earnedAt));
    return filtered.take(limit).toList();
  }

  // ========== リーグランキング ==========

  /// リーグランキングを取得（週次）
  Future<LeagueRanking> getWeeklyRanking(LeagueRank league) async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    // 全てのライバー情報を取得
    final liverInfos = await _getAllLiverInfos();
    final filteredLivers = liverInfos
        .where((info) => info.currentLeague == league)
        .toList()
      ..sort((a, b) => b.weeklyCoins.compareTo(a.weeklyCoins));

    // ランクを更新
    for (int i = 0; i < filteredLivers.length; i++) {
      filteredLivers[i] = LiverLeagueInfo(
        staffId: filteredLivers[i].staffId,
        staffName: filteredLivers[i].staffName,
        currentLeague: filteredLivers[i].currentLeague,
        totalCoinsReceived: filteredLivers[i].totalCoinsReceived,
        weeklyCoins: filteredLivers[i].weeklyCoins,
        monthlyCoins: filteredLivers[i].monthlyCoins,
        rank: i + 1,
        totalShards: filteredLivers[i].totalShards,
        lastUpdated: filteredLivers[i].lastUpdated,
      );
    }

    // ギフター情報を取得
    final gifterInfos = await _getAllGifterInfos();
    final filteredGifters = gifterInfos
        .where((info) => info.currentLeague == league)
        .toList()
      ..sort((a, b) => b.weeklyCoinsSent.compareTo(a.weeklyCoinsSent));

    // ランクを更新
    for (int i = 0; i < filteredGifters.length; i++) {
      filteredGifters[i] = GifterLeagueInfo(
        userId: filteredGifters[i].userId,
        userName: filteredGifters[i].userName,
        currentLeague: filteredGifters[i].currentLeague,
        totalCoinsSent: filteredGifters[i].totalCoinsSent,
        weeklyCoinsSent: filteredGifters[i].weeklyCoinsSent,
        monthlyCoinsSent: filteredGifters[i].monthlyCoinsSent,
        rank: i + 1,
        favoriteStaffs: filteredGifters[i].favoriteStaffs,
        lastUpdated: filteredGifters[i].lastUpdated,
      );
    }

    return LeagueRanking(
      league: league,
      liverRankings: filteredLivers,
      gifterRankings: filteredGifters,
      periodStart: weekStart,
      periodEnd: weekEnd,
      period: 'weekly',
    );
  }

  /// 全てのライバー情報を取得
  Future<List<LiverLeagueInfo>> _getAllLiverInfos() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_liverLeagueKey));

    final infos = <LiverLeagueInfo>[];
    for (final key in keys) {
      final json = prefs.getString(key);
      if (json != null) {
        infos.add(
          LiverLeagueInfo.fromJson(jsonDecode(json) as Map<String, dynamic>),
        );
      }
    }

    return infos;
  }

  /// 全てのギフター情報を取得
  Future<List<GifterLeagueInfo>> _getAllGifterInfos() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_gifterLeagueKey));

    final infos = <GifterLeagueInfo>[];
    for (final key in keys) {
      final json = prefs.getString(key);
      if (json != null) {
        infos.add(
          GifterLeagueInfo.fromJson(jsonDecode(json) as Map<String, dynamic>),
        );
      }
    }

    return infos;
  }

  /// デモデータ作成
  Future<void> createDemoLeagueData() async {
    // デモライバー
    await _saveLiverLeagueInfo(LiverLeagueInfo(
      staffId: 'staff_001',
      staffName: '山田 花子',
      currentLeague: LeagueRank.gold,
      totalCoinsReceived: 15000,
      weeklyCoins: 3000,
      monthlyCoins: 8000,
      rank: 1,
      totalShards: 150,
      lastUpdated: DateTime.now(),
    ));

    await _saveLiverLeagueInfo(LiverLeagueInfo(
      staffId: 'staff_002',
      staffName: '佐藤 美咲',
      currentLeague: LeagueRank.silver,
      totalCoinsReceived: 4500,
      weeklyCoins: 1200,
      monthlyCoins: 2500,
      rank: 2,
      totalShards: 80,
      lastUpdated: DateTime.now(),
    ));

    // デモギフター
    await _saveGifterLeagueInfo(GifterLeagueInfo(
      userId: 'user_001',
      userName: '田中 太郎',
      currentLeague: LeagueRank.platinum,
      totalCoinsSent: 35000,
      weeklyCoinsSent: 5000,
      monthlyCoinsSent: 15000,
      rank: 1,
      favoriteStaffs: {'staff_001': 20000, 'staff_002': 15000},
      lastUpdated: DateTime.now(),
    ));
  }

  /// 週次リセット（毎週月曜日に実行）
  Future<void> resetWeeklyStats() async {
    final liverInfos = await _getAllLiverInfos();
    for (final info in liverInfos) {
      final updated = LiverLeagueInfo(
        staffId: info.staffId,
        staffName: info.staffName,
        currentLeague: info.currentLeague,
        totalCoinsReceived: info.totalCoinsReceived,
        weeklyCoins: 0, // リセット
        monthlyCoins: info.monthlyCoins,
        rank: 0,
        totalShards: info.totalShards,
        lastUpdated: DateTime.now(),
      );
      await _saveLiverLeagueInfo(updated);
    }

    final gifterInfos = await _getAllGifterInfos();
    for (final info in gifterInfos) {
      final updated = GifterLeagueInfo(
        userId: info.userId,
        userName: info.userName,
        currentLeague: info.currentLeague,
        totalCoinsSent: info.totalCoinsSent,
        weeklyCoinsSent: 0, // リセット
        monthlyCoinsSent: info.monthlyCoinsSent,
        rank: 0,
        favoriteStaffs: info.favoriteStaffs,
        lastUpdated: DateTime.now(),
      );
      await _saveGifterLeagueInfo(updated);
    }
  }

  /// 月次リセット（毎月1日に実行）
  Future<void> resetMonthlyStats() async {
    final liverInfos = await _getAllLiverInfos();
    for (final info in liverInfos) {
      final updated = LiverLeagueInfo(
        staffId: info.staffId,
        staffName: info.staffName,
        currentLeague: info.currentLeague,
        totalCoinsReceived: info.totalCoinsReceived,
        weeklyCoins: 0,
        monthlyCoins: 0, // リセット
        rank: 0,
        totalShards: info.totalShards,
        lastUpdated: DateTime.now(),
      );
      await _saveLiverLeagueInfo(updated);
    }

    final gifterInfos = await _getAllGifterInfos();
    for (final info in gifterInfos) {
      final updated = GifterLeagueInfo(
        userId: info.userId,
        userName: info.userName,
        currentLeague: info.currentLeague,
        totalCoinsSent: info.totalCoinsSent,
        weeklyCoinsSent: 0,
        monthlyCoinsSent: 0, // リセット
        rank: 0,
        favoriteStaffs: info.favoriteStaffs,
        lastUpdated: DateTime.now(),
      );
      await _saveGifterLeagueInfo(updated);
    }
  }
}
