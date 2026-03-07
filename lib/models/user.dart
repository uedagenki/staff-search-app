import 'dart:convert';

class User {
  final String id;
  String email;
  String name;
  String? phoneNumber;
  String? profileImage;
  String? bio;
  DateTime? birthDate;
  String? gender; // male, female, other
  String? address;
  DateTime createdAt;
  DateTime? lastLoginAt;
  int points; // ポイント残高
  bool isEmailVerified;
  List<String>? interests; // ユーザーの興味・カテゴリー
  bool? privacyPolicyAccepted;
  DateTime? privacyPolicyAcceptedAt;
  String? privacyPolicyVersion;
  String role; // user, staff, admin
  bool isStaffRegistered; // スタッフ登録済みフラグ

  User({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.profileImage,
    this.bio,
    this.birthDate,
    this.gender,
    this.address,
    required this.createdAt,
    this.lastLoginAt,
    this.points = 0,
    this.isEmailVerified = false,
    this.interests,
    this.privacyPolicyAccepted,
    this.privacyPolicyAcceptedAt,
    this.privacyPolicyVersion,
    this.role = 'user', // デフォルトはuser
    this.isStaffRegistered = false, // デフォルトは未登録
  });

  // 年齢を計算
  int? get age {
    if (birthDate == null) return null;
    final today = DateTime.now();
    int age = today.year - birthDate!.year;
    if (today.month < birthDate!.month ||
        (today.month == birthDate!.month && today.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  factory User.fromJson(Map<String, dynamic> json, [String? docId]) {
    return User(
      id: docId ?? json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      profileImage: json['profileImage'] as String?,
      bio: json['bio'] as String?,
      birthDate: json['birthDate'] != null
          ? (json['birthDate'] is String 
              ? DateTime.parse(json['birthDate'] as String)
              : (json['birthDate'] as dynamic).toDate())
          : null,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      createdAt: json['createdAt'] is String 
          ? DateTime.parse(json['createdAt'] as String)
          : (json['createdAt'] as dynamic).toDate(),
      lastLoginAt: json['lastLoginAt'] != null
          ? (json['lastLoginAt'] is String
              ? DateTime.parse(json['lastLoginAt'] as String)
              : (json['lastLoginAt'] as dynamic).toDate())
          : null,
      points: json['points'] as int? ?? 0,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      interests: json['interests'] != null ? List<String>.from(json['interests']) : null,
      privacyPolicyAccepted: json['privacyPolicyAccepted'] as bool?,
      privacyPolicyAcceptedAt: json['privacyPolicyAcceptedAt'] != null
          ? (json['privacyPolicyAcceptedAt'] is String
              ? DateTime.parse(json['privacyPolicyAcceptedAt'] as String)
              : (json['privacyPolicyAcceptedAt'] as dynamic).toDate())
          : null,
      privacyPolicyVersion: json['privacyPolicyVersion'] as String?,
      role: json['role'] as String? ?? 'user',
      isStaffRegistered: json['isStaffRegistered'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'bio': bio,
      'birthDate': birthDate?.toIso8601String(),
      'gender': gender,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'points': points,
      'isEmailVerified': isEmailVerified,
      'interests': interests,
      'privacyPolicyAccepted': privacyPolicyAccepted,
      'privacyPolicyAcceptedAt': privacyPolicyAcceptedAt?.toIso8601String(),
      'privacyPolicyVersion': privacyPolicyVersion,
      'role': role,
      'isStaffRegistered': isStaffRegistered,
    };
  }

  User copyWith({
    String? email,
    String? name,
    String? phoneNumber,
    String? profileImage,
    String? bio,
    DateTime? birthDate,
    String? gender,
    String? address,
    DateTime? lastLoginAt,
    int? points,
    bool? isEmailVerified,
    List<String>? interests,
    bool? privacyPolicyAccepted,
    DateTime? privacyPolicyAcceptedAt,
    String? privacyPolicyVersion,
    String? role,
    bool? isStaffRegistered,
  }) {
    return User(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      points: points ?? this.points,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      interests: interests ?? this.interests,
      privacyPolicyAccepted: privacyPolicyAccepted ?? this.privacyPolicyAccepted,
      privacyPolicyAcceptedAt: privacyPolicyAcceptedAt ?? this.privacyPolicyAcceptedAt,
      privacyPolicyVersion: privacyPolicyVersion ?? this.privacyPolicyVersion,
      role: role ?? this.role,
      isStaffRegistered: isStaffRegistered ?? this.isStaffRegistered,
    );
  }

  // LocalStorageに保存用
  String toJsonString() => jsonEncode(toJson());
  
  static User fromJsonString(String jsonString) =>
      User.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
}
