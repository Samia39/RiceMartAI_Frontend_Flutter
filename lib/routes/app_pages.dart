import 'package:frontend/screens/auth/forget_password.dart';
import 'package:frontend/screens/auth/otp_verification.dart';
import 'package:frontend/screens/buyer/dashboard/buyer_dashboard_screen.dart';
import 'package:frontend/screens/chats/chat.dart';
import 'package:frontend/screens/chats/conversation.dart';
import 'package:get/get.dart';
import '../middleware/auth_middleware.dart';
import '../middleware/role_middleware.dart';
import '../screens/access_denied_screen.dart';
import '../screens/admin_screens/analytics/analytics_screen.dart';
import '../screens/admin_screens/notifications/admin_notifications_screen.dart';
import '../screens/admin_screens/orders/admin_orders_screen.dart';
import '../screens/admin_screens/payments/payment_screen.dart';
import '../screens/admin_screens/reports/reports_screen.dart';
import '../screens/admin_screens/search/admin_search_results_screen.dart';
import '../screens/admin_screens/settings/admin_settings_screen.dart';
import '../screens/admin_screens/shops/add_seller_screen.dart';
import '../screens/admin_screens/shops/approved_shops_screen.dart';
import '../screens/admin_screens/shops/shop_approvals_screen.dart';
import '../screens/admin_screens/user_management/assign_permissions_screen.dart';
import '../screens/admin_screens/user_management/roles_screen.dart';
import '../screens/admin_screens/user_management/users_screen.dart';
import '../screens/auth/forget_password.dart';
import '../screens/auth/otp_verification.dart';
import '../screens/buyer/cart/checkout_screen.dart';
import '../screens/buyer/orders/my_orders_screen.dart';
import '../screens/buyer/orders/order_details_screen.dart';
import '../screens/buyer/shops/shop_details_screen.dart';
import '../screens/buyer/cart/cart_screen.dart';
import '../screens/buyer/rice/rice_detail_screen.dart';
import '../screens/seller/shop/create_shop_screen.dart';
import '../screens/seller/shop/edit_shop_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/admin_screens/dashboard/admin_dashboard.dart';
import '../screens/seller/dashboard/seller_dashboard_screen.dart';
import '../screens/buyer/home/ai_result.dart';
import '../screens/buyer/home/ai_recommendation_screen.dart';
import '../screens/buyer/home/recommendation_result_screen.dart';

import 'app_routes.dart';
import '../middleware/permission_middleware.dart';
import '../screens/buyer/home/ai_recommendation_screen.dart';
import '../screens/buyer/home/recommendation_result_screen.dart';
import '../screens/buyer/profile/profile_screen.dart';

