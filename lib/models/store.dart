/// 店舗（会社）モデル
class Store {
  final String id;
  final String name; // 店舗名
  final String? description; // 店舗説明
  final String? address; // 住所
  final String? phoneNumber; // 電話番号
  final String? website; // ウェブサイト
  final String? logoUrl; // ロゴURL
  final String ownerId; // オーナーID
  final String ownerName; // オーナー名
  final double tipCommissionRate; // 投げ銭還元率（0.0-10.0%）
  final List<String> staffIds; // 所属スタッフIDリスト
  final bool isVerified; // 認証済み店舗
  final DateTime createdAt;
  final DateTime updatedAt;

  Store({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.phoneNumber,
    this.website,
    this.logoUrl,
    required this.ownerId,
    required this.ownerName,
    this.tipCommissionRate = 5.0, // デフォルト5%
    required this.staffIds,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      website: json['website'] as String?,
      logoUrl: json['logoUrl'] as String?,
      ownerId: json['ownerId'] as String,
      ownerName: json['ownerName'] as String,
      tipCommissionRate: (json['tipCommissionRate'] as num?)?.toDouble() ?? 5.0,
      staffIds: List<String>.from(json['staffIds'] as List? ?? []),
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'phoneNumber': phoneNumber,
      'website': website,
      'logoUrl': logoUrl,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'tipCommissionRate': tipCommissionRate,
      'staffIds': staffIds,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Store copyWith({
    String? name,
    String? description,
    String? address,
    String? phoneNumber,
    String? website,
    String? logoUrl,
    double? tipCommissionRate,
    List<String>? staffIds,
    bool? isVerified,
  }) {
    return Store(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      logoUrl: logoUrl ?? this.logoUrl,
      ownerId: ownerId,
      ownerName: ownerName,
      tipCommissionRate: tipCommissionRate ?? this.tipCommissionRate,
      staffIds: staffIds ?? this.staffIds,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// スタッフを追加
  Store addStaff(String staffId) {
    if (staffIds.contains(staffId)) return this;
    return copyWith(staffIds: [...staffIds, staffId]);
  }

  /// スタッフを削除
  Store removeStaff(String staffId) {
    return copyWith(staffIds: staffIds.where((id) => id != staffId).toList());
  }

  /// スタッフ数
  int get staffCount => staffIds.length;

  /// 投げ銭の店舗取り分を計算
  int calculateStoreCommission(int tipAmount) {
    return (tipAmount * tipCommissionRate / 100).round();
  }

  /// スタッフの取り分を計算
  int calculateStaffAmount(int tipAmount) {
    return tipAmount - calculateStoreCommission(tipAmount);
  }
}

/// スタッフの店舗所属情報
class StaffAffiliation {
  final String staffId;
  final String staffName;
  final String storeId;
  final String storeName;
  final DateTime joinedAt;
  final bool isActive;

  StaffAffiliation({
    required this.staffId,
    required this.staffName,
    required this.storeId,
    required this.storeName,
    required this.joinedAt,
    this.isActive = true,
  });

  factory StaffAffiliation.fromJson(Map<String, dynamic> json) {
    return StaffAffiliation(
      staffId: json['staffId'] as String,
      staffName: json['staffName'] as String,
      storeId: json['storeId'] as String,
      storeName: json['storeName'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staffId': staffId,
      'staffName': staffName,
      'storeId': storeId,
      'storeName': storeName,
      'joinedAt': joinedAt.toIso8601String(),
      'isActive': isActive,
    };
  }
}
