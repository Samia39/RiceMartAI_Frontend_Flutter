import 'package:get_storage/get_storage.dart';

class PermissionService {
  static final box = GetStorage();

  static bool hasPermission(String permission) {
    final permissions = List<String>.from(box.read('permissions') ?? []);

    return permissions.contains(permission);
  }
}
