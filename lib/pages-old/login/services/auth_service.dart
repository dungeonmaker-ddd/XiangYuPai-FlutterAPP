/// 🔐 认证服务层
/// 统一管理所有认证相关的API调用

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/auth_models.dart';
import '../config/auth_config.dart';

/// 🌐 认证服务接口
abstract class IAuthService {
  /// 发送短信验证码
  Future<ApiResponse<SmsCodeResponse>> sendSmsCode(SmsCodeRequest request);
  
  /// 验证短信验证码并登录
  Future<ApiResponse<LoginResponse>> verifySmsCode(SmsVerifyRequest request);
  
  /// 刷新令牌
  Future<ApiResponse<LoginResponse>> refreshToken(String refreshToken);
}

/// 🔧 认证服务实现
class AuthService implements IAuthService {
  final http.Client _client;
  final String _baseUrl;
  
  /// 构造函数
  AuthService({
    http.Client? client,
    String? baseUrl,
  }) : _client = client ?? http.Client(),
       _baseUrl = baseUrl ?? AuthConfig.baseUrl;

  /// 📱 发送短信验证码
  @override
  Future<ApiResponse<SmsCodeResponse>> sendSmsCode(SmsCodeRequest request) async {
    try {
      // 输入验证
      if (!request.isValidMobile) {
        throw const ApiException(
          code: 400,
          message: '手机号格式不正确',
        );
      }

      final url = Uri.parse('$_baseUrl${AuthConfig.sendSmsPath}');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final body = jsonEncode(request.toJson());
      
      // 开发环境下记录请求日志
      if (AuthConfig.enableApiLogging) {
        developer.log('🚀 API Request: POST $url');
        developer.log('📝 Headers: $headers');
        developer.log('📦 Body: $body');
      }

      final response = await _client.post(
        url,
        headers: headers,
        body: body,
      ).timeout(
        AuthConfig.networkTimeout,
        onTimeout: () => throw const ApiException(
          code: -1,
          message: '网络请求超时，请检查网络连接',
        ),
      );

      return _handleResponse<SmsCodeResponse>(
        response,
        (json) => SmsCodeResponse.fromJson(json as Map<String, dynamic>),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        code: -1,
        message: '发送验证码失败: ${e.toString()}',
      );
    }
  }

  /// 🔐 验证短信验证码并登录
  @override
  Future<ApiResponse<LoginResponse>> verifySmsCode(SmsVerifyRequest request) async {
    try {
      // 输入验证
      if (!request.isValidCode) {
        throw const ApiException(
          code: 400,
          message: '验证码格式不正确',
        );
      }

      final url = Uri.parse('$_baseUrl${AuthConfig.verifySmsPath}');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final body = jsonEncode(request.toJson());
      
      // 开发环境下记录请求日志
      if (AuthConfig.enableApiLogging) {
        developer.log('🔐 API Request: POST $url');
        developer.log('📝 Headers: $headers');
        developer.log('📦 Body: $body');
      }

      final response = await _client.post(
        url,
        headers: headers,
        body: body,
      ).timeout(
        AuthConfig.networkTimeout,
        onTimeout: () => throw const ApiException(
          code: -1,
          message: '网络请求超时，请检查网络连接',
        ),
      );

      return _handleResponse<LoginResponse>(
        response,
        (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        code: -1,
        message: '验证码验证失败: ${e.toString()}',
      );
    }
  }

  /// 🔄 刷新令牌
  @override
  Future<ApiResponse<LoginResponse>> refreshToken(String refreshToken) async {
    try {
      if (refreshToken.isEmpty) {
        throw const ApiException(
          code: 400,
          message: '刷新令牌不能为空',
        );
      }

      final response = await _client.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw const ApiException(
          code: -1,
          message: '网络请求超时，请检查网络连接',
        ),
      );

      return _handleResponse<LoginResponse>(
        response,
        (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        code: -1,
        message: '刷新令牌失败: ${e.toString()}',
      );
    }
  }

  /// 🔧 统一响应处理
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Object?) fromJson,
  ) {
    try {
      // 开发环境下记录响应日志
      if (AuthConfig.enableApiLogging) {
        developer.log('📡 API Response: ${response.statusCode}');
        developer.log('📄 Response Body: ${response.body}');
      }
      
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      
      // 构建API响应对象
      final apiResponse = ApiResponse<T>.fromJson(jsonData, fromJson);
      
      // 检查HTTP状态码
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (apiResponse.isSuccess) {
          return apiResponse;
        } else {
          throw ApiException(
            code: apiResponse.code,
            message: apiResponse.message,
            data: apiResponse.data,
          );
        }
      } else {
        throw ApiException(
          code: response.statusCode,
          message: _getHttpErrorMessage(response.statusCode),
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      if (AuthConfig.enableApiLogging) {
        developer.log('❌ Response Parse Error: ${e.toString()}');
      }
      throw ApiException(
        code: response.statusCode,
        message: '响应解析失败: ${e.toString()}',
      );
    }
  }

  /// 🚨 HTTP错误消息映射
  String _getHttpErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '身份验证失败';
      case 403:
        return '访问被拒绝';
      case 404:
        return '接口不存在';
      case 429:
        return '请求过于频繁，请稍后再试';
      case 500:
        return '服务器内部错误';
      case 502:
        return '网关错误';
      case 503:
        return '服务暂时不可用';
      case 504:
        return '网关超时';
      default:
        return '网络请求失败 (状态码: $statusCode)';
    }
  }

  /// 🧹 释放资源
  void dispose() {
    _client.close();
  }
}

