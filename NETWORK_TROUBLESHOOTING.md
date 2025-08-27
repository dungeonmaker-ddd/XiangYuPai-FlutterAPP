# 🌐 Flutter网络连接故障排除指南

## 📋 问题概述

Flutter应用在不同平台上访问本地开发服务器时会遇到网络连接问题，特别是在模拟器环境中。

## 🔧 已修复的问题

### 1. API端点统一
- ✅ **修复前**: 使用 `/auth/sms/send` 发送验证码
- ✅ **修复后**: 统一使用 `/auth/login` 接口，通过 `loginType` 参数区分

### 2. 网络地址配置
- ✅ **Android模拟器**: 自动使用 `10.0.2.2:8080`
- ✅ **iOS模拟器**: 自动使用 `localhost:8080`
- ✅ **Web浏览器**: 自动使用 `localhost:8080`

### 3. 客户端类型识别
- ✅ **app**: Android/iOS应用
- ✅ **web**: Web浏览器
- ✅ **mini**: 小程序等其他平台

## 🚀 使用方法

### 启用真实HTTP请求

代码现在默认使用真实的HTTP请求，不再是模拟请求。

### 网络诊断

应用启动时会自动进行快速网络连接测试：

```dart
// 在控制台查看诊断信息
await NetworkDebug.runFullDiagnostics();
```

## 📱 平台特定配置

### Android 模拟器
```
✅ API地址: http://10.0.2.2:8080/auth
📝 说明: 10.0.2.2 是Android模拟器访问宿主机的特殊IP
```

### iOS 模拟器
```
✅ API地址: http://localhost:8080/auth
📝 说明: iOS模拟器可以直接访问localhost
```

### Web 浏览器
```
✅ API地址: http://localhost:8080/auth
📝 说明: Web应用直接访问本地服务器
⚠️  注意: 需要后端配置CORS跨域支持
```

## 🔧 后端服务器配置要求

### 1. 监听地址配置
```bash
# ❌ 错误 - 只监听本地回环
java -jar app.jar --server.address=127.0.0.1 --server.port=8080

# ✅ 正确 - 监听所有网卡
java -jar app.jar --server.address=0.0.0.0 --server.port=8080
```

### 2. CORS配置（适用于Web端）
```java
@CrossOrigin(origins = "http://localhost:*")
@RestController
public class AuthController {
    // 你的控制器代码
}
```

### 3. 健康检查端点
```java
@GetMapping("/auth/health")
public ResponseEntity<Map<String, String>> health() {
    return ResponseEntity.ok(Map.of("status", "ok"));
}
```

## 🐛 故障排除步骤

### 1. 基础检查
1. 确保后端服务运行在 `localhost:8080`
2. 在浏览器访问 `http://localhost:8080/auth/health`
3. 检查防火墙是否阻止8080端口

### 2. Android特定问题
```bash
# 检查模拟器网络连接
adb shell ping 10.0.2.2

# 查看应用日志
adb logcat | grep "NetworkDebug\|AuthService"
```

### 3. iOS特定问题
```bash
# 在iOS模拟器中测试连接
xcrun simctl spawn booted curl http://localhost:8080/auth/health
```

### 4. Web特定问题
- 检查浏览器开发者工具的Network标签
- 确认是否有CORS错误
- 验证请求是否发送到正确的地址

## 📊 网络诊断输出示例

正常连接时的控制台输出：
```
🔍 NETWORK:DIAGNOSTICS 开始网络诊断...

📋 BASIC:INFO 基础信息:
   🔧 Debug模式: 是
   📱 平台: Android API 34
   🌐 Web平台: 否

🌐 NETWORK:CONFIG 网络配置信息:
   📍 BaseURL: http://10.0.2.2:8080/auth
   📱 ClientType: app
   🔧 Platform: Android
   🚀 Mode: Debug

🧪 CONNECTION:TEST 连接测试:
   ✅ Current Config: 200 (http://10.0.2.2:8080/auth)
   ✅ Android Emulator: 200 (http://10.0.2.2:8080/auth)
   ❌ iOS Simulator: 连接失败 (http://localhost:8080/auth)
   ❌ Local 127.0.0.1: 连接失败 (http://127.0.0.1:8080/auth)
   ❌ Docker Internal: 连接失败 (http://host.docker.internal:8080/auth)
```

## 🌟 API接口规范

### 发送验证码
```http
POST /auth/sms/send
Content-Type: application/json

{
  "mobile": "13800138000",
  "clientType": "app"
}
```

### 登录
```http
POST /auth/login
Content-Type: application/json

{
  "mobile": "13800138000",
  "code": "123456",
  "clientType": "app",
  "loginType": "mobile"
}
```

### 重置密码
```http
POST /auth/password/reset
Content-Type: application/json

{
  "mobile": "13800138000",
  "code": "123456",
  "newPassword": "newpass123",
  "clientType": "app"
}
```

## 💡 开发建议

1. **启动应用前**：确保后端服务正在运行
2. **网络问题**：查看控制台的网络诊断信息
3. **真机测试**：使用同一WiFi网络，配置电脑的局域网IP
4. **生产环境**：配置正确的生产服务器地址

## 🆘 获取帮助

如果仍有网络连接问题：

1. 运行完整网络诊断：`NetworkDebug.runFullDiagnostics()`
2. 检查控制台输出的详细信息
3. 确认后端服务配置是否正确
4. 尝试不同的网络环境

---
*此文档会随着项目发展持续更新*
