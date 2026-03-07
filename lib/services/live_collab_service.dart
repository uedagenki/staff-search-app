import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/live_collab_system.dart';

/// ライブコラボ・バトル管理サービス
class LiveCollabService {
  static const String _sessionsKey = 'live_collab_sessions';
  static const String _invitationsKey = 'collab_invitations';
  static const String _viewerStatsKey = 'viewer_stats';

  // ========== セッション管理 ==========

  /// コラボセッションを作成
  Future<LiveCollabSession> createCollabSession({
    required String hostUserId,
    required String hostUserName,
    required CollabMode mode,
    BattleType battleType = BattleType.none,
  }) async {
    final sessionId = 'collab_${DateTime.now().millisecondsSinceEpoch}';

    final hostParticipant = CollabParticipant(
      userId: hostUserId,
      userName: hostUserName,
      isHost: true,
      joinedAt: DateTime.now(),
    );

    final session = LiveCollabSession(
      sessionId: sessionId,
      hostUserId: hostUserId,
      mode: mode,
      battleType: battleType,
      participants: [hostParticipant],
      startedAt: DateTime.now(),
      battleDuration: battleType != BattleType.none
          ? const Duration(minutes: 3)
          : null,
    );

    await _saveSession(session);
    return session;
  }

  /// 参加者を追加
  Future<LiveCollabSession> addParticipant({
    required String sessionId,
    required String userId,
    required String userName,
    String? avatarUrl,
  }) async {
    final session = await getSession(sessionId);
    if (session == null) {
      throw Exception('Session not found');
    }

    if (session.participants.length >= session.mode.maxParticipants) {
      throw Exception('Session is full');
    }

    final newParticipant = CollabParticipant(
      userId: userId,
      userName: userName,
      avatarUrl: avatarUrl,
      isHost: false,
      joinedAt: DateTime.now(),
    );

    final updatedParticipants = [...session.participants, newParticipant];

    final updatedSession = session.copyWith(
      participants: updatedParticipants,
    );

    await _saveSession(updatedSession);
    return updatedSession;
  }

  /// 参加者を削除
  Future<LiveCollabSession> removeParticipant({
    required String sessionId,
    required String userId,
  }) async {
    final session = await getSession(sessionId);
    if (session == null) {
      throw Exception('Session not found');
    }

    final updatedParticipants = session.participants
        .where((p) => p.userId != userId)
        .toList();

    final updatedSession = session.copyWith(
      participants: updatedParticipants,
    );

    await _saveSession(updatedSession);
    return updatedSession;
  }

  /// バトルを開始
  Future<LiveCollabSession> startBattle(String sessionId) async {
    final session = await getSession(sessionId);
    if (session == null) {
      throw Exception('Session not found');
    }

    if (session.battleType == BattleType.none) {
      throw Exception('This session has no battle mode');
    }

    final updatedSession = session.copyWith(
      battleStatus: BattleStatus.active,
      battleStartTime: DateTime.now(),
    );

    await _saveSession(updatedSession);
    return updatedSession;
  }

  /// バトルを終了
  Future<LiveCollabSession> finishBattle(String sessionId) async {
    final session = await getSession(sessionId);
    if (session == null) {
      throw Exception('Session not found');
    }

    final updatedSession = session.copyWith(
      battleStatus: BattleStatus.finished,
    );

    await _saveSession(updatedSession);
    return updatedSession;
  }

  /// 投げ銭を記録（バトル用）
  Future<LiveCollabSession> recordGiftForBattle({
    required String sessionId,
    required String participantUserId,
    required int coins,
  }) async {
    final session = await getSession(sessionId);
    if (session == null) {
      throw Exception('Session not found');
    }

    final updatedParticipants = session.participants.map((p) {
      if (p.userId == participantUserId) {
        return p.copyWith(
          giftCoinsReceived: p.giftCoinsReceived + coins,
        );
      }
      return p;
    }).toList();

    final updatedSession = session.copyWith(
      participants: updatedParticipants,
    );

    await _saveSession(updatedSession);
    return updatedSession;
  }

  /// セッションを取得
  Future<LiveCollabSession?> getSession(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getString(_sessionsKey);

    if (sessionsJson == null) return null;

    final List<dynamic> sessionsList = jsonDecode(sessionsJson);
    final sessionData = sessionsList.firstWhere(
      (s) => s['sessionId'] == sessionId,
      orElse: () => null,
    );

    if (sessionData == null) return null;

    return LiveCollabSession.fromJson(sessionData as Map<String, dynamic>);
  }

