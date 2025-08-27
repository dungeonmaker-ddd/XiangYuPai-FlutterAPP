# 📦 登录模块依赖说明

## 🔧 必需的依赖

请确保在您的 `pubspec.yaml` 文件中包含以下依赖：

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # HTTP网络请求
  http: ^1.1.0
  
  # 可选：连接状态检查
  connectivity_plus: ^5.0.0
  
  # 可选：安全存储（用于保存Token）
  flutter_secure_storage: ^9.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

## 🚀 安装依赖

在项目根目录运行：

```bash
flutter pub get
```

## 📝 注意事项

### ✅ 已移除的依赖

我们已经移除了以下依赖，改为手动实现JSON序列化：
- ❌ `json_annotation` 
- ❌ `json_serializable`
- ❌ `build_runner`

这样可以：
- 🎯 减少依赖复杂度
- ⚡ 更快的构建时间
- 🔧 更容易调试和维护
- 📱 更小的应用体积

### 🔧 核心依赖说明

**http**: 用于发送HTTP请求到您的后端API
- 发送验证码请求
- 验证码验证请求
- 刷新Token请求

**connectivity_plus** (可选): 检查网络连接状态
- 在发送请求前检查网络
- 提供更好的用户体验

**flutter_secure_storage** (可选): 安全存储用户Token
- 加密存储访问令牌
- 自动处理平台差异

## 🛠️ Android权限配置

如果您使用真机测试，请确保在 `android/app/src/main/AndroidManifest.xml` 中添加网络权限：

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

## 🍎 iOS配置

对于iOS，网络权限是默认允许的，无需额外配置。

## 🧪 测试依赖

如果您需要进行单元测试，可以添加：

```yaml
dev_dependencies:
  mockito: ^5.4.0
  build_runner: ^2.4.7  # 仅用于生成mock
```

---

💡 **提示**: 当前配置已经是最精简的，只包含必要的依赖，符合YAGNI原则。
