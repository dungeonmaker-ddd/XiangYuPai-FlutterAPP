/// 🔐 登录模块专用API管理器
/// 基于通用网络模块，专门处理登录相关的所有API调用

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

// 导入通用网络模块
import '../../core/network/index.dart' as network;

// 导入登录模块的数据模型
import 'models/auth_models.dart';
import 'models/country_model.dart';
import 'config/auth_config.dart';

/// 🎯 登录模块API管理器
class LoginApi {
  static LoginApi? _instance;
  late final ApiManager _apiManager;
  SharedPreferences? _prefs;
  
  /// 私有构造函数
  LoginApi._() {
    _apiManager = ApiManager.instance;
    _initialize();
  }
  
  /// 获取单例实例
  static LoginApi get instance {
    return _instance ??= LoginApi._();
  }
  
  /// 重置实例（主要用于测试）
  static void reset() {
    _instance = null;
  }
  
  /// 初始化
  void _initialize() {
    if (AuthConfig.isDevelopment) {
      developer.log('🔐 LoginApi initialized', name: 'LOGIN_API');
    }
  }
  
  // ============== 短信验证码相关API ==============
  
  /// 📱 发送短信验证码
  /// 
  /// 参数：
  /// - [mobile] 手机号
  /// - [clientType] 客户端类型（默认'app'）
  /// - [countryCode] 国家区号（可选，用于国际化）
  /// 
  /// 返回：发送结果，包含脱敏手机号、过期时间等信息
  Future<ApiResponse<SmsCodeResponse>> sendSmsCode({
    required String mobile,
    String clientType = 'app',
    String? countryCode,
  }) async {
    try {
      // 输入验证
      if (mobile.trim().isEmpty) {
        throw const ApiException(
          code: 400,
          message: '手机号不能为空',
          type: ApiExceptionType.business,
        );
      }
      
      // 构建请求数据
      final requestData = {
        'mobile': mobile.trim(),
        'clientType': clientType,
        if (countryCode != null) 'countryCode': countryCode,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      // 调用通用API管理器
      final response = await _apiManager.post<SmsCodeResponse>(
        AuthConfig.sendSmsPath,
        data: requestData,
        fromJson: (json) => SmsCodeResponse.fromJson(json as Map<String, dynamic>),
        timeout: AuthConfig.networkTimeout,
      );
      
      // 记录成功日志
      if (response.isSuccess) {
        developer.log(
          '📱 验证码发送成功: ${response.data?.mobile}',
          name: 'LOGIN_API',
        );
      }
      
      return response;
      
    } catch (e) {
      developer.log('❌ 发送验证码失败: $e', name: 'LOGIN_API');
      throw _handleError(e, '发送验证码失败');
    }
  }
  
  /// 🔐 验证短信验证码并登录
  /// 
  /// 参数：
  /// - [mobile] 手机号
  /// - [code] 验证码
  /// - [clientType] 客户端类型（默认'app'）
  /// 
  /// 返回：登录结果，包含访问令牌、用户信息等
  Future<ApiResponse<LoginResponse>> verifySmsCode({
    required String mobile,
    required String code,
    String clientType = 'app',
  }) async {
    try {
      // 输入验证
      if (mobile.trim().isEmpty) {
        throw const ApiException(
          code: 400,
          message: '手机号不能为空',
          type: ApiExceptionType.business,
        );
      }
      
      if (code.trim().isEmpty) {
        throw const ApiException(
          code: 400,
          message: '验证码不能为空',
          type: ApiExceptionType.business,
        );
      }
      
      if (!RegExp(r'^\d{4,6}$').hasMatch(code.trim())) {
        throw const ApiException(
          code: 400,
          message: '验证码格式不正确',
          type: ApiExceptionType.business,
        );
      }
      
      // 构建请求数据
      final requestData = {
        'mobile': mobile.trim(),
        'code': code.trim(),
        'clientType': clientType,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      // 调用通用API管理器
      final response = await _apiManager.post<LoginResponse>(
        AuthConfig.verifySmsPath,
        data: requestData,
        fromJson: (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
        timeout: AuthConfig.networkTimeout,
      );
      
      // 登录成功后保存认证信息
      if (response.isSuccess && response.data != null) {
        await _saveAuthInfo(response.data!);
        developer.log(
          '🔐 验证码登录成功: ${response.data!.userInfo.nickname ?? response.data!.userInfo.mobile}',
          name: 'LOGIN_API',
        );
      }
      
      return response;
      
    } catch (e) {
      developer.log('❌ 验证码登录失败: $e', name: 'LOGIN_API');
      throw _handleError(e, '验证码登录失败');
    }
  }
  
  // ============== 密码登录相关API ==============
  
  /// 🔒 密码登录
  /// 
  /// 参数：
  /// - [mobile] 手机号
  /// - [password] 密码
  /// - [clientType] 客户端类型（默认'app'）
  /// 
  /// 返回：登录结果，包含访问令牌、用户信息等
  Future<ApiResponse<LoginResponse>> loginWithPassword({
    required String mobile,
    required String password,
    String clientType = 'app',
  }) async {
    try {
      // 输入验证
      if (mobile.trim().isEmpty) {
        throw const ApiException(
          code: 400,
          message: '手机号不能为空',
          type: ApiExceptionType.business,
        );
      }
      
      if (password.trim().isEmpty) {
        throw const ApiException(
          code: 400,
          message: '密码不能为空',
          type: ApiExceptionType.business,
        );
      }
      
      if (password.length < 6) {
        throw const ApiException(
          code: 400,
          message: '密码长度至少6位',
          type: ApiExceptionType.business,
        );
      }
      
      // 构建请求数据
      final requestData = {
        'mobile': mobile.trim(),
        'password': password.trim(),
        'clientType': clientType,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      // 调用通用API管理器（密码登录通常使用不同的端点）
      final response = await _apiManager.post<LoginResponse>(
        '/auth/password/login', // 密码登录端点
        data: requestData,
        fromJson: (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
        timeout: AuthConfig.networkTimeout,
      );
      
      // 登录成功后保存认证信息
      if (response.isSuccess && response.data != null) {
        await _saveAuthInfo(response.data!);
        developer.log(
          '🔒 密码登录成功: ${response.data!.userInfo.nickname ?? response.data!.userInfo.mobile}',
          name: 'LOGIN_API',
        );
      }
      
      return response;
      
    } catch (e) {
      developer.log('❌ 密码登录失败: $e', name: 'LOGIN_API');
      throw _handleError(e, '密码登录失败');
    }
  }
  
  // ============== 密码重置相关API ==============
  
  /// 🔄 重置密码
  /// 
  /// 参数：
  /// - [mobile] 手机号
  /// - [newPassword] 新密码
  /// - [verificationCode] 验证码
  /// - [clientType] 客户端类型（默认'app'）
  /// 
  /// 返回：重置结果
  Future<ApiResponse<Map<String, dynamic>>> resetPassword({
    required String mobile,
    required String newPassword,
    required String verificationCode,
    String clientType = 'app',
  }) async {
    try {
      // 输入验证
      if (mobile.trim().isEmpty) {
        throw const ApiException(
          code: 400,
          message: '手机号不能为空',
          type: ApiExceptionType.business,
        );
      }
      
      if (newPassword.trim().isEmpty) {
        throw const ApiException(
          code: 400,
          message: '新密码不能为空',
          type: ApiExceptionType.business,
        );
      }
      
      if (newPassword.length < 6 || newPassword.length > 20) {
        throw const ApiException(
          code: 400,
          message: '密码长度必须在6-20位之间',
          type: ApiExceptionType.business,
        );
      }
      
      if (RegExp(r'^[0-9]+$').hasMatch(newPassword)) {
        throw const ApiException(
          code: 400,
          message: '密码不能是纯数字',
          type: ApiExceptionType.business,
        );
      }
      
      if (verificationCode.trim().isEmpty) {
        throw const ApiException(
          code: 400,
          message: '验证码不能为空',
          type: ApiExceptionType.business,
        );
      }
      
      // 构建请求数据
      final requestData = {
        'mobile': mobile.trim(),
        'newPassword': newPassword.trim(),
        'verificationCode': verificationCode.trim(),
        'clientType': clientType,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      // 调用通用API管理器
      final response = await _apiManager.post<Map<String, dynamic>>(
        '/auth/password/reset',
        data: requestData,
        fromJson: (json) => json as Map<String, dynamic>,
        timeout: AuthConfig.networkTimeout,
      );
      
      if (response.isSuccess) {
        developer.log('🔄 密码重置成功: $mobile', name: 'LOGIN_API');
      }
      
      return response;
      
    } catch (e) {
      developer.log('❌ 密码重置失败: $e', name: 'LOGIN_API');
      throw _handleError(e, '密码重置失败');
    }
  }
  
  // ============== 用户信息相关API ==============
  
  /// 👤 获取当前用户信息
  /// 
  /// 返回：用户详细信息
  Future<ApiResponse<UserInfo>> getCurrentUserInfo() async {
    try {
      final response = await _apiManager.get<UserInfo>(
        '/auth/user/profile',
        fromJson: (json) => UserInfo.fromJson(json as Map<String, dynamic>),
        timeout: AuthConfig.networkTimeout,
      );
      
      if (response.isSuccess) {
        developer.log('👤 获取用户信息成功', name: 'LOGIN_API');
      }
      
      return response;
      
    } catch (e) {
      developer.log('❌ 获取用户信息失败: $e', name: 'LOGIN_API');
      throw _handleError(e, '获取用户信息失败');
    }
  }
  
  /// ✏️ 更新用户信息
  /// 
  /// 参数：
  /// - [nickname] 昵称（可选）
  /// - [avatarUrl] 头像URL（可选）
  /// 
  /// 返回：更新后的用户信息
  Future<ApiResponse<UserInfo>> updateUserInfo({
    String? nickname,
    String? avatarUrl,
  }) async {
    try {
      final requestData = <String, dynamic>{};
      if (nickname != null && nickname.trim().isNotEmpty) {
        requestData['nickname'] = nickname.trim();
      }
      if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
        requestData['avatarUrl'] = avatarUrl.trim();
      }
      
      if (requestData.isEmpty) {
        throw const ApiException(
          code: 400,
          message: '没有需要更新的信息',
          type: ApiExceptionType.business,
        );
      }
      
      requestData['timestamp'] = DateTime.now().millisecondsSinceEpoch;
      
      final response = await _apiManager.put<UserInfo>(
        '/auth/user/profile',
        data: requestData,
        fromJson: (json) => UserInfo.fromJson(json as Map<String, dynamic>),
        timeout: AuthConfig.networkTimeout,
      );
      
      if (response.isSuccess) {
        developer.log('✏️ 用户信息更新成功', name: 'LOGIN_API');
      }
      
      return response;
      
    } catch (e) {
      developer.log('❌ 用户信息更新失败: $e', name: 'LOGIN_API');
      throw _handleError(e, '用户信息更新失败');
    }
  }
  
  // ============== 令牌管理相关API ==============
  
  /// 🔄 刷新访问令牌
  /// 
  /// 返回：新的登录信息
  Future<ApiResponse<LoginResponse>> refreshAccessToken() async {
    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw const ApiException(
          code: 401,
          message: '刷新令牌不存在，请重新登录',
          type: ApiExceptionType.auth,
        );
      }
      
      final response = await _apiManager.post<LoginResponse>(
        AuthConfig.refreshTokenPath,
        headers: {
          'Authorization': 'Bearer $refreshToken',
        },
        fromJson: (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
        timeout: AuthConfig.networkTimeout,
      );
      
      // 更新认证信息
      if (response.isSuccess && response.data != null) {
        await _saveAuthInfo(response.data!);
        developer.log('🔄 令牌刷新成功', name: 'LOGIN_API');
      }
      
      return response;
      
    } catch (e) {
      // 刷新失败，清除本地认证信息
      await _clearAuthInfo();
      developer.log('❌ 令牌刷新失败: $e', name: 'LOGIN_API');
      throw _handleError(e, '令牌刷新失败，请重新登录');
    }
  }
  
  /// 🚪 登出
  /// 
  /// 返回：登出结果
  Future<ApiResponse<Map<String, dynamic>>> logout() async {
    try {
      final response = await _apiManager.post<Map<String, dynamic>>(
        '/auth/logout',
        fromJson: (json) => json as Map<String, dynamic>,
        timeout: AuthConfig.networkTimeout,
      );
      
      // 无论登出是否成功，都清除本地认证信息
      await _clearAuthInfo();
      developer.log('🚪 用户登出', name: 'LOGIN_API');
      
      return response;
      
    } catch (e) {
      // 即使登出失败，也清除本地信息
      await _clearAuthInfo();
      developer.log('❌ 登出请求失败，但已清除本地信息: $e', name: 'LOGIN_API');
      throw _handleError(e, '登出失败');
    }
  }
  
  // ============== 文件上传相关API ==============
  
  /// 📤 上传用户头像
  /// 
  /// 参数：
  /// - [filePath] 文件路径
  /// - [onProgress] 上传进度回调
  /// 
  /// 返回：上传结果，包含头像URL
  Future<ApiResponse<Map<String, dynamic>>> uploadAvatar({
    required String filePath,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final response = await _apiManager.uploadFile(
        filePath: filePath,
        fieldName: 'avatar',
        category: 'user_avatar',
        onProgress: onProgress,
      );
      
      if (response.isSuccess) {
        developer.log('📤 头像上传成功: ${response.data?.fileUrl}', name: 'LOGIN_API');
        
        // 返回格式化的响应
        return ApiResponse<Map<String, dynamic>>(
          code: response.code,
          message: response.message,
          data: {
            'avatarUrl': response.data?.fileUrl,
            'fileId': response.data?.fileId,
            'fileName': response.data?.fileName,
          },
        );
      }
      
      throw ApiException(
        code: response.code,
        message: response.message,
        type: ApiExceptionType.upload,
      );
      
    } catch (e) {
      developer.log('❌ 头像上传失败: $e', name: 'LOGIN_API');
      throw _handleError(e, '头像上传失败');
    }
  }
  
  // ============== 本地存储管理 ==============
  
  /// 保存认证信息到本地存储
  Future<void> _saveAuthInfo(LoginResponse loginData) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      
      await _prefs!.setString('login_access_token', loginData.accessToken);
      await _prefs!.setString('login_refresh_token', loginData.refreshToken);
      await _prefs!.setString('login_token_type', loginData.tokenType);
      await _prefs!.setInt('login_expires_in', loginData.expiresIn);
      await _prefs!.setInt('login_save_time', DateTime.now().millisecondsSinceEpoch);
      
      // 保存用户信息
      await _prefs!.setString('login_user_info', jsonEncode(loginData.userInfo.toJson()));
      
      developer.log('💾 认证信息已保存到本地', name: 'LOGIN_API');
    } catch (e) {
      developer.log('❌ 保存认证信息失败: $e', name: 'LOGIN_API');
    }
  }
  
  /// 获取访问令牌
  Future<String?> getAccessToken() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      return _prefs!.getString('login_access_token');
    } catch (e) {
      developer.log('❌ 获取访问令牌失败: $e', name: 'LOGIN_API');
      return null;
    }
  }
  
