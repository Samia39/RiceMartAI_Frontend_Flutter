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
  // =========================
  void addToCart({required Map<String, dynamic> rice, required int quantity}) {
    List cart = getCart();

    int existingIndex = cart.indexWhere((item) => item["id"] == rice["id"]);

    if (existingIndex != -1) {
      cart[existingIndex]["quantity"] += quantity;
    } else {
      // IMPORTANT: create COPY to avoid mutation bugs
      Map<String, dynamic> newItem = Map<String, dynamic>.from(rice);
      newItem["quantity"] = quantity;

      cart.add(newItem);
    }

    box.write("cart", cart);
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
  // =========================
  void updateQuantity({required int riceId, required int quantity}) {
    List cart = getCart();

    int index = cart.indexWhere((item) => item["id"] == riceId);

    if (index != -1) {
      cart[index]["quantity"] = quantity;
    }

    box.write("cart", cart);
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
