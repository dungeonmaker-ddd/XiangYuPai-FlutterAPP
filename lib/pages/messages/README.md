# 💬 消息系统模块

基于Flutter的完整消息系统实现，支持私聊、分类消息、系统通知等功能。

## 📋 功能特性

### 🏠 消息主页面
- **消息分类功能区**：赞和收藏、评论、粉丝、系统通知四大分类
- **最近对话列表**：显示最近的私聊对话，支持置顶、静音等操作
- **实时消息统计**：显示各分类的未读消息数量
- **下拉刷新**：支持下拉刷新获取最新消息

### 💬 私聊功能
- **消息气泡界面**：发送和接收消息的气泡样式展示
- **多种消息类型**：支持文字、图片、语音、视频消息
- **消息状态显示**：发送中、已发送、已读等状态指示
- **消息操作**：复制、转发、删除、举报等操作
- **实时输入**：支持实时输入状态显示

### 📋 分类消息
- **赞和收藏消息**：显示用户对内容的点赞和收藏通知
- **评论消息**：显示用户对内容的评论通知
- **粉丝消息**：显示新增粉丝关注通知
- **系统通知**：显示系统重要通知和提醒

### 🔧 技术特性
- **状态管理**：基于Provider的响应式状态管理
- **本地存储**：支持消息本地缓存和离线访问
- **实时推送**：模拟WebSocket实时消息推送
- **性能优化**：消息分页加载、图片懒加载等优化

## 🏗️ 架构设计

### 📁 目录结构
```
pages/messages/
├── models/                 # 数据模型
│   └── message_models.dart
├── services/              # 服务层
│   └── message_services.dart
├── providers/             # 状态管理
│   └── message_providers.dart
├── widgets/               # UI组件
│   └── message_widgets.dart
├── pages/                 # 页面组件
│   ├── message_main_page.dart
│   ├── category_message_page.dart
│   └── chat_page.dart
├── index.dart            # 统一导出
└── README.md             # 文档说明
```

### 🧩 核心组件

#### 数据模型层
- `Message`：消息基础模型
- `Conversation`：对话模型
- `MessageUser`：用户模型
- `NotificationMessage`：系统通知模型
- `MessageStats`：消息统计模型

#### 服务层
- `MessageApiService`：消息API服务
- `MessageStorageService`：本地存储服务
- `MessagePushService`：消息推送服务
- `MessageService`：综合消息服务

#### 状态管理层
- `MessageProvider`：主消息状态管理
- `ConversationProvider`：对话列表状态管理
- `ChatProvider`：聊天状态管理
- `CategoryMessageProvider`：分类消息状态管理

#### UI组件层
- `MessageCategoryCard`：消息分类卡片
- `ConversationListItem`：对话列表项
- `MessageBubble`：消息气泡
- `MessageInputBox`：消息输入框
- `CategoryMessageItem`：分类消息项
- `SystemNotificationItem`：系统通知项

## 🚀 使用方法

### 1. 基础集成

在主应用中集成消息系统：

```dart
import 'pages/messages/index.dart' as messages;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: messages.MessageSystemProviders(
        child: messages.MessageMainPage(),
      ),
    );
  }
}
```

### 2. 在Tab页面中使用

```dart
// 在主Tab页面中集成
_pages = [
  const HomePage(),
  const DiscoveryPage(),
  const messages.MessageSystemProviders(
    child: messages.MessageMainPage(),
  ),
  const ProfilePage(),
];
```

### 3. 单独使用聊天页面

```dart
// 跳转到聊天页面
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => messages.ChatPage(
      conversationId: 'conversation_id',
      otherUser: messageUser,
    ),
  ),
);
```

### 4. 单独使用分类消息页面

```dart
// 跳转到分类消息页面
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => messages.CategoryMessagePage(
      category: messages.MessageCategory.like,
    ),
  ),
);
```

## 📊 数据流程

### 消息发送流程
1. 用户在输入框输入消息
2. `ChatProvider.sendTextMessage()` 处理发送
3. `MessageService.sendMessage()` 调用API
4. 消息添加到本地缓存
5. 更新UI显示发送状态
6. 服务器返回结果后更新最终状态

### 消息接收流程
1. `MessagePushService` 接收实时推送
2. `MessageProvider` 处理新消息事件
3. 更新未读消息统计
4. `ConversationProvider` 更新对话列表
5. UI自动刷新显示新消息

### 离线消息同步
1. 应用启动时检查网络状态
2. 从本地缓存加载历史消息
3. 网络可用时同步服务器数据
4. 合并本地和服务器消息
5. 更新本地缓存

## 🎨 UI设计特色

### 消息分类卡片
- **4宫格布局**：赞和收藏、评论、粉丝、系统通知
- **渐变图标**：每个分类使用不同的渐变色图标
- **未读角标**：显示未读消息数量，支持99+显示
- **点击动画**：0.2s缩放动画反馈

### 对话列表项
- **头像显示**：圆形头像，支持在线状态指示
- **消息预览**：显示最后一条消息内容预览
- **时间显示**：智能时间格式化显示
- **未读标识**：未读消息加粗显示，显示未读数量

### 消息气泡
- **差异化设计**：发送和接收消息使用不同颜色和对齐
- **消息状态**：发送中、已发送、已读等状态图标
- **多媒体支持**：文字、图片、语音、视频等类型
- **时间分隔**：超过5分钟显示时间分隔线

### 输入框组件
- **自适应高度**：根据输入内容自动调整高度
- **扩展功能**：拍照、相册、语音、位置等功能
- **发送状态**：发送按钮根据输入状态变化
- **表情支持**：支持Emoji表情输入和显示

## 🔧 配置选项

### 消息系统常量
```dart
class MessageSystemConstants {
  static const int maxMessageLength = 1000;
  static const int messagePageSize = 50;
  static const Duration messageTimeout = Duration(seconds: 30);
  static const Color primaryColor = Color(0xFF8B5CF6);
}
```

### 自定义配置
```dart
// 自定义消息气泡颜色
MessageBubble(
  message: message,
  sentColor: Colors.blue,
  receivedColor: Colors.grey[200],
);

// 自定义分类卡片
MessageCategoryCard(
  category: MessageCategory.like,
  customIcon: Icons.favorite,
  customGradient: LinearGradient(colors: [Colors.red, Colors.pink]),
);
```

## 📱 平台适配

### iOS适配
- 安全区域适配
- 键盘弹起处理
- 滑动返回手势

### Android适配
- 状态栏颜色适配
- 返回按钮处理
- 权限请求处理

### 响应式设计
- 不同屏幕尺寸适配
- 横竖屏切换支持
- 平板布局优化

## 🚧 开发计划

### 已完成功能 ✅
- [x] 消息系统基础架构
- [x] 消息主页面
- [x] 私聊功能
- [x] 分类消息显示
- [x] 系统通知
- [x] 消息状态管理
- [x] UI组件库

### 计划中功能 📋
- [ ] 语音消息录制和播放
- [ ] 视频消息支持
- [ ] 消息搜索功能
- [ ] 消息加密
- [ ] 群聊功能
- [ ] 消息撤回
- [ ] 消息置顶
- [ ] 消息标签分类

## 🐛 已知问题

1. **模拟数据**：当前使用模拟数据，需要接入真实API
2. **离线同步**：离线消息同步逻辑需要完善
3. **性能优化**：大量消息时的性能优化
4. **内存管理**：长时间使用时的内存泄漏检查

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

---

*最后更新：2024年12月19日*
*版本：v1.0*
*基于：Flutter 3.9.0 + Provider 6.1.1*
