// 🔐 用户认证系统数据模型
// 基于Flutter单文件架构规范的8段式结构设计

// ============== 1. IMPORTS ==============
import 'package:flutter/foundation.dart';

// ============== 2. CONSTANTS ==============
/// 🎨 认证系统常量
class AuthConstants {
  // 私有构造函数，防止实例化
  const AuthConstants._();
  
  // 认证状态
  static const String statusUnauthorized = 'unauthorized';
  static const String statusAuthenticated = 'authenticated';
  static const String statusVerifying = 'verifying';
  static const String statusBlocked = 'blocked';
  
  // 登录方式
  static const String loginTypePhone = 'phone';
  static const String loginTypeEmail = 'email';
  static const String loginTypeWechat = 'wechat';
  static const String loginTypeQQ = 'qq';
  static const String loginTypeAlipay = 'alipay';
  
  // 验证类型
  static const String verificationTypeSMS = 'sms';
  static const String verificationTypeEmail = 'email';
  static const String verificationTypeID = 'id_card';
  
  // 会员等级
  static const String memberLevelFree = 'free';
  static const String memberLevelVip = 'vip';
  static const String memberLevelSvip = 'svip';
  
  // Token配置
  static const int tokenExpirationDays = 30;
  static const String tokenPrefix = 'Bearer ';
  
  // 验证码配置
  static const int verificationCodeLength = 6;
  static const int verificationCodeExpirationMinutes = 5;
  static const int verificationCodeResendCooldown = 60;
}

// ============== 3. MODELS ==============

/// 🔑 认证凭据模型
@immutable
class AuthCredentials {
  final String identifier; // 手机号/邮箱
  final String password;
  final String loginType;
  final String? verificationCode;
  final String? deviceId;
  final Map<String, dynamic>? thirdPartyData;

  const AuthCredentials({
    required this.identifier,
    required this.password,
    required this.loginType,
    this.verificationCode,
    this.deviceId,
    this.thirdPartyData,
  });

  factory AuthCredentials.fromJson(Map<String, dynamic> json) {
    return AuthCredentials(
      identifier: json['identifier'] ?? '',
      password: json['password'] ?? '',
      loginType: json['loginType'] ?? AuthConstants.loginTypePhone,
      verificationCode: json['verificationCode'],
      deviceId: json['deviceId'],
      thirdPartyData: json['thirdPartyData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'password': password,
      'loginType': loginType,
      if (verificationCode != null) 'verificationCode': verificationCode,
      if (deviceId != null) 'deviceId': deviceId,
      if (thirdPartyData != null) 'thirdPartyData': thirdPartyData,
    };
  }

  AuthCredentials copyWith({
    String? identifier,
    String? password,
    String? loginType,
    String? verificationCode,
    String? deviceId,
    Map<String, dynamic>? thirdPartyData,
  }) {
    return AuthCredentials(
      identifier: identifier ?? this.identifier,
      password: password ?? this.password,
      loginType: loginType ?? this.loginType,
      verificationCode: verificationCode ?? this.verificationCode,
      deviceId: deviceId ?? this.deviceId,
      thirdPartyData: thirdPartyData ?? this.thirdPartyData,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthCredentials &&
        other.identifier == identifier &&
        other.password == password &&
        other.loginType == loginType &&
        other.verificationCode == verificationCode &&
        other.deviceId == deviceId &&
        mapEquals(other.thirdPartyData, thirdPartyData);
  }

  @override
  int get hashCode {
    return Object.hash(
      identifier,
      password,
      loginType,
      verificationCode,
      deviceId,
      thirdPartyData,
    );
  }
}

/// 🎫 认证令牌模型
@immutable
class AuthToken {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final String tokenType;
  final List<String> scopes;

  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    this.tokenType = 'Bearer',
    this.scopes = const [],
  });

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        json['expires_at'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      tokenType: json['token_type'] ?? 'Bearer',
      scopes: List<String>.from(json['scopes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.millisecondsSinceEpoch,
      'token_type': tokenType,
      'scopes': scopes,
    };
  }

  /// 检查Token是否有效
  bool get isValid {
    return accessToken.isNotEmpty && 
           refreshToken.isNotEmpty && 
           expiresAt.isAfter(DateTime.now());
  }

  /// 检查Token是否即将过期（30分钟内）
  bool get isNearExpiration {
    final thirtyMinutesFromNow = DateTime.now().add(const Duration(minutes: 30));
    return expiresAt.isBefore(thirtyMinutesFromNow);
  }

  /// 获取Authorization Header值
  String get authorizationHeader {
    return '$tokenType $accessToken';
  }

  AuthToken copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? tokenType,
    List<String>? scopes,
  }) {
    return AuthToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      tokenType: tokenType ?? this.tokenType,
      scopes: scopes ?? this.scopes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthToken &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.expiresAt == expiresAt &&
        other.tokenType == tokenType &&
        listEquals(other.scopes, scopes);
  }

  @override
  int get hashCode {
    return Object.hash(
      accessToken,
      refreshToken,
      expiresAt,
      tokenType,
      scopes,
    );
  }
}

