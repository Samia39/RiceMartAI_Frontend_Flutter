import 'package:get/get.dart';

// Middleware
import '../middleware/auth_middleware.dart';
import '../middleware/permission_middleware.dart';
import '../middleware/role_middleware.dart';

// Routes
import 'app_routes.dart';

// Common
import '../screens/access_denied_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/shared/notification_screen.dart';

// Auth
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forget_password.dart';
import '../screens/auth/otp_verification.dart';

// Buyer
import '../screens/buyer/dashboard/buyer_dashboard_screen.dart';
import '../screens/buyer/profile/profile_screen.dart';
import '../screens/buyer/cart/cart_screen.dart';
import '../screens/buyer/cart/checkout_screen.dart';
import '../screens/buyer/orders/my_orders_screen.dart';
import '../screens/buyer/orders/order_details_screen.dart';
import '../screens/buyer/shops/shop_details_screen.dart';
import '../screens/buyer/rice/rice_detail_screen.dart';
import '../screens/buyer/rice/all_rice_screen.dart';

// Buyer AI
import '../screens/buyer/home/ai_result.dart';
import '../screens/buyer/home/ai_detection_screen.dart';
import '../screens/buyer/home/ai_recommendation_screen.dart';
import '../screens/buyer/home/recommendation_result_screen.dart';

// Buyer Complaints
import '../screens/buyer/complaints/customer_complaint_list_screen.dart';
import '../screens/buyer/complaints/customer_new_complaint_screen.dart';
import '../screens/buyer/complaints/customer_complaint_detail_screen.dart';

// Seller
import '../screens/seller/dashboard/seller_dashboard_screen.dart';
import '../screens/seller/rice/add_rice_screen.dart';
import '../screens/seller/rice/add_product_form_screen.dart';
import '../screens/seller/shop/my_shop_screen.dart';
import '../screens/seller/shop/create_shop_screen.dart';
import '../screens/seller/shop/edit_shop_screen.dart';
import '../screens/seller/shop/shop_status_screen.dart';
import '../screens/seller/payout/SellerPayoutDetailsScreen.dart';
import '../screens/seller/payout/SellerPayoutsScreen.dart';
import '../screens/seller/complaints/seller_complaint_list_screen.dart';
import '../screens/seller/complaints/seller_new_complaint_screen.dart';
import '../screens/seller/complaints/seller_complaint_detail_screen.dart';
import '../screens/seller/order/seller_order_details_screen.dart';

// Admin
import '../screens/admin_screens/dashboard/admin_home_shell.dart';
import '../screens/admin_screens/orders/admin_orders_screen.dart';
import '../screens/admin_screens/orders/admin_order_details_screen.dart';
import '../screens/admin_screens/payments/payment_screen.dart';
import '../screens/admin_screens/payments/admin_payment_settings_screen.dart';
import '../screens/admin_screens/settings/admin_settings_screen.dart';
import '../screens/admin_screens/shops/add_seller_screen.dart';
import '../screens/admin_screens/shops/approved_shops_screen.dart';
import '../screens/admin_screens/shops/approved_shop_detail_screen.dart';
import '../screens/admin_screens/shops/shop_approvals_screen.dart';

// Admin shop details has same class name as buyer ShopDetailsScreen
import '../screens/admin_screens/shops/admin_shop_details_screen.dart'
    as admin_shop;

// Admin User Management
import '../screens/admin_screens/user_management/assign_permissions_screen.dart';
import '../screens/admin_screens/user_management/roles_screen.dart';
import '../screens/admin_screens/user_management/users_screen.dart';

// Admin Courier Management
import '../screens/admin_screens/courier_management/city_screen.dart';
import '../screens/admin_screens/courier_management/courier_charge_screen.dart';

// Admin Complaints
import '../screens/admin_screens/complaints/admin_complaint_list_screen.dart';
import '../screens/admin_screens/complaints/admin_complaint_detail_screen.dart';

// Admin Payouts
import '../screens/admin_screens/payout/admin_payouts_screen.dart';

// Chat
import '../screens/chats/chat.dart';
import '../screens/chats/conversation.dart';

class AppPages {
  static final routes = [
    // =========================================================
    // SPLASH / AUTH
    // =========================================================
    GetPage(name: AppRoutes.splash, page: () => SplashScreen()),

    GetPage(name: AppRoutes.login, page: () => LoginScreen()),

    GetPage(name: AppRoutes.register, page: () => RegisterScreen()),

    GetPage(
      name: AppRoutes.verifyOtp,
      page: () => const OtpVerificationScreen(),
    ),

    GetPage(
      name: AppRoutes.forgotpassword,
      page: () => const ForgotPasswordScreen(),
    ),

    // =========================================================
    // ACCESS DENIED
    // =========================================================
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

    // =========================================================
    // CUSTOMER COMPLAINTS
    // =========================================================
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

    GetPage(
      name: AppRoutes.editShop,
      page: () => const EditShopScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('update own shop')],
    ),

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

