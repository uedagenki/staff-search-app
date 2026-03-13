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

  factory Staff.fromApiResponse(Map<String, dynamic> json) {
    final photos = (json['portfolio_photos'] as List<dynamic>? ?? [])
        .map((p) => p['photo_url'] as String)
        .where((url) => url.isNotEmpty)
        .toList();
    final postMediaUrls = (json['post_media_urls'] as List<dynamic>? ?? [])
        .map((u) => u as String)
        .where((url) => url.isNotEmpty)
        .toList();
    final avatarUrl = json['avatar_url'] as String?;

    // Priority: avatar → portfolio photos → latest post images
    final allImages = [
      if (avatarUrl != null && avatarUrl.isNotEmpty) avatarUrl,
      ...photos,
      if (photos.isEmpty) ...postMediaUrls,
    ];

    final profileImage = allImages.isNotEmpty ? allImages.first : '';
    final validImages = allImages.where((u) => u.isNotEmpty).toList();
    return Staff(
      id: json['user_id'] as String,
      name: json['name'] as String? ?? '',
      jobTitle: json['job_title'] as String? ?? '',
      category: json['job_category'] as String? ?? '',
      profileImage: profileImage,
      profileImages: validImages.isNotEmpty ? validImages : [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      isOnline: json['is_available'] as bool? ?? false,
      isLive: false,
      location: json['location'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      bio: json['bio'] as String? ?? '',
      skills: [json['job_title'] as String? ?? ''],
      experience: 0,
      qrCode: json['staff_number'] as String? ?? '',
      followersCount: json['followers_count'] as int? ?? 0,
      giftAmount: (json['total_tips_received'] as int? ?? 0).toDouble(),
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
