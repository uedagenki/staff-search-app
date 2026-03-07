/// 企業モデル（ヘッドハンティング用 + 店舗スタッフ管理）
class Company {
  final String id;
  final String name; // 企業名
  final String industry; // 業種
  final String description; // 企業説明
  final String address; // 住所
  final String? phoneNumber; // 電話番号
  final String? website; // ウェブサイト
  final String? logoUrl; // ロゴ画像URL
  final String contactEmail; // 連絡先メール
  final String contactPerson; // 担当者名
  final int employeeCount; // 従業員数
  final DateTime establishedDate; // 設立日
  final List<String> benefits; // 福利厚生
  final bool isVerified; // 認証済み企業
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // 店舗（会社）スタッフ管理用フィールド
  final List<String> staffIds; // 所属スタッフIDリスト
  final double tipCommissionRate; // 投げ銭還元率（0.0〜0.10 = 0%〜10%）
  final bool isStore; // 店舗かどうか（true=店舗、false=一般企業）

  Company({
    required this.id,
    required this.name,
    required this.industry,
    required this.description,
    required this.address,
    this.phoneNumber,
    this.website,
    this.logoUrl,
    required this.contactEmail,
    required this.contactPerson,
    required this.employeeCount,
    required this.establishedDate,
    required this.benefits,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
    List<String>? staffIds,
    this.tipCommissionRate = 0.0,
    this.isStore = false,
  }) : staffIds = staffIds ?? [];

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as String,
      name: json['name'] as String,
      industry: json['industry'] as String,
      description: json['description'] as String,
      address: json['address'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      website: json['website'] as String?,
      logoUrl: json['logoUrl'] as String?,
      contactEmail: json['contactEmail'] as String,
      contactPerson: json['contactPerson'] as String,
      employeeCount: json['employeeCount'] as int,
      establishedDate: DateTime.parse(json['establishedDate'] as String),
      benefits: List<String>.from(json['benefits'] as List),
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      staffIds: json['staffIds'] != null ? List<String>.from(json['staffIds'] as List) : [],
      tipCommissionRate: (json['tipCommissionRate'] as num?)?.toDouble() ?? 0.0,
      isStore: json['isStore'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'industry': industry,
      'description': description,
      'address': address,
      'phoneNumber': phoneNumber,
      'website': website,
      'logoUrl': logoUrl,
      'contactEmail': contactEmail,
      'contactPerson': contactPerson,
      'employeeCount': employeeCount,
      'establishedDate': establishedDate.toIso8601String(),
      'benefits': benefits,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'staffIds': staffIds,
      'tipCommissionRate': tipCommissionRate,
      'isStore': isStore,
    };
  }

  Company copyWith({
    String? name,
    String? industry,
    String? description,
    String? address,
    String? phoneNumber,
    String? website,
    String? logoUrl,
    String? contactEmail,
    String? contactPerson,
    int? employeeCount,
    DateTime? establishedDate,
    List<String>? benefits,
    bool? isVerified,
    List<String>? staffIds,
    double? tipCommissionRate,
    bool? isStore,
  }) {
    return Company(
      id: id,
      name: name ?? this.name,
      industry: industry ?? this.industry,
      description: description ?? this.description,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      logoUrl: logoUrl ?? this.logoUrl,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPerson: contactPerson ?? this.contactPerson,
      employeeCount: employeeCount ?? this.employeeCount,
      establishedDate: establishedDate ?? this.establishedDate,
      benefits: benefits ?? this.benefits,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      staffIds: staffIds ?? this.staffIds,
      tipCommissionRate: tipCommissionRate ?? this.tipCommissionRate,
      isStore: isStore ?? this.isStore,
    );
  }
}

/// ヘッドハンティングオファーモデル
class HeadhuntingOffer {
  final String id;
  final String companyId;
  final String companyName;
  final String staffId;
  final String staffName;
  final String position; // 募集職種
  final String description; // 詳細
  final int salaryMin; // 最低年収
  final int salaryMax; // 最高年収
  final String workLocation; // 勤務地
  final List<String> requirements; // 応募要件
  final List<String> benefits; // 福利厚生
  final OfferStatus status; // オファーステータス
  final DateTime createdAt;
  final DateTime? respondedAt;
  final String? responseMessage; // 返信メッセージ

  HeadhuntingOffer({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.staffId,
    required this.staffName,
    required this.position,
    required this.description,
    required this.salaryMin,
    required this.salaryMax,
    required this.workLocation,
    required this.requirements,
    required this.benefits,
    required this.status,
    required this.createdAt,
    this.respondedAt,
    this.responseMessage,
  });

  factory HeadhuntingOffer.fromJson(Map<String, dynamic> json) {
    return HeadhuntingOffer(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      companyName: json['companyName'] as String,
      staffId: json['staffId'] as String,
      staffName: json['staffName'] as String,
      position: json['position'] as String,
      description: json['description'] as String,
      salaryMin: json['salaryMin'] as int,
      salaryMax: json['salaryMax'] as int,
      workLocation: json['workLocation'] as String,
      requirements: List<String>.from(json['requirements'] as List),
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
      'position': position,
      'description': description,
      'salaryMin': salaryMin,
      'salaryMax': salaryMax,
      'workLocation': workLocation,
      'requirements': requirements,
      'benefits': benefits,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
      'responseMessage': responseMessage,
    };
  }
}

/// オファーステータス
enum OfferStatus {
  pending, // 確認待ち
  accepted, // 承諾
  declined, // 辞退
  cancelled, // キャンセル
}

extension OfferStatusExtension on OfferStatus {
  String get displayName {
    switch (this) {
      case OfferStatus.pending:
        return '確認待ち';
      case OfferStatus.accepted:
        return '承諾';
      case OfferStatus.declined:
        return '辞退';
      case OfferStatus.cancelled:
        return 'キャンセル';
    }
  }

  String get emoji {
    switch (this) {
      case OfferStatus.pending:
        return '⏳';
      case OfferStatus.accepted:
        return '✅';
      case OfferStatus.declined:
        return '❌';
      case OfferStatus.cancelled:
        return '🚫';
    }
  }
}
