class ApiResponse {
  final int code;
  final String msg;
  final dynamic data;

  ApiResponse({required this.code, required this.msg, required this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      code: json['code'] ?? 0,
      msg: json['msg'] ?? '',
      data: json['data'] ?? {},
    );
  }
}