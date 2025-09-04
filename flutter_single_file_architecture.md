# Flutter 单文件编写结构及规范

## 📋 需求分析

**1：** 建立Flutter单文件编写的标准结构，对标Python单文件模块化设计  
**2：** 防止代码组织混乱，确保即使在单文件中也保持清晰的架构层次  
**3：** 提供最小可行实现(MVP)的约束规范，适用于原型开发和POC验证  
**4：** 保持与标准Flutter架构的一致性，便于后期重构为多文件结构  

---

## 🎯 Flutter 单文件架构规范

### 📐 核心设计原则

```dart
/*
Flutter单文件结构 - AI驱动最小实现
文件内部模块结构：
1. IMPORTS      - 依赖导入 (10-20行)
2. CONSTANTS    - 常量配置 (20-30行)  
3. MODELS       - 数据模型 (50-80行)
4. SERVICES     - 业务逻辑 (80-120行)
5. CONTROLLERS  - 状态管理 (60-100行)
6. WIDGETS      - UI组件 (100-200行)
7. PAGES        - 页面视图 (80-150行)
8. APP          - 应用入口 (30-50行)
总计：~500-800行代码
*/
```

### 🏗️ 标准模板结构

```dart
// ============== 1. IMPORTS 依赖导入模块 ==============
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// ============== 2. CONSTANTS 配置常量模块 ==============
class AppConfig {
  // API配置
  static const String baseUrl = 'https://api.example.com';
  static const Duration timeout = Duration(seconds: 30);
  
  // UI配置
  static const double defaultPadding = 16.0;
  static const double borderRadius = 8.0;
  
  // 颜色主题
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color errorColor = Color(0xFFE53E3E);
}

// ============== 3. MODELS 数据模型模块 ==============
/// 用户数据模型
class User {
  final String id;
  final String name;
  final String email;
  
  const User({
    required this.id,
    required this.name,
    required this.email,
  });
  
  // JSON序列化
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
  };
  
  // 状态拷贝
  User copyWith({String? name, String? email}) => User(
    id: id,
    name: name ?? this.name,
    email: email ?? this.email,
  );
}

/// UI状态模型
enum LoadingState { idle, loading, success, error }

class AppState {
  final LoadingState status;
  final List<User> users;
  final String? errorMessage;
  
  const AppState({
    this.status = LoadingState.idle,
    this.users = const [],
    this.errorMessage,
  });
  
  AppState copyWith({
    LoadingState? status,
    List<User>? users,
    String? errorMessage,
  }) => AppState(
    status: status ?? this.status,
    users: users ?? this.users,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}

// ============== 4. SERVICES 业务逻辑模块 ==============
/// API服务类
class ApiService {
  static final _client = http.Client();
  
  /// 获取用户列表
  static Future<List<User>> fetchUsers() async {
    try {
      final response = await _client
          .get(Uri.parse('${AppConfig.baseUrl}/users'))
          .timeout(AppConfig.timeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }
  
  /// 创建用户
  static Future<User> createUser(User user) async {
    final response = await _client.post(
      Uri.parse('${AppConfig.baseUrl}/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toJson()),
    );
    
    if (response.statusCode == 201) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw ApiException('Failed to create user');
    }
  }
}

/// 自定义异常
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  
  @override
  String toString() => 'ApiException: $message';
}

// ============== 5. CONTROLLERS 状态管理模块 ==============
/// 应用状态控制器 (使用ValueNotifier简化状态管理)
class AppController extends ValueNotifier<AppState> {
  AppController() : super(const AppState());
  
  /// 加载用户数据
  Future<void> loadUsers() async {
    value = value.copyWith(status: LoadingState.loading);
    
    try {
      final users = await ApiService.fetchUsers();
      value = value.copyWith(
        status: LoadingState.success,
        users: users,
        errorMessage: null,
      );
    } catch (e) {
      value = value.copyWith(
        status: LoadingState.error,
        errorMessage: e.toString(),
      );
    }
  }
  
  /// 添加用户
  Future<void> addUser(User user) async {
    try {
      final newUser = await ApiService.createUser(user);
      final updatedUsers = [...value.users, newUser];
      value = value.copyWith(users: updatedUsers);
    } catch (e) {
      value = value.copyWith(errorMessage: e.toString());
    }
  }
  
  /// 清除错误
  void clearError() {
    value = value.copyWith(errorMessage: null);
  }
}

// ============== 6. WIDGETS UI组件模块 ==============
/// 用户卡片组件
class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback? onTap;
  
  const UserCard({
    super.key,
    required this.user,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConfig.defaultPadding,
        vertical: 8.0,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppConfig.primaryColor,
          child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?'),
        ),
        title: Text(user.name),
        subtitle: Text(user.email),
        onTap: onTap,
      ),
    );
  }
}

/// 加载指示器组件
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

/// 错误显示组件
class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  
  const ErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppConfig.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('重试'),
            ),
          ],
        ],
      ),
    );
  }
}
```

