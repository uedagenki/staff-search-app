import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/staff_story.dart';

class StoryService {
  static const String _viewersKey = 'story_viewers';
  static const String _currentUserKey = 'current_user_id';

  // ストーリー閲覧を記録
  Future<void> recordStoryView(String storyId, String itemId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_currentUserKey) ?? 'demo_user';
      final userName = prefs.getString('user_name') ?? 'ゲストユーザー';
      
      // 閲覧記録を取得
      final viewersJson = prefs.getString('${_viewersKey}_${storyId}_$itemId');
      List<Map<String, dynamic>> viewers = [];
      
      if (viewersJson != null) {
        viewers = List<Map<String, dynamic>>.from(jsonDecode(viewersJson));
      }
      
      // 既に閲覧済みかチェック
      final alreadyViewed = viewers.any((v) => v['userId'] == userId);
      
      if (!alreadyViewed) {
        // 新規閲覧記録を追加
        viewers.add({
          'userId': userId,
          'userName': userName,
          'userImage': null,
          'viewedAt': DateTime.now().toIso8601String(),
        });
        
        await prefs.setString(
          '${_viewersKey}_${storyId}_$itemId',
          jsonEncode(viewers),
        );
      }
    } catch (e) {
      // エラーは無視
    }
  }

  // ストーリーの閲覧者リストを取得
  Future<List<StoryViewer>> getStoryViewers(String storyId, String itemId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final viewersJson = prefs.getString('${_viewersKey}_${storyId}_$itemId');
      
      if (viewersJson != null) {
        final viewersList = List<Map<String, dynamic>>.from(jsonDecode(viewersJson));
        return viewersList.map((json) => StoryViewer.fromJson(json)).toList();
      }
    } catch (e) {
      // エラーは無視
    }
    return [];
  }

  // スタッフのストーリーを取得（デモデータ）
  Future<List<StaffStory>> getStaffStories() async {
    // デモデータ
    final now = DateTime.now();
    
    return [
      StaffStory(
        id: 'story_001',
        staffId: '1',
        staffName: '佐藤 健',
        staffImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        lastUpdated: now.subtract(const Duration(hours: 2)),
        items: [
          StoryItem(
            id: 'item_001',
            imageUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=800',
            timestamp: now.subtract(const Duration(hours: 2)),
            caption: '今日の仕事風景 💼',
            viewers: await getStoryViewers('story_001', 'item_001'),
          ),
          StoryItem(
            id: 'item_002',
            imageUrl: 'https://images.unsplash.com/photo-1556910103-1c02745aae4d?w=800',
            timestamp: now.subtract(const Duration(hours: 1)),
            caption: 'ランチタイム 🍜',
            viewers: await getStoryViewers('story_001', 'item_002'),
          ),
        ],
      ),
      StaffStory(
        id: 'story_002',
        staffId: '2',
        staffName: '田中 美咲',
        staffImage: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
        lastUpdated: now.subtract(const Duration(hours: 5)),
        items: [
          StoryItem(
            id: 'item_003',
            imageUrl: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=800',
            timestamp: now.subtract(const Duration(hours: 5)),
            caption: '新しいヘアスタイル提案 ✨',
            viewers: await getStoryViewers('story_002', 'item_003'),
          ),
        ],
      ),
      StaffStory(
        id: 'story_003',
        staffId: '3',
        staffName: '山田 太郎',
        staffImage: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
        lastUpdated: now.subtract(const Duration(hours: 12)),
        items: [
          StoryItem(
            id: 'item_004',
            imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
            timestamp: now.subtract(const Duration(hours: 12)),
            caption: 'トレーニング中 💪',
            viewers: await getStoryViewers('story_003', 'item_004'),
          ),
          StoryItem(
            id: 'item_005',
            imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800',
            timestamp: now.subtract(const Duration(hours: 10)),
            caption: '健康的な食事 🥗',
            viewers: await getStoryViewers('story_003', 'item_005'),
          ),
        ],
      ),
      StaffStory(
        id: 'story_004',
        staffId: '4',
        staffName: '鈴木 花子',
        staffImage: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400',
        lastUpdated: now.subtract(const Duration(hours: 18)),
        items: [
          StoryItem(
            id: 'item_006',
            imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800',
            timestamp: now.subtract(const Duration(hours: 18)),
            caption: 'リラックスタイム 🧘‍♀️',
            viewers: await getStoryViewers('story_004', 'item_006'),
          ),
        ],
      ),
    ];
  }

  // 24時間以上経過したストーリーをフィルタリング
  List<StaffStory> filterActiveStories(List<StaffStory> stories) {
    return stories.where((story) => !story.isExpired).toList();
  }
}
