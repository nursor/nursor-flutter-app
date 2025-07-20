import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nursor_app/app/routes/app_pages.dart';
import 'package:nursor_app/app/service/auth_service.dart';
import 'package:nursor_app/app/service/app_service.dart';
import 'package:nursor_app/app/service/connection/auth_connect.dart';
import 'package:nursor_app/app/service/connection/BaseConnect.dart';
import 'package:nursor_app/app/service/permission_service.dart';
import 'package:nursor_app/app/service/sqlite_manager.dart';
import 'package:nursor_app/app/service/version_service.dart';
import 'package:window_manager/window_manager.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';


Future<void> init() async {
  // 初始化 SQLite FFI
  if (Platform.isWindows || Platform.isLinux) {
    // 初始化 FFI
    sqfliteFfiInit();
    // 设置数据库工厂
    databaseFactory = databaseFactoryFfi;
  }

  Get.put(SqliteManager());   
  Get.put(BaseConnection());
  Get.put(AuthConnect());
  Get.put(AuthService());
  Get.put(AppService());
  Get.put(VersionService());
  Get.put(PermissionService());
 

  AppService appService = Get.find();
  await appService.setDeskTopRelate();
}

Future<String> getFirstPage() async {
  final authService = Get.find<AuthService>();
  final versionService = Get.find<VersionService>();
  final version = await versionService.getLatestVersion();
  if (version != null) {
    if (version.forceUpdate) {
      return Routes.NEED_UPDATE;
    }
  }
  final permissionService = Get.find<PermissionService>();
  if (await permissionService.isFileLocked()){
    exit(0);
  }
  await authService.loadUserInfoFromDB();
  if(Platform.isWindows){
    
    final needsAdmin = await permissionService.needsAdminPrivileges();
    if (needsAdmin) {
      return Routes.PERMISSIONDENY;
    }
  }
  if (await authService.isUserAvaliable()) {
    return Routes.HOME;
  }
  return Routes.LOGIN;
}