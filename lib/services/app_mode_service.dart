import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// アプリモード（ユーザー/スタッフ）を管理するサービス
class AppModeService extends ChangeNotifier {
  static final AppModeService _instance = AppModeService._internal();
  factory AppModeService() => _instance;
  AppModeService._internal() {
    _loadMode();
  }

  // モード定義
  AppMode _currentMode = AppMode.user;
  AppMode get currentMode => _currentMode;

  // ログイン状態
  bool _isUserLoggedIn = false;
  bool _isStaffLoggedIn = false;
  
  bool get isUserLoggedIn => _isUserLoggedIn;
  bool get isStaffLoggedIn => _isStaffLoggedIn;
  bool get isLoggedIn => _currentMode == AppMode.user ? _isUserLoggedIn : _isStaffLoggedIn;

  // モード切り替え可否
  bool get canSwitchToStaff => _isStaffLoggedIn;
  bool get canSwitchToUser => _isUserLoggedIn;

  /// LocalStorageからモードを読み込み
  void _loadMode() {
    try {
      final modeStr = html.window.localStorage['app_mode'];
      if (modeStr != null) {
        _currentMode = modeStr == 'staff' ? AppMode.staff : AppMode.user;
      }

      // ログイン状態をチェック
      _isUserLoggedIn = html.window.localStorage['user_logged_in'] == 'true';
      _isStaffLoggedIn = html.window.localStorage['staff_logged_in'] == 'true';

      debugPrint('===== AppModeService初期化 =====');
      debugPrint('現在のモード: ${_currentMode.name}');
      debugPrint('ユーザーログイン: $_isUserLoggedIn');
      debugPrint('スタッフログイン: $_isStaffLoggedIn');
    } catch (e) {
      debugPrint('モード読み込みエラー: $e');
    }
  }

  /// モードを切り替える
  Future<bool> switchMode(AppMode newMode) async {
    debugPrint('===== モード切り替え =====');
    debugPrint('${_currentMode.name} → ${newMode.name}');

    // 切り替え先のログイン状態をチェック
    if (newMode == AppMode.staff && !_isStaffLoggedIn) {
      debugPrint('⚠️ スタッフとしてログインしていません');
      return false;
    }

    if (newMode == AppMode.user && !_isUserLoggedIn) {
      debugPrint('⚠️ ユーザーとしてログインしていません');
      return false;
    }

    _currentMode = newMode;
    html.window.localStorage['app_mode'] = newMode.name;
    
    debugPrint('✅ モード切り替え完了: ${newMode.name}');
    notifyListeners();
    return true;
  }

  /// ユーザーとしてログイン
  void loginAsUser(Map<String, dynamic> userData) {
    _isUserLoggedIn = true;
    html.window.localStorage['user_logged_in'] = 'true';
    html.window.localStorage['user_profile'] = json.encode(userData);
    
    // ユーザーモードに切り替え
    _currentMode = AppMode.user;
    html.window.localStorage['app_mode'] = 'user';
    
    debugPrint('✅ ユーザーログイン完了: ${userData['name']}');
    notifyListeners();
  }

  /// スタッフとしてログイン
  void loginAsStaff(Map<String, dynamic> staffData) {
    _isStaffLoggedIn = true;
    html.window.localStorage['staff_logged_in'] = 'true';
    html.window.localStorage['staff_profile'] = json.encode(staffData);
    
    // スタッフモードに切り替え
    _currentMode = AppMode.staff;
    html.window.localStorage['app_mode'] = 'staff';
    
    debugPrint('✅ スタッフログイン完了: ${staffData['name']}');
    notifyListeners();
  }

  /// ユーザーログアウト
  void logoutUser() {
    _isUserLoggedIn = false;
    html.window.localStorage.remove('user_logged_in');
    html.window.localStorage.remove('user_profile');
    
    // スタッフとしてログインしている場合はスタッフモードに切り替え
    if (_isStaffLoggedIn) {
      _currentMode = AppMode.staff;
      html.window.localStorage['app_mode'] = 'staff';
    }
    
    debugPrint('✅ ユーザーログアウト完了');
    notifyListeners();
  }

  /// スタッフログアウト
  void logoutStaff() {
    _isStaffLoggedIn = false;
    html.window.localStorage.remove('staff_logged_in');
    html.window.localStorage.remove('staff_profile');
    
    // ユーザーとしてログインしている場合はユーザーモードに切り替え
    if (_isUserLoggedIn) {
      _currentMode = AppMode.user;
      html.window.localStorage['app_mode'] = 'user';
    }
    
    debugPrint('✅ スタッフログアウト完了');
    notifyListeners();
  }

  /// 現在のプロフィールデータを取得
  Map<String, dynamic>? getCurrentProfile() {
    try {
      final key = _currentMode == AppMode.user ? 'user_profile' : 'staff_profile';
      final profileJson = html.window.localStorage[key];
      
      if (profileJson != null) {
        return json.decode(profileJson);
      }
    } catch (e) {
      debugPrint('プロフィール取得エラー: $e');
    }
    return null;
  }

  /// モード名を取得（日本語）
  String get modeName => _currentMode == AppMode.user ? 'ユーザー' : 'スタッフ';
  
  /// 反対モード名を取得（日本語）
  String get oppositeModeName => _currentMode == AppMode.user ? 'スタッフ' : 'ユーザー';
}

/// アプリモード列挙型
enum AppMode {
  user,   // ユーザーモード（スタッフを探す）
  staff,  // スタッフモード（予約管理、売上分析等）
}
