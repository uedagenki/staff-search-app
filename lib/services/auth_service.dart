import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:convert';
import '../models/user.dart';

class AuthService {
  static const String _currentUserKey = 'current_user';
  static const String _usersKey = 'registered_users';

  // 現在のログインユーザーを取得
  User? getCurrentUser() {
    try {
      final userJson = html.window.localStorage[_currentUserKey];
      if (userJson != null && userJson.isNotEmpty) {
        return User.fromJsonString(userJson);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get current user: $e');
      }
    }
    return null;
  }

  // ログイン状態をチェック
  bool isLoggedIn() {
    return getCurrentUser() != null;
  }

  // ユーザー登録
  Future<AuthResult> register({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      // メールアドレスの重複チェック
      if (await _isEmailExists(email)) {
        return AuthResult(
          success: false,
          message: 'このメールアドレスは既に登録されています',
        );
      }

      // パスワードの検証
      if (password.length < 6) {
        return AuthResult(
          success: false,
          message: 'パスワードは6文字以上で入力してください',
        );
      }

      // 新規ユーザーを作成
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        points: 0, // 初回登録ボーナスポイント
      );

      // ユーザーを保存
      await _saveUser(user, password);
      await _setCurrentUser(user);

      return AuthResult(
        success: true,
        message: '登録が完了しました',
        user: user,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: '登録に失敗しました: $e',
      );
    }
  }

  // ログイン
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      // 登録済みユーザーを取得
      final users = _getRegisteredUsers();
      
      // メールアドレスで検索
      final userEntry = users.entries.firstWhere(
        (entry) {
          final user = User.fromJsonString(entry.value['userData'] as String);
          return user.email.toLowerCase() == email.toLowerCase();
        },
        orElse: () => MapEntry('', {}),
      );

      if (userEntry.key.isEmpty) {
        return AuthResult(
          success: false,
          message: 'メールアドレスまたはパスワードが正しくありません',
        );
      }

      // パスワード検証
      if (userEntry.value['password'] != password) {
        return AuthResult(
          success: false,
          message: 'メールアドレスまたはパスワードが正しくありません',
        );
      }

      // ユーザー情報を取得
      final user = User.fromJsonString(userEntry.value['userData'] as String);
      
      // 最終ログイン時刻を更新
      final updatedUser = user.copyWith(lastLoginAt: DateTime.now());
      await _saveUser(updatedUser, password);
      await _setCurrentUser(updatedUser);

      return AuthResult(
        success: true,
        message: 'ログインしました',
        user: updatedUser,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'ログインに失敗しました: $e',
      );
    }
  }

  // ログアウト
  Future<void> logout() async {
    html.window.localStorage.remove(_currentUserKey);
  }

  // ユーザー情報を更新
  Future<bool> updateUser(User user) async {
    try {
      final currentPassword = _getCurrentUserPassword(user.id);
      if (currentPassword != null) {
        await _saveUser(user, currentPassword);
        await _setCurrentUser(user);
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to update user: $e');
      }
      return false;
    }
  }

  // プライベートメソッド

  Future<bool> _isEmailExists(String email) async {
    final users = _getRegisteredUsers();
    return users.values.any((userData) {
      final user = User.fromJsonString(userData['userData'] as String);
      return user.email.toLowerCase() == email.toLowerCase();
    });
  }

  Map<String, dynamic> _getRegisteredUsers() {
    try {
      final usersJson = html.window.localStorage[_usersKey];
      if (usersJson != null && usersJson.isNotEmpty) {
        return jsonDecode(usersJson) as Map<String, dynamic>;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get registered users: $e');
      }
    }
    return {};
  }

  Future<void> _saveUser(User user, String password) async {
    final users = _getRegisteredUsers();
    users[user.id] = {
      'userData': user.toJsonString(),
      'password': password, // 実際の本番環境ではハッシュ化が必要
    };
    html.window.localStorage[_usersKey] = jsonEncode(users);
  }

  Future<void> _setCurrentUser(User user) async {
    html.window.localStorage[_currentUserKey] = user.toJsonString();
  }

  String? _getCurrentUserPassword(String userId) {
    final users = _getRegisteredUsers();
    final userData = users[userId];
    return userData?['password'] as String?;
  }

  // デモ用：テストユーザーを作成
  Future<void> createDemoUser() async {
    final demoUser = User(
      id: 'demo_user_001',
      email: 'demo@example.com',
      name: 'デモユーザー',
      phoneNumber: '090-1234-5678',
      createdAt: DateTime.now(),
      points: 1000,
      bio: 'これはデモユーザーです',
    );
    await _saveUser(demoUser, 'demo123');
  }
}

class AuthResult {
  final bool success;
  final String message;
  final User? user;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
}
