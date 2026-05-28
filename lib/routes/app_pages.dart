import 'package:get/get.dart';
import '../middleware/auth_middleware.dart';
import '../screens/buyer/orders/my_orders_screen.dart';
import '../screens/buyer/shops/shop_details_screen.dart';
import '../screens/buyer/cart/cart_screen.dart';
import '../screens/buyer/rice/rice_detail_screen.dart';
import '../screens/seller/shop/create_shop_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/buyer/dashboard/buyer_dashboard_screen.dart';
import '../screens/admin_screens/dashboard/admin_dashboard.dart';
import '../screens/seller/dashboard/seller_dashboard_screen.dart';
import '../screens/buyer/orders/order_details_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    // Splash Screen
    GetPage(name: AppRoutes.splash, page: () => SplashScreen()),

    // Login Screen
    GetPage(name: AppRoutes.login, page: () => LoginScreen()),

    // Register Screen
    GetPage(name: AppRoutes.register, page: () => RegisterScreen()),

    // =========================
    // Buyer Dashboard
    // =========================
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const BuyerDashboardScreen(),
      middlewares: [AuthMiddleware()],
    ),

    // Cart Screen
    GetPage(
      name: AppRoutes.cart,
      page: () => CartScreen(onCartUpdated: () {}),
    ),

    // Rice Details Screen
    GetPage(name: AppRoutes.riceDetails, page: () => const RiceDetailScreen()),

    // Shop Details Screen
    GetPage(name: AppRoutes.shopDetails, page: () => const ShopDetailsScreen()),

    GetPage(name: AppRoutes.myOrders, page: () => const MyOrdersScreen()),

    // Order Details Screen
    GetPage(
      name: AppRoutes.orderDetails,
      page: () => const OrderDetailsScreen(),
    ),

    GetPage(name: AppRoutes.createShop, page: () => const CreateShopScreen()),

    // =========================
    // Seller Dashboard
    // =========================
    GetPage(
      name: AppRoutes.sellerDashboard,
      page: () => const SellerDashboardScreen(),
    ),

    // =========================
    // Admin Dashboard
    // =========================
    GetPage(name: AppRoutes.adminDashboard, page: () => const AdminDashboard()),
  ];
}