  /// セッションを保存
  Future<void> _saveSession(LiveCollabSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getString(_sessionsKey);

    List<dynamic> sessionsList = [];
    if (sessionsJson != null) {
      sessionsList = jsonDecode(sessionsJson);
    }

    // 既存のセッションを更新または新規追加
    final existingIndex = sessionsList.indexWhere(
      (s) => s['sessionId'] == session.sessionId,
    );

    if (existingIndex != -1) {
      sessionsList[existingIndex] = session.toJson();
    } else {
      sessionsList.add(session.toJson());
    }

    await prefs.setString(_sessionsKey, jsonEncode(sessionsList));
  }

  /// 全セッションを取得
  Future<List<LiveCollabSession>> getAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getString(_sessionsKey);

    if (sessionsJson == null) return [];

    final List<dynamic> sessionsList = jsonDecode(sessionsJson);
    return sessionsList
        .map((e) => LiveCollabSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ========== 招待管理 ==========

  /// 招待を送信
  Future<CollabInvitation> sendInvitation({
    required String hostUserId,
    required String hostUserName,
    required String invitedUserId,
    required String sessionId,
    required CollabMode mode,
    required BattleType battleType,
  }) async {
    final invitationId = 'invite_${DateTime.now().millisecondsSinceEpoch}';

    final invitation = CollabInvitation(
      invitationId: invitationId,
      hostUserId: hostUserId,
      hostUserName: hostUserName,
      invitedUserId: invitedUserId,
      sessionId: sessionId,
      mode: mode,
      battleType: battleType,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );

    await _saveInvitation(invitation);
    return invitation;
  }

  /// 招待を承諾
  Future<void> acceptInvitation(String invitationId) async {
    final invitation = await getInvitation(invitationId);
    if (invitation == null) return;

    final updatedInvitation = CollabInvitation(
      invitationId: invitation.invitationId,
      hostUserId: invitation.hostUserId,
      hostUserName: invitation.hostUserName,
      invitedUserId: invitation.invitedUserId,
      sessionId: invitation.sessionId,
      mode: invitation.mode,
      battleType: invitation.battleType,
      createdAt: invitation.createdAt,
      expiresAt: invitation.expiresAt,
      status: 'accepted',
    );

    await _saveInvitation(updatedInvitation);
  }

  /// 招待を拒否
  Future<void> declineInvitation(String invitationId) async {
    final invitation = await getInvitation(invitationId);
    if (invitation == null) return;

    final updatedInvitation = CollabInvitation(
      invitationId: invitation.invitationId,
      hostUserId: invitation.hostUserId,
      hostUserName: invitation.hostUserName,
      invitedUserId: invitation.invitedUserId,
      sessionId: invitation.sessionId,
      mode: invitation.mode,
      battleType: invitation.battleType,
      createdAt: invitation.createdAt,
      expiresAt: invitation.expiresAt,
      status: 'declined',
    );

    await _saveInvitation(updatedInvitation);
  }

  /// 招待を取得
  Future<CollabInvitation?> getInvitation(String invitationId) async {
    final prefs = await SharedPreferences.getInstance();
    final invitationsJson = prefs.getString(_invitationsKey);

    if (invitationsJson == null) return null;

    final List<dynamic> invitationsList = jsonDecode(invitationsJson);
    final invitationData = invitationsList.firstWhere(
      (i) => i['invitationId'] == invitationId,
      orElse: () => null,
    );

    if (invitationData == null) return null;

    return CollabInvitation.fromJson(invitationData as Map<String, dynamic>);
  }

  /// 招待を保存
  Future<void> _saveInvitation(CollabInvitation invitation) async {
    final prefs = await SharedPreferences.getInstance();
    final invitationsJson = prefs.getString(_invitationsKey);

    List<dynamic> invitationsList = [];
    if (invitationsJson != null) {
      invitationsList = jsonDecode(invitationsJson);
    }

    final existingIndex = invitationsList.indexWhere(
      (i) => i['invitationId'] == invitation.invitationId,
    );

    if (existingIndex != -1) {
      invitationsList[existingIndex] = invitation.toJson();
    } else {
      invitationsList.add(invitation.toJson());
    }

    await prefs.setString(_invitationsKey, jsonEncode(invitationsList));
  }

  /// ユーザーの招待一覧を取得
  Future<List<CollabInvitation>> getUserInvitations(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final invitationsJson = prefs.getString(_invitationsKey);

    if (invitationsJson == null) return [];

    final List<dynamic> invitationsList = jsonDecode(invitationsJson);
    return invitationsList
        .map((e) => CollabInvitation.fromJson(e as Map<String, dynamic>))
        .where((i) => i.invitedUserId == userId && i.status == 'pending')
        .toList();
  }

  // ========== 視聴者数管理 ==========

  /// 視聴者を追加
  Future<ViewerStats> addViewer(String sessionId, String viewerId) async {
    final stats = await getViewerStats(sessionId);

    final updatedStats = ViewerStats(
      sessionId: sessionId,
      currentViewers: stats.currentViewers + 1,
      peakViewers: max(stats.peakViewers, stats.currentViewers + 1),
      totalUniqueViewers: stats.totalUniqueViewers + 1,
      lastUpdated: DateTime.now(),
    );

    await _saveViewerStats(updatedStats);

    // セッションの視聴者数も更新
    final session = await getSession(sessionId);
    if (session != null) {
      final updatedSession = session.copyWith(
        currentViewers: updatedStats.currentViewers,
        totalViewers: updatedStats.totalUniqueViewers,
      );
      await _saveSession(updatedSession);
    }

    return updatedStats;
  }

  /// 視聴者を削除
  Future<ViewerStats> removeViewer(String sessionId, String viewerId) async {
    final stats = await getViewerStats(sessionId);

    final updatedStats = ViewerStats(
      sessionId: sessionId,
      currentViewers: max(0, stats.currentViewers - 1),
      peakViewers: stats.peakViewers,
      totalUniqueViewers: stats.totalUniqueViewers,
      lastUpdated: DateTime.now(),
    );

    await _saveViewerStats(updatedStats);

    // セッションの視聴者数も更新
    final session = await getSession(sessionId);
    if (session != null) {
      final updatedSession = session.copyWith(
        currentViewers: updatedStats.currentViewers,
      );
      await _saveSession(updatedSession);
    }

    return updatedStats;
  }

  /// 視聴者統計を取得
  Future<ViewerStats> getViewerStats(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString('${_viewerStatsKey}_$sessionId');

    if (statsJson == null) {
      return ViewerStats(
        sessionId: sessionId,
        currentViewers: 0,
        peakViewers: 0,
        totalUniqueViewers: 0,
        lastUpdated: DateTime.now(),
      );
    }

    return ViewerStats.fromJson(jsonDecode(statsJson) as Map<String, dynamic>);
  }

  /// 視聴者統計を保存
  Future<void> _saveViewerStats(ViewerStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_viewerStatsKey}_${stats.sessionId}',
      jsonEncode(stats.toJson()),
    );
  }

  // ========== デモデータ作成 ==========

  /// デモコラボセッションを作成
  Future<void> createDemoCollabSessions() async {
    // ソロ配信
    final soloSession = await createCollabSession(
      hostUserId: 'staff_001',
      hostUserName: '山田 花子',
      mode: CollabMode.solo,
    );

    // デュエット（1vs1バトル）
    final duetSession = await createCollabSession(
      hostUserId: 'staff_002',
      hostUserName: '佐藤 美咲',
      mode: CollabMode.duet,
      battleType: BattleType.oneVsOne,
    );

    await addParticipant(
      sessionId: duetSession.sessionId,
      userId: 'staff_003',
      userName: '鈴木 愛',
    );

    // 4人バトル
    final squadSession = await createCollabSession(
      hostUserId: 'staff_004',
      hostUserName: '田中 美優',
      mode: CollabMode.squad,
      battleType: BattleType.freeForAll,
    );

    await addParticipant(
      sessionId: squadSession.sessionId,
      userId: 'staff_005',
      userName: '高橋 さくら',
    );

    await addParticipant(
      sessionId: squadSession.sessionId,
      userId: 'staff_006',
      userName: '伊藤 結衣',
    );

    await addParticipant(
      sessionId: squadSession.sessionId,
      userId: 'staff_007',
      userName: '渡辺 優奈',
    );
  }
}
