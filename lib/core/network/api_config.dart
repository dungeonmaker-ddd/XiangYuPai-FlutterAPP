/// 🌐 通用API配置模块
/// 管理全局API环境、超时时间、认证等配置

import 'dart:io';

/// 🏷️ 环境枚举
enum ApiEnvironment {
  development('开发环境'),
  testing('测试环境'),
  staging('预发布环境'),
  production('生产环境');
  
  const ApiEnvironment(this.displayName);
  final String displayName;
}

/// ⚙️ 全局API配置
class ApiConfig {
  // ============== 环境配置 ==============
  
  /// 当前环境
  static const ApiEnvironment currentEnvironment = ApiEnvironment.development;
  
  /// 环境对应的基础URL
  static const Map<ApiEnvironment, String> _baseUrls = {
    ApiEnvironment.development: 'http://10.0.2.2:8080', // 本地开发
    ApiEnvironment.testing: 'https://test-api.xiangyu.com',
    ApiEnvironment.staging: 'https://staging-api.xiangyu.com',
    ApiEnvironment.production: 'https://api.xiangyu.com',
  };
  
  /// 平台特定的本地URL配置
  static const Map<String, String> _localUrls = {
    'android_emulator': 'http://10.0.2.2:8080',    // Android模拟器
    'ios_simulator': 'http://127.0.0.1:8080',      // iOS模拟器
    'web': 'http://localhost:8080',                 // Web端
    'desktop': 'http://localhost:8080',             // 桌面端
    'custom': 'http://192.168.1.100:8080',         // 自定义IP
  };
  
  // ============== 超时配置 ==============
  
  /// 连接超时时间
  static const Duration connectTimeout = Duration(seconds: 10);
  
  /// 接收超时时间
  static const Duration receiveTimeout = Duration(seconds: 15);
  
  /// 发送超时时间
  static const Duration sendTimeout = Duration(seconds: 10);
  
  // ============== 重试配置 ==============
  
  /// 最大重试次数
  static const int maxRetryAttempts = 3;
  
  /// 重试间隔
  static const Duration retryDelay = Duration(seconds: 1);
  
  /// 需要重试的HTTP状态码
  static const List<int> retryStatusCodes = [500, 502, 503, 504];
  
  // ============== 缓存配置 ==============
  
  /// 是否启用缓存
  static const bool enableCache = true;
  
  /// 缓存最大大小 (MB)
  static const int maxCacheSize = 50;
  
  /// 默认缓存时间
  static const Duration defaultCacheTime = Duration(minutes: 5);
  
  // ============== 日志配置 ==============
  
  /// 是否启用请求日志
  static const bool enableRequestLogging = true;
  
  /// 是否启用响应日志
  static const bool enableResponseLogging = true;
  
  /// 是否启用错误日志
  static const bool enableErrorLogging = true;
  
  /// 日志级别
  static const LogLevel logLevel = LogLevel.debug;
  
  // ============== 认证配置 ==============
  
  /// Token存储键名
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userInfoKey = 'user_info';
  
  /// Token过期前刷新时间 (分钟)
  static const int tokenRefreshBeforeExpiry = 10;
  
  // ============== 客户端信息 ==============
  
  /// 客户端类型
  static const String clientType = 'flutter_app';
  
  /// 应用版本
  static const String appVersion = '1.0.0';
  
  /// 设备平台
  static String get platform {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }
  
  // ============== API端点配置 ==============
  
  /// API版本
  static const String apiVersion = 'v1';
  
  /// 通用端点
  static const Map<String, String> commonEndpoints = {
    'health': '/health',
    'version': '/version',
    'upload': '/upload',
  };
  
  /// 认证相关端点
  static const Map<String, String> authEndpoints = {
    'sendSms': '/auth/sms/send',
    'verifySms': '/auth/sms/verify',
    'login': '/auth/login',
    'logout': '/auth/logout',
    'refresh': '/auth/refresh',
    'profile': '/auth/profile',
  };
  
  /// 用户相关端点
  static const Map<String, String> userEndpoints = {
    'profile': '/user/profile',
    'updateProfile': '/user/profile',
    'avatar': '/user/avatar',
    'settings': '/user/settings',
  };
  
