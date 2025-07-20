import 'dart:convert';

import 'package:get/get.dart';
import 'package:nursor_app/app/common/constant.dart';
import 'package:nursor_app/app/data/action_res.dart';
import 'package:nursor_app/app/data/response.dart';


class InnerConnect extends GetConnect {
  @override
  void onInit() {
    super.onInit();
    httpClient.baseUrl = 'http://127.0.0.1:56431';
  }

  Future<ActionRes> startGate()async{
    var headers = {
      'Content-Type': 'application/json'
    };

    final res = await get('/run/start', headers: headers);
    if (res.statusCode == 200){
      final resp = ApiResponse.fromJson(res.body);
      if (resp.code == StatusCode.success){
        return ActionRes(status: true, message: resp.msg, data: resp.data);
      }else{
        return ActionRes(status: false, message: resp.msg, data: null);
      }
    }else{
      return ActionRes(status: false, message: "failed", data: null);
    }
  }

  Future<ActionRes> stopGate()async{
    final res = await get('/run/stop');
    if (res.statusCode == 200){
      final resp = ApiResponse.fromJson(json.decode(res.body));
    }
    return ActionRes(status: false, message: "failed", data: null);
  }

  Future<ActionRes> getGateStatus()async{
    final res = await get('/run/status');
    if (res.statusCode == 200){
      final resp = ApiResponse.fromJson(json.decode(res.body));
    }
    return ActionRes(status: false, message: "failed", data: null);
  }
}