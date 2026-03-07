/// TikTok形式のライブコラボ・バトルシステム

/// コラボ/バトルモード
enum CollabMode {
  solo('ソロ配信', 1),
  duet('デュエット', 2),
  trio('トリオ', 3),
  squad('スクワッド', 4);

  final String name;
  final int maxParticipants;

  const CollabMode(this.name, this.maxParticipants);
}

/// バトルタイプ
enum BattleType {
  none('バトルなし'),
  oneVsOne('1vs1バトル'),
  twoVsTwo('2vs2バトル'),
  freeForAll('4人バトルロイヤル');

  final String name;

  const BattleType(this.name);
}

/// バトル状態
enum BattleStatus {
  waiting('待機中'),
  ready('準備完了'),
  active('バトル中'),
  finished('終了');

  final String name;

  const BattleStatus(this.name);
}

/// コラボ参加者
class CollabParticipant {
  final String userId;
  final String userName;
  final String? avatarUrl;
  final bool isHost;
  final bool isMuted;
  final bool isCameraOff;
  final DateTime joinedAt;
  final int giftCoinsReceived; // バトル中に受け取ったコイン数

  CollabParticipant({
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.isHost,
    this.isMuted = false,
    this.isCameraOff = false,
    required this.joinedAt,
    this.giftCoinsReceived = 0,
  });

  CollabParticipant copyWith({
    String? userId,
    String? userName,
    String? avatarUrl,
    bool? isHost,
    bool? isMuted,
    bool? isCameraOff,
    DateTime? joinedAt,
    int? giftCoinsReceived,
  }) {
    return CollabParticipant(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isHost: isHost ?? this.isHost,
      isMuted: isMuted ?? this.isMuted,
      isCameraOff: isCameraOff ?? this.isCameraOff,
      joinedAt: joinedAt ?? this.joinedAt,
      giftCoinsReceived: giftCoinsReceived ?? this.giftCoinsReceived,
    );
  }

  factory CollabParticipant.fromJson(Map<String, dynamic> json) {
    return CollabParticipant(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      isHost: json['isHost'] as bool,
      isMuted: json['isMuted'] as bool? ?? false,
      isCameraOff: json['isCameraOff'] as bool? ?? false,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      giftCoinsReceived: json['giftCoinsReceived'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'avatarUrl': avatarUrl,
      'isHost': isHost,
      'isMuted': isMuted,
      'isCameraOff': isCameraOff,
      'joinedAt': joinedAt.toIso8601String(),
      'giftCoinsReceived': giftCoinsReceived,
    };
  }
}

/// ライブコラボセッション
class LiveCollabSession {
  final String sessionId;
  final String hostUserId;
  final CollabMode mode;
  final BattleType battleType;
  final BattleStatus battleStatus;
  final List<CollabParticipant> participants;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int totalViewers; // 合計視聴者数
  final int currentViewers; // 現在の同時視聴者数
  final Duration? battleDuration; // バトル時間（通常3分）
  final DateTime? battleStartTime; // バトル開始時刻

  LiveCollabSession({
    required this.sessionId,
    required this.hostUserId,
    required this.mode,
    this.battleType = BattleType.none,
    this.battleStatus = BattleStatus.waiting,
    required this.participants,
    required this.startedAt,
    this.endedAt,
    this.totalViewers = 0,
    this.currentViewers = 0,
    this.battleDuration,
    this.battleStartTime,
  });

