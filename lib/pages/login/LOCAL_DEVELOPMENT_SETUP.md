# 🏠 本地开发环境配置指南

## 🎯 概述

本指南说明如何配置Flutter应用连接到本地运行的后端服务（通过80端口网关转发）。

## 🔧 网络配置

### 📱 移动设备/模拟器IP配置

根据不同的运行环境，需要使用不同的IP地址来访问本机服务：

| 运行环境 | IP地址 | 说明 |
|---------|--------|------|
| Android模拟器 | `10.0.2.2` | 模拟器内访问宿主机IP |
| iOS模拟器 | `127.0.0.1` | 本地回环地址 |
| Web/桌面端 | `localhost` | 直接访问本地服务 |
| 真机调试 | `192.168.x.x` | 局域网IP地址 |

### ⚙️ 当前配置

在 `auth_config.dart` 中已预配置：

```dart
// 默认使用Android模拟器配置
static const Map<Environment, String> _baseUrls = {
  Environment.development: 'http://10.0.2.2', // 通过80端口网关
  // ...
};
```

## 🚀 快速启动

### 1️⃣ 确认服务端运行

确保您的后端服务正在运行并监听80端口：

```bash
# 检查80端口是否被占用
netstat -ano | findstr :80

# 或在Linux/Mac上
lsof -i :80
```

### 2️⃣ 配置客户端

根据您的运行环境修改配置：

**Android模拟器（默认）**：
```dart
// auth_config.dart - 无需修改
static const Environment currentEnvironment = Environment.development;
static const bool useMockService = false;
```

**iOS模拟器**：
```dart
// 临时修改 _baseUrls
Environment.development: 'http://127.0.0.1',
```

**真机调试**：
```dart
// 替换为您的电脑局域网IP
Environment.development: 'http://192.168.1.100', // 请替换为实际IP
```

### 3️⃣ 获取本机IP地址

**Windows**：
```cmd
ipconfig | findstr IPv4
```

**Mac/Linux**：
```bash
ifconfig | grep inet
```

**或使用网络设置查看**

### 4️⃣ 启动应用

```bash
# 清理并重新运行
flutter clean
flutter pub get
flutter run
```

## 🧪 测试连接

### 📡 测试API连接

1. **直接测试API**（可选）：
   ```bash
   # 测试发送验证码接口
   curl -X POST http://localhost/auth/sms/send \
        -H "Content-Type: application/json" \
        -d '{"mobile":"13800138000","clientType":"app"}'
   ```

2. **应用内测试**：
   - 启动应用
   - 进入手机登录页面
   - 输入手机号
   - 点击"获取验证码"
   - 查看网络请求日志

### 🔍 调试技巧

#### 启用网络日志

在 `auth_service.dart` 中已配置，可查看详细请求日志：

```dart
// 开发环境自动启用日志
static const bool enableApiLogging = true;
```

#### Flutter网络调试

```bash
# 运行时启用网络调试
flutter run --verbose
```

#### 使用网络抓包工具

推荐工具：
- **Charles Proxy**
- **Fiddler**
- **Wireshark**

## ⚠️ 常见问题

### 🚫 连接被拒绝

**症状**：`Connection refused` 或 `Network unreachable`

**解决方案**：
1. 确认后端服务正在运行
2. 检查防火墙设置
3. 验证IP地址是否正确
4. 确认端口80未被其他程序占用

### 🐌 连接超时

**症状**：请求长时间等待后超时

**解决方案**：
```dart
// 调整超时时间
static const Duration networkTimeout = Duration(seconds: 30);
static const Duration connectTimeout = Duration(seconds: 10);
```

### 📱 真机无法连接

**症状**：模拟器可以，真机不行

**解决方案**：
1. 确保手机和电脑在同一WiFi网络
2. 使用电脑的局域网IP，不是localhost
3. 关闭电脑防火墙或添加例外
4. 检查路由器是否阻止设备间通信

### 🌐 CORS跨域问题

**症状**：Web端运行时出现CORS错误

**解决方案**：
- 后端需要配置CORS允许前端域名
- 或使用代理服务器

## 🔄 不同环境切换

### 🧪 使用Mock服务（离线开发）

```dart
// auth_config.dart
static const bool useMockService = true;
```

### 🌐 连接真实API

```dart
// auth_config.dart
static const bool useMockService = false;
static const Environment currentEnvironment = Environment.development;
```

### 🚀 生产环境

```dart
// auth_config.dart
static const bool useMockService = false;
static const Environment currentEnvironment = Environment.production;
```

## 📋 检查清单

开发前请确认：

- [ ] 后端服务已启动并监听80端口
- [ ] 已根据运行环境配置正确的IP地址
- [ ] 关闭了Mock服务 (`useMockService = false`)
- [ ] 网络权限已配置（Android）
- [ ] 防火墙允许相关端口通信
- [ ] 手机与电脑在同一网络（真机调试）

## 🛠️ 高级配置

### 🔀 动态切换环境

可以创建一个开发工具来动态切换API地址：

```dart
class DevTools {
  static String? _customBaseUrl;
  
  static void setCustomBaseUrl(String url) {
    _customBaseUrl = url;
  }
  
  static String get effectiveBaseUrl {
    return _customBaseUrl ?? AuthConfig.baseUrl;
  }
}
```

### 📊 网络监控

添加网络状态监控：

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkMonitor {
  static Future<bool> isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}
```

---

🎯 **提示**：开发完成后，记得将 `useMockService` 设为 `false` 并配置正确的生产环境API地址。
