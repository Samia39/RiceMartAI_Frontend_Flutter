import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../routes/app_routes.dart';

class PermissionMiddleware extends GetMiddleware {
  final String permission;

  PermissionMiddleware(this.permission);

  @override
  RouteSettings? redirect(String? route) {
    final box = GetStorage();

    final permissions = List<String>.from(box.read('permissions') ?? []);

    if (!permissions.contains(permission)) {
      return const RouteSettings(name: AppRoutes.accessDenied);
    }

    return null;
  }
}
