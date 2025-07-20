import 'package:get/get.dart';
import 'package:nursor_app/app/service/version_service.dart';

class NeedUpdateController extends GetxController {
  final versionService = Get.find<VersionService>();

  @override
  void onInit() {
    super.onInit();
  }

  String getLatestVersion() {
    return versionService.getVersion().version;
  }

  String getCurrentVersion() {
    return VersionService.VersionString;
  }
}
