class StaffStory {
  final String id;
  final String staffId;
  final String staffName;
  final String staffImage;
  final List<StoryItem> items;
  final DateTime lastUpdated;

  StaffStory({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.staffImage,
    required this.items,
    required this.lastUpdated,
  });

  bool get isExpired {
    return DateTime.now().difference(lastUpdated).inHours >= 24;
  }
}

class StoryItem {
  final String id;
  final String imageUrl;
  final DateTime timestamp;

  StoryItem({
    required this.id,
    required this.imageUrl,
    required this.timestamp,
  });
}
