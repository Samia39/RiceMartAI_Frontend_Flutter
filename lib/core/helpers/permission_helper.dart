import 'package:get_storage/get_storage.dart';

class PermissionHelper {
  static final box = GetStorage();

  static List permissions() {
    return List<String>.from(box.read('permissions') ?? []);
  }

  static bool can(String permission) {
    return permissions().contains(permission);
  }
}
