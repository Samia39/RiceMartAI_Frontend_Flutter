import '../screens/admin_screens/payments/admin_payment_settings_screen.dart';
import '../screens/buyer/dashboard/buyer_dashboard_screen.dart';
import '../screens/chats/chat.dart';
import '../screens/chats/conversation.dart';
import '../screens/seller/rice/add_rice_screen.dart';
import '../screens/seller/shop/my_shop_screen.dart';
import 'package:ricemart_ai/screens/admin_screens/payments/admin_payment_settings_screen.dart';
import 'package:ricemart_ai/screens/buyer/dashboard/buyer_dashboard_screen.dart';
import 'package:ricemart_ai/screens/chats/chat.dart';
import 'package:ricemart_ai/screens/chats/conversation.dart';
import 'package:ricemart_ai/screens/seller/rice/add_rice_screen.dart';
import '../screens/seller/rice/add_product_form_screen.dart';
import 'package:ricemart_ai/screens/seller/shop/my_shop_screen.dart';
import '../screens/seller/payout/SellerPayoutDetailsScreen.dart';
import 'package:ricemart_ai/screens/seller/payout/SellerPayoutsScreen.dart';
import '../screens/seller/complaints/seller_complaint_list_screen.dart';
import '../screens/seller/complaints/seller_new_complaint_screen.dart';
import '../screens/seller/complaints/seller_complaint_detail_screen.dart';
import '../screens/seller/order/seller_order_details_screen.dart';
import 'package:get/get.dart';
import '../middleware/auth_middleware.dart';
import '../middleware/role_middleware.dart';
import '../screens/access_denied_screen.dart';
import '../screens/admin_screens/dashboard/admin_home_shell.dart';
import '../screens/admin_screens/orders/admin_orders_screen.dart';
import '../screens/admin_screens/payments/payment_screen.dart';
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
import '../screens/seller/shop/shop_status_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/seller/dashboard/seller_dashboard_screen.dart';
import '../screens/buyer/home/ai_result.dart';
import '../screens/buyer/home/ai_detection_screen.dart';
import '../screens/buyer/home/ai_recommendation_screen.dart';
import '../screens/buyer/home/recommendation_result_screen.dart';
import '../screens/buyer/rice/all_rice_screen.dart';
import '../screens/shared/notification_screen.dart';
import '../screens/buyer/complaints/customer_complaint_list_screen.dart';
import '../screens/buyer/complaints/customer_new_complaint_screen.dart';
import '../screens/buyer/complaints/customer_complaint_detail_screen.dart';
import 'app_routes.dart';
import '../middleware/permission_middleware.dart';
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

    // =========================================================
    // BUYER / CUSTOMER ROUTES
    // =========================================================
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

    GetPage(
      name: AppRoutes.cart,
      page: () => CartScreen(onCartUpdated: () {}),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.checkout,
      page: () => const CheckoutScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('checkout orders')],
    ),

    GetPage(
      name: AppRoutes.riceDetails,
      page: () => const RiceDetailScreen(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.shopDetails,
      page: () => const ShopDetailsScreen(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.myOrders,
      page: () => const MyOrdersScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view own orders')],
    ),

    GetPage(
      name: AppRoutes.orderDetails,
      page: () => OrderDetailsScreen(order: Get.arguments),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.createShop,
      page: () => const CreateShopScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('create shop')],
    ),

    GetPage(
      name: AppRoutes.aiDetection,
      page: () => const AIDetectionScreen(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.allRice,
      page: () => const AllRiceScreen(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.customerComplaints,
      page: () => const CustomerComplaintListScreen(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.customerNewComplaint,
      page: () => const CustomerNewComplaintScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('file complaints')],
    ),

    GetPage(
      name: AppRoutes.customerComplaintDetail,
      page: () => const CustomerComplaintDetailScreen(),
      middlewares: [AuthMiddleware()],
    ),

    // =========================================================
    // SELLER ROUTES
    // =========================================================
    GetPage(
      name: AppRoutes.sellerDashboard,
      page: () => const SellerDashboardScreen(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(['seller']),
      ],
    ),

    // Shared by seller's normal edit AND the customer shop-correction
    // flow (ShopStatusScreen "Edit & Resubmit") — both roles now hold
    // 'update own shop' on the backend for exactly this reason.
    GetPage(
      name: AppRoutes.editShop,
      page: () => const EditShopScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('update own shop')],
    ),

    // Backend route has no permission check beyond auth:sanctum —
    // matched here (previously had a 'view shop' permission that
    // doesn't exist on the backend).
    GetPage(
      name: AppRoutes.myShop,
      page: () => const MyShopScreen(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.shopStatus,
      page: () => ShopStatusScreen(shop: Get.arguments),
      middlewares: [AuthMiddleware()],
    ),

    // This route was dead (nothing called Get.toNamed(AppRoutes.addProduct))
    // and AddRiceScreen is really the product list/manage screen (view +
    // inline edit/delete), not a create-only form — so 'add product'
    // never fit. Corrected to 'view own products', which is what actually
    // gates entry to this screen; the finer-grained edit/delete actions
    // are still separately enforced by the backend regardless of what
    // this route's middleware says.
    GetPage(
      name: AppRoutes.addProduct,
      page: () => const AddRiceScreen(),
      middlewares: [
        AuthMiddleware(),
        PermissionMiddleware('view own products'),
      ],
    ),

    // Newly named (previously reached only via Navigator.push from
    // inside AddRiceScreen). Needs shopId — passed as Get.arguments.
    GetPage(
      name: AppRoutes.sellerAddProductForm,
      page: () => const AddProductFormScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('create products')],
    ),

    // Newly named (previously reached only via Get.to from SellerDrawer).
    // Maps to backend's PUT /my-shop/payout-details, guarded by
    // 'update own shop'.
    GetPage(
      name: AppRoutes.sellerPayoutDetails,
      page: () => const SellerPayoutDetailsScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('update own shop')],
    ),

    // Newly named (previously reached only via Get.to from SellerDrawer
    // and NotificationsScreen). Maps to backend's GET /seller/payouts,
    // guarded by 'view own payouts'.
    GetPage(
      name: AppRoutes.sellerPayouts,
      page: () => const SellerPayoutsScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view own payouts')],
    ),

    // Newly named (previously reached only via Get.to from SellerDrawer).
    GetPage(
      name: AppRoutes.sellerComplaints,
      page: () => const SellerComplaintListScreen(),
      middlewares: [AuthMiddleware()],
    ),

    // Newly named (previously reached only via Navigator.push from
    // SellerComplaintListScreen).
    GetPage(
      name: AppRoutes.sellerNewComplaint,
      page: () => const SellerNewComplaintScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('file complaints')],
    ),

    // Newly named (previously reached only via Navigator.push from
    // SellerComplaintListScreen and Get.to from NotificationsScreen).
    // complaintId passed via Get.arguments.
    GetPage(
      name: AppRoutes.sellerComplaintDetail,
      page: () => const SellerComplaintDetailScreen(),
      middlewares: [AuthMiddleware()],
    ),

    // Newly named (previously reached only via Get.to from
    // SellerOrdersScreen and NotificationsScreen). item map passed via
    // Get.arguments. Gated on the same permission as the orders list
    // itself, since viewing one item's detail is part of that scope.
    GetPage(
      name: AppRoutes.sellerOrderDetail,
      page: () => SellerOrderDetailScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view shop orders')],
    ),

    // =========================================================
    // ADMIN ROUTES — pending dedicated review pass.
    // =========================================================
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminHomeShell(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(['admin', 'super_admin']),
      ],
    ),

    GetPage(
      name: AppRoutes.sellerApprovals,
      page: () => const ShopApprovalsScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('approve shops')],
    ),

    GetPage(
      name: AppRoutes.approvedShops,
      page: () => const ApprovedShopsScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view shops')],
    ),

    GetPage(name: AppRoutes.paymentScreen, page: () => const PaymentScreen()),

    GetPage(
      name: AppRoutes.adminordersscreen,
      page: () => const AdminOrdersScreen(),
    ),

    GetPage(
      name: AppRoutes.adminPaymentSettings,
      page: () => const AdminPaymentSettingsScreen(),
    ),

    GetPage(
      name: AppRoutes.adminSettings,
      page: () => const AdminSettingsScreen(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.addSeller,
      page: () => const AddSellerScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('create shop')],
    ),

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

    // =========================================================
    // SHARED (any authenticated user) — CHAT
    // =========================================================
    GetPage(
      name: AppRoutes.chat,
      page: () => ChatScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.conversation,
      page: () => ConversationsScreen(),
      middlewares: [AuthMiddleware()],
    ),

    // =========================================================
    // AI FEATURES
    // =========================================================
    GetPage(
      name: AppRoutes.airesult,
      page: () => const AIResultScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.airecommendation,
      page: () => const AiRecommendationScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.airecommendationresult,
      page: () => const AiRecommendationResultScreen(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