  /// 获取刷新令牌
  Future<String?> _getRefreshToken() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      return _prefs!.getString('login_refresh_token');
    } catch (e) {
      developer.log('❌ 获取刷新令牌失败: $e', name: 'LOGIN_API');
      return null;
    }
  }
  
  /// 获取本地保存的用户信息
  Future<UserInfo?> getLocalUserInfo() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final userInfoJson = _prefs!.getString('login_user_info');
      
      if (userInfoJson != null && userInfoJson.isNotEmpty) {
        final Map<String, dynamic> json = jsonDecode(userInfoJson);
        return UserInfo.fromJson(json);
      }
      
      return null;
    } catch (e) {
      developer.log('❌ 获取本地用户信息失败: $e', name: 'LOGIN_API');
      return null;
    }
  }
  
  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    try {
      final token = await getAccessToken();
      if (token == null || token.isEmpty) return false;
      
      // 检查令牌是否过期
      _prefs ??= await SharedPreferences.getInstance();
      final saveTime = _prefs!.getInt('login_save_time') ?? 0;
      final expiresIn = _prefs!.getInt('login_expires_in') ?? 0;
      
      if (saveTime > 0 && expiresIn > 0) {
        final expiryTime = saveTime + (expiresIn * 1000); // 转换为毫秒
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        
        if (currentTime >= expiryTime) {
          developer.log('🕐 访问令牌已过期', name: 'LOGIN_API');
          return false;
        }
      }
      
      return true;
    } catch (e) {
      developer.log('❌ 检查登录状态失败: $e', name: 'LOGIN_API');
      return false;
    }
  }
  
  /// 清除认证信息
  Future<void> _clearAuthInfo() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      
      await _prefs!.remove('login_access_token');
      await _prefs!.remove('login_refresh_token');
      await _prefs!.remove('login_token_type');
      await _prefs!.remove('login_expires_in');
      await _prefs!.remove('login_save_time');
      await _prefs!.remove('login_user_info');
      
      developer.log('🧹 认证信息已清除', name: 'LOGIN_API');
    } catch (e) {
      developer.log('❌ 清除认证信息失败: $e', name: 'LOGIN_API');
    }
  }
  
  /// 清除所有登录相关数据（公开方法）
  Future<void> clearAllLoginData() async {
    await _clearAuthInfo();
  }
  
  // ============== 工具方法 ==============
  
  /// 统一错误处理
  ApiException _handleError(dynamic error, String defaultMessage) {
    if (error is ApiException) {
      return error;
    }
    
    developer.log('❌ LoginApi错误: $error', name: 'LOGIN_API');
    
    return ApiException(
      code: -1,
      message: defaultMessage,
      details: error.toString(),
      type: ApiExceptionType.unknown,
    );
  }
  
  /// 获取完整的用户信息（本地+远程）
  Future<UserInfo?> getCompleteUserInfo({bool forceRefresh = false}) async {
    try {
      if (forceRefresh || !(await isLoggedIn())) {
        // 从远程获取最新信息
        final response = await getCurrentUserInfo();
        if (response.isSuccess && response.data != null) {
          // 更新本地用户信息
          final loginData = LoginResponse(
            accessToken: await getAccessToken() ?? '',
            refreshToken: await _getRefreshToken() ?? '',
            tokenType: 'Bearer',
            expiresIn: 7200, // 默认值
            userInfo: response.data!,
          );
          await _saveAuthInfo(loginData);
          return response.data;
        }
      }
      
      // 从本地获取
      return await getLocalUserInfo();
      
    } catch (e) {
      developer.log('❌ 获取完整用户信息失败: $e', name: 'LOGIN_API');
      return await getLocalUserInfo(); // 降级到本地信息
    }
  }
  
  /// 验证手机号格式（支持多国家）
  static bool validateMobile(String mobile, {String countryCode = '+86'}) {
    if (mobile.trim().isEmpty) return false;
    
    // 根据国家代码验证
    switch (countryCode) {
      case '+86':
        return RegExp(r'^1[3-9]\d{9}$').hasMatch(mobile);
      case '+852': // 香港
        return RegExp(r'^[5-9]\d{7}$').hasMatch(mobile);
      case '+853': // 澳门
        return RegExp(r'^6\d{7}$').hasMatch(mobile);
      case '+886': // 台湾
        return RegExp(r'^09\d{8}$').hasMatch(mobile);
      case '+1': // 美国/加拿大
        return RegExp(r'^\d{10}$').hasMatch(mobile);
      default:
        // 默认验证：8-15位数字
        return RegExp(r'^\d{8,15}$').hasMatch(mobile);
    }
  }
  
  /// 验证密码格式
  static bool validatePassword(String password) {
    if (password.trim().isEmpty) return false;
    if (password.length < 6 || password.length > 20) return false;
    if (RegExp(r'^[0-9]+$').hasMatch(password)) return false; // 不能是纯数字
    return true;
  }
  
  /// 验证验证码格式
  static bool validateVerificationCode(String code) {
    return RegExp(r'^\d{4,6}$').hasMatch(code.trim());
  }
}