/// 🏭 认证服务工厂
class AuthServiceFactory {
  static IAuthService? _instance;
  
  /// 获取认证服务实例（单例模式）
  static IAuthService getInstance({
    http.Client? client,
    String? baseUrl,
  }) {
    return _instance ??= AuthService(
      client: client,
      baseUrl: baseUrl,
    );
  }
  
  /// 重置实例（主要用于测试）
  static void reset() {
    _instance = null;
  }
}

/// 🧪 模拟认证服务（用于开发测试）
class MockAuthService implements IAuthService {
  @override
  Future<ApiResponse<SmsCodeResponse>> sendSmsCode(SmsCodeRequest request) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));
    
    // 模拟发送成功
    return ApiResponse<SmsCodeResponse>(
      code: 200,
      message: '发送成功',
      data: SmsCodeResponse(
        mobile: '${request.mobile.substring(0, 3)}****${request.mobile.substring(7)}',
        message: '验证码已发送',
        sentAt: DateTime.now(),
        expiresIn: 300, // 5分钟
        nextSendIn: 60,  // 60秒后可重新发送
      ),
    );
  }

  @override
  Future<ApiResponse<LoginResponse>> verifySmsCode(SmsVerifyRequest request) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));
    
    // 简单验证码校验（测试用）
    if (request.code == '123456' || request.code == '000000') {
      return ApiResponse<LoginResponse>(
        code: 200,
        message: '登录成功',
        data: LoginResponse(
          accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
          refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
          tokenType: 'Bearer',
          expiresIn: 7200, // 2小时
          userInfo: UserInfo(
            userId: 'user_${request.mobile.hashCode}',
            mobile: '${request.mobile.substring(0, 3)}****${request.mobile.substring(7)}',
            nickname: '用户${request.mobile.substring(7)}',
            avatarUrl: null,
          ),
        ),
      );
    } else {
      throw const ApiException(
        code: 400,
        message: '验证码错误',
      );
    }
  }

  @override
  Future<ApiResponse<LoginResponse>> refreshToken(String refreshToken) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));
    
    return ApiResponse<LoginResponse>(
      code: 200,
      message: '刷新成功',
      data: LoginResponse(
        accessToken: 'new_mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'new_mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        tokenType: 'Bearer',
        expiresIn: 7200,
        userInfo: const UserInfo(
          userId: 'mock_user_id',
          mobile: '138****8000',
          nickname: '测试用户',
          avatarUrl: null,
        ),
      ),
    );
  }
}
