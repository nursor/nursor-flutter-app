import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:nursor_app/app/utils/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';


class SqliteManager extends GetxService{
  Database? _db;
  Database? _cursorDB;
  String? _cursorPath;
  static const platform = MethodChannel('com.nursor.cursor_path');
  final isCursorDBInit = false.obs;
  final _lock = Lock();


  @override
  void onInit() async {
    super.onInit();
    await init();
  }

  String? get cursorPath => _cursorPath;

  Future<void> init() async {
    final home = Platform.environment['HOME'] ?? '';
    final nursorDir = Directory(p.join(home, '.nursor'));
    if (!await nursorDir.exists()) {
      await nursorDir.create(recursive: true);
    }
    final dbPath = p.join(nursorDir.path, 'data.db');
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS kv_store (
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');
      },
    );

    _cursorPath = await getData('cursor_path');  

    // 初始化 cursorDB
    if (_cursorPath == null) {
      _cursorPath = await getCursorPath();
      await setData('cursor_path', _cursorPath);
    }
    if (await File(_cursorPath!).exists()) {
      await initCursorDB(_cursorPath!);
      isCursorDBInit.value = true;
    }else{
      error('state.vscdb file does not exist at $_cursorPath');
      isCursorDBInit.value = false;
    }
  }

  Future<String?> getCursorPath() async {
    if (Platform.isWindows){
      final Directory? appSupportDir = await getApplicationSupportDirectory();
        if (appSupportDir != null) {
          info('应用支持目录路径: ${appSupportDir.path}');
        } else {
          error('无法获取应用支持目录');
        }
      final defaultAppDir = Directory(p.join(appSupportDir!.parent.parent.path, 'cursor', "User", "globalStorage"));
      _cursorPath = p.join(defaultAppDir.path, 'state.vscdb');
    }else if (Platform.isMacOS){
      try {
        // 调用原生方法获取全局 Application Support 目录
        final String appSupportDir = await platform.invokeMethod('getApplicationSupportDirectory');
        // 拼接 Cursor 路径
        String cursorDbPath = p.join(
          appSupportDir,
          'Cursor',
          'User',
          'globalStorage',
          'state.vscdb',
        );
        // 检查文件是否存在
        File dbFile = File(cursorDbPath);
        if (await dbFile.exists()) {
          _cursorPath = cursorDbPath;
          return _cursorPath;
        } else {
          error('state.vscdb file does not exist at $cursorDbPath');
          throw Exception('state.vscdb file does not exist at $cursorDbPath');
        }
      } catch (e) {
        error('Error: Unable to find state.vscdb - $e');
        throw Exception('Error: Unable to find state.vscdb - $e');
      }
    }else if (Platform.isLinux){
      final Directory? appSupportDir = await getApplicationSupportDirectory();
      final defaultAppDir = Directory(p.join(appSupportDir!.path, 'Cursor', "User", "globalStorage"));
      _cursorPath = p.join(defaultAppDir.path, 'state.vscdb');
    }
    return _cursorPath;
  }

  Future<void> setData(String key, dynamic value) async {
    if (_db == null) throw Exception('Database not initialized');
    final jsonValue = value is String ? value : jsonEncode(value);
    await _db!.insert(
      'kv_store',
      {'key': key, 'value': jsonValue},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getData(String key) async {
    var loop = 0;
    while (loop < 20) {
      if (_db != null) {
        break;
      }
      await Future.delayed(const Duration(milliseconds: 500));
      loop++;
    }
    if (_db == null) throw Exception('Database not initialized');
    final result = await _db!.query(
      'kv_store',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (result.isEmpty) return null;
    final valueStr = result.first['value'] as String;
    return valueStr;
  }


  Future<void> initCursorDB(String cursorDBPath) async {
    _cursorDB = await openDatabase(
      cursorDBPath,
      version: 1,
    );
  }

Future<String?> getCursorData(String key) async {
  if (_cursorDB == null) throw Exception('Database not initialized');
  return _lock.synchronized(() async {
    final result = await _cursorDB!.query(
      'ItemTable',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return result.first['value'] as String;
  });
}

} 