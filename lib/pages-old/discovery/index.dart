// 🔍 发现模块统一导出文件 - 基于Flutter单文件架构规范
// 提供发现模块所有公共接口的统一导出入口

// ============== 1. PAGES EXPORTS ==============
/// 📱 页面导出
/// 主要页面文件导出，供其他模块使用

// 发现主页面
export 'pages/discovery_main_page.dart';

// 发布动态页面
export 'pages/publish_content_page.dart';

// 内容详情页面
export 'pages/content_detail_page.dart';

// 话题选择页面
export 'pages/topic_selector_page.dart';

// 地点选择页面 - 重命名以避免冲突
export 'pages/location_picker_page.dart';

// ============== 2. MODELS EXPORTS ==============
/// 📋 数据模型导出
/// 所有数据模型和枚举类型导出

// 发现页面数据模型
export 'models/discovery_models.dart' hide ContentStatus;

// 发布动态数据模型
export 'models/publish_models.dart' hide MediaType;

// 内容详情数据模型
export 'models/content_detail_models.dart';

// ============== 3. SERVICES EXPORTS ==============
/// 🔧 业务服务导出
/// 所有业务逻辑服务导出

// 发现页面业务服务
export 'services/discovery_services.dart' hide InteractionService;

// 发布动态业务服务
export 'services/publish_services.dart' hide TopicCategoryModel, MediaService;

// 内容详情业务服务
export 'services/content_detail_services.dart' hide SearchService;

// ============== 4. UTILS EXPORTS ==============
/// 🛠️ 工具类导出
/// 状态管理和工具类导出

// 发布状态管理器
export 'utils/publish_state_manager.dart';

// ============== 5. PUBLIC API SUMMARY ==============
/// 📤 公共API总结
/// 
/// 本模块对外提供的主要接口：
/// 
/// **页面组件：**
/// - `DiscoveryMainPage`: 发现主页面（三标签页瀑布流）
/// - `PublishContentPage`: 发布动态页面（多媒体编辑）
/// - `ContentDetailPage`: 内容详情页面（沉浸式阅读）
/// - `TopicSelectorPage`: 话题选择页面
/// - `LocationPickerPage`: 地点选择页面
/// 
/// **核心数据模型：**
/// - `DiscoveryContent`: 发现内容数据模型
/// - `PublishContentModel`: 发布内容数据模型
/// - `ContentDetailModel`: 内容详情数据模型
/// - `MediaModel`/`MediaItemModel`: 媒体文件模型
/// - `TopicModel`: 话题模型
/// - `LocationModel`: 位置模型
/// - `CommentModel`: 评论模型
/// 
/// **业务服务：**
/// - `DiscoveryService`: 发现页面数据服务
/// - `PublishContentService`: 发布内容服务
/// - `ContentDetailService`: 内容详情服务
/// - `MediaService`: 媒体处理服务
/// - `TopicService`: 话题服务
/// - `LocationService`: 位置服务
/// 
/// **状态管理：**
/// - `PublishStateManager`: 全局发布状态管理器
/// - `MasonryState`: 瀑布流状态模型
/// - `PublishState`: 发布页面状态模型
/// - `DetailPageState`: 详情页面状态模型
/// 
/// **枚举类型：**
/// - `TabType`: 标签页类型（关注/热门/同城）
/// - `ContentType`: 内容类型（文字/图片/视频）
/// - `MediaType`: 媒体类型（图片/视频）
/// - `PublishStatus`: 发布状态（草稿/发布中/成功/失败）
/// - `PrivacyLevel`: 隐私级别（公开/仅关注者/私密）
/// - `SharePlatform`: 分享平台（微信/微博等）

