class Store {
  final String id;
  final String name;
  final String category;
  final String address;
  final String phoneNumber;
  final String description;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final double latitude;
  final double longitude;
  final List<String> businessHours;
  final List<String> amenities;

  Store({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.phoneNumber,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.latitude,
    required this.longitude,
    required this.businessHours,
    required this.amenities,
  });
}
