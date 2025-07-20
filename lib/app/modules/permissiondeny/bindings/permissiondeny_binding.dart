import 'package:get/get.dart';

import '../controllers/permissiondeny_controller.dart';

class PermissiondenyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PermissiondenyController>(
      () => PermissiondenyController(),
    );
  }
}