// ============== 7. PAGES 页面视图模块 ==============
/// 主页面
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final AppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppController();
    _controller.loadUsers();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户列表'),
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder<AppState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          return switch (state.status) {
            LoadingState.loading => const LoadingWidget(),
            LoadingState.error => ErrorWidget(
                message: state.errorMessage ?? '未知错误',
                onRetry: _controller.loadUsers,
              ),
            LoadingState.success => _buildUserList(state.users),
            LoadingState.idle => const SizedBox.shrink(),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        backgroundColor: AppConfig.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildUserList(List<User> users) {
    if (users.isEmpty) {
      return const Center(
        child: Text('暂无用户数据'),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return UserCard(
          user: user,
          onTap: () => _showUserDetail(user),
        );
      },
    );
  }

  void _showUserDetail(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: Text('邮箱: ${user.email}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加用户'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '姓名'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: '邮箱'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final user = User(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                email: emailController.text,
              );
              _controller.addUser(user);
              Navigator.of(context).pop();
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }
}

// ============== 8. APP 应用入口模块 ==============
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter单文件应用',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ============== MAIN 程序入口 ==============
void main() {
  runApp(const MyApp());
}
```

---

## 📏 编写规范约束

### ✅ 必须遵循的规则

**1. 模块分离原则**
- 每个模块用注释清晰分隔：`// ============== N. MODULE 模块名 ==============`
- 模块内部按功能分组，相关代码紧邻放置
- 严格按照 IMPORTS → CONSTANTS → MODELS → SERVICES → CONTROLLERS → WIDGETS → PAGES → APP 的顺序

**2. 命名规范**
- 类名：大驼峰 `UserController`
- 方法名：小驼峰 `loadUsers()`
- 常量：全大写下划线 `DEFAULT_PADDING`
- 私有成员：下划线前缀 `_controller`

**3. 代码行数限制**
- 单个类不超过100行
- 单个方法不超过30行
- 总文件不超过800行
- 超出限制必须拆分为多文件

**4. 依赖管理**
- 所有外部依赖在顶部集中导入
- 按系统库 → 第三方库 → 相对导入的顺序
- 使用 `as` 别名避免命名冲突

### ⚠️ 禁止的反模式

**1. 禁止深度嵌套**
```dart
// ❌ 错误：超过3层嵌套
if (condition1) {
  if (condition2) {
    if (condition3) {
      // 太深了
    }
  }
}

// ✅ 正确：提前返回
if (!condition1) return;
if (!condition2) return;
if (!condition3) return;
// 主逻辑
```

**2. 禁止魔法值**
```dart
// ❌ 错误：硬编码数值
Container(width: 16, height: 8)

// ✅ 正确：使用常量
Container(
  width: AppConfig.defaultPadding,
  height: AppConfig.smallSpacing,
)
```

**3. 禁止混合关注点**
```dart
// ❌ 错误：Widget中包含业务逻辑
class UserWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 不应该在这里调用API
    ApiService.fetchUsers();
    return Container();
  }
}

// ✅ 正确：分离关注点
class UserWidget extends StatelessWidget {
  final User user; // 只接收数据

  @override
  Widget build(BuildContext context) {
    return Container(); // 只负责渲染
  }
}
```

---

## 🚀 使用指南

### 快速开始模板

```dart
// 创建新的单文件应用时，复制以下模板：

// ============== 1. IMPORTS ==============
import 'package:flutter/material.dart';

// ============== 2. CONSTANTS ==============
class AppConfig {
  static const String appName = 'MyApp';
}

// ============== 3. MODELS ==============
class MyModel {
  // 数据模型定义
}

// ============== 4. SERVICES ==============
class MyService {
  // 业务逻辑实现
}

// ============== 5. CONTROLLERS ==============
class MyController extends ValueNotifier<MyState> {
  // 状态管理
}

// ============== 6. WIDGETS ==============
class MyWidget extends StatelessWidget {
  // UI组件
}

// ============== 7. PAGES ==============
class MyPage extends StatefulWidget {
  // 页面视图
}

// ============== 8. APP ==============
class MyApp extends StatelessWidget {
  // 应用入口
}

void main() => runApp(const MyApp());
```

### 重构指导

当单文件超过800行时，按以下顺序拆分：

1. **第一步**：提取 `models/` - 数据模型独立性最强
2. **第二步**：提取 `services/` - 业务逻辑可独立测试
3. **第三步**：提取 `widgets/` - UI组件可复用
4. **第四步**：提取 `controllers/` - 状态管理分离
5. **最后**：保留 `pages/` 和 `app.dart` 在主文件

---

## 🎯 AI提示模板

```markdown
任务：构建Flutter单文件应用

架构选择：
1. 【单文件版】快速原型，适合POC验证，<800行
2. 【模块化版】完整架构，适合生产项目

核心约束：
- 严格按照8个模块顺序组织代码
- 每个模块用注释分隔，内部按功能分组
- 类不超过100行，方法不超过30行
- 使用ValueNotifier简化状态管理

关键决策点：
1. 状态管理：优先ValueNotifier，复杂场景用Provider
2. 网络请求：使用http包，统一错误处理
3. UI组件：StatelessWidget优先，最小化State

性能指标：
- 冷启动：<2s
- 页面切换：<300ms
- 内存占用：<100MB
```

这个规范确保了即使在单文件中也能保持清晰的架构层次，便于AI理解和人工维护，同时为后期重构提供了明确的路径。
