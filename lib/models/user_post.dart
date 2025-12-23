import 'package:flutter/material.dart';

class UserPost {
  final String id;
  final String userId;
  final String userName;
  final String userProfileImage;
  final String? staffId;
  final String? staffName;
  final String content;
  final List<String> imageUrls;
  final List<String> videoUrls;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isLiked;
  final String? location;
  final List<String> hashtags;

  UserPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userProfileImage,
    this.staffId,
    this.staffName,
    required this.content,
    required this.imageUrls,
    required this.videoUrls,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.isLiked,
    this.location,
    required this.hashtags,
  });

  // デモデータ
  static List<UserPost> getDemoData() {
    return [
      UserPost(
        id: 'post_001',
        userId: 'user_001',
        userName: '田中 花子',
        userProfileImage: 'https://i.pravatar.cc/400?img=10',
        staffId: 'staff_001',
        staffName: '佐藤 美咲',
        content: '今日は佐藤さんにヘアカットしてもらいました！最高の仕上がりです✨\n#美容師 #ヘアカット #大満足',
        imageUrls: [
          'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=800',
          'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=800',
        ],
        videoUrls: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likeCount: 156,
        commentCount: 23,
        shareCount: 8,
        isLiked: false,
        location: '東京都渋谷区',
        hashtags: ['美容師', 'ヘアカット', '大満足'],
      ),
      UserPost(
        id: 'post_002',
        userId: 'user_002',
        userName: '山田 太郎',
        userProfileImage: 'https://i.pravatar.cc/400?img=12',
        staffId: 'staff_003',
        staffName: '鈴木 健太',
        content: 'パーソナルトレーニング3ヶ月継続中！鈴木トレーナーのおかげで体重-5kg達成🎉\n#パーソナルトレーニング #ダイエット成功',
        imageUrls: [
          'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800',
        ],
        videoUrls: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likeCount: 289,
        commentCount: 45,
        shareCount: 15,
        isLiked: true,
        location: '東京都新宿区',
        hashtags: ['パーソナルトレーニング', 'ダイエット成功'],
      ),
      UserPost(
        id: 'post_003',
        userId: 'user_003',
        userName: '佐々木 愛',
        userProfileImage: 'https://i.pravatar.cc/400?img=15',
        staffId: 'staff_002',
        staffName: '高橋 由美',
        content: 'ネイルアート初体験✨\n高橋さんのセンスが素晴らしい！デザインも提案してくれて大満足です💅\n#ネイルサロン #ネイルアート',
        imageUrls: [
          'https://images.unsplash.com/photo-1604654894610-df63bc536371?w=800',
          'https://images.unsplash.com/photo-1610992015732-2449b76344bc?w=800',
          'https://images.unsplash.com/photo-1519014816548-bf5fe059798b?w=800',
        ],
        videoUrls: [],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likeCount: 432,
        commentCount: 67,
        shareCount: 22,
        isLiked: false,
        location: '東京都港区',
        hashtags: ['ネイルサロン', 'ネイルアート'],
      ),
    ];
  }
}
