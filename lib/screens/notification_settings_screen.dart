import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // 通知設定
  bool _enableNotifications = true;
  bool _enableBookingNotifications = true;
  bool _enableMessageNotifications = true;
  bool _enableLiveNotifications = true;
  bool _enableGiftNotifications = true;
  bool _enableFollowNotifications = true;
  bool _enableReviewNotifications = true;
  bool _enablePromotionNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final settingsJson = html.window.localStorage['notification_settings'];
    if (settingsJson != null) {
      try {
        final settings = jsonDecode(settingsJson);
        setState(() {
          _enableNotifications = settings['enableNotifications'] ?? true;
          _enableBookingNotifications = settings['enableBookingNotifications'] ?? true;
          _enableMessageNotifications = settings['enableMessageNotifications'] ?? true;
          _enableLiveNotifications = settings['enableLiveNotifications'] ?? true;
          _enableGiftNotifications = settings['enableGiftNotifications'] ?? true;
          _enableFollowNotifications = settings['enableFollowNotifications'] ?? true;
          _enableReviewNotifications = settings['enableReviewNotifications'] ?? true;
          _enablePromotionNotifications = settings['enablePromotionNotifications'] ?? false;
        });
      } catch (e) {
        // エラー時はデフォルト値を使用
      }
    }
  }

  void _saveSettings() {
    final settings = {
      'enableNotifications': _enableNotifications,
      'enableBookingNotifications': _enableBookingNotifications,
      'enableMessageNotifications': _enableMessageNotifications,
      'enableLiveNotifications': _enableLiveNotifications,
      'enableGiftNotifications': _enableGiftNotifications,
      'enableFollowNotifications': _enableFollowNotifications,
      'enableReviewNotifications': _enableReviewNotifications,
      'enablePromotionNotifications': _enablePromotionNotifications,
    };
    html.window.localStorage['notification_settings'] = jsonEncode(settings);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('通知設定を保存しました')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知設定'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text(
              '保存',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            // 全体設定
            _buildSectionHeader('全般'),
            SwitchListTile(
              title: const Text('通知を許可'),
              subtitle: const Text('すべての通知のオン/オフ'),
              value: _enableNotifications,
              onChanged: (value) {
                setState(() {
                  _enableNotifications = value;
                  if (!value) {
                    // 全体をオフにした場合、すべての個別設定もオフ
                    _enableBookingNotifications = false;
                    _enableMessageNotifications = false;
                    _enableLiveNotifications = false;
                    _enableGiftNotifications = false;
                    _enableFollowNotifications = false;
                    _enableReviewNotifications = false;
                    _enablePromotionNotifications = false;
                  }
                });
              },
              secondary: const Icon(Icons.notifications_active),
            ),
            const Divider(),

            // 個別設定
            _buildSectionHeader('通知の種類'),
            
            SwitchListTile(
              title: const Text('予約通知'),
              subtitle: const Text('予約の確認、リマインダー、キャンセル'),
              value: _enableBookingNotifications && _enableNotifications,
              onChanged: _enableNotifications
                  ? (value) => setState(() => _enableBookingNotifications = value)
                  : null,
              secondary: const Icon(Icons.calendar_today),
            ),

            SwitchListTile(
              title: const Text('メッセージ通知'),
              subtitle: const Text('新しいメッセージの受信'),
              value: _enableMessageNotifications && _enableNotifications,
              onChanged: _enableNotifications
                  ? (value) => setState(() => _enableMessageNotifications = value)
                  : null,
              secondary: const Icon(Icons.message),
            ),

            SwitchListTile(
              title: const Text('ライブ配信通知'),
              subtitle: const Text('フォロー中のスタッフのライブ配信開始'),
              value: _enableLiveNotifications && _enableNotifications,
              onChanged: _enableNotifications
                  ? (value) => setState(() => _enableLiveNotifications = value)
                  : null,
              secondary: const Icon(Icons.videocam),
            ),

            SwitchListTile(
              title: const Text('ギフト通知'),
              subtitle: const Text('ギフト送信の確認と受信'),
              value: _enableGiftNotifications && _enableNotifications,
              onChanged: _enableNotifications
                  ? (value) => setState(() => _enableGiftNotifications = value)
                  : null,
              secondary: const Icon(Icons.card_giftcard),
            ),

            SwitchListTile(
              title: const Text('フォロー通知'),
              subtitle: const Text('新しいフォロワー、フォロー返し'),
              value: _enableFollowNotifications && _enableNotifications,
              onChanged: _enableNotifications
                  ? (value) => setState(() => _enableFollowNotifications = value)
                  : null,
              secondary: const Icon(Icons.people),
            ),

            SwitchListTile(
              title: const Text('レビュー通知'),
              subtitle: const Text('レビューへの返信、いいね'),
              value: _enableReviewNotifications && _enableNotifications,
              onChanged: _enableNotifications
                  ? (value) => setState(() => _enableReviewNotifications = value)
                  : null,
              secondary: const Icon(Icons.star),
            ),

            const Divider(),
            _buildSectionHeader('プロモーション'),

            SwitchListTile(
              title: const Text('キャンペーン・お知らせ'),
              subtitle: const Text('特別オファー、新機能のお知らせ'),
              value: _enablePromotionNotifications && _enableNotifications,
              onChanged: _enableNotifications
                  ? (value) => setState(() => _enablePromotionNotifications = value)
                  : null,
              secondary: const Icon(Icons.campaign),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
