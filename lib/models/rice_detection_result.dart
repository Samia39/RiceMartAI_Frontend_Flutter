class RiceDetectionResult {
  final String category;
  final double confidence;
  final String cookingTime;
  final String commonUses;
  final String description;
  final int processingTimeMs;

  RiceDetectionResult({
    required this.category,
    required this.confidence,
    required this.cookingTime,
    required this.commonUses,
    required this.description,
    this.processingTimeMs = 0,
  });

  factory RiceDetectionResult.fromJson(Map<String, dynamic> json) {
    return RiceDetectionResult(
      category: json['category'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0).toDouble(),
      cookingTime: json['cooking_time'] ?? '-',
      commonUses: json['common_uses'] ?? '-',
      description: json['description'] ?? '-',
      processingTimeMs: json['processing_time_ms'] ?? 0,
    );
  }

  RiceDetectionResult copyWith({int? processingTimeMs}) {
    return RiceDetectionResult(
      category: category,
      confidence: confidence,
      cookingTime: cookingTime,
      commonUses: commonUses,
      description: description,
      processingTimeMs: processingTimeMs ?? this.processingTimeMs,
    );
  }
}