
import 'nursorcore_platform_interface.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'package:ffi/ffi.dart';

import 'package:nursorcore/ffi/nursorcoreffi.dart';
import 'package:nursorcore/model/action.dart';
import 'package:nursorcore/model/response.dart';
import 'package:http/http.dart' as http;


class Nursorcore {
  Future<String?> getPlatformVersion() {
    return NursorcorePlatform.instance.getPlatformVersion();
  }
}

enum NursorCoreMode {
  runable,
  shared,
}

class NursorCoreManager {
  static NursorCoreManager? _instance;
  static NursorCoreManager get instance => _instance ??= NursorCoreManager();

  NursorCoreMode mode = NursorCoreMode.runable;
  ReceivePort? _coreReceivePort;
  SendPort? _coreSendPort;

  bool _isRunning = false;

  final Map<String, Completer<ActionResult>> _pendingActions = {};

  static Future<NursorCoreManager> getInstance() async {
    NursorCoreMode mode;
    if (Platform.isWindows){
      mode = NursorCoreMode.shared;
    }else if (Platform.isMacOS){
      mode = NursorCoreMode.runable;
    }else{
      mode = NursorCoreMode.shared;
    }
    
    if (_instance == null) {
      _instance = NursorCoreManager();
      _instance!.mode = mode;
      await _instance!.init();
    }
    return _instance!;
  }

  bool isRunning() {
    return _isRunning;
  }

  Future<void> init() async {
    if (mode == NursorCoreMode.shared) {
      if (_coreReceivePort == null) {
        _coreReceivePort = ReceivePort();
        Isolate.spawn(_runGateIsolate, _coreReceivePort!.sendPort);
        _coreReceivePort!.listen(_handleIsolateMessage);
        var timeout = 0;
        while (_coreSendPort == null) {
          await Future.delayed(const Duration(milliseconds: 100));
          timeout++;
          if (timeout > 100) {
            throw Exception('Gate not running');
          }
        }
      }
    } else {
      if (await isCoreRunning()) return;
      // windows不在这处理，在上百年的shared中处理
      // if (Platform.isMacOS) {
      //   var isSuccess = await NursorService.startService();
      //   if (isSuccess){
      //     print("success");
      //   }else{
      //     print("faliure");
      //   }
      // } else if (Platform.isLinux) {
      //   _process = await Process.start('core-linux-amd64', [],
      //       mode: ProcessStartMode.normal);
      // }
    }
  }

  void _handleIsolateMessage(dynamic msg) {
    if (msg is SendPort) {
      _coreSendPort = msg;
    } else if (msg is ActionResult) {
      final completer = _pendingActions.remove(msg.name);
      if (completer != null && !completer.isCompleted) {
        completer.complete(msg);
      }
    } else {
      print("Unknown message from core isolate: $msg");
    }
  }