  /// バトルの残り時間
  Duration? get remainingBattleTime {
    if (battleStartTime == null || battleDuration == null) return null;
    final elapsed = DateTime.now().difference(battleStartTime!);
    final remaining = battleDuration! - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// バトル勝者を判定
  CollabParticipant? get battleWinner {
    if (battleStatus != BattleStatus.finished) return null;
    if (participants.isEmpty) return null;

    return participants.reduce((current, next) =>
        current.giftCoinsReceived > next.giftCoinsReceived ? current : next);
  }

  /// チーム別投げ銭合計（2vs2の場合）
  Map<String, int> getTeamScores() {
    if (battleType != BattleType.twoVsTwo || participants.length != 4) {
      return {};
    }

    // チームA: 最初の2人、チームB: 残りの2人
    final teamA = participants.take(2).toList();
    final teamB = participants.skip(2).toList();

    final teamAScore = teamA.fold<int>(
        0, (sum, p) => sum + p.giftCoinsReceived);
    final teamBScore = teamB.fold<int>(
        0, (sum, p) => sum + p.giftCoinsReceived);

    return {
      'teamA': teamAScore,
      'teamB': teamBScore,
    };
  }

  LiveCollabSession copyWith({
    String? sessionId,
    String? hostUserId,
    CollabMode? mode,
    BattleType? battleType,
    BattleStatus? battleStatus,
    List<CollabParticipant>? participants,
    DateTime? startedAt,
    DateTime? endedAt,
    int? totalViewers,
    int? currentViewers,
    Duration? battleDuration,
    DateTime? battleStartTime,
  }) {
    return LiveCollabSession(
      sessionId: sessionId ?? this.sessionId,
      hostUserId: hostUserId ?? this.hostUserId,
      mode: mode ?? this.mode,
      battleType: battleType ?? this.battleType,
      battleStatus: battleStatus ?? this.battleStatus,
      participants: participants ?? this.participants,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      totalViewers: totalViewers ?? this.totalViewers,
      currentViewers: currentViewers ?? this.currentViewers,
      battleDuration: battleDuration ?? this.battleDuration,
      battleStartTime: battleStartTime ?? this.battleStartTime,
    );
  }

  factory LiveCollabSession.fromJson(Map<String, dynamic> json) {
    return LiveCollabSession(
      sessionId: json['sessionId'] as String,
      hostUserId: json['hostUserId'] as String,
      mode: CollabMode.values.firstWhere(
        (e) => e.name == json['mode'],
        orElse: () => CollabMode.solo,
      ),
      battleType: BattleType.values.firstWhere(
        (e) => e.name == json['battleType'],
        orElse: () => BattleType.none,
      ),
      battleStatus: BattleStatus.values.firstWhere(
        (e) => e.name == json['battleStatus'],
        orElse: () => BattleStatus.waiting,
      ),
      participants: (json['participants'] as List)
          .map((e) => CollabParticipant.fromJson(e as Map<String, dynamic>))
          .toList(),
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] != null
          ? DateTime.parse(json['endedAt'] as String)
          : null,
      totalViewers: json['totalViewers'] as int? ?? 0,
      currentViewers: json['currentViewers'] as int? ?? 0,
      battleDuration: json['battleDuration'] != null
          ? Duration(milliseconds: json['battleDuration'] as int)
          : null,
      battleStartTime: json['battleStartTime'] != null
          ? DateTime.parse(json['battleStartTime'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'hostUserId': hostUserId,
      'mode': mode.name,
      'battleType': battleType.name,
      'battleStatus': battleStatus.name,
      'participants': participants.map((e) => e.toJson()).toList(),
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'totalViewers': totalViewers,
      'currentViewers': currentViewers,
      'battleDuration': battleDuration?.inMilliseconds,
      'battleStartTime': battleStartTime?.toIso8601String(),
    };
  }
}

/// コラボ招待
class CollabInvitation {
  final String invitationId;
  final String hostUserId;
  final String hostUserName;
  final String invitedUserId;
  final String sessionId;
  final CollabMode mode;
  final BattleType battleType;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String status; // 'pending', 'accepted', 'declined', 'expired'

  CollabInvitation({
    required this.invitationId,
    required this.hostUserId,
    required this.hostUserName,
    required this.invitedUserId,
    required this.sessionId,
    required this.mode,
    required this.battleType,
    required this.createdAt,
    this.expiresAt,
    this.status = 'pending',
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  factory CollabInvitation.fromJson(Map<String, dynamic> json) {
    return CollabInvitation(
      invitationId: json['invitationId'] as String,
      hostUserId: json['hostUserId'] as String,
      hostUserName: json['hostUserName'] as String,
      invitedUserId: json['invitedUserId'] as String,
      sessionId: json['sessionId'] as String,
      mode: CollabMode.values.firstWhere(
        (e) => e.name == json['mode'],
        orElse: () => CollabMode.duet,
      ),
      battleType: BattleType.values.firstWhere(
        (e) => e.name == json['battleType'],
        orElse: () => BattleType.none,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invitationId': invitationId,
      'hostUserId': hostUserId,
      'hostUserName': hostUserName,
      'invitedUserId': invitedUserId,
      'sessionId': sessionId,
      'mode': mode.name,
      'battleType': battleType.name,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'status': status,
    };
  }
}

/// 視聴者数統計
class ViewerStats {
  final String sessionId;
  final int currentViewers; // 現在の同時視聴者数
  final int peakViewers; // ピーク視聴者数
  final int totalUniqueViewers; // ユニーク視聴者数
  final DateTime lastUpdated;

  ViewerStats({
    required this.sessionId,
    required this.currentViewers,
    required this.peakViewers,
    required this.totalUniqueViewers,
    required this.lastUpdated,
  });

  factory ViewerStats.fromJson(Map<String, dynamic> json) {
    return ViewerStats(
      sessionId: json['sessionId'] as String,
      currentViewers: json['currentViewers'] as int,
      peakViewers: json['peakViewers'] as int,
      totalUniqueViewers: json['totalUniqueViewers'] as int,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'currentViewers': currentViewers,
      'peakViewers': peakViewers,
      'totalUniqueViewers': totalUniqueViewers,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
