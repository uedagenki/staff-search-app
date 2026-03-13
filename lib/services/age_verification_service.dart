import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 年齢確認サービス
class AgeVerificationService {
  static const String _keyAgeVerified = 'age_verified';
  static const String _keyBirthDate = 'birth_date';
  static const String _keyVerificationType = 'verification_type';
  static const String _keyVerifiedAt = 'verified_at';

  /// 年齢確認ステータスを取得
  Future<AgeVerificationStatus> getVerificationStatus(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_keyAgeVerified}_$userId';
    final birthDateKey = '${_keyBirthDate}_$userId';
    
    final isVerified = prefs.getBool(key) ?? false;
    final birthDateStr = prefs.getString(birthDateKey);
    
    if (!isVerified || birthDateStr == null) {
      return AgeVerificationStatus(
        isVerified: false,
        age: null,
        canUseDM: false,
        canDownload: false,
        canLiveStream: false,
      );
    }

    final birthDate = DateTime.parse(birthDateStr);
    final age = _calculateAge(birthDate);

    return AgeVerificationStatus(
      isVerified: true,
      age: age,
      birthDate: birthDate,
      canUseDM: age >= 16,
      canDownload: age >= 16,
      canLiveStream: age >= 18,
    );
  }

  /// 年齢を計算
  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// 生年月日を保存（登録時）
  Future<bool> saveBirthDate(String userId, DateTime birthDate) async {
    final age = _calculateAge(birthDate);
    
    // 13歳未満チェック
    if (age < 13) {
      return false; // 登録不可
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_keyBirthDate}_$userId', birthDate.toIso8601String());
    await prefs.setBool('${_keyAgeVerified}_$userId', true);
    await prefs.setString('${_keyVerificationType}_$userId', 'birth_date');
    await prefs.setString('${_keyVerifiedAt}_$userId', DateTime.now().toIso8601String());

    return true;
  }

  /// 本人確認（18歳以上のライブ配信用）
  Future<bool> verifyIdentity(String userId, {
    required String documentType, // 'drivers_license', 'passport', 'my_number_card'
    required String documentNumber,
    String? documentImagePath,
  }) async {
    // 実際のアプリでは、ここで本人確認APIを呼び出す
    // 今回はモックとして、生年月日から18歳以上であることを確認
    
    final status = await getVerificationStatus(userId);
    if (!status.isVerified || status.age == null || status.age! < 18) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_keyVerificationType}_$userId', 'identity_verified');
    await prefs.setString('identity_document_type_$userId', documentType);
    await prefs.setString('${_keyVerifiedAt}_$userId', DateTime.now().toIso8601String());

    return true;
  }

  /// 本人確認済みかチェック
  Future<bool> isIdentityVerified(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final verificationType = prefs.getString('${_keyVerificationType}_$userId');
    return verificationType == 'identity_verified';
  }

  /// 機能制限のチェック
  Future<FeatureRestriction> checkFeatureRestriction(String userId) async {
    final status = await getVerificationStatus(userId);
    
    if (!status.isVerified || status.age == null) {
      return FeatureRestriction(
        canComment: false,
        canLike: false,
        canShare: false,
        canDM: false,
        canDownload: false,
        canLiveStream: false,
        canReceiveGifts: false,
        message: '年齢確認が必要です',
      );
    }

    final age = status.age!;

    if (age < 13) {
      return FeatureRestriction(
        canComment: false,
        canLike: false,
        canShare: false,
        canDM: false,
        canDownload: false,
        canLiveStream: false,
        canReceiveGifts: false,
        message: 'このアプリは13歳以上が対象です',
      );
    }

    if (age >= 13 && age < 16) {
      return FeatureRestriction(
        canComment: true,
        canLike: true,
        canShare: true,
        canDM: false,
        canDownload: false,
        canLiveStream: false,
        canReceiveGifts: false,
        message: 'DM・ダウンロードは16歳以上から利用できます',
      );
    }

    if (age >= 16 && age < 18) {
      return FeatureRestriction(
        canComment: true,
        canLike: true,
        canShare: true,
        canDM: true,
        canDownload: true,
        canLiveStream: false,
        canReceiveGifts: false,
        message: 'ライブ配信は18歳以上から利用できます',
      );
    }

    // 18歳以上
    final isIdentityVerified = await this.isIdentityVerified(userId);
    return FeatureRestriction(
      canComment: true,
      canLike: true,
      canShare: true,
      canDM: true,
      canDownload: true,
      canLiveStream: isIdentityVerified,
      canReceiveGifts: isIdentityVerified,
      message: isIdentityVerified ? null : 'ライブ配信には本人確認が必要です',
    );
  }

  /// 年齢警告を表示すべきかチェック
  Future<bool> shouldShowAgeWarning(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'age_warning_shown_$userId';
    final shown = prefs.getBool(key) ?? false;
    
    if (!shown) {
      await prefs.setBool(key, true);
      return true;
    }
    return false;
  }
}

/// 年齢確認ステータス
class AgeVerificationStatus {
  final bool isVerified;
  final int? age;
  final DateTime? birthDate;
  final bool canUseDM;
  final bool canDownload;
  final bool canLiveStream;

  AgeVerificationStatus({
    required this.isVerified,
    required this.age,
    this.birthDate,
    required this.canUseDM,
    required this.canDownload,
    required this.canLiveStream,
  });

  Map<String, dynamic> toJson() {
    return {
      'isVerified': isVerified,
      'age': age,
      'birthDate': birthDate?.toIso8601String(),
      'canUseDM': canUseDM,
      'canDownload': canDownload,
      'canLiveStream': canLiveStream,
    };
  }
}

/// 機能制限情報
class FeatureRestriction {
  final bool canComment;
  final bool canLike;
  final bool canShare;
  final bool canDM;
  final bool canDownload;
  final bool canLiveStream;
  final bool canReceiveGifts;
  final String? message;

  FeatureRestriction({
    required this.canComment,
    required this.canLike,
    required this.canShare,
    required this.canDM,
    required this.canDownload,
    required this.canLiveStream,
    required this.canReceiveGifts,
    this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'canComment': canComment,
      'canLike': canLike,
      'canShare': canShare,
      'canDM': canDM,
      'canDownload': canDownload,
      'canLiveStream': canLiveStream,
      'canReceiveGifts': canReceiveGifts,
      'message': message,
    };
  }
}
