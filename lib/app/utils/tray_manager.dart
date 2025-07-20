import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:path/path.dart' as path;

Future<String> _getAbsolutePath(String relativePath) async {
    final directory = await getApplicationSupportDirectory();
    return '${directory.path}/$relativePath';
}

String getAssetPhysicalPath(String assetPath) {
  // 获取 exe 所在目录
  String exeDir = Platform.resolvedExecutable.substring(0, Platform.resolvedExecutable.lastIndexOf(Platform.pathSeparator));
  // 拼接 assets 路径
  String assetPhysicalPath = '$exeDir${Platform.pathSeparator}data${Platform.pathSeparator}flutter_assets${Platform.pathSeparator}$assetPath';
  return assetPhysicalPath;
}

Future<String> _getStartIconPath() async {
  String exePath = Platform.resolvedExecutable;
  // 提取目录部分
  String exeDir = exePath.substring(0, exePath.lastIndexOf(Platform.pathSeparator));
  return exeDir;
}

Future<Menu> getTrayMenu() async {
  String exitIconPath = getAssetPhysicalPath(path.join('assets', 'images', 'tray', 'exit.png'));
  Menu menu = Menu(
    items: [
      MenuItem(
        key: 'show_window',
        label: '显示主界面',
        onClick: (item){
          windowManager.show();
        }
      ),
      MenuItem.separator(),
      MenuItem(key: "start", label: "开始",),
      MenuItem(key: "stop", label: "停止", ),
      MenuItem.separator(),
      MenuItem(
        key: 'exit_app',
        label: '退出',
        icon: exitIconPath,
      ),
    ],
  );
  return menu;
}