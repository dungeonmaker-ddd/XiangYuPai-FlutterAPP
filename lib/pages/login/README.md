# 📱 登录模块功能说明

## 🗂️ 文件结构

探店APP登录模块采用分层的文件组织结构：

```
pages/login/
├── pages/                  # 📱 页面文件
│   ├── login_page.dart     # 🔐 密码登录页面
│   ├── mobile_login_page.dart # 📱 验证码登录页面
│   └── forgot_password_page.dart # 🔄 忘记密码页面
├── widgets/                # 🧩 登录专用组件  
│   ├── phone_input_widget.dart # 📱 智能手机号输入组件
│   ├── password_input_widget.dart # 🔒 密码输入组件
│   ├── code_input_widget.dart # 🔢 6位验证码输入组件
│   └── index.dart          # 组件统一导出
├── utils/                  # 🛠️ 工具类
│   └── login_routes.dart   # 🧭 统一路由管理
├── services/               # 🔧 业务逻辑服务 (预留)
├── models/                 # 📊 数据模型 (预留)
├── index.dart              # 📦 模块统一导出
└── README.md              # 📖 模块说明文档
```

## 🎯 整体架构

### 📄 页面组件
- **🔐 LoginPage**: 密码登录页面  
- **📱 MobileLoginPage**: 验证码登录页面
- **🔄 ForgotPasswordPage**: 忘记密码页面

### 🧩 共享组件
- **PhoneInputWidget**: 智能手机号输入组件
- **PasswordInputWidget**: 密码输入组件  
- **CodeInputWidget**: 6位验证码输入组件

### 🧭 路由管理
- **LoginRoutes**: 统一的路由跳转管理

## ✨ 功能特点

### 🌍 多国家支持
- 支持190+国家和地区
- 智能区号选择和手机号长度验证
- 针对中国大陆的特殊验证规则(1开头)

### 🎨 用户体验优化
- 现代化UI设计，紫色主题
- 智能表单验证和实时反馈
- 流畅的页面跳转动画
- 统一的错误提示样式

### 🔒 安全性保障
- 手机号格式严格验证
- 密码长度限制(6-20位)
- 验证码60秒倒计时防刷机制
- 输入防抖和安全检查

## 🚀 使用示例

### 方式一：使用统一导出 (推荐)
```dart
// 导入整个登录模块
import 'package:your_app/pages/login/index.dart';

// 启动登录流程
LoginRoutes.toPasswordLogin(context);
LoginRoutes.toMobileLogin(context);
LoginRoutes.toForgotPassword(context);

// 直接使用页面组件
Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
```

### 方式二：单独导入组件
```dart
// 导入特定组件
import 'package:your_app/pages/login/pages/login_page.dart';
import 'package:your_app/pages/login/widgets/index.dart';
import 'package:your_app/pages/login/utils/login_routes.dart';

// 使用路由跳转
LoginRoutes.toPasswordLogin(context);
```

### 手机号输入组件使用
```dart
PhoneInputWidget(
  controller: _phoneController,
  selectedCountry: _selectedCountry,
  onCountryChanged: (country) {
    setState(() => _selectedCountry = country);
  },
  enableValidation: true,
  showValidationHint: true,
  hintText: '请输入手机号',
)
```

### 验证码输入组件使用
```dart
CodeInputWidget(
  controller: _codeController,
  onCompleted: () {
    // 验证码输入完成时自动调用
    _verifyCode();
  },
  onChanged: () {
    setState(() {}); // 刷新UI状态
  },
)
```

## 🔄 页面流程图

```
应用启动 → 登录选择
    ↓
🔐 密码登录页面 ←→ 📱 验证码登录页面
    ↓                    ↓
忘记密码? → 🔄 忘记密码页面   验证成功 → 🏠 主页面
    ↓
手机号验证 → 验证码验证 → 重置成功
```

## 📊 验证规则

### 手机号验证
- **中国大陆(+86)**: 11位，1开头，格式: 1[3-9]xxxxxxxxx
- **其他国家**: 根据国家规则自动适配长度和格式

### 密码验证  
- **长度**: 6-20位字符
- **显示**: 支持明文/密文切换

### 验证码验证
- **长度**: 6位数字
- **倒计时**: 60秒重发限制
- **输入**: 分离式输入框，支持粘贴

## 🎨 设计规范

### 颜色规范
- **主色调**: Purple (#9C27B0)
- **文本色**: Black (#000000)  
- **提示色**: Grey[600] (#757575)
- **错误色**: Red[600] (#E53935)
- **成功色**: Green[600] (#43A047)

### 组件规范
- **按钮高度**: 50px
- **圆角半径**: 25px
- **输入框**: 底部下划线样式
- **间距**: 主要间距20px、40px

## 🚀 待优化功能

### 短期优化
- [ ] 添加生物识别登录(指纹/面容)
- [ ] 支持第三方登录(微信/QQ/微博)
- [ ] 添加记住密码功能
- [ ] 实现自动填充验证码

### 长期规划  
- [ ] 支持扫码登录
- [ ] 添加登录设备管理
- [ ] 实现单点登录(SSO)
- [ ] 支持多账号切换

## 🛠️ 技术栈

- **框架**: Flutter 3.x
- **状态管理**: StatefulWidget + setState
- **路由管理**: Navigator 2.0
- **表单验证**: 自定义验证器
- **国际化**: 多国家数据模型

---

> 💡 提示: 该登录模块严格遵循现代开发规范，注重用户体验和代码质量。所有组件均可复用，支持灵活配置。
