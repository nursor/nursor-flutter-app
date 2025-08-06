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
} 