import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_user;

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const String _usersCollection = 'users';

  // 現在のログインユーザーを取得（Firebase Auth + Firestore）
  Future<app_user.User?> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      // Firestoreからユーザー詳細情報を取得
      final docSnapshot = await _firestore
          .collection(_usersCollection)
          .doc(firebaseUser.uid)
          .get();

      if (!docSnapshot.exists) {
        // Firestoreにデータがない場合は作成
        final newUser = app_user.User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'ユーザー',
          phoneNumber: firebaseUser.phoneNumber,
          createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
          lastLoginAt: DateTime.now(),
          points: 0,
        );
        await _firestore.collection(_usersCollection).doc(firebaseUser.uid).set(newUser.toJson());
        return newUser;
      }

      return app_user.User.fromJson(docSnapshot.data()!, docSnapshot.id);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get current user: $e');
      }
      return null;
    }
  }

  // ログイン状態をチェック
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  // ユーザー登録（Firebase Authentication + Firestore）
  Future<AuthResult> register({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
    bool privacyPolicyAccepted = false,
    String privacyPolicyVersion = 'v1.0',
  }) async {
    try {
      // パスワードの検証
      if (password.length < 6) {
        return AuthResult(
          success: false,
          message: 'パスワードは6文字以上で入力してください',
        );
      }

      // プライバシーポリシー同意チェック
      if (!privacyPolicyAccepted) {
        return AuthResult(
          success: false,
          message: 'プライバシーポリシーに同意してください',
        );
      }

      // Firebase Authenticationでユーザー作成
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return AuthResult(
          success: false,
          message: 'ユーザー作成に失敗しました',
        );
      }

      // 表示名を設定
      await firebaseUser.updateDisplayName(name);

      // Firestoreにユーザー詳細情報を保存
      final now = DateTime.now();
      final user = app_user.User(
        id: firebaseUser.uid,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        createdAt: now,
        lastLoginAt: now,
        points: 0, // 初回登録ボーナスポイント
        privacyPolicyAccepted: privacyPolicyAccepted,
        privacyPolicyAcceptedAt: now,
        privacyPolicyVersion: privacyPolicyVersion,
      );

      await _firestore.collection(_usersCollection).doc(firebaseUser.uid).set(user.toJson());

      return AuthResult(
        success: true,
        message: '登録が完了しました',
        user: user,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'このメールアドレスは既に登録されています';
          break;
        case 'invalid-email':
          message = '無効なメールアドレスです';
          break;
        case 'weak-password':
          message = 'パスワードが弱すぎます';
          break;
        default:
          message = '登録に失敗しました: ${e.message}';
      }
      return AuthResult(success: false, message: message);
    } catch (e) {
      return AuthResult(
        success: false,
        message: '登録に失敗しました: $e',
      );
    }
  }

  // ログイン（Firebase Authentication）
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔐 ログイン試行: $email');
      }

      // Firebase Authenticationでログイン
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return AuthResult(
          success: false,
          message: 'ログインに失敗しました',
        );
      }

      if (kDebugMode) {
        debugPrint('✅ Firebase Auth ログイン成功: ${firebaseUser.uid}');
      }

      // Firestoreから詳細情報を取得
      final docSnapshot = await _firestore
          .collection(_usersCollection)
          .doc(firebaseUser.uid)
          .get();

      app_user.User user;
      if (!docSnapshot.exists) {
        // Firestoreにデータがない場合は作成
        if (kDebugMode) {
          debugPrint('⚠️ Firestoreにユーザーデータなし、新規作成...');
        }
        user = app_user.User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? email,
          name: firebaseUser.displayName ?? 'ユーザー',
          phoneNumber: firebaseUser.phoneNumber,
          createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
          lastLoginAt: DateTime.now(),
          points: 0,
        );
        await _firestore.collection(_usersCollection).doc(firebaseUser.uid).set(user.toJson());
      } else {
        user = app_user.User.fromJson(docSnapshot.data()!, docSnapshot.id);
        
        // 最終ログイン時刻を更新
        user = user.copyWith(lastLoginAt: DateTime.now());
        await _firestore.collection(_usersCollection).doc(firebaseUser.uid).update({
          'lastLoginAt': Timestamp.fromDate(user.lastLoginAt!),
        });
      }

      if (kDebugMode) {
        debugPrint('✅ ログイン完了: ${user.name} (${user.id})');
      }

      return AuthResult(
        success: true,
        message: 'ログインしました',
        user: user,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          message = 'メールアドレスまたはパスワードが正しくありません';
          break;
        case 'invalid-email':
          message = '無効なメールアドレスです';
          break;
        case 'user-disabled':
          message = 'このアカウントは無効化されています';
          break;
        default:
          message = 'ログインに失敗しました: ${e.message}';
      }
      if (kDebugMode) {
        debugPrint('❌ ログインエラー: ${e.code} - $message');
      }
      return AuthResult(success: false, message: message);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ログイン例外: $e');
      }
      return AuthResult(
        success: false,
        message: 'ログインに失敗しました: $e',
      );
    }
  }

  // ログアウト
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ユーザー情報を更新
  Future<bool> updateUser(app_user.User user) async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return false;

      // 表示名を更新
      if (firebaseUser.displayName != user.name) {
        await firebaseUser.updateDisplayName(user.name);
      }

      // Firestoreのユーザー情報を更新
      await _firestore.collection(_usersCollection).doc(user.id).update(user.toJson());
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to update user: $e');
      }
      return false;
    }
  }

  // パスワードリセットメール送信
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult(
        success: true,
        message: 'パスワードリセットメールを送信しました',
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'このメールアドレスは登録されていません';
          break;
        case 'invalid-email':
          message = '無効なメールアドレスです';
          break;
        default:
          message = 'メール送信に失敗しました: ${e.message}';
      }
      return AuthResult(success: false, message: message);
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'メール送信に失敗しました: $e',
      );
    }
  }

  // デモ用：テストユーザーを作成（開発環境のみ）
  Future<void> createDemoUser() async {
    try {
      if (kDebugMode) {
        debugPrint('🔧 デモユーザー作成開始...');
      }

      // Firebase Authでテストユーザー作成
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: 'demo@example.com',
        password: 'demo123',
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        await firebaseUser.updateDisplayName('デモユーザー');

        // Firestoreにデータ保存
        final demoUser = app_user.User(
          id: firebaseUser.uid,
          email: 'demo@example.com',
          name: 'デモユーザー',
          phoneNumber: '090-1234-5678',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          points: 1000,
          bio: 'これはデモユーザーです',
          privacyPolicyAccepted: true,
          privacyPolicyAcceptedAt: DateTime.now(),
          privacyPolicyVersion: 'v1.0',
          role: 'user',
          isStaffRegistered: false,
        );
        await _firestore.collection(_usersCollection).doc(firebaseUser.uid).set(demoUser.toJson());
        
        if (kDebugMode) {
          debugPrint('✅ デモユーザー作成成功: ${firebaseUser.uid}');
        }
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // デモユーザーが既に存在する場合は無視
        if (kDebugMode) {
          debugPrint('ℹ️ デモユーザーは既に存在します');
        }
      } else {
        if (kDebugMode) {
          debugPrint('❌ デモユーザー作成失敗: ${e.code} - ${e.message}');
        }
        rethrow; // エラーを再スロー
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ デモユーザー作成エラー: $e');
      }
      rethrow; // エラーを再スロー
    }
  }

  // スタッフデモ用：スタッフテストユーザーを作成（開発環境のみ）
  Future<void> createStaffDemoUser() async {
    try {
      if (kDebugMode) {
        debugPrint('🔧 スタッフデモユーザー作成開始...');
      }

      // Firebase Authでテストユーザー作成
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: 'staff-demo@example.com',
        password: 'demo123',
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        await firebaseUser.updateDisplayName('デモスタッフ');

        // Firestoreにデータ保存（スタッフ登録済み）
        final demoStaffUser = app_user.User(
          id: firebaseUser.uid,
          email: 'staff-demo@example.com',
          name: 'デモスタッフ',
          phoneNumber: '090-9876-5432',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          points: 5000,
          bio: 'これはスタッフデモアカウントです。スタッフ機能を体験できます。',
          privacyPolicyAccepted: true,
          privacyPolicyAcceptedAt: DateTime.now(),
          privacyPolicyVersion: 'v1.0',
          role: 'staff',
          isStaffRegistered: true,
        );
        await _firestore.collection(_usersCollection).doc(firebaseUser.uid).set(demoStaffUser.toJson());
        
        if (kDebugMode) {
          debugPrint('✅ スタッフデモユーザー作成成功: ${firebaseUser.uid}');
        }
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // スタッフデモユーザーが既に存在する場合は無視
        if (kDebugMode) {
          debugPrint('ℹ️ スタッフデモユーザーは既に存在します');
        }
      } else {
        if (kDebugMode) {
          debugPrint('❌ スタッフデモユーザー作成失敗: ${e.code} - ${e.message}');
        }
        rethrow; // エラーを再スロー
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ スタッフデモユーザー作成エラー: $e');
      }
      rethrow; // エラーを再スロー
    }
  }

  // Firebase Auth リスナー（リアルタイムでログイン状態を監視）
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();
}

class AuthResult {
  final bool success;
  final String message;
  final app_user.User? user;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
}
