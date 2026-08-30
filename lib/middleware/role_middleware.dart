import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../routes/app_routes.dart';

class RoleMiddleware extends GetMiddleware {
  final List<String> rolesAllowed;

  RoleMiddleware(this.rolesAllowed);

  @override
  RouteSettings? redirect(String? route) {
    final box = GetStorage();

    final roles = box.read('roles') ?? [];

    if (roles is! List) {
      return const RouteSettings(name: AppRoutes.login);
    }

    final hasRole = roles.any((role) => rolesAllowed.contains(role));

    if (!hasRole) {
      // Go to a neutral page, not another role-gated route — redirecting
      // to a specific dashboard here risks a redirect loop for any user
      // whose role doesn't match that dashboard either.
      return const RouteSettings(name: AppRoutes.accessDenied);
    }

    return null;
  }
}
