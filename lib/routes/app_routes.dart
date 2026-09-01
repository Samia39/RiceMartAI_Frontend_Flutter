class AppRoutes {
  // Splash
  static const splash = "/";

  // Authentication
  static const login = "/login";
  static const register = "/register";
  static const verifyOtp = "/verify-otp";
  static const forgotpassword = "/forgot-password";
  static const accessDenied = "/access-denied";

  // =========================
  // BUYER DASHBOARD
  // =========================
  static const dashboard = "/dashboard";
  static const cart = "/cart";
  static const checkout = "/checkout";
  static const riceDetails = "/rice-details";
  static const shopDetails = "/shop-details";
  static const myOrders = "/my-orders";
  static const orderDetails = "/order-details";
  static const createShop = "/create-shop";
  static const airecommendation = "/ai-recommendation";
  static const airecommendationresult = "/ai-recommendation-result";
  static const profile = "/profile";

  // Newly converted from Navigator.push/Get.to to named routes so
  // middleware (AuthMiddleware etc.) actually runs for them.
  static const aiDetection = "/ai-detection";
  static const allRice = "/all-rice";
  static const notifications = "/notifications";
  static const customerComplaints = "/customer-complaints";
  static const customerNewComplaint = "/customer-complaints/new";
  static const customerComplaintDetail = "/customer-complaints/detail";

  // =========================
  // Seller Dashboard
  // =========================
  static const sellerDashboard = "/seller-dashboard";

  // Seller Edit Shop
  static const editShop = "/edit-shop";
  static const myShop = "/my-shop";
  static const shopStatus = "/shop-status";
  static const addProduct = "/add-product";

  // Newly converted from Navigator.push/Get.to to named routes so
  // middleware actually runs for them.
  static const sellerAddProductForm = "/seller/add-product-form";
  static const sellerPayoutDetails = "/seller/payout-details";
  static const sellerPayouts = "/seller/payouts";
  static const sellerComplaints = "/seller/complaints";
  static const sellerNewComplaint = "/seller/complaints/new";
  static const sellerComplaintDetail = "/seller/complaints/detail";
  static const sellerOrderDetail = "/seller/order-detail";

  // =========================
  // ADMIN DASHBOARD
  // =========================
  static const adminDashboard = "/admin-dashboard";
  // Admin
  static const analytics = "/analytics";
  static const sellerApprovals = "/seller-approvals";
  static const approvedShops = "/approved-shops";
  static const paymentScreen = "/payment-screen";
  static const adminPaymentSettings = "/admin-payment-settings";
  static const adminordersscreen = "/admin-orders";

  static const reports = "/reports";
  static const adminSettings = "/admin-settings";
  static const adminNotifications = "/admin-notifications";
  static const addSeller = "/add-seller";
  static const adminSearch = "/admin-search";
  // User Management
  static const users = "/users";
  static const roles = "/roles";
  static const assignPermissions = "/assign-permissions";
  static const chat = "/chat";
  static const conversation = "/conversation";
  static const airesult = "/airesult";

  // Newly converted from Navigator.push/Get.to to named routes so
  // middleware actually runs for them.
  static const adminOrderDetail = "/admin/order-detail";
  static const adminShopVerification = "/admin/shop-verification";
  static const adminApprovedShopDetail = "/admin/approved-shop-detail";
  static const adminCities = "/admin/cities";
  static const adminCourierCharges = "/admin/courier-charges";
  static const adminComplaints = "/admin/complaints";
  static const adminComplaintDetail = "/admin/complaints/detail";
  static const adminPayouts = "/admin/payouts";
}
