import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/review.dart';

class ReviewService {
  static const String _reviewsKey = 'user_reviews';

  // レビュー一覧を取得
  Future<List<Review>> getReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final reviewsJson = prefs.getStringList(_reviewsKey) ?? [];
    
    return reviewsJson.map((json) {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return Review(
        id: data['id'] as String,
        staffId: data['staffId'] as String,
        staffName: data['staffName'] as String,
        staffImage: data['staffImage'] as String,
        staffJobTitle: data['staffJobTitle'] as String,
        rating: (data['rating'] as num).toDouble(),
        comment: data['comment'] as String,
        timestamp: DateTime.parse(data['timestamp'] as String),
      );
    }).toList();
  }

  // レビューを追加
  Future<void> addReview(Review review) async {
    final prefs = await SharedPreferences.getInstance();
    final reviewsJson = prefs.getStringList(_reviewsKey) ?? [];
    
    final reviewData = {
      'id': review.id,
      'staffId': review.staffId,
      'staffName': review.staffName,
      'staffImage': review.staffImage,
      'staffJobTitle': review.staffJobTitle,
      'rating': review.rating,
      'comment': review.comment,
      'timestamp': review.timestamp.toIso8601String(),
    };
    
    reviewsJson.add(jsonEncode(reviewData));
    await prefs.setStringList(_reviewsKey, reviewsJson);
  }

  // レビューを削除
  Future<void> deleteReview(String reviewId) async {
    final prefs = await SharedPreferences.getInstance();
    final reviewsJson = prefs.getStringList(_reviewsKey) ?? [];
    
    reviewsJson.removeWhere((json) {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return data['id'] == reviewId;
    });
    
    await prefs.setStringList(_reviewsKey, reviewsJson);
  }
}
