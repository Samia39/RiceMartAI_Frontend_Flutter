// ignore_for_file: deprecated_member_use
// ─────────────────────────────────────────────────────────────────────────────
//  RICE MART — DASHBOARD SERVICE
//  Models · Controllers · Price & Cart logic — NO UI here
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────
//  RICE PRICE MODEL
// ─────────────────────────────────────────────
class RicePrice {
  final String name;
  final double price;
  final double change; // % change vs previous admin-set price

  const RicePrice({
    required this.name,
    required this.price,
    required this.change,
  });

  factory RicePrice.fromJson(Map<String, dynamic> json) => RicePrice(
    name: json['name'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    change: (json['change'] ?? 0).toDouble(),
  );

  RicePrice copyWith({String? name, double? price, double? change}) =>
      RicePrice(
        name: name ?? this.name,
        price: price ?? this.price,
        change: change ?? this.change,
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'change': change,
  };
}

// ─────────────────────────────────────────────
//  SHOP MODEL
// ─────────────────────────────────────────────
class ShopModel {
  final String id;
  final String name;
  final String ownerName;
  final String location;
  final String phone;
  final double rating;
  final int reviews;
  final bool open;
  final String specialty;
  final String image;
  final bool isRegistered; // only registered shops expose products in Rice List

  const ShopModel({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.location,
    required this.phone,
    required this.rating,
    required this.reviews,
    required this.open,
    required this.specialty,
    required this.image,
    this.isRegistered = true,
  });

  /// All known shops (mock — replace with API)
  static const List<ShopModel> all = [
    ShopModel(
      id: 'shop_001',
      name: 'Anware Sidra Rice Shop',
      ownerName: 'Muhammad Anwar',
      location: 'Lahore, Punjab',
      phone: '+92 300 1234567',
      rating: 4.8,
      reviews: 124,
      open: true,
      specialty: 'Basmati & Super Basmati',
      image: 'assets/images/rice.jpeg',
      isRegistered: true,
    ),
    ShopModel(
      id: 'shop_002',
      name: 'Al-Madina Rice Store',
      ownerName: 'Tariq Hussain',
      location: 'Karachi, Sindh',
      phone: '+92 321 7654321',
      rating: 4.5,
      reviews: 89,
      open: true,
      specialty: 'Sella & Brown Rice',
      image: 'assets/images/rice.jpeg',
      isRegistered: true,
    ),
    ShopModel(
      id: 'shop_003',
      name: 'Punjab Rice Center',
      ownerName: 'Asif Mehmood',
      location: 'Faisalabad, Punjab',
      phone: '+92 333 9876543',
      rating: 4.6,
      reviews: 102,
      open: false,
      specialty: 'Kainat & IR-6 Rice',
      image: 'assets/images/rice.jpeg',
      isRegistered: true,
    ),
    ShopModel(
      id: 'shop_004',
      name: 'Kernel Basmati House',
      ownerName: 'Khalid Zafar',
      location: 'Islamabad, ICT',
      phone: '+92 311 1122334',
      rating: 4.9,
      reviews: 211,
      open: true,
      specialty: 'Kernel & Premium Basmati',
      image: 'assets/images/rice.jpeg',
      isRegistered: false, // pending approval — not shown in Rice List yet
    ),
    ShopModel(
      id: 'shop_005',
      name: 'Green Valley Rice',
      ownerName: 'Bilal Chaudhry',
      location: 'Multan, Punjab',
      phone: '+92 345 5566778',
      rating: 4.3,
      reviews: 67,
      open: true,
      specialty: 'Organic Brown Rice',
      image: 'assets/images/rice.jpeg',
      isRegistered: true,
    ),
  ];

  static List<ShopModel> get registered =>
      all.where((s) => s.isRegistered).toList();
}

// ─────────────────────────────────────────────
//  RICE PRODUCT MODEL
// ─────────────────────────────────────────────
class RiceProduct {
  final String name;
  final String shop;
  final String shopId;
  final String imagePath;
  final double price;

  const RiceProduct({
    required this.name,
    required this.shop,
    required this.shopId,
    required this.imagePath,
    required this.price,
  });

  /// Products from REGISTERED shops only — shown in Rice List on Home screen
  static List<RiceProduct> fromRegisteredShops() {
    final registeredIds = ShopModel.registered.map((s) => s.id).toSet();
    return _all.where((p) => registeredIds.contains(p.shopId)).toList();
  }

