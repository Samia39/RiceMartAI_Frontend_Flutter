import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthMiddleware extends GetMiddleware {
  final box = GetStorage();

  @override
  RouteSettings? redirect(String? route) {
    var token = box.read('token'); // ✅ read saved token

    if (token == null) {
      return const RouteSettings(name: '/login');
    }

    return null; // ✅ allow access
  }
}
