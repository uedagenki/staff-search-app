import 'package:flutter/foundation.dart';
import '../models/admin_user.dart';
import '../../utils/storage_helper.dart';
import 'dart:convert';

class AdminAuthService {
  static const String _adminUserKey = 'admin_user';
  static const String _adminUsersKey = 'admin_users';

  // デモ用の管理者アカウント
  static final Map<String, String> _demoAdmins = {
    'admin@stafffinder.com': 'admin123',
    'superadmin@stafffinder.com': 'superadmin123',
  };

  // 現在ログイン中の管理者を取得
  Future<AdminUser?> getCurrentAdmin() async {
    try {
      final userJson = await StorageHelper.getString(_adminUserKey);
      if (userJson != null && userJson.isNotEmpty) {
        return AdminUser.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get current admin: $e');
      }
    }
    return null;
  }

  // 管理者ログイン
  Future<AdminUser?> login(String email, String password) async {
    try {
      // デモ用認証
      if (_demoAdmins.containsKey(email) && _demoAdmins[email] == password) {
        final role = email.contains('superadmin') ? 'super_admin' : 'admin';
        final adminUser = AdminUser(
          id: 'admin_${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          name: email.split('@')[0],
          role: role,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        // ローカルストレージに保存
        await StorageHelper.setString(
          _adminUserKey,
          jsonEncode(adminUser.toJson()),
        );

        // ログイン履歴を保存
        await _saveLoginHistory(adminUser);

        return adminUser;
      }

      // 実際の実装では、ここでFirebase Authまたはカスタム認証を使用
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Admin login failed: $e');
      }
      return null;
    }
  }

  // ログアウト
  Future<void> logout() async {
    await StorageHelper.remove(_adminUserKey);
  }

  // ログイン履歴を保存
  Future<void> _saveLoginHistory(AdminUser admin) async {
    try {
      final historyJson = await StorageHelper.getString('admin_login_history');
      List<dynamic> history = [];
      
      if (historyJson != null) {
        history = jsonDecode(historyJson);
      }

      history.insert(0, {
        'adminId': admin.id,
        'email': admin.email,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // 最新100件のみ保持
      if (history.length > 100) {
        history = history.sublist(0, 100);
      }

      await StorageHelper.setString(
        'admin_login_history',
        jsonEncode(history),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save login history: $e');
      }
    }
  }

  // 管理者権限チェック
  bool hasPermission(AdminUser? admin, String permission) {
    if (admin == null) return false;

    switch (permission) {
      case 'delete_user':
      case 'delete_staff':
      case 'manage_admins':
        return admin.isSuperAdmin;
      case 'edit_user':
      case 'edit_staff':
      case 'view_reports':
        return admin.isAdmin;
      case 'moderate_content':
        return admin.isModerator;
      default:
        return false;
    }
  }
}
