import 'package:flutter/material.dart';
import '../models/live_collab_system.dart';
import '../services/live_collab_service.dart';
import '../services/local_auth_service.dart';
import 'live_collab_battle_screen.dart';

/// コラボ・バトル作成画面
class CreateCollabScreen extends StatefulWidget {
  final CollabMode initialMode;
  final bool autoStartIfSolo;

  const CreateCollabScreen({
    super.key,
    this.initialMode = CollabMode.solo,
    this.autoStartIfSolo = false,
  });

  @override
  State<CreateCollabScreen> createState() => _CreateCollabScreenState();
}

class _CreateCollabScreenState extends State<CreateCollabScreen> {
  final _collabService = LiveCollabService();
  final _authService = LocalAuthService();

  late CollabMode _selectedMode;
  BattleType _selectedBattleType = BattleType.none;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode;

    // ソロモードで自動開始フラグがある場合は即座に配信開始
    if (widget.autoStartIfSolo && _selectedMode == CollabMode.solo) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _createSession();
      });
    }
  }

  Future<void> _createSession() async {
    setState(() => _isCreating = true);

    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ログインが必要です'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final session = await _collabService.createCollabSession(
        hostUserId: user.id,
        hostUserName: user.name ?? 'ユーザー',
        mode: _selectedMode,
        battleType: _selectedBattleType,
      );

      // 視聴者カウントを開始
      await _collabService.addViewer(session.sessionId, user.id);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LiveCollabBattleScreen(
              sessionId: session.sessionId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('作成に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎥 ライブ配信を開始'),
      ),
      body: _isCreating
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModeSelection(),
                  const SizedBox(height: 24),
                  _buildBattleTypeSelection(),
                  const SizedBox(height: 32),
                  _buildStartButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildModeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '配信モード',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...CollabMode.values.map((mode) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: _selectedMode == mode
                ? Colors.purple.shade50
                : Colors.white,
            child: ListTile(
              leading: Icon(
                _getModeIcon(mode),
                color: _selectedMode == mode
                    ? Colors.purple
                    : Colors.grey,
              ),
              title: Text(
                mode.name,
                style: TextStyle(
                  fontWeight: _selectedMode == mode
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              subtitle: Text(_getModeDescription(mode)),
              trailing: _selectedMode == mode
                  ? const Icon(Icons.check_circle, color: Colors.purple)
                  : null,
              onTap: () {
                setState(() {
                  _selectedMode = mode;
                  // ソロの場合はバトルをなしに
                  if (mode == CollabMode.solo) {
                    _selectedBattleType = BattleType.none;
                  }
                });
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBattleTypeSelection() {
    if (_selectedMode == CollabMode.solo) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'バトル設定',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...BattleType.values.map((battleType) {
          final isAvailable = _isBattleTypeAvailable(battleType);

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: !isAvailable
                ? Colors.grey.shade200
                : _selectedBattleType == battleType
                    ? Colors.pink.shade50
                    : Colors.white,
            child: ListTile(
              leading: Icon(
                Icons.sports_kabaddi,
                color: !isAvailable
                    ? Colors.grey
                    : _selectedBattleType == battleType
                        ? Colors.pink
                        : Colors.grey,
              ),
              title: Text(
                battleType.name,
                style: TextStyle(
                  fontWeight: _selectedBattleType == battleType
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isAvailable ? Colors.black : Colors.grey,
                ),
              ),
              subtitle: Text(_getBattleTypeDescription(battleType)),
              trailing: _selectedBattleType == battleType
                  ? const Icon(Icons.check_circle, color: Colors.pink)
                  : null,
              onTap: isAvailable
                  ? () {
                      setState(() {
                        _selectedBattleType = battleType;
                      });
                    }
                  : null,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _createSession,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow, size: 28),
            const SizedBox(width: 8),
            Text(
              _selectedBattleType != BattleType.none
                  ? 'バトル配信を開始'
                  : 'ライブ配信を開始',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getModeIcon(CollabMode mode) {
    switch (mode) {
      case CollabMode.solo:
        return Icons.person;
      case CollabMode.duet:
        return Icons.people;
      case CollabMode.trio:
        return Icons.group;
      case CollabMode.squad:
        return Icons.groups;
    }
  }

  String _getModeDescription(CollabMode mode) {
    switch (mode) {
      case CollabMode.solo:
        return '1人で配信';
      case CollabMode.duet:
        return '2人でコラボ配信';
      case CollabMode.trio:
        return '3人でコラボ配信';
      case CollabMode.squad:
        return '4人でコラボ配信';
    }
  }

  String _getBattleTypeDescription(BattleType battleType) {
    switch (battleType) {
      case BattleType.none:
        return 'バトルなしで通常配信';
      case BattleType.oneVsOne:
        return '1対1の投げ銭バトル';
      case BattleType.twoVsTwo:
        return '2対2のチームバトル';
      case BattleType.freeForAll:
        return '4人全員でバトル';
    }
  }

  bool _isBattleTypeAvailable(BattleType battleType) {
    switch (battleType) {
      case BattleType.none:
        return true;
      case BattleType.oneVsOne:
        return _selectedMode == CollabMode.duet;
      case BattleType.twoVsTwo:
        return _selectedMode == CollabMode.squad;
      case BattleType.freeForAll:
        return _selectedMode == CollabMode.squad;
    }
  }
}
