import 'package:get/get.dart';
import '../screens/splash_screen.dart';
import '../screens/login screen/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/otp_screen.dart';
import '../screens/user_dashboard.dart';
import '../screens/admin_dashboard.dart';
import '../screens/seller_dashboard.dart';
import '../screens/admin/admin_shops_screen.dart';
import '../screens/admin/admin_shop_detail_screen.dart';
import '../screens/user/shop_detail_screen.dart';
import '../screens/user/shops_screen.dart';
import '../screens/user/create_shop_screen.dart';
import '../screens/user/profile_screen.dart';
import '../screens/user/chat_screen.dart';
import '../screens/user/conversations_screen.dart';
import '../screens/seller/seller_shop_screen.dart';
import '../screens/seller/seller_products_screen.dart';
import '../screens/seller/seller_orders_screen.dart';
import '../screens/seller/add_product_screen.dart';
import '../screens/seller/seller_conversations_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash               = '/';
  static const String login                = '/login';
  static const String register             = '/register';
  static const String otp                  = '/otp';
  static const String userDashboard        = '/user-dashboard';
  static const String adminDashboard       = '/admin-dashboard';
  static const String sellerDashboard      = '/seller-dashboard';
  static const String adminShops           = '/admin-shops';
  static const String adminShopDetail      = '/admin-shop-detail';
  static const String shopDetail           = '/shop-detail';
  static const String shops                = '/shops';
  static const String createShop           = '/create-shop';
  static const String profile              = '/profile';
  static const String chat                 = '/chat';
  static const String conversations        = '/conversations';
  static const String sellerShop           = '/seller-shop';
  static const String sellerProducts       = '/seller-products';
  static const String sellerOrders         = '/seller-orders';
  static const String addProduct           = '/add-product';
  static const String sellerConversations  = '/seller-conversations';

  static final List<GetPage> pages = [
    GetPage(name: splash,              page: () => const SplashScreen()),
    GetPage(name: login,               page: () => const LoginScreen()),
    GetPage(name: register,            page: () => const RegisterScreen()),
    GetPage(name: otp,                 page: () => const OtpScreen()),
    GetPage(name: userDashboard,       page: () => const UserDashboard()),
    GetPage(name: adminDashboard,      page: () => const AdminDashboard()),
    GetPage(name: sellerDashboard,     page: () => const SellerDashboard()),
    GetPage(name: adminShops,          page: () => const AdminShopsScreen()),
    GetPage(name: adminShopDetail,     page: () => const AdminShopDetailScreen()),
    GetPage(name: shopDetail,          page: () => const ShopDetailScreen()),
    GetPage(name: shops,               page: () => const ShopsScreen()),
    GetPage(name: createShop,          page: () => const CreateShopScreen()),
    GetPage(name: profile,             page: () => const ProfileScreen()),
    GetPage(name: chat,                page: () => const ChatScreen()),
    GetPage(name: conversations,       page: () => const ConversationsScreen()),
    GetPage(name: sellerShop,          page: () => const SellerShopScreen()),
    GetPage(name: sellerProducts,      page: () => const SellerProductsScreen()),
    GetPage(name: sellerOrders,        page: () => const SellerOrdersScreen()),
    GetPage(name: addProduct,          page: () => const AddProductScreen()),
    GetPage(name: sellerConversations, page: () => const SellerConversationsScreen()),
  ];
}