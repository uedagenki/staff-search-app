import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _messageNotifications = true;
  bool _reviewNotifications = true;
  bool _followNotifications = true;
  bool _bookingNotifications = true;
  bool _promotionNotifications = false;
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    try {
      final settingsJson = html.window.localStorage['notification_settings'];
      if (settingsJson != null && settingsJson.isNotEmpty) {
        final settings = jsonDecode(settingsJson) as Map<String, dynamic>;
        setState(() {
          _messageNotifications = settings['messageNotifications'] ?? true;
          _reviewNotifications = settings['reviewNotifications'] ?? true;
          _followNotifications = settings['followNotifications'] ?? true;
          _bookingNotifications = settings['bookingNotifications'] ?? true;
          _promotionNotifications = settings['promotionNotifications'] ?? false;
          _soundEnabled = settings['soundEnabled'] ?? true;
        });
      }
    } catch (e) {
      debugPrint('通知設定の読み込みエラー: $e');
    }
  }

  void _saveSettings() {
    try {
      final settings = {
        'messageNotifications': _messageNotifications,
        'reviewNotifications': _reviewNotifications,
        'followNotifications': _followNotifications,
        'bookingNotifications': _bookingNotifications,
        'promotionNotifications': _promotionNotifications,
        'soundEnabled': _soundEnabled,
      };
      html.window.localStorage['notification_settings'] = jsonEncode(settings);
    } catch (e) {
      debugPrint('通知設定の保存エラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知設定'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '通知タイプ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildSwitchTile(
            icon: Icons.message,
            iconColor: Colors.blue,
            title: 'メッセージ通知',
            subtitle: '新しいメッセージを受信したとき',
            value: _messageNotifications,
            onChanged: (value) {
              setState(() {
                _messageNotifications = value;
              });
              _saveSettings();
            },
          ),
          _buildSwitchTile(
            icon: Icons.star,
            iconColor: Colors.amber,
            title: 'レビュー通知',
            subtitle: '新しいレビューを受け取ったとき',
            value: _reviewNotifications,
            onChanged: (value) {
              setState(() {
                _reviewNotifications = value;
              });
              _saveSettings();
            },
          ),
          _buildSwitchTile(
            icon: Icons.person_add,
            iconColor: Colors.green,
            title: 'フォロー通知',
            subtitle: '新しいフォロワーを獲得したとき',
            value: _followNotifications,
            onChanged: (value) {
              setState(() {
                _followNotifications = value;
              });
              _saveSettings();
            },
          ),
          _buildSwitchTile(
            icon: Icons.calendar_today,
            iconColor: Colors.purple,
            title: '予約通知',
            subtitle: '新しい予約が入ったとき',
            value: _bookingNotifications,
            onChanged: (value) {
              setState(() {
                _bookingNotifications = value;
              });
              _saveSettings();
            },
          ),
          _buildSwitchTile(
            icon: Icons.campaign,
            iconColor: Colors.orange,
            title: 'プロモーション通知',
            subtitle: 'キャンペーンやお知らせ',
            value: _promotionNotifications,
            onChanged: (value) {
              setState(() {
                _promotionNotifications = value;
              });
              _saveSettings();
            },
          ),
          const Divider(height: 32),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '通知設定',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildSwitchTile(
            icon: Icons.volume_up,
            iconColor: Colors.blue,
            title: '通知音',
            subtitle: '通知時に音を鳴らす',
            value: _soundEnabled,
            onChanged: (value) {
              setState(() {
                _soundEnabled = value;
              });
              _saveSettings();
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              color: Colors.blue.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          '通知について',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '通知はアプリ内でのみ表示されます。ブラウザの通知設定も確認してください。',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 13, color: Colors.grey),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
