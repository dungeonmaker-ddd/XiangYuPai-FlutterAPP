# 🚀 Flutter开发指南

## 📋 常用开发命令

### 🏗️ 项目管理
```bash
# 创建新项目
flutter create my_app

# 获取依赖包
flutter pub get

# 清理构建缓存
flutter clean

# 分析代码质量
flutter analyze

# 格式化代码
flutter format .
```

### 🔧 开发调试
```bash
# 运行应用（开发模式）
flutter run

# 热重载（开发时按 r）
# 热重启（开发时按 R）

# 运行在特定设备
flutter run -d chrome        # Web
flutter run -d android       # Android
flutter run -d ios          # iOS

# 查看连接的设备
flutter devices
```

### 📦 构建发布
```bash
# 构建APK（Android）
flutter build apk --release

# 构建AAB（Android App Bundle）
flutter build appbundle --release

# 构建iOS
flutter build ios --release

# 构建Web
flutter build web --release
```

## 🎯 开发最佳实践

### 1️⃣ 代码规范
- ✅ 使用有意义的变量和函数名
- ✅ 遵循Dart命名规范（驼峰命名）
- ✅ 添加适当的注释和文档
- ✅ 保持函数简洁（单一职责原则）

### 2️⃣ Widget设计
```dart
// ✅ 好的实践
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
```

### 3️⃣ 状态管理
```dart
// 使用Provider进行状态管理
class UserProvider extends ChangeNotifier {
  String _userName = '';
  
  String get userName => _userName;
  
  void updateUserName(String name) {
    _userName = name;
    notifyListeners();
  }
}
```

### 4️⃣ 性能优化
- ✅ 使用const构造函数
- ✅ 避免在build方法中创建对象
- ✅ 合理使用ListView.builder
- ✅ 图片优化和缓存

### 5️⃣ 测试策略
```dart
// 单元测试示例
void main() {
  test('用户名验证测试', () {
    expect(validateUserName('test'), true);
    expect(validateUserName(''), false);
  });
}

// Widget测试示例
testWidgets('按钮点击测试', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();
  expect(find.text('1'), findsOneWidget);
});
```

## 🛠️ 推荐工具和插件

### VS Code扩展
- 🎯 Flutter - 官方Flutter支持
- 🎯 Dart - Dart语言支持
- 🎯 Flutter Widget Snippets - 代码片段
- 🎯 Flutter Tree - Widget树可视化
- 🎯 Error Lens - 错误高亮显示

### 调试工具
- 🔍 Flutter Inspector - Widget检查器
- 📊 Performance View - 性能分析
- 🐛 Debugger - 断点调试
- 📱 Device Preview - 多设备预览

## 📚 学习资源

### 官方文档
- 📖 [Flutter官方文档](https://flutter.dev/docs)
- 📖 [Dart语言指南](https://dart.dev/guides)
- 📖 [Flutter Cookbook](https://flutter.dev/docs/cookbook)

### 社区资源
- 🌟 [Pub.dev](https://pub.dev) - 包管理
- 🌟 [FlutterFire](https://firebase.flutter.dev) - Firebase集成
- 🌟 [Flutter Community](https://github.com/fluttercommunity)

## 🎨 UI设计指南

### Material Design
```dart
// 使用Material Design组件
MaterialApp(
  theme: ThemeData(
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  ),
  home: MyHomePage(),
)
```

### 响应式设计
```dart
// 响应式布局示例
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return DesktopLayout();
    } else {
      return MobileLayout();
    }
  },
)
```

## 🔒 安全最佳实践

- 🛡️ 不在代码中硬编码敏感信息
- 🛡️ 使用HTTPS进行网络请求
- 🛡️ 验证用户输入
- 🛡️ 使用安全的存储方案

---

📝 **记住YAGNI原则**：只实现当前需要的功能，避免过度设计！
