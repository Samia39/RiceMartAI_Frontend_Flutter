import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class RoleMiddleware extends GetMiddleware {
  final List<String> rolesAllowed;

  RoleMiddleware(this.rolesAllowed);

  @override
  RouteSettings? redirect(String? route) {
    final box = GetStorage();

    final roles = box.read('roles') ?? [];

    if (roles is! List) {
      return const RouteSettings(name: '/login');
    }

    final hasRole = roles.any((role) => rolesAllowed.contains(role));

    if (!hasRole) {
      return const RouteSettings(name: '/dashboard');
    }

    return null;
  }
}
