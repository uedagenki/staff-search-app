import 'package:flutter/foundation.dart';
import '../models/live_stream.dart';
import '../utils/storage_helper.dart';
import 'dart:convert';
import 'dart:math';

class LiveStreamService {
  static final LiveStreamService _instance = LiveStreamService._internal();
  factory LiveStreamService() => _instance;
  LiveStreamService._internal();

  // Agora App ID (本番環境では環境変数から取得)
  static const String agoraAppId = 'YOUR_AGORA_APP_ID';
  
  // サンプルトークン生成（本番環境ではサーバーサイドで生成）
  String _generateToken() {
    // 実際の本番環境では、Agoraサーバーから取得する
    // ここではデモ用のダミートークンを返す
    return 'sample_token_${DateTime.now().millisecondsSinceEpoch}';
  }

  // ライブ配信を開始
  Future<LiveStream> startLiveStream({
    required String staffId,
    required String staffName,
    required String staffProfileImage,
    required String title,
    required String category,
  }) async {
    final channelName = 'live_${staffId}_${DateTime.now().millisecondsSinceEpoch}';
    final token = _generateToken();

    final liveStream = LiveStream(
      id: 'stream_${DateTime.now().millisecondsSinceEpoch}',
      staffId: staffId,
      staffName: staffName,
      staffProfileImage: staffProfileImage,
      title: title,
      category: category,
      startedAt: DateTime.now(),
      channelName: channelName,
      token: token,
    );

    // LocalStorageに保存
    await _saveLiveStream(liveStream);

    return liveStream;
  }

  // ライブ配信を終了
  Future<void> stopLiveStream(String streamId) async {
    final streams = await getActiveLiveStreams();
    final stream = streams.firstWhere((s) => s.id == streamId);
    stream.isActive = false;

    // LocalStorageを更新
    final allStreams = await _getAllLiveStreams();
    final updatedStreams = allStreams.map((s) => s.id == streamId ? stream : s).toList();
    await _saveAllLiveStreams(updatedStreams);
  }

  // アクティブなライブ配信一覧を取得
  Future<List<LiveStream>> getActiveLiveStreams() async {
    final allStreams = await _getAllLiveStreams();
    return allStreams.where((s) => s.isActive).toList();
  }

  // 視聴者数を更新
  Future<void> updateViewerCount(String streamId, int count) async {
    final allStreams = await _getAllLiveStreams();
    final stream = allStreams.firstWhere((s) => s.id == streamId);
    stream.viewerCount = count;

    await _saveAllLiveStreams(allStreams);
  }

  // いいね数を増やす
  Future<void> incrementLikeCount(String streamId) async {
    final allStreams = await _getAllLiveStreams();
    final stream = allStreams.firstWhere((s) => s.id == streamId);
    stream.likeCount += 1;

    await _saveAllLiveStreams(allStreams);
  }

  // ギフト金額を追加
  Future<void> addGiftAmount(String streamId, int amount) async {
    final allStreams = await _getAllLiveStreams();
    final stream = allStreams.firstWhere((s) => s.id == streamId);
    stream.giftAmount += amount;

    await _saveAllLiveStreams(allStreams);
  }

  // コメントを追加
  Future<void> addComment({
    required String streamId,
    required String userId,
    required String userName,
    required String userProfileImage,
    required String message,
  }) async {
    final comment = LiveComment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      userName: userName,
      userProfileImage: userProfileImage,
      message: message,
      timestamp: DateTime.now(),
    );

    // コメントをLocalStorageに保存
    final commentsJson = await StorageHelper.getString('live_comments_$streamId');
    List<LiveComment> comments = [];
    
    if (commentsJson != null) {
      final List<dynamic> commentsData = jsonDecode(commentsJson);
      comments = commentsData.map((json) => LiveComment.fromJson(json)).toList();
    }

    comments.add(comment);

    // 最新100件のみ保持
    if (comments.length > 100) {
      comments = comments.sublist(comments.length - 100);
    }

    await StorageHelper.setString(
      'live_comments_$streamId',
      jsonEncode(comments.map((c) => c.toJson()).toList()),
    );
  }

  // コメント一覧を取得
  Future<List<LiveComment>> getComments(String streamId) async {
    final commentsJson = await StorageHelper.getString('live_comments_$streamId');
    
    if (commentsJson == null) {
      return [];
    }

    final List<dynamic> commentsData = jsonDecode(commentsJson);
    return commentsData.map((json) => LiveComment.fromJson(json)).toList();
  }

  // サンプルライブ配信データを生成
  Future<void> generateSampleLiveStreams() async {
    final sampleStreams = [
      LiveStream(
        id: 'stream_001',
        staffId: 'staff_001',
        staffName: '山田 美容師',
        staffProfileImage: 'https://i.pravatar.cc/150?img=1',
        title: '新しいヘアスタイルの紹介!',
        category: '美容・健康',
        startedAt: DateTime.now().subtract(const Duration(minutes: 15)),
        viewerCount: 234,
        likeCount: 45,
        giftAmount: 12500,
        channelName: 'live_staff_001_${DateTime.now().millisecondsSinceEpoch}',
        token: _generateToken(),
      ),
      LiveStream(
        id: 'stream_002',
        staffId: 'staff_002',
        staffName: '佐藤 トレーナー',
        staffProfileImage: 'https://i.pravatar.cc/150?img=2',
        title: '自宅でできる筋トレ講座',
        category: '美容・健康',
        startedAt: DateTime.now().subtract(const Duration(minutes: 45)),
        viewerCount: 567,
        likeCount: 123,
        giftAmount: 34000,
        channelName: 'live_staff_002_${DateTime.now().millisecondsSinceEpoch}',
        token: _generateToken(),
      ),
      LiveStream(
        id: 'stream_003',
        staffId: 'staff_003',
        staffName: '田中 ネイリスト',
        staffProfileImage: 'https://i.pravatar.cc/150?img=3',
        title: '春のネイルデザイン特集',
        category: '美容・健康',
        startedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        viewerCount: 89,
        likeCount: 12,
        giftAmount: 3500,
        channelName: 'live_staff_003_${DateTime.now().millisecondsSinceEpoch}',
        token: _generateToken(),
      ),
    ];

    await _saveAllLiveStreams(sampleStreams);
  }

  // Private helper methods
  Future<void> _saveLiveStream(LiveStream stream) async {
    final allStreams = await _getAllLiveStreams();
    allStreams.add(stream);
    await _saveAllLiveStreams(allStreams);
  }

  Future<List<LiveStream>> _getAllLiveStreams() async {
    final streamsJson = await StorageHelper.getString('live_streams');
    
    if (streamsJson == null) {
      return [];
    }

    final List<dynamic> streamsData = jsonDecode(streamsJson);
    return streamsData.map((json) => LiveStream.fromJson(json)).toList();
  }

  Future<void> _saveAllLiveStreams(List<LiveStream> streams) async {
    await StorageHelper.setString(
      'live_streams',
      jsonEncode(streams.map((s) => s.toJson()).toList()),
    );
  }
}