class AppPages {
  static final routes = [
    // Splash Screen
    GetPage(name: AppRoutes.splash, page: () => SplashScreen()),

    // Login Screen
    GetPage(name: AppRoutes.login, page: () => LoginScreen()),

    // Register Screen
    GetPage(name: AppRoutes.register, page: () => RegisterScreen()),

    GetPage(
      name: AppRoutes.verifyOtp,
      page: () => const OtpVerificationScreen(),
    ),
    GetPage(
      name: AppRoutes.forgotpassword,
      page: () => const ForgotPasswordScreen(),
    ),

    // Access Denied Screen
    GetPage(
      name: AppRoutes.accessDenied,
      page: () => const AccessDeniedScreen(),
    ),

    // =========================
    // Buyer Dashboard
    // =========================
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const BuyerDashboardScreen(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(['customer']),
      ],
    ),

    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      middlewares: [AuthMiddleware()],
    ),

    // Cart Screen
    GetPage(
      name: AppRoutes.cart,
      page: () => CartScreen(onCartUpdated: () {}),
    ),

    // Checkout Screen
    GetPage(name: AppRoutes.checkout, page: () => const CheckoutScreen()),

    // Rice Details Screen
    GetPage(name: AppRoutes.riceDetails, page: () => const RiceDetailScreen()),

    // Shop Details Screen
    GetPage(name: AppRoutes.shopDetails, page: () => const ShopDetailsScreen()),

    // My Orders
    GetPage(
      name: AppRoutes.myOrders,
      page: () => const MyOrdersScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view orders')],
    ),

    // Order Details
    GetPage(
      name: AppRoutes.orderDetails,
      page: () => OrderDetailsScreen(order: Get.arguments),
    ),

    //  Create Shop Screen
    GetPage(
      name: AppRoutes.createShop,
      page: () => const CreateShopScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('create shop')],
    ),

    // =========================
    // Seller Dashboard
    // =========================
    GetPage(
      name: AppRoutes.sellerDashboard,
      page: () => const SellerDashboardScreen(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(['seller']),
      ],
    ),

    GetPage(
      name: AppRoutes.editShop,
      page: () => const EditShopScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('manage shop')],
    ),

    // =========================
    // Admin Dashboard
    // =========================
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboard(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(['admin', 'super_admin']),
      ],
    ),

    // Admin Analytics
    GetPage(
      name: AppRoutes.analytics,
      page: () => const AnalyticsScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view analytics')],
    ),

    // Admin Seller Approvals
    GetPage(
      name: AppRoutes.sellerApprovals,
      page: () => const ShopApprovalsScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('approve shops')],
    ),

    // Admin Approved Shops
    GetPage(
      name: AppRoutes.approvedShops,
      page: () => const ApprovedShopsScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view shops')],
    ),
    // Admin Payments
    GetPage(name: AppRoutes.paymentScreen, page: () => const PaymentScreen()),
    // Admin Orders
    GetPage(
      name: AppRoutes.adminordersscreen,
      page: () => const AdminOrdersScreen(),
    ),

    // Admin Reports
    GetPage(
      name: AppRoutes.reports,
      page: () => const ReportsScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('manage reports')],
    ),

    // Admin Settings
    GetPage(
      name: AppRoutes.adminSettings,
      page: () => const AdminSettingsScreen(),
      middlewares: [AuthMiddleware()],
    ),

    // Admin Notifications
    GetPage(
      name: AppRoutes.adminNotifications,
      page: () => const AdminNotificationsScreen(),
      middlewares: [AuthMiddleware()],
    ),

    // Admin Add Seller
    GetPage(
      name: AppRoutes.addSeller,
      page: () => const AddSellerScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('create shop')],
    ),

    // Admin Search
    GetPage(
      name: AppRoutes.adminSearch,
      page: () => AdminSearchResultsScreen(query: Get.arguments),
      middlewares: [AuthMiddleware()],
    ),

    // User Management
    GetPage(
      name: AppRoutes.users,
      page: () => UsersScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view users')],
    ),

    GetPage(
      name: AppRoutes.roles,
      page: () => RolesScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('manage roles')],
    ),

    GetPage(
      name: AppRoutes.assignPermissions,
      page: () => const AssignPermissionScreen(),
      middlewares: [
        AuthMiddleware(),
        PermissionMiddleware('manage permissions'),
      ],
    ),
    GetPage(name: AppRoutes.chat, page: () => ChatScreen()),
    GetPage(name: AppRoutes.conversation, page: () => ConversationsScreen()),
    GetPage(
      name: AppRoutes.airesult,
      page: () => const AIResultScreen(result: {}),
    ),
    GetPage(
      name: AppRoutes.airecommendation,
      page: () => const AiRecommendationScreen(),
    ),
    GetPage(
      name: AppRoutes.airecommendationresult,
      page: () => const AiRecommendationResultScreen(query: "", result: {}),
    ),
    GetPage(
      name: AppRoutes.verifyOtp,
      page: () => const OtpVerificationScreen(),
    ),
    GetPage(
      name: AppRoutes.forgotpassword,
      page: () => const ForgotPasswordScreen(),
    ),
  ];
}
