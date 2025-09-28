// 🧩 首页组件统一导出文件
// 集中管理所有首页相关的UI组件导出

// 通用组件
export 'common/countdown_widget.dart';
export 'common/loading_states.dart';

// 首页专用组件
export 'top_navigation_widget.dart';
export 'category_grid_widget.dart';
export 'recommendation_card_widget.dart';
export 'user_card_widget.dart';
export 'game_banner_widget.dart';
export 'team_up_banner_widget.dart';
export 'nearby_tabs_widget.dart';

/// 首页组件库
/// 
/// 包含的组件：
/// - CountdownWidget: 倒计时组件
/// - LoadingStates: 加载状态组件集合
/// - TopNavigationWidget: 顶部导航区域组件
/// - CategoryGridWidget: 分类网格组件
/// - RecommendationCardWidget: 推荐卡片组件
/// - UserCardWidget: 用户卡片组件
/// - GameBannerWidget: 游戏推广横幅组件
/// - TeamUpBannerWidget: 组队聚会横幅组件
/// - NearbyTabsWidget: 附近标签组件
/// 
/// 使用方式：
/// ```dart
/// import '../widgets/index.dart';
/// 
/// // 在页面中使用组件
/// TopNavigationWidget(
///   currentLocation: location,
///   onLocationTap: handleLocationTap,
/// )
/// ```
