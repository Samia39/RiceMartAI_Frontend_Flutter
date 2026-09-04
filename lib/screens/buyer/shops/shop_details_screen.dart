import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/product_service.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/services/shop_service.dart';
import '../../../core/utils/themes.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/shop_reviews_section.dart';

class ShopDetailsScreen extends StatefulWidget {
  const ShopDetailsScreen({super.key});

  @override
  State<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> {
  // ✅ Shop data now lives in local state instead of being read directly
  // from Get.arguments each build — this lets us REPLACE it once we
  // recover the shop from the URL id after a web refresh.
  Map<String, dynamic> _shop = {};

  // ✅ True while we're trying to recover the shop from the URL id
  // (only happens when Get.arguments was lost, e.g. web page refresh).
  bool isResolvingShop = false;

  // ✅ Null-safe id extraction; handles int, String, or missing id.
  int? _extractId(Map<String, dynamic> map) {
    final id = map["id"];
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }

  int? get shopId => _extractId(_shop);

  List<Map<String, dynamic>> productList = [];
  bool isLoading = true;
  bool isStartingChat = false;

  @override
  void initState() {
    super.initState();
    _initShop();
  }

  Future<void> _initShop() async {
    // 1. Try normal in-memory navigation arguments first (fast path —
    // this is what happens on every regular in-app tap).
    final args = Get.arguments;
    Map<String, dynamic> argShop = {};
    if (args is Map<String, dynamic>) {
      argShop = args;
    } else if (args is Map) {
      argShop = Map<String, dynamic>.from(args);
    }

    // 🔍 DEBUG
    debugPrint("=== SHOP DETAILS INIT DEBUG ===");
    debugPrint("Get.arguments = $args");
    debugPrint("Get.parameters = ${Get.parameters}");
    debugPrint("argShop extracted id = ${_extractId(argShop)}");

    if (_extractId(argShop) != null) {
      setState(() => _shop = argShop);
      fetchProducts();
      return;
    }

    // 2. Arguments were empty/lost (e.g. web page refresh). Fall back to
    // the shop id carried in the URL itself, e.g. #/shop-details?id=12
    final idFromUrl = Get.parameters['id'];
    final parsedId = idFromUrl != null ? int.tryParse(idFromUrl) : null;

    debugPrint("idFromUrl (raw) = $idFromUrl");
    debugPrint("parsedId = $parsedId");

    if (parsedId == null) {
      // No id anywhere — genuinely nothing to show.
      setState(() => isLoading = false);
      return;
    }

    setState(() => isResolvingShop = true);
    debugPrint("→ Calling ShopService().fetchShopById($parsedId)...");

    final recovered = await ShopService().fetchShopById(parsedId);
    debugPrint("→ fetchShopById result = $recovered");

    if (!mounted) return;

    if (recovered != null) {
      debugPrint("→ Recovered shop successfully.");
      setState(() {
        _shop = recovered;
        isResolvingShop = false;
      });
      fetchProducts();
    } else {
      setState(() {
        debugPrint("→ fetchShopById returned null. Showing 'not found'.");
        isResolvingShop = false;
        isLoading = false;
      });
    }
  }

  Future<void> fetchProducts() async {
    final id = shopId;
    if (id == null) return;

    final data = await ProductService().fetchShopProducts(shopId: id);

    if (!mounted) return;
    setState(() {
      productList = data;
      isLoading = false;
    });
  }

  // =============================================
  // Opens or creates a conversation with the shop
  // =============================================
  Future<void> openChat() async {
    final id = shopId;
    if (id == null) {
      Get.snackbar(
        "Error",
        "Shop information is missing. Please go back and try again.",
      );
      return;
    }

    setState(() => isStartingChat = true);

    final result = await ChatService().startConversation(shopId: id);

    if (!mounted) return;
    setState(() => isStartingChat = false);

    if (result["conversation_id"] != null) {
      Get.toNamed(
        AppRoutes.chat,
        arguments: {
          "conversation_id": result["conversation_id"],
          "other_name": _shop["shop_name"] ?? "Shop",
        },
      );
    } else {
      Get.snackbar("Error", "Could not start chat. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Still resolving the shop from the URL id — show a loading state
    // instead of immediately showing "not found".
    if (isResolvingShop) {
      return Container(
        decoration: AppDecorations.gradientBackground,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: const Text("Shop")),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // ✅ Guard: if we truly have no shop id (no arguments AND no URL id,
    // or the URL id didn't match any shop), show a friendly fallback
    // instead of letting the rest of the widget tree crash on nulls.
    if (shopId == null) {
      return Container(
        decoration: AppDecorations.gradientBackground,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: const Text("Shop")),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.storefront_outlined,
                    size: 56,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "We couldn't load this shop.",
                    style: AppTextStyles.heading3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "This can happen if the page was refreshed. Please go back and open the shop again.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text("Go Back"),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(_shop["shop_name"] ?? "")),
        // =========================
        // ✅ RESPONSIVE BODY
        // Content is centered and width-capped on large screens.
        // Product grid uses SliverGridDelegateWithMaxCrossAxisExtent so
        // column count adjusts automatically to screen width, while
        // mainAxisExtent keeps card height fixed.
        // =========================
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =========================
                  // SHOP INFO CARD
                  // =========================
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppDecorations.card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _shop["shop_name"] ?? "",
                          style: AppTextStyles.heading2,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Owner: ${_shop["owner_name"] ?? "N/A"}",
                          style: AppTextStyles.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Address: ${_shop["address"] ?? "N/A"}",
                          style: AppTextStyles.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _shop["description"] ?? "",
                          style: AppTextStyles.bodyLarge,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // =========================
                  // CHAT WITH SELLER BUTTON
                  // =========================
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isStartingChat ? null : openChat,
                      icon: isStartingChat
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.chat_bubble_outline),
                      label: Text(
                        isStartingChat ? "Opening..." : "Chat with Seller",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // =========================
                  // TITLE
                  // =========================
                  Text("Available Products", style: AppTextStyles.heading3),
                  const SizedBox(height: 14),

                  if (isLoading)
                    const Center(child: CircularProgressIndicator()),

                  if (!isLoading && productList.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: AppDecorations.card,
                      child: const Text("No products available"),
                    ),

                  if (!isLoading && productList.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: productList.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            mainAxisExtent: 260,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                          ),
                      itemBuilder: (context, index) {
                        final product = productList[index];
                        final imageUrl = ProductService.getImageUrl(product);

                        // ✅ Whole card is now clickable -> goes to product details
                        return GestureDetector(
                          onTap: () async {
                            final result = await Get.toNamed(
                              AppRoutes.riceDetails,
                              arguments: product,
                            );
                            if (result == true) {
                              setState(() {});
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: AppDecorations.card,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ✅ PRODUCT IMAGE
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    height: 90,
                                    width: double.infinity,
                                    color: AppColors.cream,
                                    child: imageUrl != null
                                        ? Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 90,
                                            errorBuilder: (c, e, s) =>
                                                const Icon(
                                                  Icons.rice_bowl,
                                                  size: 50,
                                                  color: AppColors.darkGreen,
                                                ),
                                          )
                                        : const Icon(
                                            Icons.rice_bowl,
                                            size: 50,
                                            color: AppColors.darkGreen,
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  product["name"] ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.heading4,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product["rice_category"]?["name"] ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodyMedium,
                                ),
                                const SizedBox(height: 8),

                                // ✅ PRICE + ADD TO CART
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Rs ${product["price"]}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.heading4.copyWith(
                                          color: AppColors.darkGreen,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        CartService().addToCart(
                                          rice: product,
                                          quantity: 1,
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "${product["name"]} added to cart",
                                            ),
                                            duration: const Duration(
                                              seconds: 1,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 28,
                                        width: 28,
                                        decoration: BoxDecoration(
                                          color: AppColors.darkGreen,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.add_shopping_cart_rounded,
                                          color: Colors.white,
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${product["stock"]} KG left",
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 24),

                  // =========================
                  // SHOP REVIEWS
                  // Visible to any customer viewing this shop, so they
                  // can see what past buyers said before purchasing.
                  // =========================
                  Text("Customer Reviews", style: AppTextStyles.heading3),
                  const SizedBox(height: 14),
                  ShopReviewsSection(shopId: shopId!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
