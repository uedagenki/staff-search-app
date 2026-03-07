import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../models/live_collab_system.dart';
import '../services/live_collab_service.dart';
import '../services/local_auth_service.dart';

/// TikTok形式のコラボ・バトルライブ配信画面
class LiveCollabBattleScreen extends StatefulWidget {
  final String sessionId;

  const LiveCollabBattleScreen({
    super.key,
    required this.sessionId,
  });

  @override
  State<LiveCollabBattleScreen> createState() => _LiveCollabBattleScreenState();
}

class _LiveCollabBattleScreenState extends State<LiveCollabBattleScreen> {
  final _collabService = LiveCollabService();
  final _authService = LocalAuthService();

  LiveCollabSession? _session;
  Timer? _battleTimer;
  Timer? _viewerUpdateTimer;
  Duration _remainingTime = Duration.zero;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSession();
    _startViewerUpdates();
  }

  @override
  void dispose() {
    _battleTimer?.cancel();
    _viewerUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSession() async {
    setState(() => _isLoading = true);

    try {
      final session = await _collabService.getSession(widget.sessionId);
      setState(() {
        _session = session;
      });

      // バトル中の場合、タイマーを開始
      if (session?.battleStatus == BattleStatus.active) {
        _startBattleTimer();
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startBattleTimer() {
    _battleTimer?.cancel();
    _battleTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_session == null) return;

      final remaining = _session!.remainingBattleTime;
      if (remaining == null || remaining.inSeconds <= 0) {
        _finishBattle();
        timer.cancel();
        return;
      }

      setState(() {
        _remainingTime = remaining;
      });
    });
  }

  void _startViewerUpdates() {
    // 10秒ごとに視聴者数をランダム更新（デモ用）
    _viewerUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _simulateViewerChange();
    });
  }

  Future<void> _simulateViewerChange() async {
    if (_session == null) return;

    // ランダムに視聴者数を増減
    final random = DateTime.now().millisecond % 3;
    if (random == 0) {
      await _collabService.addViewer(widget.sessionId, 'viewer_${DateTime.now().millisecond}');
    } else if (random == 1 && _session!.currentViewers > 0) {
      await _collabService.removeViewer(widget.sessionId, 'viewer_${DateTime.now().millisecond}');
    }

    await _loadSession();
  }

  Future<void> _startBattle() async {
    await _collabService.startBattle(widget.sessionId);
    await _loadSession();
    _startBattleTimer();
  }

  Future<void> _finishBattle() async {
    await _collabService.finishBattle(widget.sessionId);
    await _loadSession();
    _showBattleResult();
  }

  void _showBattleResult() {
    if (_session == null) return;

    final winner = _session!.battleWinner;
    if (winner == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🏆 バトル終了！'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '勝者',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              winner.userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${NumberFormat('#,###').format(winner.giftCoinsReceived)} コイン',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _session == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildVideoGrid(),
          _buildTopBar(),
          if (_session!.battleType != BattleType.none) _buildBattleInfo(),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildVideoGrid() {
    final participants = _session!.participants;
    final mode = _session!.mode;

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: mode == CollabMode.solo ? 1 : 2,
        childAspectRatio: mode == CollabMode.solo ? 9 / 16 : 9 / 16,
      ),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        return _buildParticipantVideo(participants[index]);
      },
    );
  }

  Widget _buildParticipantVideo(CollabParticipant participant) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: participant.isHost ? Colors.amber : Colors.white24,
          width: participant.isHost ? 3 : 1,
        ),
      ),
      child: Stack(
        children: [
          // ビデオプレースホルダー
          Center(
            child: Icon(
              participant.isCameraOff ? Icons.videocam_off : Icons.person,
              size: 64,
              color: Colors.white54,
            ),
          ),

          // ユーザー情報
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  if (participant.isHost)
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                  if (participant.isHost) const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      participant.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (participant.isMuted)
                    const Icon(Icons.mic_off, color: Colors.red, size: 16),
                ],
              ),
            ),
          ),

          // バトルスコア
          if (_session!.battleType != BattleType.none)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.pink.shade400],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  NumberFormat('#,###').format(participant.giftCoinsReceived),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 視聴者数表示
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.visibility, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _formatViewerCount(_session!.currentViewers),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // コラボモード表示
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _session!.mode.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Spacer(),

              // 閉じるボタン
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBattleInfo() {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade600, Colors.pink.shade600],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.shade200,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sports_kabaddi, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _session!.battleType.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (_session!.battleStatus == BattleStatus.active) ...[
                const SizedBox(height: 8),
                Text(
                  _formatDuration(_remainingTime),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ] else if (_session!.battleStatus == BattleStatus.waiting) ...[
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _startBattle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple,
                  ),
                  child: const Text('バトル開始'),
                ),
              ] else if (_session!.battleStatus == BattleStatus.finished) ...[
                const SizedBox(height: 8),
                const Text(
                  '終了',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
          child: Row(
            children: [
              // コメント入力
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'コメントを入力...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 投げ銭ボタン
              IconButton(
                onPressed: _showGiftDialog,
                icon: const Icon(Icons.card_giftcard, color: Colors.amber, size: 32),
              ),

              // シェアボタン
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share, color: Colors.white, size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatViewerCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showGiftDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '投げ銭を送る',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('対象を選択してください'),
            const SizedBox(height: 16),
            ..._session!.participants.map((p) => ListTile(
                  title: Text(p.userName),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: 投げ銭処理を実装
                  },
                )),
          ],
        ),
      ),
    );
  }
}
