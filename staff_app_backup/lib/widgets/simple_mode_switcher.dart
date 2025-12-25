import 'package:flutter/material.dart';
import 'dart:html' as html;

/// シンプルなモード切り替えボタン（URL遷移方式）
class SimpleModeDropdown extends StatelessWidget {
  const SimpleModeDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_outline,
              size: 14,
              color: Color(0xFF667EEA),
            ),
            const SizedBox(width: 4),
            const Text(
              'ユーザー',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_drop_down,
              size: 14,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'user',
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 18, color: Color(0xFF667EEA)),
              SizedBox(width: 8),
              Text('ユーザーモード'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'staff',
          child: Row(
            children: [
              Icon(Icons.work_outline, size: 18, color: Color(0xFFF093FB)),
              SizedBox(width: 8),
              Text('スタッフモード'),
            ],
          ),
        ),
      ],
      onSelected: (mode) {
        if (mode == 'staff') {
          _switchToStaffApp(context);
        }
        // ユーザーモードは既に表示中なので何もしない
      },
    );
  }

  void _switchToStaffApp(BuildContext context) {
    // スタッフとしてログインしているかチェック
    final isStaffLoggedIn = html.window.localStorage['staff_logged_in'] == 'true';

    if (!isStaffLoggedIn) {
      // ログインしていない場合はダイアログを表示
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.work_outline, color: Color(0xFFF093FB)),
              SizedBox(width: 8),
              Text('スタッフモード'),
            ],
          ),
          content: const Text(
            'スタッフモードを使用するには、スタッフとしてログインする必要があります。\n\nスタッフ登録またはログインを行いますか？',
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
                // スタッフログイン画面にリダイレクト
                html.window.location.href = 'https://5061-ivmmk44rjvkdnze0ep01h-5185f4aa.sandbox.novita.ai/staff_login.html';
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF093FB),
                foregroundColor: Colors.white,
              ),
              child: const Text('ログイン'),
            ),
          ],
        ),
      );
    } else {
      // ログイン済みの場合は直接スタッフアプリにリダイレクト（ダイアログなし）
      html.window.location.href = 'https://5061-ivmmk44rjvkdnze0ep01h-5185f4aa.sandbox.novita.ai/';
    }
  }
}

/// スタッフアプリ用のシンプルなモード切り替えボタン
class StaffModeDropdown extends StatelessWidget {
  const StaffModeDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.work_outline,
              size: 14,
              color: Color(0xFFF093FB),
            ),
            const SizedBox(width: 4),
            const Text(
              'スタッフ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_drop_down,
              size: 14,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'user',
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 18, color: Color(0xFF667EEA)),
              SizedBox(width: 8),
              Text('ユーザーモード'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'staff',
          child: Row(
            children: [
              Icon(Icons.work_outline, size: 18, color: Color(0xFFF093FB)),
              SizedBox(width: 8),
              Text('スタッフモード'),
            ],
          ),
        ),
      ],
      onSelected: (mode) {
        if (mode == 'user') {
          _switchToUserApp(context);
        }
        // スタッフモードは既に表示中なので何もしない
      },
    );
  }

  void _switchToUserApp(BuildContext context) {
    // ユーザーとしてログインしているかチェック
    final isUserLoggedIn = html.window.localStorage['user_logged_in'] == 'true';

    if (!isUserLoggedIn) {
      // ログインしていない場合はダイアログを表示
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.person_outline, color: Color(0xFF667EEA)),
              SizedBox(width: 8),
              Text('ユーザーモード'),
            ],
          ),
          content: const Text(
            'ユーザーモードを使用するには、ユーザーとしてログインする必要があります。\n\nユーザー登録またはログインを行いますか？',
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
                // ユーザーログイン画面にリダイレクト
                html.window.location.href = 'https://5060-ivmmk44rjvkdnze0ep01h-5185f4aa.sandbox.novita.ai/user_login.html';
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
              ),
              child: const Text('ログイン'),
            ),
          ],
        ),
      );
    } else {
      // ログイン済みの場合は直接ユーザーアプリにリダイレクト（ダイアログなし）
      html.window.location.href = 'https://5060-ivmmk44rjvkdnze0ep01h-5185f4aa.sandbox.novita.ai/';
    }
  }
}
