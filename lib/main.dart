import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'core/services/cart_service.dart';
import 'core/utils/themes.dart';
import 'routes/app_routes.dart';
import 'routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  Get.put(CartService());

  // Initialize Stripe only on native platforms.
  // flutter_stripe is causing Platform._operatingSystem
  // when initialized on Flutter Web.
  if (!kIsWeb) {
    Stripe.publishableKey =
        "pk_test_51U7HrHQ8RiNpzmf2FmvcBjKae5hJ4CF5fM7tBUVSHp4djWo5Nk2WcVwJhc1XyNgZVJq95f0elTmYlPEDINfmW1Qo001oGGzNee";

    try {
      await Stripe.instance.applySettings();
    } catch (e) {
      debugPrint("Stripe initialization error: $e");
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
    );
  }
}
