import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:nursor_app/app/data/response.dart';


class BaseConnection extends GetConnect {

  @override
  void onInit() async {
    httpClient.timeout = const Duration(seconds: 10);
    httpClient.defaultDecoder = (map) {
      if (map is Map<String, dynamic>) {
        // 如果返回的json中包含detail，那么就抛出异常
        if(map.containsKey("detail")){
          throw Exception('${map["detail"]}');
        }
        return ApiResponse.fromJson(map);
      }
      throw Exception('Invalid response format');
    };
    httpClient.baseUrl = 'https://api.nursor.org';
    // httpClient.baseUrl = 'http://127.0.0.1:8000';
  }

  Future<ApiResponse> postData(String url, dynamic body) async {
      final response = await post(url, body).timeout(const Duration(seconds: 10), onTimeout: () {
        print("Timeout error:L $url");
        print("Timeout error");
        return const Response(
          statusCode: 408,
          body: {
            "code": 10509,
            "msg": "Timeout Error",
            "data": {},
          },
        );
      },).onError((e, stackTrace) {
        print("Network error");
        return const Response(
          statusCode: 500,
          body: {
            "code": 10508,
            "msg": "Network Error",
            "data": {
            },
          },
        );
      });

    if (response.status.hasError) {
      if(response.body!=null){
        try{
          return ApiResponse.fromJson(response.body);
        }catch(e){
          print("json decode error: $e");
          return ApiResponse(code: 10508, msg: "Server Error", data: {});
        }
      }else{
        var payload  = {
            "code": 10508,
            "msg": "Network Error",
            "data": {
              "error_status": response.statusCode,
            },
        };
        return ApiResponse.fromJson(payload);
      }
    } else {
      try{
        var responseJson = jsonDecode(response.bodyString!);
        var apiResponse = ApiResponse.fromJson(responseJson);
        return apiResponse;
      }catch(e){
        print("json decode error: $e");
        return ApiResponse(code: 10508, msg: "Server Error", data: {});
      }
    }
  }


  Future<ApiResponse> getData(String url) async {
    final response = await get(url).timeout(const Duration(seconds: 10), onTimeout: () {
        print("Timeout error");
        return const Response(
          statusCode: 408,
          body: {
            "code": 10509,
            "msg": "Timeout Error",
            "data": {},
          },
        );
      },).onError((e, stackTrace) {
        print("Network error");
        print("Request URL: $url");
        return const Response(
          statusCode: 500,
          body: {
            "code": 10508,
            "msg": "Network Error",
            "data": {},
          },
        );
      });

    if (!response.status.isOk) {
      if(response.body!=null){
        try{
          return ApiResponse.fromJson(response.body);
        }catch(e){
          print("json decode error: $e");
          return ApiResponse(code: 10508, msg: "Server Error", data: {});
        }
      }else{
        var payload  = {
            "code": 10508,
            "msg": "Network Error",
            "data": {
              "error_status": response.statusCode,
            },
        };
        return ApiResponse.fromJson(payload);
      }
    } else {
      var responseJson = jsonDecode(response.bodyString!);
      var apiResponse = ApiResponse.fromJson(responseJson);
      return apiResponse;
    }
  }

}
