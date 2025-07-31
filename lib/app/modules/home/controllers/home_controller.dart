import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nursor_app/app/service/animate_service.dart';
import 'package:nursor_app/app/routes/app_pages.dart';
import 'package:nursor_app/app/service/app_service.dart';
import 'package:nursor_app/app/service/auth_service.dart';
import 'package:nursor_app/app/service/sqlite_manager.dart';
import 'package:nursor_app/app/service/version_service.dart';

class HomeController extends GetxController {
  final AnimateController animateController = Get.put(AnimateController());
  final AppService appService = Get.find<AppService>();
  final AuthService authService = Get.find<AuthService>();
  final VersionService versionService = Get.find<VersionService>();
  final SqliteManager sqliteManager = Get.find<SqliteManager>();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    // 最多重复3次
    Future.delayed(Duration.zero, ()async{
      await authService.startAsyncUploadCursorInfo();
    });
    
  }

  Future<void> onButtonClick() async {
    if(appService.isTaskDoing.value){
      return;
    }
    if (!authService.isCustomIdUpload.value) {
      if (authService.isCustomIdUpload.value){
        Get.snackbar(
        "Error",
        "Cursor登录信息验证失败",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
        maxWidth: 300,
        margin: EdgeInsets.only(top: 20),
      );
      return;
      }
    }
    appService.isTaskDoing.value = true;
    if(animateController.step.value == AnimateType.unbegin) {
      animateController.startAnimation();
      var res = await appService.startCoreGate();
      if (res.status){
        Timer(Duration(milliseconds: animateController.getAnimateTimeToFinish()), () {
          animateController.successAnimation();
          appService.setTrayIcon(true);
        });
      } else {
        Timer(Duration(milliseconds: animateController.getAnimateTimeToFinish()), () {
          animateController.failAnimation();
          appService.setTrayIcon(false);
        }); 
        Get.snackbar("failure", res.message);
      }
    } else if(animateController.step.value == AnimateType.starting) {
      if (animateController.actionTime.value >= 0.9) {
        animateController.successAnimation();
        appService.setTrayIcon(true);
      } else {
        print("动画尚未结束");
      }
    } else if(animateController.step.value == AnimateType.running || animateController.step.value == AnimateType.runningFromFailed) {
      animateController.stopAnimation();
      appService.setTrayIcon(false);
      appService.stopGateCore();
    } else if(animateController.step.value == AnimateType.failed || animateController.step.value == AnimateType.failedAfterRetry) {
      animateController.startingFromFailedAnimation();
      var res = await appService.startCoreGate();
      if (res.status){
        animateController.runningFromFailedAnimation();
        appService.setTrayIcon(true);
      } else {
        animateController.failedAfterRetryAnimation();
        appService.setTrayIcon(false);
        Get.snackbar(
          "Error",
          res.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
          maxWidth: 300,
          margin: EdgeInsets.only(top: 20),
        );
      }
    }
    appService.isTaskDoing.value = false;
  }

  void onLogoutClick() async {
    await authService.logout();
    Get.offAllNamed(Routes.LOGIN);
  }



}
