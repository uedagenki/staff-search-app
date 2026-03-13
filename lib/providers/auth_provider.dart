import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/google_sign_in_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _isRestoringSession = true;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get isRestoringSession => _isRestoringSession;
  String? get errorMessage => _errorMessage;

  final _api = ApiClient();

  Future<void> restoreSession() async {
    final token = await _api.getAccessToken();
    if (token == null) {
      _isLoggedIn = false;
      _isRestoringSession = false;
      notifyListeners();
      return;
    }
    try {
      final resp = await _api.get('/api/v1/auth/me');
      if (resp.isSuccess && resp.data != null) {
        _currentUser = _userFromBackend(resp.data!);
        _isLoggedIn = true;
      } else {
        await _api.clearTokens();
        _isLoggedIn = false;
      }
    } catch (_) {
      await _api.clearTokens();
      _isLoggedIn = false;
    }
    _isRestoringSession = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final resp = await _api.post(
        '/api/v1/auth/login',
        {'email': email, 'password': password},
        requireAuth: false,
      );
      if (resp.isSuccess && resp.data != null) {
        await _api.saveTokens(
          resp.data!['access_token'] as String,
          resp.data!['refresh_token'] as String,
        );
        final userMap = resp.data!['user'] as Map<String, dynamic>;
        _currentUser = _userFromBackend(userMap);
        _isLoggedIn = true;
      } else {
        _errorMessage = _mapAuthError(resp.statusCode, resp.error);
      }
    } on UnauthorizedException {
      _errorMessage = 'Invalid email or password.';
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again later.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> register(
    String name,
    String email,
    String? phone,
    String password,
    String role,
    bool privacyPolicyAccepted,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final body = <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'privacy_policy_accepted': privacyPolicyAccepted,
      };
      if (phone != null && phone.isNotEmpty) body['phone'] = phone;

      final resp = await _api.post('/api/v1/auth/register', body, requireAuth: false);
      if (resp.isSuccess && resp.data != null) {
        await _api.saveTokens(
          resp.data!['access_token'] as String,
          resp.data!['refresh_token'] as String,
        );
        final userMap = resp.data!['user'] as Map<String, dynamic>;
        _currentUser = _userFromBackend(userMap);
        _isLoggedIn = true;
      } else {
        if (resp.statusCode == 409) {
          _errorMessage = 'An account with this email already exists.';
        } else {
          _errorMessage = _mapAuthError(resp.statusCode, resp.error);
        }
      }
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again later.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loginWithGoogle() async {
    final result = await GoogleSignInService.instance.signIn();

    if (result is GoogleSignInCancelled) return;

    if (result is GoogleSignInError) {
      _errorMessage = result.message;
      notifyListeners();
      return;
    }

    final success = result as GoogleSignInSuccess;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final resp = await _api.post(
        '/api/v1/auth/google',
        {'id_token': success.idToken},
        requireAuth: false,
      );
      if (resp.isSuccess && resp.data != null) {
        await _api.saveTokens(
          resp.data!['access_token'] as String,
          resp.data!['refresh_token'] as String,
        );
        final userMap = resp.data!['user'] as Map<String, dynamic>;
        _currentUser = _userFromBackend(userMap);
        _isLoggedIn = true;
      } else {
        await GoogleSignInService.instance.signOut();
        if (resp.statusCode == 403) {
          _errorMessage = 'This account has been suspended.';
        } else {
          _errorMessage = 'Google authentication failed. Please try again.';
        }
      }
    } catch (_) {
      await GoogleSignInService.instance.signOut();
      _errorMessage = 'Unable to connect. Check your network and retry.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Returns null on success, or an error message string on failure.
  Future<String?> changePassword(String currentPassword, String newPassword) async {
    try {
      final resp = await _api.post(
        '/api/v1/auth/change-password',
        {'current_password': currentPassword, 'new_password': newPassword},
      );
      if (resp.isSuccess) return null;
      if (resp.statusCode == 401) return '現在のパスワードが正しくありません';
      return 'エラーが発生しました。もう一度お試しください。';
    } catch (_) {
      return 'エラーが発生しました。もう一度お試しください。';
    }
  }

  Future<void> logout() async {
    try {
      await _api.post('/api/v1/auth/logout', {});
    } catch (_) {}
    await _api.clearTokens();
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  void updateCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  String _mapAuthError(int statusCode, String? errorCode) {
    switch (statusCode) {
      case 401:
        return 'Invalid email or password.';
      case 403:
        if (errorCode == 'account_disabled') {
          return 'Your account has been disabled. Contact support.';
        }
        return 'Access denied.';
      case 429:
        return 'Too many attempts. Please wait before trying again.';
      default:
        return 'Something went wrong. Please try again later.';
    }
  }

  User _userFromBackend(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phoneNumber: json['phone_number'] as String?,
      profileImage: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      points: json['points'] as int? ?? 0,
      role: json['role'] as String? ?? 'user',
      isStaffRegistered: json['is_staff_registered'] as bool? ?? false,
      privacyPolicyAccepted: json['privacy_policy_accepted'] as bool?,
    );
  }
}
