import 'dart:io';

import 'package:get/get.dart';
import 'package:nursor_app/app/common/constant.dart';
import 'package:nursor_app/app/data/version_dto.dart';
import 'package:nursor_app/app/service/connection/BaseConnect.dart';

class VersionService extends GetxService{
  static final VersionService _instance = VersionService._internal();
  factory VersionService() => _instance;
  VersionService._internal();

  static const String VersionString = "1.0.3";

  VersionDto _version = VersionDto(version: VersionString, comment: "1.0.0", forceUpdate: false, downloadUrl: "");

  final BaseConnection _baseConnection = Get.find<BaseConnection>();

  VersionDto getVersion() {
    return _version;
  }

  Future<VersionDto?> getLatestVersion() async {
    final response = await _baseConnection.postData(
      '/api/v1/version/version/check/',
      {
        "version": VersionString,
        "system": Platform.isMacOS ? "macos" : Platform.isWindows ? "windows" : "linux",
      },
    );
    if (response.code == StatusCode.success) {
      _version = VersionDto.fromJson(response.data);
    }else{
      _version = VersionDto(version: VersionString, comment: "failed to get version", forceUpdate: false, downloadUrl: "");
    }
    return _version;
  }

  
  
}