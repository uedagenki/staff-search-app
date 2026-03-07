import 'company.dart'; // OfferStatusとOfferStatusExtensionをインポート

/// 店舗スタッフ登録オファーモデル
class StoreStaffOffer {
  final String id;
  final String companyId;
  final String companyName;
  final String staffId;
  final String staffName;
  final String staffEmail;
  final String position; // 提案するポジション
  final String message; // オファーメッセージ
  final double tipCommissionRate; // 提示する投げ銭還元率
  final List<String> benefits; // 特典
  final OfferStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final String? responseMessage; // スタッフからの返信メッセージ

  StoreStaffOffer({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.staffId,
    required this.staffName,
    required this.staffEmail,
    required this.position,
    required this.message,
    required this.tipCommissionRate,
    required this.benefits,
    required this.status,
    required this.createdAt,
    this.respondedAt,
    this.responseMessage,
  });

  factory StoreStaffOffer.fromJson(Map<String, dynamic> json) {
    return StoreStaffOffer(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      companyName: json['companyName'] as String,
      staffId: json['staffId'] as String,
      staffName: json['staffName'] as String,
      staffEmail: json['staffEmail'] as String,
      position: json['position'] as String,
      message: json['message'] as String,
      tipCommissionRate: (json['tipCommissionRate'] as num).toDouble(),
      benefits: List<String>.from(json['benefits'] as List),
      status: OfferStatus.values.firstWhere(
        (s) => s.toString() == 'OfferStatus.${json['status']}',
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'] as String)
          : null,
      responseMessage: json['responseMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'companyName': companyName,
      'staffId': staffId,
      'staffName': staffName,
      'staffEmail': staffEmail,
      'position': position,
      'message': message,
      'tipCommissionRate': tipCommissionRate,
      'benefits': benefits,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
      'responseMessage': responseMessage,
    };
  }
}
