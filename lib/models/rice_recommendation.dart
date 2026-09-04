class RiceRecommendation {
  final String category;
  final String cookingTime;
  final String commonUses;
  final String description;

  RiceRecommendation({
    required this.category,
    required this.cookingTime,
    required this.commonUses,
    required this.description,
  });

  factory RiceRecommendation.fromJson(Map<String, dynamic> json) {
    return RiceRecommendation(
      category: json['category'] ?? 'Unknown',
      cookingTime: json['cooking_time'] ?? '-',
      commonUses: json['common_uses'] ?? '-',
      description: json['description'] ?? '-',
    );
  }
}