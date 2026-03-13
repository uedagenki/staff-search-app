// SCREEN: Notification Settings Screen (New) | NOTIF-01
import '../../utils/screen_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  final String userId;

  const NotificationSettingsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> with ScreenLogMixin {
  @override
  String get screenId => 'Notification Settings Screen (New) | NOTIF-01';

  final _notificationService = NotificationService();
  NotificationSettings? _settings;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final settings = await _notificationService.getSettings(widget.userId);
      if (mounted) {
        setState(() {
          _settings = settings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load settings: $e');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    if (_settings == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _notificationService.saveSettings(_settings!);
      
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('設定を保存しました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save settings: $e');
      }
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('通知設定'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_settings == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('通知設定'),
        ),
        body: const Center(
          child: Text('設定の読み込みに失敗しました'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('通知設定'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        children: [
          // 通知全般
          SwitchListTile(
            title: const Text('プッシュ通知を有効にする'),
            subtitle: const Text('すべての通知のON/OFF'),
            value: _settings!.isEnabled,
            onChanged: (value) {
              setState(() {
                _settings!.isEnabled = value;
              });
              _saveSettings();
            },
          ),
          const Divider(),

          // 通知種類
          if (_settings!.isEnabled) ...[
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '通知の種類',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            SwitchListTile(
              title: const Text('新着メッセージ'),
              subtitle: const Text('チャットメッセージが届いた時'),
              value: _settings!.newMessages,
              onChanged: (value) {
                setState(() {
                  _settings!.newMessages = value;
                });
                _saveSettings();
              },
            ),

            SwitchListTile(
              title: const Text('ライブ配信開始'),
              subtitle: const Text('フォロー中のスタッフがライブ配信を開始した時'),
              value: _settings!.liveStart,
              onChanged: (value) {
                setState(() {
                  _settings!.liveStart = value;
                });
                _saveSettings();
              },
            ),

            SwitchListTile(
              title: const Text('ギフト受信'),
              subtitle: const Text('ギフトを受け取った時（スタッフのみ）'),
              value: _settings!.giftReceived,
              onChanged: (value) {
                setState(() {
                  _settings!.giftReceived = value;
                });
                _saveSettings();
              },
            ),

            SwitchListTile(
              title: const Text('予約確認'),
              subtitle: const Text('予約が確定した時'),
              value: _settings!.bookingConfirmed,
              onChanged: (value) {
                setState(() {
                  _settings!.bookingConfirmed = value;
                });
                _saveSettings();
              },
            ),

            SwitchListTile(
              title: const Text('レビュー受信'),
              subtitle: const Text('レビューが投稿された時（スタッフのみ）'),
              value: _settings!.reviewReceived,
              onChanged: (value) {
                setState(() {
                  _settings!.reviewReceived = value;
                });
                _saveSettings();
              },
            ),

            const Divider(),

            // テスト通知
            ListTile(
              leading: const Icon(Icons.notifications_active),
              title: const Text('テスト通知を送信'),
              subtitle: const Text('通知が正しく動作するか確認します'),
              onTap: () async {
                await _notificationService.sendNotification(
                  userId: widget.userId,
                  title: 'テスト通知',
                  body: '通知設定が正しく動作しています',
                  type: 'test',
                );
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('テスト通知を送信しました'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}
