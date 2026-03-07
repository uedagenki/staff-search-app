/// TikTok形式のライブ配信リーグシステムとかけらシステム

/// リーグランク（TikTok準拠）
enum LeagueRank {
  bronze('ブロンズ', 0, 999, '🥉'),
  silver('シルバー', 1000, 4999, '🥈'),
  gold('ゴールド', 5000, 19999, '🥇'),
  platinum('プラチナ', 20000, 49999, '💎'),
  diamond('ダイヤモンド', 50000, 99999, '💠'),
  master('マスター', 100000, 499999, '👑'),
  grandmaster('グランドマスター', 500000, 999999, '⭐'),
  legend('レジェンド', 1000000, 999999999, '🏆');

  final String name;
  final int minCoins;
  final int maxCoins;
  final String emoji;

  const LeagueRank(this.name, this.minCoins, this.maxCoins, this.emoji);

  /// コイン数からリーグランクを判定
  static LeagueRank fromCoins(int coins) {
    if (coins < 1000) return LeagueRank.bronze;
    if (coins < 5000) return LeagueRank.silver;
    if (coins < 20000) return LeagueRank.gold;
    if (coins < 50000) return LeagueRank.platinum;
    if (coins < 100000) return LeagueRank.diamond;
    if (coins < 500000) return LeagueRank.master;
    if (coins < 1000000) return LeagueRank.grandmaster;
    return LeagueRank.legend;
  }

  /// 次のリーグまでに必要なコイン数
  int coinsToNextLeague(int currentCoins) {
    if (this == LeagueRank.legend) return 0;
    return maxCoins - currentCoins + 1;
  }

  /// リーグランクのカラー
  String get colorHex {
    switch (this) {
      case LeagueRank.bronze:
        return '#CD7F32';
      case LeagueRank.silver:
        return '#C0C0C0';
      case LeagueRank.gold:
        return '#FFD700';
      case LeagueRank.platinum:
        return '#E5E4E2';
      case LeagueRank.diamond:
        return '#B9F2FF';
      case LeagueRank.master:
        return '#9370DB';
      case LeagueRank.grandmaster:
        return '#FF1493';
      case LeagueRank.legend:
        return '#FF4500';
    }
  }
}

/// かけら（シャード）システム - TikTok形式
class LiveShard {
  final String id;
  final String userId;
  final String staffId;
  final int shardCount; // かけら数
  final DateTime earnedAt;
  final String source; // 'gift', 'daily_bonus', 'event'
  final int giftCoins; // 投げ銭コイン数（sourceがgiftの場合）

  LiveShard({
    required this.id,
    required this.userId,
    required this.staffId,
    required this.shardCount,
    required this.earnedAt,
    required this.source,
    this.giftCoins = 0,
  });

  factory LiveShard.fromJson(Map<String, dynamic> json) {
    return LiveShard(
      id: json['id'] as String,
      userId: json['userId'] as String,
      staffId: json['staffId'] as String,
      shardCount: json['shardCount'] as int,
      earnedAt: DateTime.parse(json['earnedAt'] as String),
      source: json['source'] as String,
      giftCoins: json['giftCoins'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'staffId': staffId,
      'shardCount': shardCount,
      'earnedAt': earnedAt.toIso8601String(),
      'source': source,
      'giftCoins': giftCoins,
    };
  }
}

/// ライバー（スタッフ）のリーグ情報
class LiverLeagueInfo {
  final String staffId;
  final String staffName;
  final LeagueRank currentLeague;
  final int totalCoinsReceived; // 受け取った総コイン数
  final int weeklyCoins; // 今週受け取ったコイン数
  final int monthlyCoins; // 今月受け取ったコイン数
  final int rank; // リーグ内順位
  final int totalShards; // 獲得したかけら総数
  final DateTime lastUpdated;

  LiverLeagueInfo({
    required this.staffId,
    required this.staffName,
    required this.currentLeague,
    required this.totalCoinsReceived,
    required this.weeklyCoins,
    required this.monthlyCoins,
    required this.rank,
    required this.totalShards,
    required this.lastUpdated,
  });

  /// 次のリーグまでの進捗率（0.0 - 1.0）
  double get progressToNextLeague {
    if (currentLeague == LeagueRank.legend) return 1.0;
    final coinsInCurrentLeague = totalCoinsReceived - currentLeague.minCoins;
    final coinsNeededForLeague =
        currentLeague.maxCoins - currentLeague.minCoins + 1;
    return (coinsInCurrentLeague / coinsNeededForLeague).clamp(0.0, 1.0);
  }

