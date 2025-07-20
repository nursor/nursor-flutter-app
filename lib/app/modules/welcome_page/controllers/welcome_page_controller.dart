import 'package:get/get.dart';
import 'package:nursor_app/app/init.dart';
import 'package:nursor_app/app/routes/app_pages.dart';
import 'package:nursor_app/app/service/app_service.dart';
import 'package:nursor_app/app/service/auth_service.dart';
import 'package:nursor_app/app/service/sqlite_manager.dart';
import 'package:nursor_app/app/service/version_service.dart';

class WelcomePageController extends GetxController {

  final isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    isLoading.value = true;
    Future.delayed(Duration.zero, ()async{
      var nextPage = await getFirstPage();
      if (nextPage == Routes.HOME){
        await Get.find<AuthService>().setUserToCursor();
        final AuthService authService = Get.find<AuthService>();
        await authService.refreshUserPlanInfo();
        await authService.startAsyncUploadCursorInfo();
        await authService.monitorCursorToken();
        Get.offAndToNamed(Routes.HOME);
        return;
      }
      isLoading.value = false;
      Get.offAllNamed(nextPage);
    });
  }

  @override
  void dispose() {
    isLoading.value = false;
    super.dispose();
  }
}
