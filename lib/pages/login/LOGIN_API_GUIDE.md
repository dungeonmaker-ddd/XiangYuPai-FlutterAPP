# 🔐 登录模块API管理器使用指南

## 📋 目录

- [概述](#概述)
- [快速开始](#快速开始)
- [API文档](#api文档)
- [使用示例](#使用示例)
- [迁移指南](#迁移指南)
- [最佳实践](#最佳实践)
- [错误处理](#错误处理)

## 🎯 概述

`LoginApi` 是登录模块专用的API管理器，基于通用网络模块构建，专门处理登录相关的所有API调用。它提供了：

### ✨ 主要特性

- 🎯 **专门化设计**: 专为登录模块定制的API接口
- 🔧 **统一管理**: 所有登录相关API的统一入口
- 🛡️ **强大的验证**: 内置输入验证和错误处理
- 💾 **自动存储**: 自动管理认证信息的本地存储
- 🔄 **令牌管理**: 自动处理访问令牌和刷新令牌
- 🧪 **Mock支持**: 内置Mock API用于开发测试
- 📱 **多国家支持**: 支持多国家手机号验证

### 🏗️ 架构优势

```
┌─────────────────────────────────────┐
│         EnhancedLoginPage           │  ← UI层
├─────────────────────────────────────┤
│         LoginApi                    │  ← 专用API管理器
├─────────────────────────────────────┤
│         ApiManager (通用)            │  ← 通用网络层
├─────────────────────────────────────┤
│    BaseHttpService + 拦截器         │  ← 底层HTTP服务
└─────────────────────────────────────┘
```

## 🚀 快速开始

### 1. 导入模块

```dart
import 'package:your_app/pages/login/login_api.dart';
import 'package:your_app/core/network/index.dart'; // 可选，用于错误处理
```

### 2. 获取API实例

```dart
// 获取真实API实例
final loginApi = LoginApi.instance;

// 或者使用工厂模式（推荐）
final loginApi = LoginApiFactory.getInstance();

// 开发测试时使用Mock API
final loginApi = LoginApiFactory.getInstance(useMock: true);
```

### 3. 基本使用

```dart
class LoginService {
  final LoginApi _api = LoginApi.instance;
  
  /// 发送验证码
  Future<bool> sendCode(String mobile) async {
    try {
      final response = await _api.sendSmsCode(mobile: mobile);
      return response.isSuccess;
    } on ApiException catch (e) {
      print('发送失败: ${e.message}');
      return false;
    }
  }
  
  /// 验证码登录
  Future<UserInfo?> loginWithCode(String mobile, String code) async {
    try {
      final response = await _api.verifySmsCode(
        mobile: mobile, 
        code: code,
      );
      
      if (response.isSuccess && response.data != null) {
        return response.data!.userInfo;
      }
      return null;
    } on ApiException catch (e) {
      print('登录失败: ${e.message}');
      return null;
    }
  }
}
```

## 📚 API文档

### 🔐 认证相关

#### sendSmsCode
发送短信验证码

```dart
Future<ApiResponse<SmsCodeResponse>> sendSmsCode({
  required String mobile,          // 手机号
  String clientType = 'app',       // 客户端类型
  String? countryCode,             // 国家区号（可选）
})
```

**示例**：
```dart
final response = await loginApi.sendSmsCode(
  mobile: '13800138000',
  countryCode: '+86',
);

if (response.isSuccess) {
  print('验证码已发送: ${response.data?.message}');
}
```

#### verifySmsCode
验证码登录

```dart
Future<ApiResponse<LoginResponse>> verifySmsCode({
  required String mobile,          // 手机号
  required String code,            // 验证码
  String clientType = 'app',       // 客户端类型
})
```

**示例**：
```dart
final response = await loginApi.verifySmsCode(
  mobile: '13800138000',
  code: '123456',
);

if (response.isSuccess) {
  final userInfo = response.data?.userInfo;
  print('登录成功: ${userInfo?.nickname}');
}
```

#### loginWithPassword
密码登录

```dart
Future<ApiResponse<LoginResponse>> loginWithPassword({
  required String mobile,          // 手机号
  required String password,        // 密码
  String clientType = 'app',       // 客户端类型
})
```

#### resetPassword
重置密码

```dart
Future<ApiResponse<Map<String, dynamic>>> resetPassword({
  required String mobile,          // 手机号
  required String newPassword,     // 新密码
  required String verificationCode, // 验证码
  String clientType = 'app',       // 客户端类型
})
```

### 👤 用户信息相关

#### getCurrentUserInfo
获取当前用户信息

```dart
Future<ApiResponse<UserInfo>> getCurrentUserInfo()
```

#### updateUserInfo
更新用户信息

```dart
Future<ApiResponse<UserInfo>> updateUserInfo({
  String? nickname,                // 昵称
  String? avatarUrl,              // 头像URL
})
```

### 🔄 令牌管理

#### refreshAccessToken
刷新访问令牌

```dart
Future<ApiResponse<LoginResponse>> refreshAccessToken()
```

#### logout
登出

```dart
Future<ApiResponse<Map<String, dynamic>>> logout()
```

### 📤 文件上传

#### uploadAvatar
上传用户头像

```dart
Future<ApiResponse<Map<String, dynamic>>> uploadAvatar({
  required String filePath,        // 文件路径
  void Function(int sent, int total)? onProgress, // 进度回调
})
```

### 🔧 工具方法

#### 本地存储管理

```dart
Future<String?> getAccessToken()           // 获取访问令牌
Future<UserInfo?> getLocalUserInfo()      // 获取本地用户信息
Future<bool> isLoggedIn()                 // 检查登录状态
Future<void> clearAllLoginData()          // 清除所有登录数据
```

#### 验证工具

```dart
static bool validateMobile(String mobile, {String countryCode = '+86'})
static bool validatePassword(String password)
static bool validateVerificationCode(String code)
```

## 💡 使用示例

### 完整的登录流程

```dart
class LoginController {
  final LoginApi _api = LoginApi.instance;
  
  /// 完整的验证码登录流程
  Future<LoginResult> loginWithSmsCode(String mobile) async {
    try {
      // 1. 验证手机号
      if (!LoginApi.validateMobile(mobile)) {
        return LoginResult.error('手机号格式不正确');
      }
      
      // 2. 发送验证码
      final sendResponse = await _api.sendSmsCode(mobile: mobile);
      if (!sendResponse.isSuccess) {
        return LoginResult.error(sendResponse.message);
      }
      
      // 3. 等待用户输入验证码（这里需要UI交互）
      final code = await _waitForUserInput();
      
      // 4. 验证码登录
      final loginResponse = await _api.verifySmsCode(
        mobile: mobile,
        code: code,
      );
      
      if (loginResponse.isSuccess && loginResponse.data != null) {
        return LoginResult.success(loginResponse.data!.userInfo);
      } else {
        return LoginResult.error(loginResponse.message);
      }
      
    } on ApiException catch (e) {
      return LoginResult.error(e.message);
    } catch (e) {
      return LoginResult.error('登录失败: $e');
    }
  }
  
  /// 检查登录状态
  Future<bool> checkLoginStatus() async {
    try {
      final isLoggedIn = await _api.isLoggedIn();
      if (isLoggedIn) {
        // 尝试获取用户信息验证令牌有效性
        final userInfo = await _api.getCurrentUserInfo();
        return userInfo.isSuccess;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// 登出
  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (e) {
      // 即使登出失败，本地数据也会被清除
      print('登出失败: $e');
    }
  }
}

class LoginResult {
  final bool success;
  final String? error;
  final UserInfo? userInfo;
  
  LoginResult.success(this.userInfo) : success = true, error = null;
  LoginResult.error(this.error) : success = false, userInfo = null;
}
```

### 头像上传示例

```dart
class AvatarUploadController {
  final LoginApi _api = LoginApi.instance;
  
  Future<String?> uploadAvatar(String imagePath) async {
    try {
      final response = await _api.uploadAvatar(
        filePath: imagePath,
        onProgress: (sent, total) {
          final progress = (sent / total * 100).toInt();
          print('上传进度: $progress%');
          // 更新UI进度
        },
      );
      
      if (response.isSuccess && response.data != null) {
        final avatarUrl = response.data!['avatarUrl'] as String?;
        
        // 自动更新用户信息
        if (avatarUrl != null) {
          await _api.updateUserInfo(avatarUrl: avatarUrl);
        }
        
        return avatarUrl;
      }
      
      return null;
    } on ApiException catch (e) {
      print('头像上传失败: ${e.message}');
      return null;
    }
  }
}
```

## 🔄 迁移指南

### 从原有AuthService迁移

#### 迁移前（原有代码）

```dart
// 复杂的服务调用
final authService = AuthServiceFactory.getInstance();

try {
  final request = SmsCodeRequest(mobile: mobile);
  final response = await authService.sendSmsCode(request);
  
  if (response.isSuccess && response.data != null) {
    // 手动处理响应
    final smsData = response.data!;
    // ... 更多手动处理
  }
} on ApiException catch (e) {
  // 手动错误处理
  print('发送失败: ${e.message}');
}
```

#### 迁移后（新代码）

```dart
// 简洁的API调用
final loginApi = LoginApi.instance;

try {
  final response = await loginApi.sendSmsCode(mobile: mobile);
  
  if (response.isSuccess) {
    print('验证码发送成功: ${response.data?.message}');
    // 认证信息自动管理
  }
} on ApiException catch (e) {
  // 统一的错误处理
  print('发送失败: ${e.message}');
}
```

### 分步迁移策略

1. **保留原有代码**：新旧系统可以并存
2. **新功能优先**：新开发的功能使用LoginApi
3. **逐步替换**：按页面逐步迁移到新API

### 配置迁移

#### 原有配置
```dart
// auth_config.dart
class AuthConfig {
  static const String baseUrl = 'http://10.0.2.2';
  static const bool useMockService = false;
}
```

#### 新配置（无需修改）
```dart
// LoginApi会自动使用AuthConfig的配置
final loginApi = LoginApiFactory.getInstance(
  useMock: AuthConfig.useMockService
);
```

## 🎯 最佳实践

### 1. 错误处理

```dart
// ✅ 推荐：使用具体的异常类型
try {
  final response = await loginApi.verifySmsCode(mobile: mobile, code: code);
} on ApiException catch (e) {
  switch (e.type) {
    case ApiExceptionType.network:
      _showError('网络连接失败，请检查网络');
      break;
    case ApiExceptionType.business:
      _showError(e.message);
      break;
    case ApiExceptionType.auth:
      _redirectToLogin();
      break;
    default:
      _showError('操作失败，请重试');
  }
} catch (e) {
  _showError('未知错误: $e');
}
```

### 2. 状态管理

```dart
// ✅ 推荐：使用状态管理模式
class LoginState {
  final bool isLoading;
  final String? error;
  final UserInfo? userInfo;
  
  // 使用copyWith模式更新状态
  LoginState copyWith({
    bool? isLoading,
    String? error,
    UserInfo? userInfo,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userInfo: userInfo ?? this.userInfo,
    );
  }
}
```

### 3. 输入验证

```dart
// ✅ 推荐：使用内置验证方法
bool validateInput(String mobile, String password) {
  if (!LoginApi.validateMobile(mobile)) {
    _showError('手机号格式不正确');
    return false;
  }
  
  if (!LoginApi.validatePassword(password)) {
    _showError('密码格式不正确');
    return false;
  }
  
  return true;
}
```

### 4. 生命周期管理

```dart
class LoginController extends ChangeNotifier {
  final LoginApi _api = LoginApi.instance;
  Timer? _countdownTimer;
  
  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
  
  // 确保及时清理资源
  void cleanup() {
    _countdownTimer?.cancel();
  }
}
```

## 🚨 错误处理

### 常见错误类型

| 错误类型 | 说明 | 处理建议 |
|---------|------|---------|
| `ApiExceptionType.network` | 网络连接问题 | 提示用户检查网络，提供重试 |
| `ApiExceptionType.business` | 业务逻辑错误 | 显示具体错误信息 |
| `ApiExceptionType.auth` | 认证失败 | 清除本地信息，跳转登录 |
| `ApiExceptionType.timeout` | 请求超时 | 提供重试选项 |
| `ApiExceptionType.parse` | 数据解析错误 | 记录日志，通用错误提示 |

### 错误处理模板

```dart
Future<T?> handleApiCall<T>(Future<ApiResponse<T>> Function() apiCall) async {
  try {
    final response = await apiCall();
    if (response.isSuccess) {
      return response.data;
    } else {
      _showError(response.message);
      return null;
    }
  } on ApiException catch (e) {
    _handleApiException(e);
    return null;
  } catch (e) {
    _showError('操作失败，请重试');
    return null;
  }
}

void _handleApiException(ApiException e) {
  switch (e.type) {
    case ApiExceptionType.network:
      _showError('网络连接失败');
      break;
    case ApiExceptionType.auth:
      _clearAuthAndRedirect();
      break;
    default:
      _showError(e.message);
  }
}
```

## 🔧 配置选项

### Mock模式配置

```dart
// 在auth_config.dart中配置
class AuthConfig {
  static const bool useMockService = true; // 开启Mock模式
}

// 或者运行时配置
final loginApi = LoginApiFactory.getInstance(useMock: true);
```

### 网络配置

```dart
// 在api_config.dart中配置
class ApiConfig {
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const bool enableRequestLogging = true;
}
```

## 🧪 测试支持

### 单元测试

```dart
void main() {
  group('LoginApi Tests', () {
    late LoginApi loginApi;
    
    setUp(() {
      // 使用Mock API进行测试
      loginApi = LoginApiFactory.getInstance(useMock: true);
    });
    
    tearDown(() {
      LoginApiFactory.reset();
    });
    
    test('should send SMS code successfully', () async {
      final response = await loginApi.sendSmsCode(mobile: '13800138000');
      expect(response.isSuccess, true);
      expect(response.data?.mobile, contains('138****8000'));
    });
    
    test('should validate mobile correctly', () {
      expect(LoginApi.validateMobile('13800138000'), true);
      expect(LoginApi.validateMobile('1234567890'), false);
    });
  });
}
```

### Widget测试

```dart
void main() {
  testWidgets('EnhancedLoginPage should work correctly', (WidgetTester tester) async {
    // 设置Mock模式
    AuthConfig.useMockService = true;
    
    await tester.pumpWidget(
      MaterialApp(home: EnhancedLoginPage()),
    );
    
    // 测试UI交互
    await tester.enterText(find.byType(TextField).first, '13800138000');
    await tester.tap(find.text('获取验证码'));
    await tester.pump();
    
    // 验证状态变化
    expect(find.text('验证码已发送'), findsOneWidget);
  });
}
```

---

🎉 **恭喜！** 您现在已经掌握了LoginApi的完整使用方法。这个专用的API管理器将大大简化您的登录相关代码，提高开发效率和代码质量。

如果您有任何问题或建议，请随时反馈！
