import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../utils/storage_helper.dart';
import '../models/media_item.dart';

class MediaService {
  static final MediaService _instance = MediaService._internal();
  factory MediaService() => _instance;
  MediaService._internal();

  // メディアアイテムを保存
  Future<bool> saveMedia(MediaItem media) async {
    try {
      final mediaList = await getUserMedia(media.userId);
      mediaList.insert(0, media);
      
      final jsonList = mediaList.map((m) => m.toJson()).toList();
      await StorageHelper.setString('media_${media.userId}', jsonEncode(jsonList));
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save media: $e');
      }
      return false;
    }
  }

  // ユーザーのメディアを取得
  Future<List<MediaItem>> getUserMedia(String userId, {String? type}) async {
    try {
      final jsonStr = await StorageHelper.getString('media_$userId');
      
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonStr);
        final mediaList = jsonList.map((json) => MediaItem.fromJson(json)).toList();
        
        // タイプでフィルター
        if (type != null) {
          return mediaList.where((m) => m.type == type).toList();
        }
        
        return mediaList;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load user media: $e');
      }
    }
    return [];
  }

  // メディアを削除
  Future<bool> deleteMedia(String userId, String mediaId) async {
    try {
      final mediaList = await getUserMedia(userId);
      final updatedList = mediaList.where((m) => m.id != mediaId).toList();
      
      final jsonList = updatedList.map((m) => m.toJson()).toList();
      await StorageHelper.setString('media_$userId', jsonEncode(jsonList));
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to delete media: $e');
      }
      return false;
    }
  }

  // いいねを追加/削除
  Future<bool> toggleLike(String userId, String mediaId) async {
    try {
      final mediaList = await getUserMedia(userId);
      final mediaIndex = mediaList.indexWhere((m) => m.id == mediaId);
      
      if (mediaIndex != -1) {
        final media = mediaList[mediaIndex];
        mediaList[mediaIndex] = media.copyWith(
          likesCount: media.likesCount + 1,
        );
        
        final jsonList = mediaList.map((m) => m.toJson()).toList();
        await StorageHelper.setString('media_$userId', jsonEncode(jsonList));
        
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to toggle like: $e');
      }
    }
    return false;
  }

  // アルバムを作成
  Future<bool> createAlbum(Album album) async {
    try {
      final albums = await getUserAlbums(album.userId);
      albums.insert(0, album);
      
      final jsonList = albums.map((a) => a.toJson()).toList();
      await StorageHelper.setString('albums_${album.userId}', jsonEncode(jsonList));
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to create album: $e');
      }
      return false;
    }
  }

  // ユーザーのアルバムを取得
  Future<List<Album>> getUserAlbums(String userId) async {
    try {
      final jsonStr = await StorageHelper.getString('albums_$userId');
      
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonStr);
        return jsonList.map((json) => Album.fromJson(json)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load albums: $e');
      }
    }
    return [];
  }

  // アルバムにメディアを追加
  Future<bool> addMediaToAlbum(String userId, String albumId, String mediaId) async {
    try {
      final albums = await getUserAlbums(userId);
      final albumIndex = albums.indexWhere((a) => a.id == albumId);
      
      if (albumIndex != -1) {
        final album = albums[albumIndex];
        if (!album.mediaIds.contains(mediaId)) {
          final updatedMediaIds = List<String>.from(album.mediaIds)..add(mediaId);
          
          albums[albumIndex] = Album(
            id: album.id,
            userId: album.userId,
            title: album.title,
            description: album.description,
            coverUrl: album.coverUrl,
            mediaIds: updatedMediaIds,
            createdAt: album.createdAt,
            updatedAt: DateTime.now(),
          );
          
          final jsonList = albums.map((a) => a.toJson()).toList();
          await StorageHelper.setString('albums_$userId', jsonEncode(jsonList));
          
          return true;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to add media to album: $e');
      }
    }
    return false;
  }

  // アルバムのメディアを取得
  Future<List<MediaItem>> getAlbumMedia(String userId, String albumId) async {
    try {
      final albums = await getUserAlbums(userId);
      final album = albums.firstWhere((a) => a.id == albumId);
      
      final allMedia = await getUserMedia(userId);
      return allMedia.where((m) => album.mediaIds.contains(m.id)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load album media: $e');
      }
    }
    return [];
  }

  // サンプルメディアを生成（テスト用）
  Future<void> createSampleMedia(String userId) async {
    final sampleImages = [
      MediaItem(
        id: 'media_${DateTime.now().millisecondsSinceEpoch}_1',
        userId: userId,
        type: 'image',
        url: 'https://picsum.photos/800/600?random=1',
        thumbnailUrl: 'https://picsum.photos/200/150?random=1',
        caption: '美しい風景写真',
        tags: ['風景', '自然', '旅行'],
        likesCount: 42,
        commentsCount: 5,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        metadata: {
          'width': 800,
          'height': 600,
          'size': 250000,
        },
      ),
      MediaItem(
        id: 'media_${DateTime.now().millisecondsSinceEpoch}_2',
        userId: userId,
        type: 'image',
        url: 'https://picsum.photos/800/600?random=2',
        thumbnailUrl: 'https://picsum.photos/200/150?random=2',
        caption: '都市の夜景',
        tags: ['都市', '夜景', '建築'],
        likesCount: 28,
        commentsCount: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        metadata: {
          'width': 800,
          'height': 600,
          'size': 300000,
        },
      ),
      MediaItem(
        id: 'media_${DateTime.now().millisecondsSinceEpoch}_3',
        userId: userId,
        type: 'image',
        url: 'https://picsum.photos/800/600?random=3',
        thumbnailUrl: 'https://picsum.photos/200/150?random=3',
        caption: '美味しい料理',
        tags: ['料理', 'グルメ', 'レストラン'],
        likesCount: 56,
        commentsCount: 8,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        metadata: {
          'width': 800,
          'height': 600,
          'size': 280000,
        },
      ),
      MediaItem(
        id: 'media_${DateTime.now().millisecondsSinceEpoch}_4',
        userId: userId,
        type: 'video',
        url: 'https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        thumbnailUrl: 'https://picsum.photos/200/150?random=4',
        caption: 'サンプル動画',
        tags: ['動画', 'エンタメ'],
        likesCount: 73,
        commentsCount: 12,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        metadata: {
          'duration': 596,
          'width': 1280,
          'height': 720,
          'size': 5253880,
        },
      ),
    ];

    for (final media in sampleImages) {
      await saveMedia(media);
    }

    // サンプルアルバムを作成
    final album = Album(
      id: 'album_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      title: 'お気に入りの写真',
      description: '特別な思い出のコレクション',
      coverUrl: sampleImages.first.url,
      mediaIds: sampleImages.take(3).map((m) => m.id).toList(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await createAlbum(album);
  }
}