/// 🏭 登录API工厂类
class LoginApiFactory {
  static LoginApi? _mockInstance;
  
  /// 获取登录API实例
  static LoginApi getInstance({bool useMock = false}) {
    if (useMock) {
      return _mockInstance ??= _MockLoginApi();
    }
    return LoginApi.instance;
  }
  
  /// 重置实例（主要用于测试）
  static void reset() {
    LoginApi.reset();
    _mockInstance = null;
  }
}

/// 🧪 Mock登录API（用于开发测试）
class _MockLoginApi extends LoginApi {
  _MockLoginApi() : super._();
  
  @override
  Future<ApiResponse<SmsCodeResponse>> sendSmsCode({
    required String mobile,
    String clientType = 'app',
    String? countryCode,
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));
    
    return ApiResponse<SmsCodeResponse>(
      code: 200,
      message: '验证码发送成功',
      data: SmsCodeResponse(
        mobile: '${mobile.substring(0, 3)}****${mobile.substring(7)}',
        message: '验证码已发送至您的手机',
        sentAt: DateTime.now(),
        expiresIn: 300, // 5分钟
        nextSendIn: 60,  // 60秒后可重新发送
      ),
    );
  }
  
  @override
  Future<ApiResponse<LoginResponse>> verifySmsCode({
    required String mobile,
    required String code,
    String clientType = 'app',
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));
    
    // 简单验证码校验（测试用）
    if (code == '123456' || code == '000000') {
      final loginResponse = LoginResponse(
        accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        tokenType: 'Bearer',
        expiresIn: 7200, // 2小时
        userInfo: UserInfo(
          userId: 'user_${mobile.hashCode}',
          mobile: '${mobile.substring(0, 3)}****${mobile.substring(7)}',
          nickname: '用户${mobile.substring(7)}',
          avatarUrl: null,
        ),
      );
      
      // 保存认证信息
      await _saveAuthInfo(loginResponse);
      
      return ApiResponse<LoginResponse>(
        code: 200,
        message: '登录成功',
        data: loginResponse,
      );
    } else {
      throw const ApiException(
        code: 400,
        message: '验证码错误',
        type: ApiExceptionType.business,
      );
    }
  }
  
  @override
  Future<ApiResponse<LoginResponse>> loginWithPassword({
    required String mobile,
    required String password,
    String clientType = 'app',
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 2));
    
    // 简单密码校验（测试用）
    if (password == '123456' || password == 'password') {
      final loginResponse = LoginResponse(
        accessToken: 'mock_password_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        tokenType: 'Bearer',
        expiresIn: 7200,
        userInfo: UserInfo(
          userId: 'user_${mobile.hashCode}',
          mobile: '${mobile.substring(0, 3)}****${mobile.substring(7)}',
          nickname: '用户${mobile.substring(7)}',
          avatarUrl: null,
        ),
      );
      
      // 保存认证信息
      await _saveAuthInfo(loginResponse);
      
      return ApiResponse<LoginResponse>(
        code: 200,
        message: '登录成功',
        data: loginResponse,
      );
    } else {
      throw const ApiException(
        code: 400,
        message: '密码错误',
        type: ApiExceptionType.business,
      );
    }
  }
}