    GetPage(
      name: AppRoutes.addProduct,
      page: () => const AddRiceScreen(),
      middlewares: [
        AuthMiddleware(),
        PermissionMiddleware('view own products'),
      ],
    ),

    GetPage(
      name: AppRoutes.sellerAddProductForm,
      page: () => const AddProductFormScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('create products')],
    ),

    // =========================================================
    // SELLER PAYOUTS
    // =========================================================
    GetPage(
      name: AppRoutes.sellerPayoutDetails,
      page: () => const SellerPayoutDetailsScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('update own shop')],
    ),

    GetPage(
      name: AppRoutes.sellerPayouts,
      page: () => const SellerPayoutsScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view own payouts')],
    ),

    // =========================================================
    // SELLER COMPLAINTS
    // =========================================================
    GetPage(
      name: AppRoutes.sellerComplaints,
      page: () => const SellerComplaintListScreen(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.sellerNewComplaint,
      page: () => const SellerNewComplaintScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('file complaints')],
    ),

    GetPage(
      name: AppRoutes.sellerComplaintDetail,
      page: () => const SellerComplaintDetailScreen(),
      middlewares: [AuthMiddleware()],
    ),

    // =========================================================
    // SELLER ORDER DETAILS
    // =========================================================
    GetPage(
      name: AppRoutes.sellerOrderDetail,
      page: () => SellerOrderDetailScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view shop orders')],
    ),

    // =========================================================
    // ADMIN
    // =========================================================
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminHomeShell(),
      middlewares: [
        AuthMiddleware(),
        RoleMiddleware(['admin', 'super_admin']),
      ],
    ),

    // =========================================================
    // ADMIN SHOP MANAGEMENT
    // =========================================================
    GetPage(
      name: AppRoutes.sellerApprovals,
      page: () => const ShopApprovalsScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('approve shops')],
    ),

    GetPage(
      name: AppRoutes.approvedShops,
      page: () => const ApprovedShopsScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view all shops')],
    ),

    GetPage(
      name: AppRoutes.addSeller,
      page: () => const AddSellerScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('create sellers')],
    ),

    GetPage(
      name: AppRoutes.adminApprovedShopDetail,
      page: () => const ApprovedShopDetailScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view all shops')],
    ),

    GetPage(
      name: AppRoutes.adminShopVerification,
      page: () => const admin_shop.ShopDetailsScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view all shops')],
    ),

    // =========================================================
    // ADMIN ORDERS
    // =========================================================
    GetPage(
      name: AppRoutes.adminordersscreen,
      page: () => const AdminOrdersScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view all orders')],
    ),

    GetPage(
      name: AppRoutes.adminOrderDetail,
      page: () => const AdminOrderDetailsScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view all orders')],
    ),

    // =========================================================
    // ADMIN PAYMENTS
    // =========================================================
    GetPage(
      name: AppRoutes.paymentScreen,
      page: () => const PaymentScreen(),
      middlewares: [
        AuthMiddleware(),
        PermissionMiddleware('view all payments'),
      ],
    ),

    GetPage(
      name: AppRoutes.adminPaymentSettings,
      page: () => const AdminPaymentSettingsScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('manage settings')],
    ),

    GetPage(
      name: AppRoutes.adminPayouts,
      page: () => const AdminPayoutsScreen(),
      middlewares: [
        AuthMiddleware(),
        PermissionMiddleware('view all payments'),
      ],
    ),

    // =========================================================
    // ADMIN SETTINGS
    // =========================================================
    GetPage(
      name: AppRoutes.adminSettings,
      page: () => const AdminSettingsScreen(),
      middlewares: [AuthMiddleware()],
    ),

    // =========================================================
    // ADMIN USER MANAGEMENT
    // =========================================================
    GetPage(
      name: AppRoutes.users,
      page: () => UsersScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view users')],
    ),

    GetPage(
      name: AppRoutes.roles,
      page: () => RolesScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view roles')],
    ),

    GetPage(
      name: AppRoutes.assignPermissions,
      page: () => const AssignPermissionScreen(),
      middlewares: [
        AuthMiddleware(),
        PermissionMiddleware('assign permissions'),
      ],
    ),

    // =========================================================
    // ADMIN COURIER MANAGEMENT
    // =========================================================
    GetPage(
      name: AppRoutes.adminCities,
      page: () => const CityScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('manage cities')],
    ),

    GetPage(
      name: AppRoutes.adminCourierCharges,
      page: () => const CourierChargeScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('manage cities')],
    ),

    // =========================================================
    // ADMIN COMPLAINTS
    // =========================================================
    GetPage(
      name: AppRoutes.adminComplaints,
      page: () => const AdminComplaintListScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view complaints')],
    ),

    GetPage(
      name: AppRoutes.adminComplaintDetail,
      page: () => const AdminComplaintDetailScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view complaints')],
    ),

    // =========================================================
    // SHARED CHAT
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
