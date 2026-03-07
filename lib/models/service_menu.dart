/// サービスメニューモデル
class ServiceMenu {
  final String id;
  final String staffId;
  final String name;
  final String description;
  final int price;
  final int duration; // 所要時間（分）
  final String category; // カテゴリー
  final bool isActive;
  final DateTime createdAt;
  
  ServiceMenu({
    required this.id,
    required this.staffId,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.category,
    this.isActive = true,
    required this.createdAt,
  });

  factory ServiceMenu.fromJson(Map<String, dynamic> json) {
    return ServiceMenu(
      id: json['id'] as String,
      staffId: json['staffId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
      duration: json['duration'] as int,
      category: json['category'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staffId': staffId,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'category': category,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ServiceMenu copyWith({
    bool? isActive,
  }) {
    return ServiceMenu(
      id: id,
      staffId: staffId,
      name: name,
      description: description,
      price: price,
      duration: duration,
      category: category,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
