/// 🔧 认证模块配置
/// 管理API环境、超时时间等配置项

enum Environment {
  development,
  staging,
  production,
}

class AuthConfig {
  // 当前环境
  static const Environment currentEnvironment = Environment.development;
  
  // API基础URL配置
  static const Map<Environment, String> _baseUrls = {
    Environment.development: 'http://10.0.2.2', // Android模拟器访问本机localhost
    Environment.staging: 'https://staging-api.xiangyu.com',
    Environment.production: 'https://api.xiangyu.com',
  };
  
  // 本地开发时的备用地址配置
  static const Map<String, String> _localUrls = {
    'android_emulator': 'http://10.0.2.2',    // Android模拟器
    'ios_simulator': 'http://127.0.0.1',      // iOS模拟器
    'localhost': 'http://localhost',           // Web或桌面端
    'custom_ip': 'http://192.168.1.100',      // 自定义IP（请替换为实际IP）
  };
  
  // 网络超时配置
  static const Duration networkTimeout = Duration(seconds: 10);
  static const Duration connectTimeout = Duration(seconds: 5);
  
  // 验证码相关配置
  static const int defaultCodeLength = 6;
  static const int defaultCountdown = 60;
  static const int maxResendAttempts = 3;
  
  // 客户端类型
  static const String clientType = 'app';
  
  /// 获取当前环境的API基础URL
  static String get baseUrl => _baseUrls[currentEnvironment] ?? _baseUrls[Environment.development]!;
  
  /// 根据平台获取本地开发URL
  static String getLocalUrl(String platform) {
    return _localUrls[platform] ?? _localUrls['android_emulator']!;
  }
  
  /// 是否为开发环境
  static bool get isDevelopment => currentEnvironment == Environment.development;
  
  /// 是否为生产环境
  static bool get isProduction => currentEnvironment == Environment.production;
  
  /// API端点路径
  static const String sendSmsPath = '/auth/sms/send';
  static const String verifySmsPath = '/auth/sms/verify';
  static const String refreshTokenPath = '/auth/refresh';
  
  /// 获取完整的API URL
  static String getApiUrl(String path) => '$baseUrl$path';
  
  /// 调试模式下的设置
  static const bool enableApiLogging = true;
  static const bool useMockService = false; // 改为false以使用真实本地API
}
