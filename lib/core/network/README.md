# 🌐 通用网络请求模块

这是一个强大、灵活、易用的Flutter网络请求基础设施，基于您现有的`auth_service`和`auth_config`进行了全面升级。

## 📋 目录

- [核心特性](#核心特性)
- [架构设计](#架构设计)
- [快速开始](#快速开始)
- [API文档](#api文档)
- [迁移指南](#迁移指南)
- [最佳实践](#最佳实践)

## 🚀 核心特性

### ✨ 主要优势

- **🎯 统一管理**: 一个`ApiManager`管理所有API调用
- **🔧 高度可配置**: 支持多环境、自定义拦截器、灵活配置
- **🛡️ 强大的错误处理**: 统一异常处理、自动重试、智能错误恢复
- **🔐 自动认证**: 自动Token管理、无感刷新、安全存储
- **📝 完整日志**: 详细的请求/响应日志、性能监控
- **💾 智能缓存**: 可配置的响应缓存、离线支持
- **📤 文件支持**: 内置文件上传/下载功能
- **🧪 易于测试**: 支持Mock服务、依赖注入

### 🔄 相比原有系统的改进

| 方面 | 原有系统 | 新系统 |
|------|---------|--------|
| **复杂度** | 需要手动管理多个Service | 一个ApiManager统一管理 |
| **配置** | 分散在各个文件 | 集中在ApiConfig |
| **错误处理** | 每个Service单独处理 | 统一的异常体系 |
| **认证** | 手动Token管理 | 自动认证、无感刷新 |
| **日志** | 简单的打印 | 结构化日志、性能监控 |
| **缓存** | 无 | 智能缓存系统 |
| **扩展性** | 难以扩展 | 插件化拦截器系统 |

## 🏗️ 架构设计

```
📁 core/network/
├── 📄 api_config.dart          # 全局配置管理
├── 📄 api_models.dart          # 通用数据模型
├── 📄 api_interceptors.dart    # 拦截器系统
├── 📄 base_http_service.dart   # 基础HTTP服务
├── 📄 api_manager.dart         # API管理器（核心）
├── 📄 index.dart              # 统一导出
├── 📄 migration_example.dart   # 迁移示例
└── 📄 README.md               # 文档
```

### 🔧 核心组件说明

#### 1. ApiConfig - 配置中心
```dart
// 环境配置
ApiEnvironment.development  // 开发环境
ApiEnvironment.production   // 生产环境

// 获取配置
ApiConfig.baseUrl          // 基础URL
ApiConfig.defaultHeaders   // 默认请求头
ApiConfig.connectTimeout   // 连接超时
```

#### 2. ApiManager - 核心管理器
```dart
// 单例模式，全局唯一
final api = ApiManager.instance;

// 认证相关
await api.sendSmsCode(mobile: '13800138000');
await api.verifySmsCode(mobile: '13800138000', code: '123456');
await api.getUserProfile();

// 通用请求
await api.get<List<String>>('/endpoint');
await api.post<Map<String, dynamic>>('/endpoint', data: {...});
```

#### 3. 拦截器系统
```dart
// 自动添加的拦截器
LoggingInterceptor()      // 日志记录
AuthInterceptor()         // 自动认证
ErrorInterceptor()        // 错误处理
RetryInterceptor()        // 自动重试
PerformanceInterceptor()  // 性能监控
```

#### 4. 统一异常处理
```dart
try {
  final response = await api.getUserProfile();
} on ApiException catch (e) {
  if (e.isAuthError) {
    // 处理认证错误
  } else if (e.isNetworkError) {
    // 处理网络错误
  }
}
```

## 🚀 快速开始

### 1. 基础设置

在`main.dart`中初始化：

```dart
import 'package:your_app/core/network/index.dart';

void main() {
  // 打印配置信息（仅调试模式）
  ApiConfigExtension.printConfig();
  
  runApp(MyApp());
}
```

### 2. 基本用法

```dart
import 'package:your_app/core/network/index.dart';

class LoginService {
  static final _api = ApiManager.instance;
  
  /// 发送验证码
  static Future<bool> sendCode(String mobile) async {
    try {
      final response = await _api.sendSmsCode(mobile: mobile);
      return response.isSuccess;
    } on ApiException catch (e) {
      print('发送失败: ${e.message}');
      return false;
    }
  }
  
  /// 验证码登录
  static Future<bool> login(String mobile, String code) async {
    try {
      final response = await _api.verifySmsCode(
        mobile: mobile, 
        code: code,
      );
      
      if (response.isSuccess) {
        // 认证信息已自动保存
        return true;
      }
      return false;
    } on ApiException catch (e) {
      print('登录失败: ${e.message}');
      return false;
    }
  }
}
```

### 3. 高级用法

```dart
// 自定义请求
final response = await ApiManager.instance.get<CustomModel>(
  '/custom/endpoint',
  queryParameters: {'page': '1'},
  headers: {'Custom-Header': 'value'},
  fromJson: (json) => CustomModel.fromJson(json),
  enableCache: true,
  timeout: Duration(seconds: 30),
);

// 文件上传
final uploadResult = await ApiManager.instance.uploadFile(
  filePath: '/path/to/file.jpg',
  category: 'avatar',
  onProgress: (sent, total) {
    print('上传进度: ${(sent / total * 100).toInt()}%');
  },
);

// 分页数据
final pageResponse = await ApiManager.instance.getRecommendations(
  page: 1,
  size: 20,
  category: 'food',
);
```

## 📚 API文档

### 🔐 认证相关

#### sendSmsCode
发送短信验证码
```dart
Future<ApiResponse<SmsCodeResponse>> sendSmsCode({
  required String mobile,
  String clientType = 'app',
})
```

#### verifySmsCode
验证码登录
```dart
Future<ApiResponse<LoginResponse>> verifySmsCode({
  required String mobile,
  required String code,
  String clientType = 'app',
})
```

#### refreshToken
刷新访问令牌
```dart
Future<ApiResponse<LoginResponse>> refreshToken()
```

#### getUserProfile
获取用户信息
```dart
Future<ApiResponse<UserProfile>> getUserProfile()
```

### 🏠 首页相关

#### getCategories
获取分类列表
```dart
Future<ApiResponse<List<Category>>> getCategories({
  bool enableCache = true,
})
```

#### getRecommendations
获取推荐内容（分页）
```dart
Future<ApiResponse<PageResponse<Recommendation>>> getRecommendations({
  int page = 1,
  int size = 20,
  String? category,
  bool enableCache = true,
})
```

#### search
搜索功能
```dart
Future<ApiResponse<PageResponse<SearchResult>>> search({
  required String keyword,
  int page = 1,
  int size = 20,
  String? category,
  String? sortBy,
  Map<String, dynamic>? filters,
})
```

### 📤 文件相关

#### uploadFile
文件上传
```dart
Future<ApiResponse<UploadResult>> uploadFile({
  required String filePath,
  String fieldName = 'file',
  String category = 'general',
  Map<String, String>? extra,
  void Function(int sent, int total)? onProgress,
})
```

#### downloadFile
文件下载
```dart
Future<List<int>> downloadFile({
  required String url,
  void Function(int received, int total)? onProgress,
})
```

### 🚀 通用请求

#### get/post/put/delete
通用HTTP方法
```dart
Future<ApiResponse<T>> get<T>(String endpoint, {...})
Future<ApiResponse<T>> post<T>(String endpoint, {...})
Future<ApiResponse<T>> put<T>(String endpoint, {...})
Future<ApiResponse<T>> delete<T>(String endpoint, {...})
```

## 🔄 迁移指南

### 从原有AuthService迁移

#### 迁移前（复杂）
```dart
// 需要手动管理多个组件
final authService = AuthServiceFactory.getInstance();
final request = SmsVerifyRequest(mobile: mobile, code: code);
final response = await authService.verifySmsCode(request);

if (response.isSuccess) {
  // 手动保存认证信息
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('access_token', response.data!.accessToken);
  // ... 更多手动处理
}
```

#### 迁移后（简洁）
```dart
// 一行代码完成，自动处理认证信息
final response = await ApiManager.instance.verifySmsCode(
  mobile: mobile,
  code: code,
);
// 认证信息已自动保存
```

### 配置迁移

#### 原有配置
```dart
// auth_config.dart
class AuthConfig {
  static const String baseUrl = 'http://10.0.2.2';
  static const Duration networkTimeout = Duration(seconds: 10);
  // ...
}
```

#### 新配置
```dart
// api_config.dart - 更强大的配置系统
class ApiConfig {
  static const ApiEnvironment currentEnvironment = ApiEnvironment.development;
  static const Duration connectTimeout = Duration(seconds: 10);
  // 自动平台检测、多环境支持、更多配置选项
}
```

## 🎯 最佳实践

### 1. 错误处理
```dart
// ✅ 推荐：使用具体的异常类型
try {
  final response = await api.getUserProfile();
} on ApiException catch (e) {
  switch (e.type) {
    case ApiExceptionType.network:
      // 网络错误处理
      break;
    case ApiExceptionType.auth:
      // 认证错误处理
      break;
    case ApiExceptionType.business:
      // 业务错误处理
      break;
  }
}

// ❌ 避免：捕获所有异常
try {
  final response = await api.getUserProfile();
} catch (e) {
  // 无法区分错误类型
}
```

### 2. 数据模型
```dart
// ✅ 推荐：使用fromJson工厂方法
final response = await api.get<List<User>>(
  '/users',
  fromJson: (json) {
    final List<dynamic> items = json as List<dynamic>;
    return items.map((item) => User.fromJson(item)).toList();
  },
);

// ✅ 推荐：使用分页模型
final response = await api.get<PageResponse<User>>(
  '/users',
  fromJson: (json) => PageResponse.fromJson(
    json as Map<String, dynamic>,
    (item) => User.fromJson(item as Map<String, dynamic>),
  ),
);
```

### 3. 缓存使用
```dart
// ✅ 推荐：对不经常变化的数据启用缓存
final categories = await api.getCategories(enableCache: true);

// ✅ 推荐：对用户相关的数据不启用缓存
final userProfile = await api.getUserProfile(); // 默认不缓存
```

### 4. 性能优化
```dart
// ✅ 推荐：使用合适的超时时间
final response = await api.get('/quick-endpoint', 
  timeout: Duration(seconds: 5));

final response = await api.get('/slow-endpoint', 
  timeout: Duration(seconds: 30));

// ✅ 推荐：监控上传/下载进度
await api.uploadFile(
  filePath: filePath,
  onProgress: (sent, total) {
    final progress = (sent / total * 100).toInt();
    // 更新UI进度
  },
);
```

### 5. 测试支持
```dart
// 在测试中重置API管理器
tearDown(() {
  ApiManager.reset();
});

// 使用Mock服务
// 可以通过修改ApiConfig.useMockService来启用Mock
```

## 🔧 配置选项

### 环境配置
```dart
// 在api_config.dart中修改
static const ApiEnvironment currentEnvironment = ApiEnvironment.production;
```

### 超时配置
```dart
static const Duration connectTimeout = Duration(seconds: 10);
static const Duration receiveTimeout = Duration(seconds: 15);
static const Duration sendTimeout = Duration(seconds: 10);
```

### 日志配置
```dart
static const bool enableRequestLogging = true;
static const bool enableResponseLogging = true;
static const LogLevel logLevel = LogLevel.debug;
```

### 重试配置
```dart
static const int maxRetryAttempts = 3;
static const Duration retryDelay = Duration(seconds: 1);
static const List<int> retryStatusCodes = [500, 502, 503, 504];
```

## 🤝 贡献指南

1. 遵循现有的代码风格
2. 添加适当的注释和文档
3. 确保所有功能都有相应的错误处理
4. 更新相关的测试用例

## 📝 更新日志

### v1.0.0 (2024-12-19)
- 🎉 初始版本发布
- ✨ 完整的API管理系统
- 🔧 强大的拦截器系统
- 📚 完善的文档和示例

---

🎉 **恭喜！** 您现在拥有了一个现代化、强大、易用的网络请求基础设施。这个系统将大大简化您的API调用代码，提高开发效率和代码质量。