  factory LiverLeagueInfo.fromJson(Map<String, dynamic> json) {
    return LiverLeagueInfo(
      staffId: json['staffId'] as String,
      staffName: json['staffName'] as String,
      currentLeague: LeagueRank.values.firstWhere(
        (e) => e.name == json['currentLeague'],
        orElse: () => LeagueRank.bronze,
      ),
      totalCoinsReceived: json['totalCoinsReceived'] as int,
      weeklyCoins: json['weeklyCoins'] as int,
      monthlyCoins: json['monthlyCoins'] as int,
      rank: json['rank'] as int,
      totalShards: json['totalShards'] as int,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staffId': staffId,
      'staffName': staffName,
      'currentLeague': currentLeague.name,
      'totalCoinsReceived': totalCoinsReceived,
      'weeklyCoins': weeklyCoins,
      'monthlyCoins': monthlyCoins,
      'rank': rank,
      'totalShards': totalShards,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

/// ギフター（投げ銭する側）のリーグ情報
class GifterLeagueInfo {
  final String userId;
  final String userName;
  final LeagueRank currentLeague;
  final int totalCoinsSent; // 送った総コイン数
  final int weeklyCoinsSent; // 今週送ったコイン数
  final int monthlyCoinsSent; // 今月送ったコイン数
  final int rank; // リーグ内順位
  final Map<String, int> favoriteStaffs; // スタッフID -> 送ったコイン数
  final DateTime lastUpdated;

  GifterLeagueInfo({
    required this.userId,
    required this.userName,
    required this.currentLeague,
    required this.totalCoinsSent,
    required this.weeklyCoinsSent,
    required this.monthlyCoinsSent,
    required this.rank,
    required this.favoriteStaffs,
    required this.lastUpdated,
  });

  /// 次のリーグまでの進捗率
  double get progressToNextLeague {
    if (currentLeague == LeagueRank.legend) return 1.0;
    final coinsInCurrentLeague = totalCoinsSent - currentLeague.minCoins;
    final coinsNeededForLeague =
        currentLeague.maxCoins - currentLeague.minCoins + 1;
    return (coinsInCurrentLeague / coinsNeededForLeague).clamp(0.0, 1.0);
  }

  factory GifterLeagueInfo.fromJson(Map<String, dynamic> json) {
    return GifterLeagueInfo(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      currentLeague: LeagueRank.values.firstWhere(
        (e) => e.name == json['currentLeague'],
        orElse: () => LeagueRank.bronze,
      ),
      totalCoinsSent: json['totalCoinsSent'] as int,
      weeklyCoinsSent: json['weeklyCoinsSent'] as int,
      monthlyCoinsSent: json['monthlyCoinsSent'] as int,
      rank: json['rank'] as int,
      favoriteStaffs: Map<String, int>.from(json['favoriteStaffs'] as Map),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'currentLeague': currentLeague.name,
      'totalCoinsSent': totalCoinsSent,
      'weeklyCoinsSent': weeklyCoinsSent,
      'monthlyCoinsSent': monthlyCoinsSent,
      'rank': rank,
      'favoriteStaffs': favoriteStaffs,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

/// リーグランキング
class LeagueRanking {
  final LeagueRank league;
  final List<LiverLeagueInfo> liverRankings;
  final List<GifterLeagueInfo> gifterRankings;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String period; // 'weekly', 'monthly', 'all_time'

  LeagueRanking({
    required this.league,
    required this.liverRankings,
    required this.gifterRankings,
    required this.periodStart,
    required this.periodEnd,
    required this.period,
  });

  factory LeagueRanking.fromJson(Map<String, dynamic> json) {
    return LeagueRanking(
      league: LeagueRank.values.firstWhere(
        (e) => e.name == json['league'],
        orElse: () => LeagueRank.bronze,
      ),
      liverRankings: (json['liverRankings'] as List)
          .map((e) => LiverLeagueInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      gifterRankings: (json['gifterRankings'] as List)
          .map((e) => GifterLeagueInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      period: json['period'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'league': league.name,
      'liverRankings': liverRankings.map((e) => e.toJson()).toList(),
      'gifterRankings': gifterRankings.map((e) => e.toJson()).toList(),
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'period': period,
    };
  }
}

/// かけら獲得設定（投げ銭金額に応じて）
class ShardRewardConfig {
  static const Map<int, int> coinToShardMap = {
    100: 1, // 100コイン投げ銭で1かけら
    500: 6, // 500コイン投げ銭で6かけら（ボーナス+1）
    1000: 15, // 1000コイン投げ銭で15かけら（ボーナス+5）
    5000: 80, // 5000コイン投げ銭で80かけら（ボーナス+30）
    10000: 170, // 10000コイン投げ銭で170かけら（ボーナス+70）
  };

  /// 投げ銭金額からかけら数を計算
  static int calculateShards(int coins) {
    // 完全一致する場合
    if (coinToShardMap.containsKey(coins)) {
      return coinToShardMap[coins]!;
    }

    // 基本レート: 100コインあたり1かけら
    int baseShards = coins ~/ 100;

    // ボーナス計算（大きい投げ銭ほどボーナス率が高い）
    double bonusRate = 0.0;
    if (coins >= 10000) {
      bonusRate = 0.7; // 70%ボーナス
    } else if (coins >= 5000) {
      bonusRate = 0.6; // 60%ボーナス
    } else if (coins >= 1000) {
      bonusRate = 0.5; // 50%ボーナス
    } else if (coins >= 500) {
      bonusRate = 0.2; // 20%ボーナス
    }

    int bonusShards = (baseShards * bonusRate).round();
    return baseShards + bonusShards;
  }

  /// かけらを特典に交換（例: 100かけらで特別アイテム）
  static Map<int, String> get shardRewards => {
        50: '🎁 ブロンズバッジ',
        100: '🎁 シルバーバッジ',
        500: '🎁 ゴールドバッジ',
        1000: '🎁 限定スタンプセット',
        5000: '🎁 プラチナフレーム',
        10000: '🎁 ダイヤモンドアイコン',
      };
}
