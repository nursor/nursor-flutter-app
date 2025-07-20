import 'package:get/get.dart';
import 'package:nursor_app/app/common/constant.dart';
import 'package:nursor_app/app/data/response.dart';
import 'package:nursor_app/app/service/connection/BaseConnect.dart';

class AuthConnect extends BaseConnection {
  final BaseConnection _baseConnection = Get.find<BaseConnection>();

  Future<ApiResponse> refreshUserPlanInfo(String accessToken) async {
    final response = await _baseConnection.get('/api/user/auth/info/plan/info', headers: {'Authorization': 'Bearer $accessToken'});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return ApiResponse(code: 10509, msg: "Timeout Error", data: {});
    }
  }

  Future<ApiResponse> uploadCursorInfo(String accessToken, String cursorToken) async {
    // 伪装成client_id
    final response = await _baseConnection.post('/api/user/auth/info/binding', {'client_id': cursorToken}, headers: {'Authorization': 'Bearer $accessToken'});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return ApiResponse(code: 10509, msg: "Timeout Error", data: {});
    }
  }
}