/// 🔐 认证状态模型
@immutable
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final bool isVerifying;
  final String? userId;
  final AuthToken? token;
  final String? errorMessage;
  final DateTime? lastLoginAt;
  final String loginType;
  final Map<String, dynamic> metadata;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.isVerifying = false,
    this.userId,
    this.token,
    this.errorMessage,
    this.lastLoginAt,
    this.loginType = AuthConstants.loginTypePhone,
    this.metadata = const {},
  });

  factory AuthState.initial() {
    return const AuthState();
  }

  factory AuthState.loading() {
    return const AuthState(isLoading: true);
  }

  factory AuthState.authenticated({
    required String userId,
    required AuthToken token,
    required String loginType,
    Map<String, dynamic>? metadata,
  }) {
    return AuthState(
      isAuthenticated: true,
      isLoading: false,
      userId: userId,
      token: token,
      lastLoginAt: DateTime.now(),
      loginType: loginType,
      metadata: metadata ?? {},
    );
  }

  factory AuthState.error(String errorMessage) {
    return AuthState(
      isLoading: false,
      errorMessage: errorMessage,
    );
  }

  factory AuthState.verifying() {
    return const AuthState(
      isLoading: true,
      isVerifying: true,
    );
  }

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    bool? isVerifying,
    String? userId,
    AuthToken? token,
    String? errorMessage,
    DateTime? lastLoginAt,
    String? loginType,
    Map<String, dynamic>? metadata,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      isVerifying: isVerifying ?? this.isVerifying,
      userId: userId ?? this.userId,
      token: token ?? this.token,
      errorMessage: errorMessage,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      loginType: loginType ?? this.loginType,
      metadata: metadata ?? this.metadata,
    );
  }

  /// 清除错误状态
  AuthState clearError() {
    return copyWith(errorMessage: null);
  }

  /// 登出状态
  AuthState logout() {
    return const AuthState();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.isAuthenticated == isAuthenticated &&
        other.isLoading == isLoading &&
        other.isVerifying == isVerifying &&
        other.userId == userId &&
        other.token == token &&
        other.errorMessage == errorMessage &&
        other.lastLoginAt == lastLoginAt &&
        other.loginType == loginType &&
        mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode {
    return Object.hash(
      isAuthenticated,
      isLoading,
      isVerifying,
      userId,
      token,
      errorMessage,
      lastLoginAt,
      loginType,
      metadata,
    );
  }
}

/// 📱 验证码请求模型
@immutable
class VerificationRequest {
  final String identifier;
  final String type;
  final String purpose;
  final String? deviceId;

  const VerificationRequest({
    required this.identifier,
    required this.type,
    required this.purpose,
    this.deviceId,
  });

  factory VerificationRequest.fromJson(Map<String, dynamic> json) {
    return VerificationRequest(
      identifier: json['identifier'] ?? '',
      type: json['type'] ?? AuthConstants.verificationTypeSMS,
      purpose: json['purpose'] ?? 'login',
      deviceId: json['deviceId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'type': type,
      'purpose': purpose,
      if (deviceId != null) 'deviceId': deviceId,
    };
  }

  VerificationRequest copyWith({
    String? identifier,
    String? type,
    String? purpose,
    String? deviceId,
  }) {
    return VerificationRequest(
      identifier: identifier ?? this.identifier,
      type: type ?? this.type,
      purpose: purpose ?? this.purpose,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VerificationRequest &&
        other.identifier == identifier &&
        other.type == type &&
        other.purpose == purpose &&
        other.deviceId == deviceId;
  }

  @override
  int get hashCode {
    return Object.hash(identifier, type, purpose, deviceId);
  }
}

// ============== 4. SERVICES ==============
// 服务接口在 services/auth_services.dart 中定义

// ============== 5. CONTROLLERS ==============
// 控制器在各自的页面文件中定义

// ============== 6. WIDGETS ==============
// UI组件在 widgets/auth_widgets.dart 中定义

// ============== 7. PAGES ==============
// 页面组件在 pages/ 目录中定义

// ============== 8. EXPORTS ==============
// 本文件导出的公共类和接口将被 index.dart 统一导出
