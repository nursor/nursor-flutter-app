class User {
  final String planName;
  final int fastAskUsed;
  final int fastAskTotal;
  final int premiumAskUsed;
  final int premiumAskTotal;
  final String startTime;
  final String endTime;
  final String? uniqueCode;
  String activeToken;
  final String planType;
  final String innerToken;
  String accessToken;
  String refreshToken;
  String username;
  String password;

  User({
    required this.planName,
    required this.fastAskUsed,
    required this.fastAskTotal,
    required this.premiumAskUsed,
    required this.premiumAskTotal,
    required this.startTime,
    required this.endTime,
    this.uniqueCode,
    required this.activeToken,
    required this.planType,
    required this.innerToken,
    required this.accessToken,
    required this.refreshToken,
    required this.username,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      planName: json['plan_name'] ?? 'free',
      fastAskUsed: json['fast_ask_used'] ?? 0,
      fastAskTotal: json['fast_ask_total'] ?? 0,
      premiumAskUsed: json['premium_ask_used'] ?? 0,
      premiumAskTotal: json['premium_ask_total'] ?? 0,
      startTime: json['start_time'] ?? DateTime.now().toIso8601String(),
      endTime: json['end_time'] ?? DateTime.now().toIso8601String(),
      uniqueCode: json['unique_code'],
      activeToken: json['active_token'] ?? '',
      planType: json['plan_type'] ?? 'free',
      innerToken: json['inner_token'] ?? '',
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan_name': planName,
      'fast_ask_used': fastAskUsed,
      'fast_ask_total': fastAskTotal,
      'premium_ask_used': premiumAskUsed,
      'premium_ask_total': premiumAskTotal,
      'start_time': startTime,
      'end_time': endTime,
      'unique_code': uniqueCode,
      'active_token': activeToken,
      'plan_type': planType,
      'inner_token': innerToken,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'username': username,
      'password': password,
    };
  }
}