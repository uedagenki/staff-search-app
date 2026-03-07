import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// ローカルストレージベースの認証サービス
/// Firebaseを使用せず、SharedPreferencesで認証を管理
class LocalAuthService {
  static const String _currentUserKey = 'current_user';
  static const String _usersKey = 'registered_users';
  static const String _sessionKey = 'is_logged_in';

  /// 現在ログインしているユーザーを取得
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_currentUserKey);
      
      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        return User.fromJson(userMap);
      }
      return null;
    } catch (e) {
      print('❌ Error getting current user: $e');
      return null;
    }
  }

  /// ログイン状態を確認
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sessionKey) ?? false;
  }

  /// ユーザー登録
  Future<AuthResult> register({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
    bool privacyPolicyAccepted = false,
    String? privacyPolicyVersion,
    String role = 'user',
    bool isStaffRegistered = false,
  }) async {
    try {
      // パスワードの検証
      if (password.length < 6) {
        return AuthResult(
          success: false,
          message: 'パスワードは6文字以上である必要があります',
        );
      }

      // プライバシーポリシーの確認
      if (!privacyPolicyAccepted) {
        return AuthResult(
          success: false,
          message: 'プライバシーポリシーに同意してください',
        );
      }

      final prefs = await SharedPreferences.getInstance();
      
      // 既存ユーザーの確認
      final usersJson = prefs.getString(_usersKey);
      List<dynamic> users = [];
      
      if (usersJson != null) {
        users = jsonDecode(usersJson);
        
        // 同じメールアドレスが登録済みか確認
        final existingUser = users.firstWhere(
          (u) => u['email'] == email,
          orElse: () => null,
        );
        
        if (existingUser != null) {
          return AuthResult(
            success: false,
            message: 'このメールアドレスは既に登録されています',
          );
        }
      }

      // 新しいユーザーを作成
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        points: role == 'staff' ? 5000 : 1000, // スタッフは5000ポイント、ユーザーは1000ポイント
        privacyPolicyAccepted: privacyPolicyAccepted,
        privacyPolicyAcceptedAt: DateTime.now(),
        privacyPolicyVersion: privacyPolicyVersion ?? '1.0',
        role: role,
        isStaffRegistered: isStaffRegistered,
      );

      // パスワードを別途保存（実際のアプリではハッシュ化が必要）
      final userWithPassword = {
        ...newUser.toJson(),
        'password': password,
      };

      users.add(userWithPassword);
      await prefs.setString(_usersKey, jsonEncode(users));

      // 自動ログイン
      await prefs.setString(_currentUserKey, jsonEncode(newUser.toJson()));
      await prefs.setBool(_sessionKey, true);

      print('✅ User registered successfully: ${newUser.email}');
      
      return AuthResult(
        success: true,
        message: '登録が完了しました',
        user: newUser,
      );
    } catch (e) {
      print('❌ Registration error: $e');
      return AuthResult(
        success: false,
        message: '登録中にエラーが発生しました: $e',
      );
    }
  }

  /// ログイン
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Login attempt: $email');
      
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);
      
      if (usersJson == null) {
        print('❌ No users registered');
        return AuthResult(
          success: false,
          message: 'メールアドレスまたはパスワードが正しくありません',
        );
      }

      final users = jsonDecode(usersJson) as List<dynamic>;
      
      // ユーザーを検索
      final userMap = users.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
        orElse: () => null,
      );
      
      if (userMap == null) {
        print('❌ Invalid credentials');
        return AuthResult(
          success: false,
          message: 'メールアドレスまたはパスワードが正しくありません',
        );
      }

      // パスワードフィールドを削除してUserオブジェクトを作成
      final userDataMap = Map<String, dynamic>.from(userMap);
      userDataMap.remove('password');
      
      final user = User.fromJson(userDataMap);
      
      // 最終ログイン時刻を更新
      final updatedUser = user.copyWith(lastLoginAt: DateTime.now());
      
      // ストレージに保存
      await prefs.setString(_currentUserKey, jsonEncode(updatedUser.toJson()));
      await prefs.setBool(_sessionKey, true);
      
      // ユーザーリストも更新
      final updatedUserMap = {...userMap, 'lastLoginAt': DateTime.now().toIso8601String()};
      final userIndex = users.indexWhere((u) => u['email'] == email);
      users[userIndex] = updatedUserMap;
      await prefs.setString(_usersKey, jsonEncode(users));

      print('✅ Login successful: ${user.email}, role: ${user.role}');
      
      return AuthResult(
        success: true,
        message: 'ログインしました',
        user: updatedUser,
      );
    } catch (e) {
      print('❌ Login error: $e');
      return AuthResult(
        success: false,
        message: 'ログイン中にエラーが発生しました: $e',
      );
    }
  }

  /// ログアウト
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
      await prefs.setBool(_sessionKey, false);
      print('✅ Logout successful');
    } catch (e) {
      print('❌ Logout error: $e');
    }
  }

  /// ユーザー情報を更新
  Future<void> updateUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 現在のユーザー情報を更新
      await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
      
      // ユーザーリストも更新
      final usersJson = prefs.getString(_usersKey);
      if (usersJson != null) {
        final users = jsonDecode(usersJson) as List<dynamic>;
        final userIndex = users.indexWhere((u) => u['id'] == user.id);
        
        if (userIndex != -1) {
          // パスワードを保持したまま更新
          final oldPassword = users[userIndex]['password'];
          users[userIndex] = {...user.toJson(), 'password': oldPassword};
          await prefs.setString(_usersKey, jsonEncode(users));
        }
      }
      
      print('✅ User updated: ${user.email}');
    } catch (e) {
      print('❌ Update user error: $e');
    }
  }

  /// パスワードリセット用メール送信（モック）
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);
      
      if (usersJson == null) {
        return AuthResult(
          success: false,
          message: 'このメールアドレスは登録されていません',
        );
      }

      final users = jsonDecode(usersJson) as List<dynamic>;
      final userExists = users.any((u) => u['email'] == email);
      
      if (!userExists) {
        return AuthResult(
          success: false,
          message: 'このメールアドレスは登録されていません',
        );
      }

      print('📧 Password reset email would be sent to: $email');
      
      return AuthResult(
        success: true,
        message: 'パスワードリセット用のメールを送信しました（※ローカルモード）',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'エラーが発生しました: $e',
      );
    }
  }

  /// デモユーザーを作成（ユーザー向け）
  Future<void> createDemoUser() async {
    try {
      print('🎭 Creating demo user...');
      
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);
      List<dynamic> users = usersJson != null ? jsonDecode(usersJson) : [];
      
      // 既存のデモユーザーを確認
      final existingDemo = users.firstWhere(
        (u) => u['email'] == 'demo@example.com',
        orElse: () => null,
      );
      
      if (existingDemo != null) {
        print('ℹ️ Demo user already exists');
        return;
      }

      // デモユーザーを作成
      final demoUser = {
        'id': 'demo_user_001',
        'email': 'demo@example.com',
        'password': 'demo123',
        'name': 'デモユーザー',
        'phoneNumber': '090-1234-5678',
        'createdAt': DateTime.now().toIso8601String(),
        'lastLoginAt': DateTime.now().toIso8601String(),
        'points': 1000,
        'privacyPolicyAccepted': true,
        'privacyPolicyAcceptedAt': DateTime.now().toIso8601String(),
        'privacyPolicyVersion': '1.0',
        'role': 'user',
        'isStaffRegistered': false,
      };

      users.add(demoUser);
      await prefs.setString(_usersKey, jsonEncode(users));
      
      print('✅ Demo user created successfully');
    } catch (e) {
      print('❌ Error creating demo user: $e');
    }
  }

  /// デモスタッフを作成（スタッフ向け）
  Future<void> createStaffDemoUser() async {
    try {
      print('🎭 Creating staff demo user...');
      
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);
      List<dynamic> users = usersJson != null ? jsonDecode(usersJson) : [];
      
      // 既存のデモスタッフを確認
      final existingDemo = users.firstWhere(
        (u) => u['email'] == 'staff-demo@example.com',
        orElse: () => null,
      );
      
      if (existingDemo != null) {
        print('ℹ️ Staff demo user already exists');
        return;
      }

      // デモスタッフを作成
      final staffDemo = {
        'id': 'staff_demo_001',
        'email': 'staff-demo@example.com',
        'password': 'demo123',
        'name': 'デモスタッフ',
        'phoneNumber': '090-9876-5432',
        'createdAt': DateTime.now().toIso8601String(),
        'lastLoginAt': DateTime.now().toIso8601String(),
        'points': 5000,
        'privacyPolicyAccepted': true,
        'privacyPolicyAcceptedAt': DateTime.now().toIso8601String(),
        'privacyPolicyVersion': '1.0',
        'role': 'staff',
        'isStaffRegistered': true,
      };

      users.add(staffDemo);
      await prefs.setString(_usersKey, jsonEncode(users));
      
      print('✅ Staff demo user created successfully');
    } catch (e) {
      print('❌ Error creating staff demo user: $e');
    }
  }
}

/// 認証結果
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
