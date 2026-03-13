class PortfolioPhoto {
  final String id;
  final String staffProfileId;
  final String photoUrl;
  final int displayOrder;
  final DateTime createdAt;

  const PortfolioPhoto({
    required this.id,
    required this.staffProfileId,
    required this.photoUrl,
    required this.displayOrder,
    required this.createdAt,
  });

  factory PortfolioPhoto.fromJson(Map<String, dynamic> json) {
    return PortfolioPhoto(
      id: json['id'] as String,
      staffProfileId: json['staff_profile_id'] as String,
      photoUrl: json['photo_url'] as String,
      displayOrder: json['display_order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
