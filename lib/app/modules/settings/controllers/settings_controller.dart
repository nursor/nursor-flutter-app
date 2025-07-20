import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:nursor_app/app/service/auth_service.dart';
import 'package:nursor_app/app/service/sqlite_manager.dart';


class SettingsController extends GetxController {
  
  final AuthService authService = Get.find<AuthService>();
  final SqliteManager sqliteManager = Get.find<SqliteManager>();
  final hasError = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    cursorPathController.text = sqliteManager.cursorPath ?? '';
  }

  final cursorPathController = TextEditingController();


  void handleCursorPathChange(String value) async {
    if (value.isEmpty) {
      hasError.value = true;
      errorMessage.value = '请输入Cursor安装路径';
      return;
    }
    if (!await File(value).exists()) {
      hasError.value = true;
      errorMessage.value = 'Cursor安装路径不存在';
      return;
    }
    await sqliteManager.setData('cursor_path', value);
    cursorPathController.text = value;
    Get.back();
  }

  Future<void> installCertificate() async {
    final result = await Process.run(
      '/bin/bash',
      ['/Library/Application Support/Nursor/trust_ca_once.sh'],
    );

    print('stdout: ${result.stdout}');
    print('stderr: ${result.stderr}');

    if (result.stderr.isEmpty) {
      hasError.value = false;
      errorMessage.value = '证书安装成功';
    } else {
      hasError.value = true;
      errorMessage.value = '证书安装失败';
    }
  }
}
