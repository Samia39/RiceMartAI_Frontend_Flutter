import 'package:frontend/screens/admin_screens/payments/admin_payment_settings_screen.dart';
import 'package:frontend/screens/buyer/dashboard/buyer_dashboard_screen.dart';
import 'package:frontend/screens/chats/chat.dart';
import 'package:frontend/screens/chats/conversation.dart';
import 'package:frontend/screens/seller/rice/add_rice_screen.dart';
import 'package:frontend/screens/seller/rice/add_product_form_screen.dart';
import 'package:frontend/screens/seller/shop/my_shop_screen.dart';
import 'package:frontend/screens/seller/payout/SellerPayoutDetailsScreen.dart';
import 'package:frontend/screens/seller/payout/SellerPayoutsScreen.dart';
import 'package:frontend/screens/seller/complaints/seller_complaint_list_screen.dart';
import 'package:frontend/screens/seller/complaints/seller_new_complaint_screen.dart';
import 'package:frontend/screens/seller/complaints/seller_complaint_detail_screen.dart';
import 'package:frontend/screens/seller/order/seller_order_details_screen.dart';
import 'package:get/get.dart';
import '../middleware/auth_middleware.dart';
import '../middleware/role_middleware.dart';
import '../screens/access_denied_screen.dart';
import '../screens/admin_screens/dashboard/admin_home_shell.dart';
import '../screens/admin_screens/orders/admin_orders_screen.dart';
import '../screens/admin_screens/orders/admin_order_details_screen.dart';
import '../screens/admin_screens/payments/payment_screen.dart';
import '../screens/admin_screens/settings/admin_settings_screen.dart';
import '../screens/admin_screens/shops/add_seller_screen.dart';
import '../screens/admin_screens/shops/approved_shops_screen.dart';
import '../screens/admin_screens/shops/approved_shop_detail_screen.dart';
import '../screens/admin_screens/shops/shop_approvals_screen.dart';
// Aliased: the admin "shop verification" screen shares its class name
// (ShopDetailsScreen) with the buyer-facing screen imported below.
import '../screens/admin_screens/shops/admin_shop_details_screen.dart'
    as admin_shop;
import '../screens/admin_screens/user_management/assign_permissions_screen.dart';
import '../screens/admin_screens/user_management/roles_screen.dart';
import '../screens/admin_screens/user_management/users_screen.dart';
import '../screens/admin_screens/courier_management/city_screen.dart';
import '../screens/admin_screens/courier_management/courier_charge_screen.dart';
import '../screens/admin_screens/complaints/admin_complaint_list_screen.dart';
import '../screens/admin_screens/complaints/admin_complaint_detail_screen.dart';
import '../screens/admin_screens/payout/admin_payouts_screen.dart';
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
    // ADMIN ROUTES
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

    // Fixed: 'view shops' doesn't exist on the backend.
    GetPage(
      name: AppRoutes.approvedShops,
      page: () => const ApprovedShopsScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view all shops')],
    ),

    // Was missing ALL middleware — gated to match backend's
    // GET /admin/payments ('view all payments'). The approve/reject
    // actions inside this screen still separately require 'manage
    // payments' on the backend.
    GetPage(
      name: AppRoutes.paymentScreen,
      page: () => const PaymentScreen(),
      middlewares: [
        AuthMiddleware(),
        PermissionMiddleware('view all payments'),
      ],
    ),

    // Was missing ALL middleware — matches backend's 'view all orders'.
    GetPage(
      name: AppRoutes.adminordersscreen,
      page: () => const AdminOrdersScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view all orders')],
    ),

    // Was missing ALL middleware — this screen both views AND saves
    // payment settings, so gated on 'manage settings' (the mutating
    // action), matching backend's POST /admin/payment-settings.
    GetPage(
      name: AppRoutes.adminPaymentSettings,
      page: () => const AdminPaymentSettingsScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('manage settings')],
    ),

    // Non-functional mockup right now (no real backend calls) — left as
    // AuthMiddleware-only per your call; revisit once it's wired up.
    GetPage(
      name: AppRoutes.adminSettings,
      page: () => const AdminSettingsScreen(),
      middlewares: [AuthMiddleware()],
    ),

    // Fixed: 'create shop' is the CUSTOMER'S permission for applying to
    // become a seller — admin doesn't have it. The correct admin
    // permission for creating a seller account directly is
    // 'create sellers' (matches backend's /admin/create-seller route,
    // and the same fix already applied to the "Add Shop" button's
    // visibility check in admin_dashboard_tab.dart).
    GetPage(
      name: AppRoutes.addSeller,
      page: () => const AddSellerScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('create sellers')],
    ),

    GetPage(
      name: AppRoutes.users,
      page: () => UsersScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view users')],
    ),

    // Fixed: 'manage roles' doesn't exist — role management is
    // super_admin-only on the backend, gated by 'view roles' for list
    // entry (create/update/delete are separate permissions the screen's
    // own controller calls hit directly).
    GetPage(
      name: AppRoutes.roles,
      page: () => RolesScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view roles')],
    ),

    // Fixed: 'manage permissions' doesn't exist — the real backend
    // permission is 'assign permissions' (also super_admin-only).
    GetPage(
      name: AppRoutes.assignPermissions,
      page: () => const AssignPermissionScreen(),
      middlewares: [
        AuthMiddleware(),
        PermissionMiddleware('assign permissions'),
      ],
    ),

    // Newly named (previously Get.to from AdminDrawer). Both city and
    // courier-charge management map to the backend's single 'manage
    // cities' permission.
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

    // Newly named (previously Get.to from AdminDrawer). Matches
    // backend's GET /complaints, which only super_admin can call in
    // practice ('view complaints' is not assigned to plain admin) — per
    // the business rule that only Super Admin handles complaints.
    GetPage(
      name: AppRoutes.adminComplaints,
      page: () => const AdminComplaintListScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view complaints')],
    ),

    // Newly named (previously Navigator.push from
    // AdminComplaintListScreen and Get.to from NotificationsScreen).
    // complaintId passed via Get.arguments.
    GetPage(
      name: AppRoutes.adminComplaintDetail,
      page: () => const AdminComplaintDetailScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view complaints')],
    ),

    // Newly named (previously Get.to from AdminDrawer and
    // NotificationsScreen).
    GetPage(
      name: AppRoutes.adminPayouts,
      page: () => const AdminPayoutsScreen(),
      middlewares: [
        AuthMiddleware(),
        PermissionMiddleware('view all payments'),
      ],
    ),

    // Newly named (previously Get.to from AdminOrdersScreen and
    // NotificationsScreen). {order, isHistory} passed via Get.arguments.
    GetPage(
      name: AppRoutes.adminOrderDetail,
      page: () => const AdminOrderDetailsScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view all orders')],
    ),

    // Newly named (previously Navigator.push from AdminShopsTab's
    // Approved tab). Shop map passed via Get.arguments.
    GetPage(
      name: AppRoutes.adminApprovedShopDetail,
      page: () => const ApprovedShopDetailScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view all shops')],
    ),

    // Newly named (previously Navigator.push from AdminShopsTab's
    // Pending/Rejected tabs and from the standalone ShopApprovalsScreen).
    // {shop, readOnly} passed via Get.arguments. The individual
    // approve/reject/correction buttons inside are separately gated by
    // the backend on their own permissions regardless of this route gate.
    GetPage(
      name: AppRoutes.adminShopVerification,
      page: () => const admin_shop.ShopDetailsScreen(),
      middlewares: [AuthMiddleware(), PermissionMiddleware('view all shops')],
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
