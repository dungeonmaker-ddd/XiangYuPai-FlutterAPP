// 🔍 搜索模块统一导出文件
// 基于Flutter单文件架构规范的模块化设计

// ============== 数据模型导出 ==============
export 'models/search_models.dart';

// ============== 业务服务导出 ==============
export 'services/search_services.dart';

// ============== 页面文件导出 ==============
export 'pages/search_entry_page.dart';
export 'pages/search_results_page.dart';

// ============== 组件文件导出 ==============
export 'widgets/search_widgets.dart';

/// 🔍 搜索模块概览
/// 
/// 本模块提供完整的搜索功能实现，包括：
/// 
/// **核心功能**：
/// - 🔍 搜索入口：搜索输入、历史记录、搜索建议
/// - 📊 搜索结果：多维度分类展示、无限滚动
/// - 📈 搜索统计：行为追踪、点击统计
/// 
/// **数据模型**：
/// - SearchState: 搜索状态管理
/// - SearchResultData: 搜索结果数据
/// - SearchContentItem/UserItem/OrderItem/TopicItem: 各类搜索项
/// 
/// **业务服务**：
/// - SearchService: 核心搜索服务
/// - SearchAnalyticsService: 搜索统计服务
/// 
/// **页面组件**：
/// - SearchEntryPage: 搜索入口页面
/// - SearchResultsPage: 搜索结果页面
/// 
/// **使用示例**：
/// ```dart
/// import 'package:your_app/pages/search/index.dart';
/// 
/// // 跳转到搜索入口
/// Navigator.pushNamed(context, SearchEntryPage.routeName);
/// 
/// // 直接搜索并显示结果
/// Navigator.push(context, MaterialPageRoute(
///   builder: (context) => SearchResultsPage(initialKeyword: '王者荣耀'),
/// ));
/// 
/// // 使用搜索服务
/// final searchService = SearchService();
/// final results = await searchService.search(SearchRequest(keyword: '王者荣耀'));
/// ```
/// 
/// **架构特点**：
/// - ✅ 单文件8段式架构，结构清晰
/// - ✅ 完整的搜索功能实现
/// - ✅ 模块化设计，高内聚低耦合
/// - ✅ 支持多种搜索类型和结果展示
/// - ✅ 内置缓存和性能优化
/// - ✅ 完整的错误处理和用户反馈