  static const List<RiceProduct> _all = [
    // shop_001 — registered ✓
    RiceProduct(
      name: 'Basmati Rice',
      shop: 'Anware Sidra Rice Shop',
      shopId: 'shop_001',
      imagePath: 'assets/images/rice.jpeg',
      price: 280,
    ),
    RiceProduct(
      name: 'Super Basmati',
      shop: 'Anware Sidra Rice Shop',
      shopId: 'shop_001',
      imagePath: 'assets/images/rice.jpeg',
      price: 320,
    ),
    // shop_002 — registered ✓
    RiceProduct(
      name: 'Sella Rice',
      shop: 'Al-Madina Rice Store',
      shopId: 'shop_002',
      imagePath: 'assets/images/rice.jpeg',
      price: 250,
    ),
    // shop_003 — registered ✓
    RiceProduct(
      name: 'Kainat Rice',
      shop: 'Punjab Rice Center',
      shopId: 'shop_003',
      imagePath: 'assets/images/rice.jpeg',
      price: 265,
    ),
    // shop_004 — NOT registered, excluded from Rice List
    RiceProduct(
      name: 'Kernel Basmati',
      shop: 'Kernel Basmati House',
      shopId: 'shop_004',
      imagePath: 'assets/images/rice.jpeg',
      price: 295,
    ),
    // shop_005 — registered ✓
    RiceProduct(
      name: 'Brown Rice',
      shop: 'Green Valley Rice',
      shopId: 'shop_005',
      imagePath: 'assets/images/rice.jpeg',
      price: 200,
    ),
  ];
}

// ─────────────────────────────────────────────
//  CART ITEM
// ─────────────────────────────────────────────
class CartItem {
  final RiceProduct product;
  int qty;
  CartItem({required this.product, this.qty = 1});
}

// ─────────────────────────────────────────────
//  RICE PRICE SERVICE
//  Priority: admin-set (local) → API → fallback
// ─────────────────────────────────────────────
class RicePriceService {
  static const String _apiUrl = 'https://your-api-endpoint.com/api/rice-prices';

  static Future<List<RicePrice>> fetchPrices() async {
    // 1. Admin-persisted prices take priority
    final admin = AdminPriceController.loadLocalPrices();
    if (admin != null && admin.isNotEmpty) return admin;

    // 2. Remote API
    try {
      final r = await http
          .get(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 8));
      if (r.statusCode == 200) {
        final List data = json.decode(r.body);
        return data.map((e) => RicePrice.fromJson(e)).toList();
      }
    } catch (_) {}

    // 3. Hardcoded fallback
    return _fallback;
  }

  static const List<RicePrice> _fallback = [
    RicePrice(name: 'Super Basmati Rice', price: 320, change: 3),
    RicePrice(name: 'Regular Basmati Rice', price: 280, change: 5),
    RicePrice(name: 'Sella Rice', price: 250, change: -2),
    RicePrice(name: 'Brown Rice', price: 240, change: 1),
    RicePrice(name: 'Kernel Basmati', price: 300, change: 4),
    RicePrice(name: 'Kainat Rice', price: 265, change: 2),
    RicePrice(name: 'IR-6 Rice', price: 150, change: -1),
  ];
}

// ─────────────────────────────────────────────
//  ADMIN PRICE CONTROLLER
//  Admin sets prices → persisted to GetStorage
//  → RicePriceService reads them on next fetch
// ─────────────────────────────────────────────
class AdminPriceController extends GetxController {
  static const String _key = 'admin_rice_prices';
  final _box = GetStorage();

  final prices = <RicePrice>[].obs;

  @override
  void onInit() {
    super.onInit();
    prices.assignAll(
      loadLocalPrices() ??
          RicePriceService._fallback
              .map(
                (p) =>
                    RicePrice(name: p.name, price: p.price, change: p.change),
              )
              .toList(),
    );
  }

  static List<RicePrice>? loadLocalPrices() {
    final raw = GetStorage().read<String>(_key);
    if (raw == null) return null;
    try {
      return (json.decode(raw) as List)
          .map((e) => RicePrice.fromJson(e))
          .toList();
    } catch (_) {
      return null;
    }
  }

  void updatePrice(int i, double newPrice) {
    if (i < 0 || i >= prices.length) return;
    final old = prices[i];
    final pct = old.price > 0
        ? ((newPrice - old.price) / old.price * 100)
        : 0.0;
    prices[i] = old.copyWith(price: newPrice, change: pct);
    prices.refresh();
    _box.write(_key, json.encode(prices.map((p) => p.toJson()).toList()));
  }
}

// ─────────────────────────────────────────────
//  CART CONTROLLER
// ─────────────────────────────────────────────
class CartController extends GetxController {
  final items = <CartItem>[].obs;

  void add(RiceProduct p) {
    final idx = items.indexWhere((e) => e.product.name == p.name);
    if (idx >= 0) {
      items[idx].qty++;
      items.refresh();
    } else {
      items.add(CartItem(product: p));
    }
  }

  void remove(RiceProduct p) =>
      items.removeWhere((e) => e.product.name == p.name);

  void increment(CartItem i) {
    i.qty++;
    items.refresh();
  }

  void decrement(CartItem i) {
    if (i.qty > 1) {
      i.qty--;
      items.refresh();
    } else {
      remove(i.product);
    }
  }

  bool contains(RiceProduct p) => items.any((e) => e.product.name == p.name);
  int get totalCount => items.fold(0, (s, e) => s + e.qty);
  double get totalPrice =>
      items.fold(0.0, (s, e) => s + e.product.price * e.qty);
} //
