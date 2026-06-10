// Stub file for web platform — permission_handler is not supported on web.
// This file is used via conditional import:
//   import 'package:permission_handler/permission_handler.dart'
//       if (dart.library.html) 'package:frontend/core/utils/permission_stub.dart';

class Permission {
  static final camera = _PermissionStub();
}

class _PermissionStub {
  Future<PermissionStatus> get status async => PermissionStatus.granted;
  Future<PermissionStatus> request() async => PermissionStatus.granted;
}

enum PermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  limited,
}

extension PermissionStatusX on PermissionStatus {
  bool get isGranted => this == PermissionStatus.granted;
  bool get isDenied => this == PermissionStatus.denied;
  bool get isPermanentlyDenied => this == PermissionStatus.permanentlyDenied;
}

Future<void> openAppSettings() async {}
