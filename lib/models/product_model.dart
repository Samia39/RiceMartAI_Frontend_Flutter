class ProductModel {
  final int id;
  final int sellerId;
  final int? shopId;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? image;
  final String category;
  final String status;

  ProductModel({
    required this.id,
    required this.sellerId,
    this.shopId,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.image,
    required this.category,
    required this.status,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      sellerId: json['seller_id'],
      shopId: json['shop_id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.parse(json['price'].toString()),
      stock: json['stock'] is int
          ? json['stock']
          : int.parse(json['stock'].toString()),
      image: json['image'],
      category: json['category'] ?? 'rice',
      status: json['status'] ?? 'pending',
    );
  }
}