class ActionRes {
  final bool status;
  final String message;
  final dynamic data;

  ActionRes({required this.status, required this.message, required this.data});

  factory ActionRes.fromJson(Map<String, dynamic> json) {
    return ActionRes(
      status: json['status'],
      message: json['message'],
      data: json['data'],
    );
  }
}