import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:get/get_connect/http/src/status/http_status.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:nursor_app/app/common/constant.dart';
import 'package:nursor_app/app/data/action_res.dart';
import 'package:nursor_app/app/data/response.dart';
import 'package:nursor_app/app/data/user.dart';
import 'package:nursor_app/app/service/connection/BaseConnect.dart';
import 'package:nursor_app/app/service/connection/auth_connect.dart';
import 'package:nursor_app/app/service/sqlite_manager.dart';
import 'package:nursor_app/app/utils/cryptutils.dart';
import 'package:nursorcore/nursorcore.dart';
import 'package:sentry_flutter/sentry_flutter.dart';



class AuthService extends GetxController {

  final userInfo = Rx<User>(
     User(
      planName: 'free',
      trafficTotal: 0,
      trafficUsed: 0,
      aiAskUsed: 0,
      aiAskTotal: 0,
      startTime: DateTime.now().toIso8601String(),
      endTime: DateTime.now().toIso8601String(),
      uniqueCode: null,
      activeToken: '',
      planType: 'free',
      innerToken: '',
      accessToken: '',
      refreshToken: '',
      username: '',
      password: '',
    )
  );

  final BaseConnection _baseConnection = Get.find<BaseConnection>();
  final AuthConnect _authConnect = Get.find<AuthConnect>();
  final SqliteManager _sqliteManager = Get.find<SqliteManager>();

  late AESCipher _aesCipher;
  final isCursorTokenValid = false.obs;
  final isCustomIdUpload = false.obs;
  final cursorStatusMsg = ''.obs;
  final cacheCursorToken = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    // userInfo.value =
    _aesCipher = AESCipher("12345678901234567890123456789012");
  }

  void setActivateToken(String token) {
    userInfo.value.activeToken = token;
  }

  Future<ActionRes> login(String accessToken) async {
    try {
      final response = await _baseConnection.postData(
        '/api/user/auth/new/activate',
        {'access_token': accessToken},
      );
      if (response.code == StatusCode.success) {
        userInfo.value = User.fromJson(response.data['user']);
        userInfo.value.accessToken = response.data['access_token'];
        userInfo.value.refreshToken = response.data['refresh_token'];
        await saveUserInfoToDB();
        return ActionRes(status: true, message: 'Login success', data: userInfo);
        } else {
          return ActionRes(status: false, message: response.msg, data: null);
        }
    } catch (error) {
      print('Error during login: $error');
      return ActionRes(status: false, message: 'Network error', data: null);
    }
  }

  Future<void> logout() async {
    userInfo.value = User(
      planName: 'free',
      trafficTotal: 0,
      trafficUsed: 0,
      aiAskUsed: 0,
      aiAskTotal: 0,
      startTime: DateTime.now().toIso8601String(),
      endTime: DateTime.now().toIso8601String(),
      uniqueCode: null,
      activeToken: '',
      planType: 'free',
      innerToken: '',
      accessToken: '',
      refreshToken: '',
      username: '',
      password: '',
    );

    await _sqliteManager.setData('userinfo', userInfo);
  }

  Future<void> refreshUserPlanInfo() async {
    print('Refreshing user plan info');
    try {
      final response = await _authConnect.refreshUserPlanInfo(userInfo.value.accessToken);

      if (response.code == StatusCode.success) {
        var latestPlanInfo = response.data;
        latestPlanInfo['access_token'] = userInfo.value.accessToken;
        latestPlanInfo['refresh_token'] = userInfo.value.refreshToken;
        userInfo.value = User.fromJson(latestPlanInfo);
      } else {
        print('Error: ${response.msg}');
      }
      await saveUserInfoToDB();
    } catch (error) {
      print('Error refreshing user plan: $error');
    }
  }

  Future<void> loadUserInfoFromDB() async {
    final localUserInfo = await _sqliteManager.getData('userinfo');
    if (localUserInfo != null) {
      userInfo.value = User.fromJson(jsonDecode(localUserInfo));
    }
  }

  Future<void> saveUserInfoToDB() async {
    await _sqliteManager.setData('userinfo', userInfo);
  }

  bool isEndTimeValid(String endTime) {
    try {
      final endDate = DateTime.parse(endTime);
      final currentDate = DateTime.now();
      return endDate.isAfter(currentDate);
    } catch (error) {
      print('Error parsing end_time: $error');
      return false;
    }
  }

  Future<bool> isUserAvaliable() async {
    await loadUserInfoFromDB();
    return userInfo.value.accessToken.isNotEmpty == true &&
        userInfo.value.activeToken != '' &&
        // userInfo.value.planName != 'free' &&
        // userInfo.value.planName != '' &&
        isEndTimeValid(userInfo.value.endTime);
  }

  Future<bool> isPlanExpired() async {
    await loadUserInfoFromDB();
    return !isEndTimeValid(userInfo.value.endTime);
  }

  

  Future<String> getUserInnerToken() async {
    await loadUserInfoFromDB();
    if (userInfo.value.accessToken.isNotEmpty) {
      return userInfo.value.innerToken;
    }
    return '';
  }


  Future<void> setUserToCursor() async {
    final instance = await NursorCoreManager.getInstance();
    var acRes = await instance.setUserInfo(userInfo.value.accessToken, userInfo.value.uniqueCode ?? '', userInfo.value.username, userInfo.value.password);
    if (acRes.message == "core_error"){
      Get.snackbar("Error", "core error",colorText: Colors.red,  );
    }
  }
}