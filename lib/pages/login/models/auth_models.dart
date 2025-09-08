/// 🔐 认证相关数据模型
/// 符合API规范的请求响应模型定义

/// 🔑 登录方式枚举
enum LoginMethod {
  /// 手机号登录
  phone,
  /// 邮箱登录
  email,
  /// 微信登录
  wechat,
  /// QQ登录
  qq,
  /// 密码登录
  password,
  /// 短信验证码登录
  smsCode,
  /// 忘记密码
  forgotPassword,
  /// 重置密码
  resetPassword,
}

/// 📱 短信验证码发送请求
class SmsCodeRequest {
  /// 手机号 - 中国大陆格式：1[3-9]xxxxxxxxx
  final String mobile;
  
  /// 客户端类型：web、app、mini
  final String clientType;

  const SmsCodeRequest({
    required this.mobile,
    this.clientType = 'app', // 默认为APP端
  });

  /// 验证手机号格式
  bool get isValidMobile {
    // 中国大陆手机号验证正则：1[3-9]xxxxxxxxx
    final RegExp regex = RegExp(r'^1[3-9]\d{9}$');
    return regex.hasMatch(mobile);
  }

  factory SmsCodeRequest.fromJson(Map<String, dynamic> json) {
    return SmsCodeRequest(
      mobile: json['mobile'] as String,
      clientType: json['clientType'] as String? ?? 'app',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mobile': mobile,
      'clientType': clientType,
    };
  }

  @override
  String toString() => 'SmsCodeRequest(mobile: $mobile, clientType: $clientType)';
}

/// 📨 短信验证码发送响应数据
class SmsCodeResponse {
  /// 手机号（脱敏显示）
  final String mobile;
  
  /// 响应消息
  final String message;
  
  /// 发送时间
  final DateTime sentAt;
  
  /// 验证码有效期（秒）
  final int expiresIn;
  
  /// 下次发送间隔（秒）
  final int? nextSendIn;

  const SmsCodeResponse({
    required this.mobile,
    required this.message,
    required this.sentAt,
    required this.expiresIn,
    this.nextSendIn,
  });

  factory SmsCodeResponse.fromJson(Map<String, dynamic> json) {
    return SmsCodeResponse(
      mobile: json['mobile'] as String,
      message: json['message'] as String,
      sentAt: DateTime.parse(json['sent_at'] as String),
      expiresIn: json['expires_in'] as int,
      nextSendIn: json['next_send_in'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mobile': mobile,
      'message': message,
      'sent_at': sentAt.toIso8601String(),
      'expires_in': expiresIn,
      'next_send_in': nextSendIn,
    };
  }

  @override
  String toString() => 'SmsCodeResponse(mobile: $mobile, message: $message)';
}

/// 🎯 API统一响应格式
class ApiResponse<T> {
  /// 响应码
  final int code;
  
  /// 响应消息
  final String message;
  
  /// 响应数据
  final T? data;

  const ApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  /// 是否成功
  bool get isSuccess => code == 200;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse<T>(
      code: json['code'] as int,
      message: json['msg'] as String,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) {
    return {
      'code': code,
      'msg': message,
      'data': data != null ? toJsonT(data as T) : null,
    };
  }

  @override
  String toString() => 'ApiResponse(code: $code, message: $message)';
}

/// 📱 短信验证码验证请求
class SmsVerifyRequest {
  /// 手机号
  final String mobile;
  
  /// 验证码
  final String code;
  
  /// 客户端类型
  final String clientType;

  const SmsVerifyRequest({
    required this.mobile,
    required this.code,
    this.clientType = 'app',
  });

  /// 验证码格式验证
  bool get isValidCode {
    // 验证码通常为4-6位数字
    final RegExp regex = RegExp(r'^\d{4,6}$');
    return regex.hasMatch(code);
  }

  factory SmsVerifyRequest.fromJson(Map<String, dynamic> json) {
    return SmsVerifyRequest(
      mobile: json['mobile'] as String,
      code: json['code'] as String,
      clientType: json['clientType'] as String? ?? 'app',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mobile': mobile,
      'code': code,
      'clientType': clientType,
    };
  }

  @override
  String toString() => 'SmsVerifyRequest(mobile: $mobile, code: $code)';
}

/// 🎫 登录成功响应
class LoginResponse {
  /// 访问令牌
  final String accessToken;
  
  /// 刷新令牌
  final String refreshToken;
  
  /// 令牌类型
  final String tokenType;
  
  /// 过期时间（秒）
  final int expiresIn;
  
  /// 用户信息
  final UserInfo userInfo;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.userInfo,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: json['expires_in'] as int,
      userInfo: UserInfo.fromJson(json['user_info'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'user_info': userInfo.toJson(),
    };
  }
}

/// 👤 用户信息
class UserInfo {
  /// 用户ID
  final String userId;
  
  /// 手机号（脱敏）
  final String mobile;
  
  /// 昵称
  final String? nickname;
  
  /// 头像URL
  final String? avatarUrl;

  const UserInfo({
    required this.userId,
    required this.mobile,
    this.nickname,
    this.avatarUrl,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userId: json['user_id'] as String,
      mobile: json['mobile'] as String,
      nickname: json['nickname'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'mobile': mobile,
      'nickname': nickname,
      'avatar_url': avatarUrl,
    };
  }
}

/// 💥 API异常类
class ApiException implements Exception {
  final int code;
  final String message;
  final dynamic data;

  const ApiException({
    required this.code,
    required this.message,
    this.data,
  });

  @override
  String toString() => 'ApiException(code: $code, message: $message)';
}

/// 🎭 业务状态枚举
enum AuthStatus {
  /// 初始状态
  initial,
  /// 加载中
  loading,
  /// 验证码已发送
  codeSent,
  /// 验证中
  verifying,
  /// 登录成功
  success,
  /// 失败
  error,
}

/// 📊 验证码发送状态
class SmsCodeState {
  final AuthStatus status;
  final String? message;
  final SmsCodeResponse? data;
  final int countdown;
  final bool canResend;
  final ApiException? error;

  const SmsCodeState({
    this.status = AuthStatus.initial,
    this.message,
    this.data,
    this.countdown = 0,
    this.canResend = true,
    this.error,
  });

  SmsCodeState copyWith({
    AuthStatus? status,
    String? message,
    SmsCodeResponse? data,
    int? countdown,
    bool? canResend,
    ApiException? error,
  }) {
    return SmsCodeState(
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
      countdown: countdown ?? this.countdown,
      canResend: canResend ?? this.canResend,
      error: error ?? this.error,
    );
  }

  @override
  String toString() => 'SmsCodeState(status: $status, countdown: $countdown)';
}
