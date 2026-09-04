import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CartService extends GetxController {
  final box = GetStorage();

  // Reactive cart — any Obx() watching this rebuilds automatically
  final RxList cart = [].obs;

  @override
  void onInit() {
    super.onInit();
    cart.value = box.read("cart") ?? [];
  }

  List getCart() => cart;

  String addToCart({
    required Map<String, dynamic> rice,
    required int quantity,
  }) {
    final int stock = int.tryParse(rice["stock"].toString()) ?? 0;

    int existingIndex = cart.indexWhere((item) => item["id"] == rice["id"]);

    if (existingIndex != -1) {
      final int currentQty = cart[existingIndex]["quantity"];

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
      final int newQty = quantity > stock ? stock : quantity;

      if (newQty <= 0) {
        return "maxed";
      }

      Map<String, dynamic> newItem = Map<String, dynamic>.from(rice);
      newItem["quantity"] = newQty;

      cart.add(newItem);
      _persist();

      return newQty < quantity ? "capped" : "added";
    }
  }

  void removeItem(int riceId) {
    cart.removeWhere((item) => item["id"] == riceId);
    _persist();
  }

  int updateQuantity({required int riceId, required int quantity}) {
    int index = cart.indexWhere((item) => item["id"] == riceId);

    if (index != -1) {
      final int stock = int.tryParse(cart[index]["stock"].toString()) ?? 0;
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

  double totalPrice() {
    double total = 0;
    for (var item in cart) {
      total += (double.parse(item["price"].toString()) * item["quantity"]);
    }
    return total;
  }

  void clearCart() {
    cart.clear();
    box.remove("cart");
  }

  void _persist() {
    box.write("cart", cart.toList());
  }
}
