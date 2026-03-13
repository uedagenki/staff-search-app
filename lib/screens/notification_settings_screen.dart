// SCREEN: Notification Settings Screen | NOTIF-01
import '../../utils/screen_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/push_notification.dart';
import '../services/fcm_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> with ScreenLogMixin {
  @override
  String get screenId => 'Notification Settings Screen | NOTIF-01';

  final _fcmService = FCMService();
  
  bool _isLoading = true;
  AppNotificationSettings _settings = AppNotificationSettings();
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _fcmService.getNotificationSettings();
    final token = _fcmService.fcmToken;
    
    setState(() {
      _settings = settings;
      _fcmToken = token;
      _isLoading = false;
    });
  }

  Future<void> _saveSetting() async {
    await _fcmService.saveNotificationSettings(_settings);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('設定を保存しました'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知設定'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // FCMトークン表示（デバッグ用）
                if (kDebugMode && _fcmToken != null)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.developer_mode, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'FCMトークン（開発用）',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _fcmToken!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),

                // 通知の有効/無効
                _buildSectionHeader('通知'),
                _buildSwitchTile(
                  title: 'プッシュ通知',
                  subtitle: 'すべての通知を受信します',
                  value: _settings.enabled,
                  icon: Icons.notifications_active,
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings.copyWith(enabled: value);
                    });
                    _saveSetting();
                  },
                ),

                const Divider(height: 1),

                // サウンドとバイブレーション
                _buildSectionHeader('通知の表示'),
                _buildSwitchTile(
                  title: '通知音',
                  subtitle: '通知時に音を鳴らします',
                  value: _settings.soundEnabled,
                  icon: Icons.volume_up,
                  enabled: _settings.enabled,
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings.copyWith(soundEnabled: value);
                    });
                    _saveSetting();
                  },
                ),
                _buildSwitchTile(
                  title: 'バイブレーション',
                  subtitle: '通知時に振動します',
                  value: _settings.vibrationEnabled,
                  icon: Icons.vibration,
                  enabled: _settings.enabled,
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings.copyWith(vibrationEnabled: value);
                    });
                    _saveSetting();
                  },
                ),

                const Divider(height: 1),

                // 通知タイプ
                _buildSectionHeader('通知タイプ'),
                _buildSwitchTile(
                  title: '新しいフォロワー',
                  subtitle: 'フォローされたときに通知します',
                  value: _settings.newFollowerEnabled,
                  icon: Icons.person_add,
                  enabled: _settings.enabled,
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings.copyWith(newFollowerEnabled: value);
                    });
                    _saveSetting();
                  },
                ),
                _buildSwitchTile(
                  title: '新しいメッセージ',
                  subtitle: 'メッセージを受信したときに通知します',
                  value: _settings.newMessageEnabled,
                  icon: Icons.message,
                  enabled: _settings.enabled,
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings.copyWith(newMessageEnabled: value);
                    });
                    _saveSetting();
                  },
                ),
                _buildSwitchTile(
                  title: 'ギフト受信',
                  subtitle: 'ギフトを受け取ったときに通知します',
                  value: _settings.newGiftEnabled,
                  icon: Icons.card_giftcard,
                  enabled: _settings.enabled,
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings.copyWith(newGiftEnabled: value);
                    });
                    _saveSetting();
                  },
                ),
                _buildSwitchTile(
                  title: 'ライブ配信開始',
                  subtitle: 'フォロー中のユーザーがライブ配信を開始したときに通知します',
                  value: _settings.liveStartEnabled,
                  icon: Icons.videocam,
                  enabled: _settings.enabled,
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings.copyWith(liveStartEnabled: value);
                    });
                    _saveSetting();
                  },
                ),
                _buildSwitchTile(
                  title: '予約リマインダー',
                  subtitle: '予約の前日に通知します',
                  value: _settings.bookingReminderEnabled,
                  icon: Icons.event,
                  enabled: _settings.enabled,
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings.copyWith(bookingReminderEnabled: value);
                    });
                    _saveSetting();
                  },
                ),

                const SizedBox(height: 24),

                // 注意事項
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 20, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            '通知について',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• 通知を受信するには、デバイスの通知設定で許可が必要です\n'
                        '• バックグラウンドでも通知を受信できます\n'
                        '• 重要な通知は常に送信されます',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey.shade100,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    bool enabled = true,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: enabled ? onChanged : null,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: enabled ? Colors.black87 : Colors.grey,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
        ),
      ),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: enabled
              ? Colors.blue.shade50
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.blue : Colors.grey,
        ),
      ),
    );
  }
}
