import 'product_model.dart';
class Shop {
  final int id;
  final int sellerId;
  final String name;
  final String description;
  final String? logo;
  final String? address;
  final String status;
  final List<Product> products;

  Shop({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.description,
    this.logo,
    this.address,
    required this.status,
    this.products = const [],
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'],
      sellerId: json['seller_id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      logo: json['logo'],
      address: json['address'],
      status: json['status'] ?? 'pending',
      products: json['products'] != null
          ? (json['products'] as List)
              .map((e) => Product.fromJson(e))
              .toList()
          : [],
    );
  }
}