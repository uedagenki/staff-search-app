import 'package:flutter/material.dart';
import 'dart:convert';
import '../utils/storage_helper.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  // プライバシー設定
  bool _profilePublic = true;
  bool _showAge = true;
  bool _showLocation = true;
  bool _allowMessages = true;
  bool _allowBookings = true;
  bool _showOnlineStatus = true;
  bool _showGiftHistory = false;
  bool _allowSearch = true;
  String _messagePermission = 'everyone'; // everyone, following, none

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settingsJson = await StorageHelper.getString('privacy_settings');
    if (settingsJson != null) {
      try {
        final settings = jsonDecode(settingsJson);
        setState(() {
          _profilePublic = settings['profilePublic'] ?? true;
          _showAge = settings['showAge'] ?? true;
          _showLocation = settings['showLocation'] ?? true;
          _allowMessages = settings['allowMessages'] ?? true;
          _allowBookings = settings['allowBookings'] ?? true;
          _showOnlineStatus = settings['showOnlineStatus'] ?? true;
          _showGiftHistory = settings['showGiftHistory'] ?? false;
          _allowSearch = settings['allowSearch'] ?? true;
          _messagePermission = settings['messagePermission'] ?? 'everyone';
        });
      } catch (e) {
        // エラー時はデフォルト値を使用
      }
    }
  }

  Future<void> _saveSettings() async {
    final settings = {
      'profilePublic': _profilePublic,
      'showAge': _showAge,
      'showLocation': _showLocation,
      'allowMessages': _allowMessages,
      'allowBookings': _allowBookings,
      'showOnlineStatus': _showOnlineStatus,
      'showGiftHistory': _showGiftHistory,
      'allowSearch': _allowSearch,
      'messagePermission': _messagePermission,
    };
    await StorageHelper.setString('privacy_settings', jsonEncode(settings));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('プライバシー設定を保存しました')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プライバシー設定'),
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
            // 情報表示
            Card(
              margin: const EdgeInsets.all(16),
              color: Colors.blue[50],
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.privacy_tip, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'プライバシー設定で、他のユーザーに公開する情報を管理できます。',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // プロフィール公開設定
            _buildSectionHeader('プロフィール'),
            
            SwitchListTile(
              title: const Text('プロフィールを公開'),
              subtitle: const Text('他のユーザーがプロフィールを閲覧可能'),
              value: _profilePublic,
              onChanged: (value) {
                setState(() {
                  _profilePublic = value;
                  if (!value) {
                    // プロフィール非公開の場合、他の設定も制限
                    _allowSearch = false;
                  }
                });
              },
              secondary: const Icon(Icons.person),
            ),

            SwitchListTile(
              title: const Text('年齢を表示'),
              subtitle: const Text('プロフィールに年齢を表示'),
              value: _showAge && _profilePublic,
              onChanged: _profilePublic
                  ? (value) => setState(() => _showAge = value)
                  : null,
              secondary: const Icon(Icons.cake),
            ),

            SwitchListTile(
              title: const Text('位置情報を表示'),
              subtitle: const Text('プロフィールに住所を表示'),
              value: _showLocation && _profilePublic,
              onChanged: _profilePublic
                  ? (value) => setState(() => _showLocation = value)
                  : null,
              secondary: const Icon(Icons.location_on),
            ),

            SwitchListTile(
              title: const Text('オンライン状態を表示'),
              subtitle: const Text('他のユーザーにオンライン状態を表示'),
              value: _showOnlineStatus && _profilePublic,
              onChanged: _profilePublic
                  ? (value) => setState(() => _showOnlineStatus = value)
                  : null,
              secondary: const Icon(Icons.circle),
            ),

            SwitchListTile(
              title: const Text('ギフト履歴を表示'),
              subtitle: const Text('送信したギフトの履歴を公開'),
              value: _showGiftHistory && _profilePublic,
              onChanged: _profilePublic
                  ? (value) => setState(() => _showGiftHistory = value)
                  : null,
              secondary: const Icon(Icons.card_giftcard),
            ),

            const Divider(),

            // コミュニケーション設定
            _buildSectionHeader('コミュニケーション'),

            SwitchListTile(
              title: const Text('メッセージを許可'),
              subtitle: const Text('他のユーザーからのメッセージ受信'),
              value: _allowMessages,
              onChanged: (value) => setState(() => _allowMessages = value),
              secondary: const Icon(Icons.message),
            ),

            if (_allowMessages)
              ListTile(
                leading: const SizedBox(width: 40),
                title: const Text('メッセージ送信権限'),
                subtitle: Text(_getMessagePermissionLabel()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showMessagePermissionDialog();
                },
              ),

            SwitchListTile(
              title: const Text('予約を許可'),
              subtitle: const Text('他のユーザーからの予約リクエスト'),
              value: _allowBookings,
              onChanged: (value) => setState(() => _allowBookings = value),
              secondary: const Icon(Icons.calendar_today),
            ),

            const Divider(),

            // 検索・発見
            _buildSectionHeader('検索・発見'),

            SwitchListTile(
              title: const Text('検索結果に表示'),
              subtitle: const Text('他のユーザーの検索結果に表示'),
              value: _allowSearch && _profilePublic,
              onChanged: _profilePublic
                  ? (value) => setState(() => _allowSearch = value)
                  : null,
              secondary: const Icon(Icons.search),
            ),

            const SizedBox(height: 20),

            // データ管理
            _buildSectionHeader('データ管理'),

            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('データをダウンロード'),
              subtitle: const Text('アカウントデータのコピーをダウンロード'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('データダウンロード機能（準備中）')),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text(
                'アカウントを削除',
                style: TextStyle(color: Colors.red),
              ),
              subtitle: const Text('アカウントとすべてのデータを削除'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showDeleteAccountDialog();
              },
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

  String _getMessagePermissionLabel() {
    switch (_messagePermission) {
      case 'everyone':
        return 'すべてのユーザー';
      case 'following':
        return 'フォロー中のユーザーのみ';
      case 'none':
        return '誰も許可しない';
      default:
        return 'すべてのユーザー';
    }
  }

  void _showMessagePermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('メッセージ送信権限'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('すべてのユーザー'),
              value: 'everyone',
              groupValue: _messagePermission,
              onChanged: (value) {
                setState(() => _messagePermission = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('フォロー中のユーザーのみ'),
              value: 'following',
              groupValue: _messagePermission,
              onChanged: (value) {
                setState(() => _messagePermission = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('誰も許可しない'),
              value: 'none',
              groupValue: _messagePermission,
              onChanged: (value) {
                setState(() => _messagePermission = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('アカウント削除'),
          ],
        ),
        content: const Text(
          'アカウントを削除すると、すべてのデータが永久に失われます。\n\nこの操作は取り消せません。本当に削除しますか？',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('アカウント削除機能（準備中）'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('削除する'),
          ),
        ],
      ),
    );
  }
}
