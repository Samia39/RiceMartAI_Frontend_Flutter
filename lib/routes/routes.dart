import 'package:get/get.dart';
import '../screens/splash_screen.dart';
import '../screens/login screen/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/user_dashboard.dart';
import '../screens/admin_dashboard.dart';
import '../screens/seller_dashboard.dart';

import '../screens/user/shops_screen.dart';
import '../screens/user/shop_detail_screen.dart';
import '../screens/admin/admin_shops_screen.dart';
import '../screens/admin/admin_shop_detail_screen.dart';
import '../screens/user/conversations_screen.dart';
import '../screens/user/chat_screen.dart';




class AppRoutes {
  AppRoutes._();

  static const String splash          = '/';
  static const String login           = '/login';
  static const String register        = '/register';
  static const String userDashboard   = '/user-dashboard';
  static const String adminDashboard  = '/admin-dashboard';
  static const String sellerDashboard = '/seller-dashboard';
  static const String userProducts    = '/user-products';
  static const String productDetail   = '/product-detail';
  static const String shops           = '/shops';
  static const String shopDetail      = '/shop-detail';
  static const String adminProducts   = '/admin-products';

  static final List<GetPage> pages = [
    GetPage(name: splash,          page: () => const SplashScreen()),
    GetPage(name: login,           page: () => const LoginScreen()),
    GetPage(name: register,        page: () => const RegisterScreen()),
    GetPage(name: userDashboard,   page: () => const UserDashboard()),
    GetPage(name: adminDashboard,  page: () => const AdminDashboard()),
    GetPage(name: sellerDashboard, page: () => const SellerDashboard()),
    
    GetPage(name: shops,           page: () => const ShopsScreen()),
    GetPage(name: shopDetail,      page: () => const ShopDetailScreen()),
  
   GetPage(name: '/admin-shops',       page: () => const AdminShopsScreen()),
   GetPage(name: '/admin-shop-detail', page: () => const AdminShopDetailScreen()),
   GetPage(name: '/conversations', page: () => const ConversationsScreen()),
   GetPage(name: '/chat-screen',   page: () => const ChatScreen()), 
    
  ];
}