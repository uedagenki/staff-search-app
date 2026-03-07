import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/post_comment.dart';

/// 投稿コメント管理サービス
class PostCommentService {
  static const String _commentsKey = 'post_comments';
  static const String _currentUserKey = 'current_user';

  /// コメント一覧を取得
  Future<List<PostComment>> getComments(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final commentsJson = prefs.getString(_commentsKey);
    
    if (commentsJson == null) {
      return [];
    }

    final List<dynamic> commentsList = json.decode(commentsJson);
    final allComments = commentsList
        .map((json) => PostComment.fromJson(json))
        .toList();

    // 指定された投稿のコメントのみフィルター
    return allComments
        .where((comment) => comment.postId == postId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// コメントを投稿
  Future<PostComment> addComment({
    required String postId,
    required String content,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 現在のユーザー情報を取得
    final currentUser = await _getCurrentUser();
    
    // 新しいコメントを作成
    final comment = PostComment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      userId: currentUser['id'] as String,
      userName: currentUser['name'] as String,
      userAvatar: currentUser['avatar'] as String?,
      content: content,
      createdAt: DateTime.now(),
    );

    // 既存のコメント一覧を取得
    final commentsJson = prefs.getString(_commentsKey);
    List<dynamic> commentsList = [];
    
    if (commentsJson != null) {
      commentsList = json.decode(commentsJson);
    }

    // 新しいコメントを追加
    commentsList.add(comment.toJson());

    // 保存
    await prefs.setString(_commentsKey, json.encode(commentsList));

    return comment;
  }

  /// コメントにいいねを付ける/外す
  Future<void> toggleCommentLike(String commentId) async {
    final prefs = await SharedPreferences.getInstance();
    final commentsJson = prefs.getString(_commentsKey);
    
    if (commentsJson == null) return;

    List<dynamic> commentsList = json.decode(commentsJson);
    
    for (var i = 0; i < commentsList.length; i++) {
      if (commentsList[i]['id'] == commentId) {
        final comment = PostComment.fromJson(commentsList[i]);
        comment.isLiked = !comment.isLiked;
        comment.likeCount += comment.isLiked ? 1 : -1;
        commentsList[i] = comment.toJson();
        break;
      }
    }

    await prefs.setString(_commentsKey, json.encode(commentsList));
  }

  /// コメントを削除
  Future<void> deleteComment(String commentId) async {
    final prefs = await SharedPreferences.getInstance();
    final commentsJson = prefs.getString(_commentsKey);
    
    if (commentsJson == null) return;

    List<dynamic> commentsList = json.decode(commentsJson);
    commentsList.removeWhere((json) => json['id'] == commentId);

    await prefs.setString(_commentsKey, json.encode(commentsList));
  }

  /// 現在のユーザー情報を取得（デモ用）
  Future<Map<String, dynamic>> _getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    
    if (userJson != null) {
      return json.decode(userJson);
    }

    // デフォルトユーザー
    return {
      'id': 'user_demo',
      'name': 'デモユーザー',
      'avatar': null,
    };
  }

  /// 現在のユーザー情報を設定
  Future<void> setCurrentUser({
    required String id,
    required String name,
    String? avatar,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _currentUserKey,
      json.encode({
        'id': id,
        'name': name,
        'avatar': avatar,
      }),
    );
  }

  /// デモコメントを生成
  Future<void> generateDemoComments(String postId) async {
    final demoComments = [
      {'userName': '田中太郎', 'content': '素敵な投稿ですね！✨'},
      {'userName': '佐藤花子', 'content': 'いつも応援しています💕'},
      {'userName': '鈴木一郎', 'content': 'すごい！参考になります👍'},
      {'userName': '高橋美咲', 'content': 'また行きたいです😊'},
      {'userName': '伊藤健太', 'content': '素晴らしいですね🎉'},
    ];

    for (var i = 0; i < demoComments.length; i++) {
      final comment = PostComment(
        id: 'demo_comment_${postId}_$i',
        postId: postId,
        userId: 'demo_user_$i',
        userName: demoComments[i]['userName']!,
        userAvatar: null,
        content: demoComments[i]['content']!,
        createdAt: DateTime.now().subtract(Duration(hours: i + 1)),
        likeCount: (5 - i) * 2,
      );

      final prefs = await SharedPreferences.getInstance();
      final commentsJson = prefs.getString(_commentsKey);
      List<dynamic> commentsList = [];
      
      if (commentsJson != null) {
        commentsList = json.decode(commentsJson);
      }

      // 既に存在するか確認
      if (!commentsList.any((json) => json['id'] == comment.id)) {
        commentsList.add(comment.toJson());
        await prefs.setString(_commentsKey, json.encode(commentsList));
      }
    }
  }
}
