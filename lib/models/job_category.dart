class JobCategory {
  final String key;
  final String labelJa;
  final String labelEn;
  final String icon;

  const JobCategory({
    required this.key,
    required this.labelJa,
    required this.labelEn,
    required this.icon,
  });

  factory JobCategory.fromJson(Map<String, dynamic> json) => JobCategory(
        key: json['key'] as String,
        labelJa: json['label_ja'] as String,
        labelEn: json['label_en'] as String,
        icon: json['icon'] as String,
      );
}
