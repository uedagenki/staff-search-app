import 'portfolio_photo.dart';

class StaffProfile {
  final String id;
  final String userId;
  final String name;
  final String? avatarUrl;
  final String staffNumber;
  final String jobTitle;
  final String jobCategory;
  final String? location;
  final String? bio;
  final String? introVideoUrl;
  final bool isAvailable;
  final bool acceptBookings;
  final double rating;
  final int reviewCount;
  final int followersCount;
  final int totalTipsReceived;
  final List<PortfolioPhoto> portfolioPhotos;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StaffProfile({
    required this.id,
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.staffNumber,
    required this.jobTitle,
    required this.jobCategory,
    this.location,
    this.bio,
    this.introVideoUrl,
    required this.isAvailable,
    required this.acceptBookings,
    required this.rating,
    required this.reviewCount,
    required this.followersCount,
    required this.totalTipsReceived,
    required this.portfolioPhotos,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StaffProfile.fromJson(Map<String, dynamic> json) {
    final photos = (json['portfolio_photos'] as List<dynamic>? ?? [])
        .map((e) => PortfolioPhoto.fromJson(e as Map<String, dynamic>))
        .toList();
    return StaffProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      staffNumber: json['staff_number'] as String,
      jobTitle: json['job_title'] as String? ?? '',
      jobCategory: json['job_category'] as String? ?? '',
      location: json['location'] as String?,
      bio: json['bio'] as String?,
      introVideoUrl: json['intro_video_url'] as String?,
      isAvailable: json['is_available'] as bool? ?? false,
      acceptBookings: json['accept_bookings'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      followersCount: json['followers_count'] as int? ?? 0,
      totalTipsReceived: json['total_tips_received'] as int? ?? 0,
      portfolioPhotos: photos,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
