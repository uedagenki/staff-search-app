import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// SharedPreferencesからモードを読み込み
  Future<void> _loadMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeStr = prefs.getString('app_mode');
      if (modeStr != null) {
        _currentMode = modeStr == 'staff' ? AppMode.staff : AppMode.user;
      }

      // ログイン状態をチェック
      _isUserLoggedIn = prefs.getBool('user_logged_in') ?? false;
      _isStaffLoggedIn = prefs.getBool('staff_logged_in') ?? false;

      debugPrint('===== AppModeService初期化 =====');
      debugPrint('現在のモード: ${_currentMode.name}');
      debugPrint('ユーザーログイン: $_isUserLoggedIn');
      debugPrint('スタッフログイン: $_isStaffLoggedIn');
      notifyListeners();
    } catch (e) {
      debugPrint('モード読み込みエラー: $e');
    }
  }

  /// モードを切り替える
  Future<void> switchMode(AppMode newMode) async {
    if (_currentMode == newMode) return;

    // スタッフモードに切り替える場合、スタッフとしてログインしている必要がある
    if (newMode == AppMode.staff && !_isStaffLoggedIn) {
      debugPrint('❌ スタッフとしてログインしていないため、モード切り替えできません');
      return;
    }

    // ユーザーモードに切り替える場合、ユーザーとしてログインしている必要がある
    if (newMode == AppMode.user && !_isUserLoggedIn) {
      debugPrint('❌ ユーザーとしてログインしていないため、モード切り替えできません');
      return;
    }

    _currentMode = newMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_mode', newMode.name);
    notifyListeners();
    
    debugPrint('✅ モード切り替え完了: ${newMode.name}');
  }

  /// ユーザーとしてログイン
  Future<void> loginAsUser(Map<String, dynamic> userData) async {
    _isUserLoggedIn = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('user_logged_in', true);
    await prefs.setString('user_profile', json.encode(userData));
    
    // ユーザーモードに切り替え
    _currentMode = AppMode.user;
    await prefs.setString('app_mode', 'user');
    notifyListeners();
    
    debugPrint('✅ ユーザーログイン完了');
  }

  /// スタッフとしてログイン
  Future<void> loginAsStaff(Map<String, dynamic> staffData) async {
    _isStaffLoggedIn = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('staff_logged_in', true);
    await prefs.setString('staff_profile', json.encode(staffData));
    
    // スタッフモードに切り替え
    _currentMode = AppMode.staff;
    await prefs.setString('app_mode', 'staff');
    notifyListeners();
    
    debugPrint('✅ スタッフログイン完了');
  }

  /// ユーザーとしてログアウト
  Future<void> logoutUser() async {
    _isUserLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_logged_in');
    await prefs.remove('user_profile');
    
    // スタッフとしてログインしている場合はスタッフモードに切り替え
    if (_isStaffLoggedIn) {
      _currentMode = AppMode.staff;
      await prefs.setString('app_mode', 'staff');
    }
    notifyListeners();
    
    debugPrint('✅ ユーザーログアウト完了');
  }

  /// スタッフとしてログアウト
  Future<void> logoutStaff() async {
    _isStaffLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('staff_logged_in');
    await prefs.remove('staff_profile');
    
    // ユーザーとしてログインしている場合はユーザーモードに切り替え
    if (_isUserLoggedIn) {
      _currentMode = AppMode.user;
      await prefs.setString('app_mode', 'user');
    }
    notifyListeners();
    
    debugPrint('✅ スタッフログアウト完了');
  }

  /// プロフィールデータを取得
  Future<Map<String, dynamic>?> getProfile(AppMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = mode == AppMode.user ? 'user_profile' : 'staff_profile';
      final profileJson = prefs.getString(key);
      if (profileJson != null && profileJson.isNotEmpty) {
        return json.decode(profileJson) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('プロフィール取得エラー: $e');
    }
    return null;
  }
}

/// アプリモード
enum AppMode {
  user,  // ユーザーモード
  staff, // スタッフモード
}
