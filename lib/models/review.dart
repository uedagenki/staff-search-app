class Review {
  final String id;
  final String staffId;
  final String staffName;
  final String staffImage;
  final String staffJobTitle;
  final double rating;
  final String comment;
  final DateTime timestamp;

  Review({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.staffImage,
    required this.staffJobTitle,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });
}
