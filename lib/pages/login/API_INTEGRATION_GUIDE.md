# 📱 手机登录API集成指南

## 🎯 概述

本指南详细说明了如何将手机登录页面与真实API接口进行集成，包括数据模型设计、服务层架构和错误处理机制。

## 📊 API接口设计

### 📱 发送短信验证码

**接口**: `POST /auth/sms/send`

**请求参数**:
```dart
SmsCodeRequest(
  mobile: "13800138000",      // 手机号
  clientType: "app"           // 客户端类型：web/app/mini
)
```

**响应格式**:
```dart
ApiResponse<SmsCodeResponse>(
  code: 200,
  message: "发送成功",
  data: SmsCodeResponse(
    mobile: "138****8000",     // 脱敏手机号
    message: "验证码已发送",
    sentAt: DateTime.now(),
    expiresIn: 300,           // 有效期5分钟
    nextSendIn: 60            // 60秒后可重发
  )
)
```

### 🔐 验证短信验证码

**接口**: `POST /auth/sms/verify`

**请求参数**:
```dart
SmsVerifyRequest(
  mobile: "13800138000",
  code: "123456",
  clientType: "app"
)
```

**响应格式**:
```dart
ApiResponse<LoginResponse>(
  code: 200,
  message: "登录成功",
  data: LoginResponse(
    accessToken: "eyJhbGciOiJIUzI1NiIs...",
    refreshToken: "refresh_token_here",
    tokenType: "Bearer",
    expiresIn: 7200,          // 2小时
    userInfo: UserInfo(...)
  )
)
```

## 🏗️ 架构设计

### 📦 文件结构

```
pages/login/
├── models/
│   └── auth_models.dart          # 数据模型定义
├── services/
│   └── auth_service.dart         # API服务层
├── config/
│   └── auth_config.dart          # 配置管理
├── pages/
│   └── mobile_login_page.dart    # 手机登录页面
└── widgets/
    ├── phone_input_widget.dart   # 手机号输入组件
    └── code_input_widget.dart    # 验证码输入组件
```

### 🔄 状态管理

使用 `SmsCodeState` 管理验证码发送状态：

```dart
class SmsCodeState {
  final AuthStatus status;        // 当前状态
  final String? message;          // 消息文本
  final SmsCodeResponse? data;    // API响应数据
  final int countdown;            // 倒计时秒数
  final bool canResend;          // 是否可以重发
  final ApiException? error;      // 错误信息
}
```

## 🚀 使用方法

### 1️⃣ 环境配置

在 `auth_config.dart` 中配置API环境：

```dart
class AuthConfig {
  static const Environment currentEnvironment = Environment.development;
  static const bool useMockService = true; // 开发时使用Mock服务
}
```

### 2️⃣ 初始化服务

在页面中初始化认证服务：

```dart
@override
void initState() {
  super.initState();
  // 开发环境使用Mock服务，生产环境使用真实API
  _authService = AuthConfig.useMockService 
    ? MockAuthService() 
    : AuthServiceFactory.getInstance();
}
```

### 3️⃣ 发送验证码

```dart
Future<void> _sendCode() async {
  try {
    final request = SmsCodeRequest(
      mobile: _phoneController.text.trim(),
      clientType: 'app',
    );

    final response = await _authService.sendSmsCode(request);
    
    // 更新UI状态
    setState(() {
      _smsState = _smsState.copyWith(
        status: AuthStatus.codeSent,
        data: response.data,
      );
    });
    
    // 启动倒计时
    _startCountdown(response.data?.nextSendIn ?? 60);
    
  } on ApiException catch (e) {
    _showError(e.message);
  }
}
```

### 4️⃣ 验证登录

```dart
Future<void> _verifyCode() async {
  try {
    final request = SmsVerifyRequest(
      mobile: _phoneController.text.trim(),
      code: _codeController.text.trim(),
      clientType: 'app',
    );

    final response = await _authService.verifySmsCode(request);
    
    // 保存登录token
    await SecureStorage.saveTokens(response.data);
    
    // 导航到主页
    LoginRoutes.toHomePage(context);
    
  } on ApiException catch (e) {
    _showError(e.message);
  }
}
```

## 🔧 切换到生产环境

### 步骤1：更新配置

```dart
// auth_config.dart
static const Environment currentEnvironment = Environment.production;
static const bool useMockService = false;
```

### 步骤2：更新服务初始化

```dart
// mobile_login_page.dart
@override
void initState() {
  super.initState();
  _authService = AuthServiceFactory.getInstance(
    baseUrl: AuthConfig.baseUrl,
  );
}
```

### 步骤3：添加依赖

在 `pubspec.yaml` 中添加必要依赖：

```yaml
dependencies:
  http: ^1.1.0
  json_annotation: ^4.8.1
  json_serializable: ^6.7.1

dev_dependencies:
  build_runner: ^2.4.7
```

### 步骤4：生成模型代码

```bash
dart pub get
dart pub run build_runner build
```

## 🚨 错误处理

### 常见错误码处理

```dart
switch (apiException.code) {
  case 400:
    return '请求参数错误，请检查手机号格式';
  case 429:
    return '发送过于频繁，请稍后再试';
  case 500:
    return '服务器繁忙，请稍后再试';
  default:
    return '网络错误，请检查网络连接';
}
```

### 网络超时处理

```dart
try {
  final response = await _authService.sendSmsCode(request);
} on ApiException catch (e) {
  if (e.code == -1) {
    _showError('网络连接超时，请检查网络');
  } else {
    _showError(e.message);
  }
}
```

## 🧪 测试方法

### Mock服务测试

使用 `MockAuthService` 进行本地测试：

- 验证码 `123456` 或 `000000` 可以成功登录
- 其他验证码会返回错误
- 自动模拟网络延迟和倒计时

### 真实API测试

1. 配置正确的API地址
2. 确保网络权限
3. 测试各种异常场景
4. 验证token存储和刷新机制

## 📋 检查清单

### 🔄 切换生产环境前检查

- [ ] API地址配置正确
- [ ] 关闭Mock服务
- [ ] 网络权限配置
- [ ] 错误处理完善
- [ ] 安全存储集成
- [ ] 用户体验优化

### ✅ 功能测试检查

- [ ] 手机号格式验证
- [ ] 验证码发送成功
- [ ] 倒计时功能正常
- [ ] 重发验证码功能
- [ ] 验证码登录成功
- [ ] 错误提示友好
- [ ] 网络异常处理

## 🔗 相关文档

- [Flutter HTTP 网络请求](https://docs.flutter.dev/development/data-and-backend/networking)
- [JSON序列化最佳实践](https://docs.flutter.dev/development/data-and-backend/json)
- [安全存储解决方案](https://pub.dev/packages/flutter_secure_storage)

---

📝 **注意**: 本指南基于现代开发规则设计，遵循YAGNI、DRY等原则，确保代码简洁、可维护。