// ============== 6. USAGE EXAMPLES ==============
/// 📖 使用示例
/// 
/// ```dart
/// // 1. 导入发现模块
/// import 'pages/discovery/index.dart';
/// 
/// // 2. 使用发现主页面
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: DiscoveryMainPage(),
///       routes: {
///         '/publish': (context) => PublishContentPage(),
///         '/detail': (context) => ContentDetailPage(
///           contentId: ModalRoute.of(context)!.settings.arguments as String,
///         ),
///       },
///     );
///   }
/// }
/// 
/// // 3. 使用数据模型
/// void handleContentData() {
///   final content = DiscoveryContent(
///     id: '123',
///     text: '示例内容',
///     user: DiscoveryUser(
///       id: 'user123',
///       nickname: '用户昵称',
///       avatar: 'avatar_url',
///       createdAt: DateTime.now(),
///     ),
///     type: ContentType.text,
///     createdAt: '刚刚',
///     createdAtRaw: DateTime.now(),
///   );
/// }
/// 
/// // 4. 使用业务服务
/// void loadDiscoveryData() async {
///   final service = DiscoveryService();
///   final contents = await service.getFollowingContent(page: 1, limit: 20);
///   print('加载到 ${contents.length} 条内容');
/// }
/// 
/// // 5. 使用状态管理器
/// void monitorPublishState() {
///   final stateManager = PublishStateManager();
///   stateManager.stateStream.listen((event) {
///     print('发布状态变化: ${event.type} - ${event.status}');
///   });
/// }
/// ```

// ============== 7. ARCHITECTURE COMPLIANCE ==============
/// 🏗️ 架构规范遵循
/// 
/// 本模块严格遵循 `flutter.mdc` 中定义的架构规范：
/// 
/// **1. 单文件架构 (8-Section Structure):**
/// - 每个页面文件都采用8段式结构
/// - IMPORTS → CONSTANTS → MODELS → SERVICES → CONTROLLERS → WIDGETS → PAGES → EXPORTS
/// 
/// **2. 模块化设计 (Feature-First):**
/// - 按功能模块组织文件结构
/// - `pages/` - 页面组件
/// - `models/` - 数据模型
/// - `services/` - 业务服务
/// - `utils/` - 工具类
/// - `widgets/` - 可复用组件（预留）
/// 
/// **3. 清晰的依赖关系:**
/// - Models: 无外部依赖，纯数据结构
/// - Services: 依赖Models，提供业务逻辑
/// - Pages: 依赖Models和Services，实现UI交互
/// - Utils: 提供跨页面的共享状态管理
/// 
/// **4. 统一的导出接口:**
/// - 通过index.dart提供统一的模块接口
/// - 隐藏内部实现细节
/// - 便于其他模块集成和使用
/// 
/// **5. 响应式状态管理:**
/// - 使用ValueNotifier进行状态管理
/// - 支持跨页面的状态同步
/// - 实现了发布状态的全局监听

// ============== 8. INTEGRATION POINTS ==============
/// 🔗 集成接入点
/// 
/// 本模块与其他主要页面的集成接入点：
/// 
/// **与首页模块集成:**
/// ```dart
/// // 在首页中添加发现页面入口
/// import 'pages/discovery/index.dart';
/// 
/// // 底部导航栏集成
/// BottomNavigationBar(
///   items: [
///     BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
///     BottomNavigationBarItem(icon: Icon(Icons.explore), label: '发现'),
///     BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
///   ],
///   onTap: (index) {
///     if (index == 1) {
///       Navigator.push(context, 
///         MaterialPageRoute(builder: (context) => DiscoveryMainPage())
///       );
///     }
///   },
/// )
/// ```
/// 
/// **与用户模块集成:**
/// ```dart
/// // 在发现页面中跳转到用户详情
/// void openUserProfile(String userId) {
///   Navigator.push(context,
///     MaterialPageRoute(builder: (context) => UserProfilePage(userId: userId))
///   );
/// }
/// ```
/// 
/// **与消息模块集成:**
/// ```dart
/// // 评论和互动消息推送
/// void handleCommentNotification(String contentId) {
///   Navigator.push(context,
///     MaterialPageRoute(builder: (context) => ContentDetailPage(contentId: contentId))
///   );
/// }
/// ```

/// 📝 版本信息
/// 
/// - 模块版本: 1.0.0
/// - 创建时间: 2024年
/// - 最后更新: 2024年
/// - 架构标准: flutter.mdc v1.0
/// - 兼容性: Flutter 3.0+, Dart 3.0+