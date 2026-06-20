import 'dart:convert';
import 'package:http/http.dart' as http;

class AiRecommendationService {
  final String baseUrl = "http://127.0.0.1:8000/api";

  // =========================
  // GET AI RECOMMENDATION
  // =========================
  Future<Map<String, dynamic>> getRecommendation({
    required String query,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/ai-recommendation"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"query": query}),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Controller returns: { "ai": {...}, "products": [...] }
        return {
          "ai": decoded["ai"] ?? {},
          "products": decoded["products"] ?? [],
        };
      }

      // Controller returns: { "error": "..." } on failure
      return {
        "error": decoded["error"] ?? "Server error: ${response.statusCode}",
      };
    } catch (e) {
      return {"error": "Connection failed: $e"};
    }
  }

  // =========================
  // PARSE AI DATA
  // =========================
  AiRiceInfo? parseAiData(Map<String, dynamic> aiMap) {
    try {
      return AiRiceInfo.fromJson(aiMap);
    } catch (_) {
      return null;
    }
  }

  // =========================
  // PARSE MATCHED PRODUCTS
  // =========================
  List<MatchedProduct> parseProducts(List<dynamic> productList) {
    return productList
        .map((p) => MatchedProduct.fromJson(p as Map<String, dynamic>))
        .toList();
  }
}

// =========================================================
// MODEL: AI Rice Info
// Matches the JSON structure returned by the controller
// =========================================================
class AiRiceInfo {
  final String overview;
  final String riceType;
  final String origin;
  final String grainSize;
  final String texture;
  final List<String> bestUses;
  final String nutrition;
  final String storageTips;
  final RiceRecipe recipe;
  final List<String> relatedKeywords;

  AiRiceInfo({
    required this.overview,
    required this.riceType,
    required this.origin,
    required this.grainSize,
    required this.texture,
    required this.bestUses,
    required this.nutrition,
    required this.storageTips,
    required this.recipe,
    required this.relatedKeywords,
  });

  factory AiRiceInfo.fromJson(Map<String, dynamic> json) {
    return AiRiceInfo(
      overview: json['overview'] ?? '',
      riceType: json['rice_type'] ?? '',
      origin: json['origin'] ?? '',
      grainSize: json['grain_size'] ?? '',
      texture: json['texture'] ?? '',
      bestUses: List<String>.from(json['best_uses'] ?? []),
      nutrition: json['nutrition'] ?? '',
      storageTips: json['storage_tips'] ?? '',
      recipe: RiceRecipe.fromJson(json['recipe'] ?? {}),
      relatedKeywords: List<String>.from(json['related_keywords'] ?? []),
    );
  }
}

// =========================================================
// MODEL: Recipe (nested inside AiRiceInfo)
// =========================================================
class RiceRecipe {
  final String name;
  final List<String> ingredients;
  final List<String> steps;

  RiceRecipe({
    required this.name,
    required this.ingredients,
    required this.steps,
  });

  factory RiceRecipe.fromJson(Map<String, dynamic> json) {
    return RiceRecipe(
      name: json['name'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      steps: List<String>.from(json['steps'] ?? []),
    );
  }
}

// =========================================================
// MODEL: Matched Product
// Matches the product map built in the controller
// =========================================================
class MatchedProduct {
  final int id;
  final String name;
  final double price;
  final int stock;
  final String shopName;
  final String categoryName;

  MatchedProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.shopName,
    required this.categoryName,
  });

  factory MatchedProduct.fromJson(Map<String, dynamic> json) {
    return MatchedProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] ?? 0,
      shopName: json['shop_name'] ?? 'N/A',
      categoryName: json['category_name'] ?? 'N/A',
    );
  }
}
