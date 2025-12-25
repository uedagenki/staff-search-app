class Staff {
  final String id;
  final String name;
  final String jobTitle;
  final String category;
  final String profileImage;
  final List<String> profileImages; // 複数のプロフィール画像（最大5枚）
  final double rating;
  final int reviewCount;
  final bool isOnline;
  final bool isLive;
  final String location;
  final String bio;
  final List<String> skills;
  final int experience; // 経験年数
  final String qrCode;
  final double? latitude;
  final double? longitude;
  double? distance; // 現在地からの距離（km）
  final String? storeId; // 所属店舗ID
  final String? storeName; // 所属店舗名
  final String? companyName; // 会社名
  final int followersCount; // フォロワー数
  final double giftAmount; // 受け取ったギフト総額（円）
  final int categoryRank; // カテゴリー内ランキング
  final int totalStaffInCategory; // カテゴリー内の総スタッフ数
  final Map<String, dynamic>? pricing; // 料金情報（時間料金またはメニュー料金）

  Staff({
    required this.id,
    required this.name,
    required this.jobTitle,
    required this.category,
    required this.profileImage,
    List<String>? profileImages,
    required this.rating,
    required this.reviewCount,
    required this.isOnline,
    required this.isLive,
    required this.location,
    required this.bio,
    required this.skills,
    required this.experience,
    required this.qrCode,
    this.latitude,
    this.longitude,
    this.distance,
    this.storeId,
    this.storeName,
    this.companyName,
    this.followersCount = 0,
    this.giftAmount = 0.0,
    this.categoryRank = 1,
    this.totalStaffInCategory = 100,
    this.pricing,
  }) : profileImages = profileImages ?? [profileImage];

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'] as String,
      name: json['name'] as String,
      jobTitle: json['jobTitle'] as String,
      category: json['category'] as String,
      profileImage: json['profileImage'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      isOnline: json['isOnline'] as bool,
      isLive: json['isLive'] as bool,
      location: json['location'] as String,
      bio: json['bio'] as String,
      skills: List<String>.from(json['skills'] as List),
      experience: json['experience'] as int,
      qrCode: json['qrCode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'jobTitle': jobTitle,
      'category': category,
      'profileImage': profileImage,
      'rating': rating,
      'reviewCount': reviewCount,
      'isOnline': isOnline,
      'isLive': isLive,
      'location': location,
      'bio': bio,
      'skills': skills,
      'experience': experience,
      'qrCode': qrCode,
    };
  }
}
