import 'package:flutter/services.dart';

class NursorService {
  static const MethodChannel _channel = MethodChannel('org.nursor.nursor_xpc');

  static Future<bool> startService() async {
    try {
      final result = await _channel.invokeMethod<bool>('startService');
      print('Service started: $result');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to start service: ${e.message}');
      return false;
    }
  }

  static Future<bool> stopService() async {
    try {
      final result = await _channel.invokeMethod<bool>('stopService');
      print('Service stopped: $result');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to stop service: ${e.message}');
      return false;
    }
  }
}