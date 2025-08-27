# 🚀 快速开始指南

## 📋 本地服务对接配置

### 🎯 当前设置

您的配置已经准备就绪，连接本机80端口服务：

```dart
// ✅ 已配置
Environment.development: 'http://10.0.2.2'  // Android模拟器访问本机
useMockService = false                       // 使用真实API
enableApiLogging = true                      // 启用调试日志
```

### 🔧 立即开始

**1. 确认后端服务运行**
```bash
# 检查80端口
netstat -ano | findstr :80
```

**2. 启动Flutter应用**
```bash
flutter run
```

**3. 测试API连接**
- 方式1：直接使用手机登录页面
- 方式2：使用API测试页面 `ApiTestPage()`

### 📱 不同设备配置

| 设备类型 | 修改配置 |
|---------|---------|
| Android模拟器 | ✅ 无需修改 |
| iOS模拟器 | 改为 `http://127.0.0.1` |
| 真机调试 | 改为您的局域网IP |

### 🧪 API测试页面

使用内置的API测试工具：

```dart
import 'package:your_app/pages/login/index.dart';

// 在任何页面跳转到测试页面
Navigator.push(
  context, 
  MaterialPageRoute(builder: (context) => ApiTestPage())
);
```

### 🔍 调试技巧

**查看网络日志**：
- 启动应用后查看Flutter控制台
- 每个API请求都会有详细日志
- 格式：🚀 Request → 📡 Response

**常见问题解决**：
1. 连接被拒绝 → 检查服务是否启动
2. 网络超时 → 检查防火墙设置
3. 真机无法连接 → 使用局域网IP

### 🔄 快速切换环境

**使用Mock服务（离线开发）**：
```dart
// auth_config.dart
static const bool useMockService = true;
```

**连接生产API**：
```dart
// auth_config.dart
static const Environment currentEnvironment = Environment.production;
static const bool useMockService = false;
```

### 📊 预期API格式

**发送验证码请求**：
```json
POST /auth/sms/send
{
  "mobile": "13800138000",
  "clientType": "app"
}
```

**验证码验证请求**：
```json
POST /auth/sms/verify
{
  "mobile": "13800138000", 
  "code": "123456",
  "clientType": "app"
}
```

### ✅ 检查清单

开发前确认：
- [ ] 后端服务运行在80端口
- [ ] 防火墙允许连接
- [ ] 设备网络配置正确
- [ ] Flutter应用已配置网络权限

**就是这么简单！🎉**

---

💡 **快速提示**: 如果遇到问题，首先查看Flutter控制台的网络日志，然后参考 `LOCAL_DEVELOPMENT_SETUP.md` 获取详细帮助。
