import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nursor_app/app/data/action_res.dart';
import 'package:nursor_app/app/modules/home/controllers/home_controller.dart';
import 'package:nursor_app/app/service/animate_service.dart';
import 'package:nursor_app/app/service/auth_service.dart';
import 'package:nursor_app/app/service/connection/BaseConnect.dart';
import 'package:nursor_app/app/service/connection/inner_connect.dart';
import 'package:nursor_app/app/utils/tray_manager.dart';
import 'package:nursorcore/ffi/nursorcoreffi.dart';
import 'package:nursorcore/nursorcore.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';


class AppService extends GetxController with TrayListener, WindowListener{
  late int deviceId;
  late String version;

  late SendPort _sendPortForCore;
  final ReceivePort _receivePortForCore = ReceivePort();
  final isRefreshingNodeList = false.obs;
  final isTaskDoing = false.obs;

  final InnerConnect innerConnect = Get.put(InnerConnect());

  @override
  void onInit()async{
    super.onInit();
    _sendPortForCore = _receivePortForCore.sendPort;
  }

  bool isDesktop(){
   return Platform.isLinux || Platform.isWindows || Platform.isMacOS;
  }

  bool isMobile(){
    return Platform.isAndroid || Platform.isIOS|| Platform.isFuchsia;
  }


  Future<ActionRes> startCoreGate()async{
    final instance = await NursorCoreManager.getInstance();
    final authService = Get.find<AuthService>();
    final userToken = await authService.getUserToken();
    final res = await instance.startGate(userToken);
    if (res.success){
      return ActionRes(status: true, message: res.message, data: res.data);
    }else{
      return ActionRes(status: false, message: res.message, data: res.data);
    }
  }

  Future<ActionRes> stopGateCore()async{
    final instance = await NursorCoreManager.getInstance();
    final res = await instance.stopGate();
    if (res.success){
      return ActionRes(status: true, message: res.message, data: res.data);
    }else{
      return ActionRes(status: false, message: res.message, data: res.data);
    }
  }

  Future<void> setTrayIcon(bool isActive)async{
    if (isActive){
      await trayManager.setIcon(
        Platform.isWindows
            ? 'assets/images/tray/tray_logo.ico'
            : 'assets/images/tray/tray_logo.png',
      );
    }else{
      await trayManager.setIcon(
        Platform.isWindows
            ? 'assets/images/tray/tray_logo_inactive.ico'
            : 'assets/images/tray/tray_logo_inactive.png',
      );
    }
  }

  Future<void> setDeskTopRelate()async{
    // 菜单栏
    await setTrayIcon(false);
    trayManager.addListener(this);
    trayManager.setToolTip("nursor");
    await trayManager.setContextMenu(await getTrayMenu());
    
    // 窗口设置
    await windowManager.ensureInitialized();
    WindowOptions options = const WindowOptions(
        size: Size(800, 600),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal
    );
    windowManager.waitUntilReadyToShow(options, ()async{
      await windowManager.show();
      await windowManager.focus();
    });
    windowManager.setTitle("nursor");
    windowManager.setBrightness(Brightness.light);
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.setPreventClose(true);
    await windowManager.setSkipTaskbar(false);
  }

  @override
  void onWindowClose()async{
    print("onWindowClose appservice");
    windowManager.hide();
  }

  @override
  void dispose(){
    print("appservice dispose");
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
    windowManager.focus();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }


  @override
  void onTrayMenuItemClick(MenuItem menuItem)async {
    if (menuItem.key == 'show_window') {
      await windowManager.show();
      await windowManager.focus();
    } else if (menuItem.key == 'exit_app') {
      if(Platform.isWindows){
        final instance = await NursorCoreManager.getInstance();
        if (instance.isRunning()){
          await stopGateCore();
        }
        await windowManager.destroy();
      }else{
        await windowManager.destroy();
      }
    }else if (menuItem.key == 'start') {
      final animateController = Get.find<AnimateController>();
      final appService = Get.find<AppService>();
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
          
        }
      }else if(animateController.step.value == AnimateType.failed || animateController.step.value == AnimateType.failedAfterRetry) {
        animateController.startingFromFailedAnimation();
        var res = await appService.startCoreGate();
        if (res.status){
          animateController.runningFromFailedAnimation();
          appService.setTrayIcon(true);
        } else {
          animateController.failedAfterRetryAnimation();
          appService.setTrayIcon(false);
        }
      }

    }else if (menuItem.key == 'stop') {
      final animateController = Get.find<AnimateController>();
      final appService = Get.find<AppService>();
      if(animateController.step.value == AnimateType.running || animateController.step.value == AnimateType.runningFromFailed) {
        animateController.stopAnimation();
        appService.setTrayIcon(false);
        appService.stopGateCore();
      }
    }
  }
}