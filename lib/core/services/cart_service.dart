import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Manages the shopping cart for the whole app.
///
/// IMPORTANT: This is a singleton. `CartService()` always returns the
/// SAME instance (see the factory constructor below), so every screen
/// that calls `CartService()` is reading/writing the same cart —
/// instead of each call creating its own throwaway copy.
class CartService extends GetxController {
  // =========================
  // SINGLETON SETUP
  // =========================
  // Holds the one and only instance of CartService.
  static final CartService _instance = CartService._internal();

  // Every `CartService()` call returns `_instance` instead of
  // building a new object.
  factory CartService() => _instance;

  // Private constructor — runs only once, the first time CartService
  // is ever referenced. Loads whatever was saved on disk immediately,
  // so we don't have to rely on GetX's onInit() lifecycle at all.
  CartService._internal() {
    _loadCartFromStorage();
  }

  // =========================
  // STORAGE
  // =========================
  final GetStorage box = GetStorage();

  // Reactive cart list — any Obx()/GetX() widget watching this
  // rebuilds automatically when items are added/removed/changed.
  final RxList cart = [].obs;

  /// Loads the persisted cart from GetStorage into memory.
  /// Wrapped in try/catch so corrupted or unexpected storage data
  /// can't crash the app on startup.
  void _loadCartFromStorage() {
    try {
      final stored = box.read("cart");
      if (stored is List) {
        cart.value = List<Map<String, dynamic>>.from(
          stored.map((e) => Map<String, dynamic>.from(e as Map)),
        );
      } else {
        cart.value = [];
      }
    } catch (e) {
      // If anything about the stored data is malformed, just start
      // with an empty cart instead of crashing.
      cart.value = [];
    }
  }

  /// Also kept for safety: if CartService is ever registered through
  /// Get.put() somewhere (e.g. in bindings), this will re-sync the
  /// cart too. Harmless to run twice — it just reloads the same data.
  @override
  void onInit() {
    super.onInit();
    _loadCartFromStorage();
  }

  // =========================
  // READ CART
  // =========================
  List getCart() => cart;

  // =========================
  // ADD TO CART
  // =========================
  /// Adds [rice] to the cart with the given [quantity], clamped to
  /// available stock.
  /// Returns:
  ///   "added"  -> added/updated normally
  ///   "capped" -> quantity was reduced to fit available stock
  ///   "maxed"  -> already at (or requested at) max stock, nothing added
  String addToCart({
    required Map<String, dynamic> rice,
    required int quantity,
  }) {
    // Safe parse: never throws even if "stock" is missing/malformed.
    final int stock = int.tryParse(rice["stock"]?.toString() ?? "") ?? 0;

    final int existingIndex = cart.indexWhere(
      (item) => item["id"] == rice["id"],
    );

    if (existingIndex != -1) {
      // Item already in cart — bump its quantity.
      final int currentQty =
          int.tryParse(cart[existingIndex]["quantity"]?.toString() ?? "") ?? 0;

      if (currentQty >= stock) {
        return "maxed";
      }

      final int requestedTotal = currentQty + quantity;
      final int newQty = requestedTotal > stock ? stock : requestedTotal;

      cart[existingIndex]["quantity"] = newQty;
      cart.refresh(); // needed since we mutated a nested map in place
      _persist();

      return requestedTotal > stock ? "capped" : "added";
    } else {
      // New item — add a fresh entry.
      final int newQty = quantity > stock ? stock : quantity;

      if (newQty <= 0) {
        return "maxed";
      }

      final Map<String, dynamic> newItem = Map<String, dynamic>.from(rice);
      newItem["quantity"] = newQty;

      cart.add(newItem);
      _persist();

      return newQty < quantity ? "capped" : "added";
    }
  }

  // =========================
  // REMOVE ITEM
  // =========================
  void removeItem(int riceId) {
    cart.removeWhere((item) => item["id"] == riceId);
    _persist();
  }

  // =========================
  // UPDATE QUANTITY
  // =========================
  /// Updates the quantity for [riceId], clamped between 1 and stock.
  /// Returns the actual (clamped) quantity that was set.
  int updateQuantity({required int riceId, required int quantity}) {
    final int index = cart.indexWhere((item) => item["id"] == riceId);

    if (index != -1) {
      final int stock =
          int.tryParse(cart[index]["stock"]?.toString() ?? "") ?? 0;
      final int clamped = quantity > stock
          ? stock
          : (quantity < 1 ? 1 : quantity);

      cart[index]["quantity"] = clamped;
      cart.refresh();
      _persist();

      return clamped;
    }

    return quantity;
  }

  // =========================
  // TOTAL PRICE (subtotal only, no delivery)
  // =========================
  double totalPrice() {
    double total = 0;

    for (var item in cart) {
      // tryParse instead of parse: a missing/bad "price" field
      // becomes 0 instead of crashing the whole checkout screen.
      final double price =
          double.tryParse(item["price"]?.toString() ?? "") ?? 0;
      final int qty = int.tryParse(item["quantity"]?.toString() ?? "") ?? 0;

      total += price * qty;
    }

    return total;
  }

  // =========================
  // CLEAR CART
  // =========================
  void clearCart() {
    cart.clear();
    box.remove("cart");
  }

  // =========================
  // PERSIST TO STORAGE
  // =========================
  void _persist() {
    box.write("cart", cart.toList());
  }
}