  /// 首页相关端点
  static const Map<String, String> homeEndpoints = {
    'categories': '/home/categories',
    'recommendations': '/home/recommendations',
    'nearby': '/home/nearby',
    'search': '/home/search',
  };
  
  // ============== 获取配置方法 ==============
  
  /// 获取当前环境的基础URL
  static String get baseUrl {
    return _baseUrls[currentEnvironment] ?? _baseUrls[ApiEnvironment.development]!;
  }
  
  /// 根据平台获取本地URL
  static String getLocalUrl([String? platformType]) {
    final targetPlatform = platformType ?? _detectPlatform();
    return _localUrls[targetPlatform] ?? _localUrls['android_emulator']!;
  }
  
  /// 获取完整的API URL
  static String getApiUrl(String endpoint) {
    return '$baseUrl/api/$apiVersion$endpoint';
  }
  
  /// 获取认证相关URL
  static String getAuthUrl(String key) {
    final endpoint = authEndpoints[key];
    if (endpoint == null) throw ArgumentError('Unknown auth endpoint: $key');
    return getApiUrl(endpoint);
  }
  
  /// 获取用户相关URL
  static String getUserUrl(String key) {
    final endpoint = userEndpoints[key];
    if (endpoint == null) throw ArgumentError('Unknown user endpoint: $key');
    return getApiUrl(endpoint);
  }
  
  /// 获取首页相关URL
  static String getHomeUrl(String key) {
    final endpoint = homeEndpoints[key];
    if (endpoint == null) throw ArgumentError('Unknown home endpoint: $key');
    return getApiUrl(endpoint);
  }
  
  // ============== 环境判断方法 ==============
  
  /// 是否为开发环境
  static bool get isDevelopment => currentEnvironment == ApiEnvironment.development;
  
  /// 是否为测试环境
  static bool get isTesting => currentEnvironment == ApiEnvironment.testing;
  
  /// 是否为预发布环境
  static bool get isStaging => currentEnvironment == ApiEnvironment.staging;
  
  /// 是否为生产环境
  static bool get isProduction => currentEnvironment == ApiEnvironment.production;
  
  /// 是否为调试模式
  static bool get isDebugMode => isDevelopment || isTesting;
  
  // ============== 默认请求头 ==============
  
  /// 获取默认请求头
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json; charset=utf-8',
    'Accept': 'application/json',
    'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
    'User-Agent': '$clientType/$appVersion ($platform)',
    'X-Client-Type': clientType,
    'X-Client-Version': appVersion,
    'X-Platform': platform,
    'X-Request-ID': _generateRequestId(),
  };
  
  /// 获取认证请求头
  static Map<String, String> getAuthHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
  
  // ============== 私有方法 ==============
  
  /// 自动检测平台
  static String _detectPlatform() {
    if (Platform.isAndroid) {
      // 检测是否为模拟器
      return 'android_emulator'; // 简化处理，实际可以检测真机/模拟器
    } else if (Platform.isIOS) {
      return 'ios_simulator';
    } else {
      return 'web';
    }
  }
  
  /// 生成请求ID
  static String _generateRequestId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${platform.substring(0, 3)}';
  }
}

/// 📊 日志级别
enum LogLevel {
  none('无日志'),
  error('错误'),
  warning('警告'),
  info('信息'),
  debug('调试'),
  verbose('详细');
  
  const LogLevel(this.displayName);
  final String displayName;
}

/// 🔧 API配置扩展
extension ApiConfigExtension on ApiConfig {
  /// 打印当前配置信息
  static void printConfig() {
    if (!ApiConfig.isDebugMode) return;
    
    print('🌐 ============== API配置信息 ==============');
    print('📍 当前环境: ${ApiConfig.currentEnvironment.displayName}');
    print('🔗 基础URL: ${ApiConfig.baseUrl}');
    print('⏱️ 连接超时: ${ApiConfig.connectTimeout.inSeconds}秒');
    print('📱 客户端: ${ApiConfig.clientType} v${ApiConfig.appVersion}');
    print('🖥️ 平台: ${ApiConfig.platform}');
    print('🔍 调试模式: ${ApiConfig.isDebugMode}');
    print('📝 日志级别: ${ApiConfig.logLevel.displayName}');
    print('=======================================');
  }
}
