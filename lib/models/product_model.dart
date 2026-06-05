class Product {
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

  Product({
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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      sellerId: json['seller_id'],
      shopId: json['shop_id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.parse(json['price'].toString()),
      stock: json['stock'],
      image: json['image'],
      category: json['category'] ?? 'rice',
      status: json['status'] ?? 'pending',
    );
  }
}