  Future<bool> isCoreRunning() async {
    if (mode == NursorCoreMode.shared) return true;
    try {
      final response = await http
          .get(Uri.parse('http://127.0.0.1:56431/status'))
          .timeout(const Duration(seconds: 1),
              onTimeout: () => http.Response('Timeout', 408));
      if (response.statusCode == 200) {
        final apiResp = ApiResponse.fromJson(jsonDecode(response.body));
        return apiResp.code == 0;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> waitCoreRunning() async {
    for (int a = 0; a < 3; a++) {
      if (await isCoreRunning()) {
        return true;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    return false;
  }

  Future<ActionResult> startGate(String userToken) async {
    try {
      if (mode == NursorCoreMode.shared) {
        final completer = Completer<ActionResult>();
        _pendingActions['start'] = completer;
        final payload = new Map<String, String>();
        // name': 'start_go_gate', 'args': userToken}
        payload["name"] = "start_go_gate";
        payload["args"] = userToken;
        _coreSendPort?.send(payload);
        return await completer.future.timeout(
            const Duration(seconds: 60),
            onTimeout: () =>
                ActionResult(name: 'start', data: null, success: false, message: 'Timeout'));
      } else {
        if (!await waitCoreRunning()) {
          return ActionResult(
              name: 'start',
              data: null,
              success: false,
              message: 'Failed to start gate');
        }
        final response =
            await http.post(Uri.parse('http://127.0.0.1:56431/run/start'), body: jsonEncode({'user_token': userToken}));
        if (response.statusCode == 200) {
          final apiResp = ApiResponse.fromJson(jsonDecode(response.body));
          _isRunning = apiResp.code == 0;
          return ActionResult(
              name: 'start',
              data: apiResp.data,
              success: apiResp.code == 0,
              message: apiResp.msg);
        }
        return ActionResult(
            name: 'start',
            data: null,
            success: false,
            message: 'Failed to start gate');
      }
    } catch (e) {
      return ActionResult(
          name: 'start',
          data: null,
          success: false,
          message: e.toString());
    }
  }

  Future<ActionResult> stopGate() async {
    if (mode == NursorCoreMode.shared) {
      final completer = Completer<ActionResult>();
      _pendingActions['stop'] = completer;
      // final payload = jsonEncode({'name': 'stop_go_gate', 'args': ""});
      var payload = Map<String, String>();
      payload["name"] = "stop_go_gate";
      payload["args"] = "";
      _coreSendPort?.send(payload);
      return await completer.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () =>
              ActionResult(name: 'stop', data: null, success: false, message: 'Timeout'));
    } else {
        final response =
            await http.get(Uri.parse('http://127.0.0.1:56431/run/stop'));
        if (response.statusCode == 200) {
          final apiResp = ApiResponse.fromJson(jsonDecode(response.body));
          _isRunning = apiResp.code == 0;
          return ActionResult(
              name: 'stop',
              data: apiResp.data,
              success: apiResp.code == 0,
              message: apiResp.msg);
        }

      return ActionResult(
          name: 'stop', data: null, success: false, message: 'Gate stopped');
    }
  }

  Future<ActionResult> closeGate() async {
    if (mode == NursorCoreMode.shared) {
      if (_coreSendPort == null) {
        return ActionResult(
            name: 'close',
            data: null,
            success: true,
            message: 'Gate already closed');
      }
      final completer = Completer<ActionResult>();
      _pendingActions['close'] = completer;
      final payload = jsonEncode({'name': 'close_go_gate', 'args': ""});
      _coreSendPort?.send(payload);
      return await completer.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () =>
              ActionResult(name: 'close', data: null, success: false, message: 'Timeout'));
    } else {
      if (!await waitCoreRunning()) {
        return ActionResult(
            name: 'close',
            data: null,
            success: true,
            message: 'Gate already closed');
      }
      final response =
            await http.get(Uri.parse('http://127.0.0.1:56431/run/stop'));
        if (response.statusCode == 200) {
          final apiResp = ApiResponse.fromJson(jsonDecode(response.body));
          _isRunning = apiResp.code == 0;
          return ActionResult(
              name: 'close',
              data: apiResp.data,
              success: apiResp.code == 0,
              message: apiResp.msg);
        }
    }
    return ActionResult(
        name: 'close', data: null, success: true, message: 'Gate closed');
  }

  Future<ActionResult> setUserInfo(String userToken, String userId, String username, String password) async {
    if (mode == NursorCoreMode.shared) {
      final completer = Completer<ActionResult>();
      _pendingActions['set_user_info'] = completer;
      final payload = jsonEncode({'name': 'set_user_info', 'args': jsonEncode({'user_token': userToken, 'user_id': userId, 'username': username, 'password': password})});
      _coreSendPort?.send(payload);
      return await completer.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () =>
              ActionResult(name: 'set_user_info', data: null, success: false, message: 'Timeout'));
    }else{
      final response =
            await http.post(Uri.parse('http://127.0.0.1:56431/run/userInfo'), body: jsonEncode({'user_token': userToken, 'user_id': userId, 'username': username, 'password': password}));
        if (response.statusCode == 200) {
          final apiResp = ApiResponse.fromJson(jsonDecode(response.body));
          _isRunning = apiResp.code == 0;
          return ActionResult(
              name: 'set_user_info',
              data: apiResp.data,
              success: apiResp.code == 0,
              message: apiResp.msg);
        }else{
          return ActionResult(name: "set_user_info", data: null, success: false, message: "core_error");
        }
    }
    return ActionResult(name: 'set_user_info', data: null, success: false, message: 'Failed to set user info');
  }
}




@pragma('vm:entry-point')
NursorCore loadLibrary() {
  const libName = 'ncore';
  DynamicLibrary dylib;
  if (Platform.isWindows) {
    dylib = DynamicLibrary.open('nursor-core-amd64.dll');
  } else if (Platform.isMacOS) {
    dylib = DynamicLibrary.open('libncore.dylib');
  } else if (Platform.isLinux) {
    dylib = DynamicLibrary.open('lib$libName.so');
  } else {
    throw UnsupportedError('Unsupported platform');
  }
  return NursorCore(dylib);
}

@pragma('vm:entry-point')
void _runGateIsolate(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  final nursorCore = loadLibrary();

  receivePort.listen((msg) {
    // print("Received message from core isolate: $msg");
    if (msg is Map<String, String>) {
      var payload = msg;
      final name = payload["name"];
      String args = payload["args"] ?? "";
      if (name == 'start_go_gate') {
        final result = nursorCore.runGate(args.toNativeUtf8().cast<Char>());
        final resultString = result.cast<Utf8>().toDartString();
        final resultJson = jsonDecode(resultString);
        final resultApiResponse = ActionResult(name: 'start', data: resultJson["data"], success: resultJson["status"]=="success", message: resultJson["message"]);
        sendPort.send(resultApiResponse);
      } else if (name == 'stop_go_gate') {
        nursorCore.stopGate();
        final resultApiResponse = ActionResult(name: 'stop', data: null, success: true, message: "success");
        sendPort.send(resultApiResponse);
      } else if (name == 'close_go_gate') {
        final resultApiResponse = ActionResult(name: 'close', data: null, success: true, message: 'Gate closed');
        sendPort.send(resultApiResponse);
      }else if (name == 'set_user_info') {
        final userInfo = jsonDecode(args);  
        nursorCore.setUserInfo(userInfo["user_token"].toNativeUtf8().cast<Char>(), userInfo["user_id"].toNativeUtf8().cast<Char>(), userInfo["username"].toNativeUtf8().cast<Char>(), userInfo["password"].toNativeUtf8().cast<Char>());
        final resultApiResponse = ActionResult(name: 'set_user_info', data: null, success: true, message: 'User info set');
        sendPort.send(resultApiResponse);
      }
    }
  });
}
