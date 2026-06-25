import 'product_model.dart';

class Shop {
  final int id;
  final int sellerId;
  final String name;
  final String description;
  final String? logo;
  final String? address;
  final String status;
  final String? ownerName;
  final String? phone;
  final String? cnicNumber;
  final String? cnicImage;
  final String? sellerName;
  final List<ProductModel> products; // ← FIX: String? → List<ProductModel>

  Shop({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.description,
    this.logo,
    this.address,
    required this.status,
    this.ownerName,
    this.phone,
    this.cnicNumber,
    this.cnicImage,
    this.sellerName,
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
      ownerName: json['owner_name'],
      phone: json['phone'],
      cnicNumber: json['cnic_number'],
      cnicImage: json['cnic_image'],
      sellerName: json['seller'] != null ? json['seller']['name'] : null,
      products: json['products'] != null
          ? (json['products'] as List)
              .map((e) => ProductModel.fromJson(e))
              .toList()
          : [],
    );
  }
}