import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/staff_story.dart';
import '../services/story_service.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<StaffStory> stories;
  final int initialIndex;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late int _currentStoryIndex;
  late AnimationController _progressController;
  int _currentItemIndex = 0;
  final StoryService _storyService = StoryService();
  bool _showViewers = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _currentStoryIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_isPaused) {
          _nextStoryItem();
        }
      });
    
    // アニメーションの更新時に画面を再描画
    _progressController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    
    _progressController.forward();
    _recordView(); // 初回閲覧を記録
  }

  void _recordView() {
    final story = widget.stories[_currentStoryIndex];
    final item = story.items[_currentItemIndex];
    _storyService.recordStoryView(story.id, item.id);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _nextStoryItem() {
    if (_currentItemIndex <
        widget.stories[_currentStoryIndex].items.length - 1) {
      setState(() {
        _currentItemIndex++;
      });
      _progressController.reset();
      _progressController.forward();
      _recordView(); // 閲覧を記録
    } else {
      _nextStory();
    }
  }

  void _previousStoryItem() {
    if (_currentItemIndex > 0) {
      setState(() {
        _currentItemIndex--;
      });
      _progressController.reset();
      _progressController.forward();
      _recordView(); // 閲覧を記録
    } else {
      _previousStory();
    }
  }

  void _nextStory() {
    if (_currentStoryIndex < widget.stories.length - 1) {
      setState(() {
        _currentStoryIndex++;
        _currentItemIndex = 0;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _progressController.reset();
      _progressController.forward();
      _recordView(); // 閲覧を記録
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
        _currentItemIndex = 0;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _progressController.reset();
      _progressController.forward();
      _recordView(); // 閲覧を記録
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 2) {
            _previousStoryItem();
          } else {
            _nextStoryItem();
          }
        },
        child: PageView.builder(
          controller: _pageController,
          physics: const ClampingScrollPhysics(), // スワイプを有効化
          itemCount: widget.stories.length,
          onPageChanged: (index) {
            setState(() {
              _currentStoryIndex = index;
              _currentItemIndex = 0;
            });
            _progressController.reset();
            _progressController.forward();
            _recordView(); // 新しいストーリーの閲覧を記録
          },
          itemBuilder: (context, index) {
            return _buildStoryPage(widget.stories[index]);
          },
        ),
      ),
    );
  }

  Widget _buildStoryPage(StaffStory story) {
    return Stack(
      children: [
        // 背景画像
        Positioned.fill(
          child: CachedNetworkImage(
            imageUrl: story.items[_currentItemIndex].imageUrl,
            fit: BoxFit.cover,
          ),
        ),

        // グラデーションオーバーレイ
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
        ),

        // プログレスバー
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: List.generate(
                    story.items.length,
                    (index) => Expanded(
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        child: LinearProgressIndicator(
                          value: index == _currentItemIndex
                              ? _progressController.value
                              : index < _currentItemIndex
                                  ? 1.0
                                  : 0.0,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ヘッダー
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(story.staffImage),
                      radius: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story.staffName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatTime(story.items[_currentItemIndex].timestamp),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // キャプション（下部）
        if (story.items[_currentItemIndex].caption != null)
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                story.items[_currentItemIndex].caption!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),

        // 閲覧者数表示（下部）
        Positioned(
          bottom: 50,
          left: 16,
          right: 16,
          child: GestureDetector(
            onTap: () => _showViewersList(story),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.remove_red_eye, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${story.items[_currentItemIndex].viewers.length}人が視聴',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inHours < 1) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else {
      return '${difference.inDays}日前';
    }
  }

  void _showViewersList(StaffStory story) {
    setState(() {
      _isPaused = true;
    });
    _progressController.stop(); // ストーリーを一時停止
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // ハンドル
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // ヘッダー
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    '閲覧者',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${story.items[_currentItemIndex].viewers.length}',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // 閲覧者リスト
            Expanded(
              child: story.items[_currentItemIndex].viewers.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.remove_red_eye_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'まだ誰も閲覧していません',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: story.items[_currentItemIndex].viewers.length,
                      itemBuilder: (context, index) {
                        final viewer = story.items[_currentItemIndex].viewers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            backgroundImage: viewer.userImage != null
                                ? NetworkImage(viewer.userImage!)
                                : null,
                            child: viewer.userImage == null
                                ? Text(
                                    viewer.userName[0],
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          title: Text(
                            viewer.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            _formatTime(viewer.viewedAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      setState(() {
        _isPaused = false;
      });
      _progressController.forward(); // ダイアログを閉じたら再開
    });
  }
}
