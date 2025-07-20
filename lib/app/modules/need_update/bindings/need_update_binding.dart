import 'package:get/get.dart';

import '../controllers/need_update_controller.dart';

class NeedUpdateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NeedUpdateController>(
      () => NeedUpdateController(),
    );
  }
}
