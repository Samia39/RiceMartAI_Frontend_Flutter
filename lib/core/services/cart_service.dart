import 'package:get_storage/get_storage.dart';

class CartService {
  final box = GetStorage();

  // =========================
  // GET CART
  // =========================
  List getCart() {
    return box.read("cart") ?? [];
  }

  // =========================
  // ADD TO CART
  // Returns a status so the calling screen can show the right message:
  //   "added"   -> added normally
  //   "capped"  -> added, but quantity was reduced to match available stock
  //   "maxed"   -> already at max stock in cart, nothing added
  // =========================
  String addToCart({
    required Map<String, dynamic> rice,
    required int quantity,
  }) {
    List cart = getCart();

    final int stock = int.tryParse(rice["stock"].toString()) ?? 0;

    int existingIndex = cart.indexWhere((item) => item["id"] == rice["id"]);

    if (existingIndex != -1) {
      final int currentQty = cart[existingIndex]["quantity"];

      if (currentQty >= stock) {
        // already holding all available stock
        return "maxed";
      }

      final int requestedTotal = currentQty + quantity;
      final int newQty = requestedTotal > stock ? stock : requestedTotal;

      cart[existingIndex]["quantity"] = newQty;
      box.write("cart", cart);

      return requestedTotal > stock ? "capped" : "added";
    } else {
      final int newQty = quantity > stock ? stock : quantity;

      if (newQty <= 0) {
        return "maxed";
      }

      // IMPORTANT: create COPY to avoid mutation bugs
      Map<String, dynamic> newItem = Map<String, dynamic>.from(rice);
      newItem["quantity"] = newQty;

      cart.add(newItem);
      box.write("cart", cart);

      return newQty < quantity ? "capped" : "added";
    }
  }

  // =========================
  // REMOVE ITEM
  // =========================
  void removeItem(int riceId) {
    List cart = getCart();

    cart.removeWhere((item) => item["id"] == riceId);

    box.write("cart", cart);
  }

  // =========================
  // UPDATE QUANTITY
  // Clamped to the item's stock so it can never be pushed above it,
  // e.g. from the cart screen's +/- buttons.
  // Returns the quantity that was actually saved.
  // =========================
  int updateQuantity({required int riceId, required int quantity}) {
    List cart = getCart();

    int index = cart.indexWhere((item) => item["id"] == riceId);

    if (index != -1) {
      final int stock = int.tryParse(cart[index]["stock"].toString()) ?? 0;
      final int clamped = quantity > stock
          ? stock
          : (quantity < 1 ? 1 : quantity);

      cart[index]["quantity"] = clamped;
      box.write("cart", cart);

      return clamped;
    }

    return quantity;
  }

  // =========================
  // TOTAL PRICE
  // =========================
  double totalPrice() {
    List cart = getCart();

    double total = 0;

    for (var item in cart) {
      total += (double.parse(item["price"].toString()) * item["quantity"]);
    }

    return total;
  }

  // =========================
  // CLEAR CART
  // =========================
  void clearCart() {
    box.remove("cart");
  }
}
