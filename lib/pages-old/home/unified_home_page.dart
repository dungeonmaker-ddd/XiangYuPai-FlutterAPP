// 🏠 首页统一页面 - 单文件架构完整实现（重构版）
// 基于Flutter单文件架构规范的8段式结构设计

// ============== 1. IMPORTS ==============
// Flutter核心库
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Dart核心库
import 'dart:async';
import 'dart:developer' as developer;

// 项目内部文件 - 按依赖关系排序
import 'home_models.dart';      // 数据模型
import 'home_services.dart';    // 业务服务
import 'location_picker_page.dart'; // 子页面
import 'search/index.dart';     // 搜索子模块
import 'submodules/service_system/index.dart'; // 服务系统模块
import 'submodules/team_center/index.dart'; // 组局中心模块
import 'submodules/filter_system/enhanced_location_picker_page.dart'; // 增强版区域选择页面
import 'submodules/filter_system/filter_page.dart'; // 筛选条件页面
import '../discovery/index.dart' as discovery; // 发现模块（包含发布动态页面）- 使用别名避免命名冲突

// ============== 2. CONSTANTS ==============
/// 🎨 首页私有常量（页面级别）
class _HomePageConstants {
  // 私有构造函数，防止实例化
  const _HomePageConstants._();
  
  // 页面标识
  static const String pageTitle = '首页';
  static const String routeName = '/home';
  
  // 动画时长
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration refreshDuration = Duration(seconds: 2);
  
  // 性能配置
  static const int maxUserDisplayCount = 50;
  static const double loadMoreThreshold = 200.0;
  
  // UI配置
  static const double gamebannerHeight = 160.0;
  static const double teamUpBannerHeight = 140.0;
  static const double userListHeight = 140.0;
}

// 全局常量引用：HomeConstants 在 home_models.dart 中定义

// ============== 3. MODELS ==============
/// 📋 数据模型引用
/// 主要模型定义在 home_models.dart 中：
/// - HomeConstants: 全局常量配置
/// - HomeUserModel: 用户数据模型
/// - HomeCategoryModel: 分类数据模型  
/// - HomeLocationModel: 位置数据模型
/// - HomeState: 页面状态模型
/// - LocationRegionModel: 地区模型
/// - LocationPickerState: 地区选择状态

// ============== 4. SERVICES ==============
/// 🔧 业务服务引用
/// 主要服务定义在 home_services.dart 中：
/// - HomeService: 首页数据服务
/// - _LocationService: 地区选择服务（私有）
/// 
/// 服务功能包括：
/// - 用户数据获取和管理
/// - 分类数据加载
/// - 地区数据处理
/// - API调用和错误处理

// ============== 5. CONTROLLERS ==============
/// 🧠 首页控制器
class _HomeController extends ValueNotifier<HomeState> {
  _HomeController() : super(const HomeState()) {
    _scrollController = ScrollController();
    _initialize();
  }

  late ScrollController _scrollController;
  int _currentTabIndex = 0; // 当前选中的Tab索引

  ScrollController get scrollController => _scrollController;
  int get currentTabIndex => _currentTabIndex;

  /// 初始化数据
  Future<void> _initialize() async {
    try {
      value = value.copyWith(isLoading: true, errorMessage: null);

      // 设置默认位置
      final defaultLocation = const HomeLocationModel(
        locationId: 'shenzhen',
        name: '深圳',
        isHot: true,
      );

      // 设置限时专享结束时间（当前时间+2小时）
      final promoEndTime = DateTime.now().add(const Duration(hours: 2));

      // 并发加载数据
      final results = await Future.wait([
        HomeService.getCategories(),
        HomeService.getRecommendedUsers(limit: HomeConstants.recommendedUserLimit),
        HomeService.getNearbyUsers(limit: HomeConstants.defaultPageSize),
      ]);

      value = value.copyWith(
        isLoading: false,
        currentLocation: defaultLocation,
        categories: results[0] as List<HomeCategoryModel>,
        recommendedUsers: results[1] as List<HomeUserModel>,
        nearbyUsers: results[2] as List<HomeUserModel>,
        promoEndTime: promoEndTime,
      );

      // 设置滚动监听
      _scrollController.addListener(_onScroll);
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: '加载失败，请重试',
      );
      developer.log('首页初始化失败: $e');
    }
  }

  /// 滚动监听
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - _HomePageConstants.loadMoreThreshold) {
      loadMoreUsers();
    }
  }

  /// 加载更多用户
  Future<void> loadMoreUsers() async {
    if (value.isLoadingMore || !value.hasMoreData) return;

    try {
      value = value.copyWith(isLoadingMore: true);

      final moreUsers = await HomeService.getNearbyUsers(
        page: value.currentPage + 1,
        limit: HomeConstants.defaultPageSize,
      );

      if (moreUsers.isNotEmpty) {
        final updatedUsers = List<HomeUserModel>.from(value.nearbyUsers)
          ..addAll(moreUsers);
        
        value = value.copyWith(
          isLoadingMore: false,
          nearbyUsers: updatedUsers,
          currentPage: value.currentPage + 1,
        );
      } else {
        value = value.copyWith(
          isLoadingMore: false,
          hasMoreData: false,
        );
      }
    } catch (e) {
      value = value.copyWith(isLoadingMore: false);
      developer.log('加载更多用户失败: $e');
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    value = value.copyWith(
      currentPage: 1,
      hasMoreData: true,
    );
    await _initialize();
  }

  /// 搜索
  void search(String keyword) {
    if (keyword.trim().isEmpty) {
      developer.log('搜索关键词为空，忽略搜索请求');
      return;
    }
    
    developer.log('首页触发搜索: $keyword');
    
    // 保存搜索历史（异步执行，不阻塞UI）
    SearchService().saveSearchHistory(keyword.trim()).catchError((e) {
      developer.log('保存搜索历史失败: $e');
    });
    
    // 触发搜索事件通知（如果需要的话）
    _notifySearchEvent(keyword.trim());
  }
  
  /// 通知搜索事件
  void _notifySearchEvent(String keyword) {
    // 可以在这里添加搜索事件的统计或其他逻辑
    developer.log('搜索事件已记录: $keyword');
  }
  
  /// 跳转到搜索入口页面
  void openSearchEntry() {
    developer.log('打开搜索入口页面');
    // 这个方法将在页面中调用Navigator
  }
  
  /// 直接跳转到搜索结果页面
  void openSearchResults(String keyword) {
    if (keyword.trim().isEmpty) return;
    
    developer.log('直接打开搜索结果页面: $keyword');
    // 保存搜索历史
    SearchService().saveSearchHistory(keyword.trim()).catchError((e) {
      developer.log('保存搜索历史失败: $e');
    });
  }

  /// 选择分类
  void selectCategory(HomeCategoryModel category) {
    developer.log('选择分类: ${category.name}');
    
    // 将分类名称作为搜索关键词，跳转到搜索结果页面
    // 这样可以展示该分类相关的所有内容
    final keyword = category.name;
    
    // 保存搜索历史
    SearchService().saveSearchHistory(keyword).catchError((e) {
      developer.log('保存搜索历史失败: $e');
    });
    
    // 通知搜索事件
    _notifySearchEvent('分类:$keyword');
  }

  /// 选择用户
  void selectUser(HomeUserModel user) {
    // TODO: 跳转到用户详情页面
    developer.log('选择用户: ${user.nickname}');
  }

  /// 更改位置
  void changeLocation(HomeLocationModel location) {
    value = value.copyWith(currentLocation: location);
    refresh(); // 位置变更后刷新数据
  }

  /// 切换筛选标签
  void switchTab(String tabName) {
    if (value.selectedTab != tabName) {
      value = value.copyWith(selectedTab: tabName);
      // TODO: 根据不同标签加载不同数据
      developer.log('切换到标签: $tabName');
    }
  }

  /// 更新选中的区域
  void updateSelectedRegion(String region) {
    value = value.copyWith(selectedRegion: region);
    refresh(); // 区域变更后刷新数据
    developer.log('更新区域: $region');
  }

  /// 应用筛选条件
  void applyFilters(Map<String, dynamic> filters) {
    value = value.copyWith(activeFilters: filters);
    refresh(); // 筛选条件变更后刷新数据
    developer.log('应用筛选条件: $filters');
  }

  /// 清除筛选条件
  void clearFilters() {
    value = value.copyWith(
      activeFilters: null,
      selectedRegion: null,
    );
    refresh(); // 清除筛选后刷新数据
    developer.log('清除筛选条件');
  }

  /// 切换底部Tab
  void switchBottomTab(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      developer.log('切换底部Tab: $index');
      // 这里可以根据需要通知状态变化
      // notifyListeners(); // 如果需要UI更新的话
    }
  }

  /// 获取当前筛选状态摘要
  String getFilterSummary() {
    final filters = value.activeFilters;
    final region = value.selectedRegion;

    List<String> summaryParts = [];

    if (region != null && region != '全深圳') {
      summaryParts.add('区域: $region');
    }

    if (filters != null && filters.isNotEmpty) {
      summaryParts.add('筛选: ${filters.length}项');
    }

    return summaryParts.isEmpty ? '无筛选' : summaryParts.join(' | ');
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
}

// ============== 6. WIDGETS ==============
/// 🧩 UI组件定义
/// 
/// 本段包含首页专用的UI组件：
/// - _CountdownWidget: 倒计时显示组件
/// - _SearchBarWidget: 搜索栏组件
/// - _CategoryGridWidget: 分类网格组件  
/// - _RecommendationCardWidget: 推荐卡片组件
/// - _UserCardWidget: 用户卡片组件
///
/// 设计原则：
/// - 组件职责单一，高内聚低耦合
/// - 支持自定义配置和回调
/// - 遵循Material Design规范
/// - 优化性能，减少不必要的重建

/// ⏰ 倒计时组件
/// 
/// 功能：显示距离指定时间的剩余时长
/// 用途：限时专享活动的倒计时显示
/// 特性：自动更新、格式化显示、到期处理
class _CountdownWidget extends StatefulWidget {
  final DateTime endTime;
  final TextStyle? textStyle;

  const _CountdownWidget({
    required this.endTime,
    this.textStyle,
  });

  @override
  State<_CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<_CountdownWidget> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final remaining = widget.endTime.difference(now);
    if (remaining.isNegative) {
      _remaining = Duration.zero;
      _timer.cancel();
    } else {
      _remaining = remaining;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining == Duration.zero) {
      return Text('已结束', style: widget.textStyle);
    }

    final hours = _remaining.inHours.toString().padLeft(2, '0');
    final minutes = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Text(
      '$hours:$minutes:$seconds',
      style: widget.textStyle,
    );
  }
}

/// 🔝 顶部导航区域组件（渐变紫色背景）
class _TopNavigationWidget extends StatefulWidget {
  final String? currentLocation;
  final VoidCallback? onLocationTap;
  final ValueChanged<String>? onSearchSubmitted;

  const _TopNavigationWidget({
    this.currentLocation,
    this.onLocationTap,
    this.onSearchSubmitted,
  });

  @override
  State<_TopNavigationWidget> createState() => _TopNavigationWidgetState();
}

class _TopNavigationWidgetState extends State<_TopNavigationWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
      // 渐变紫色背景 #8B5CF6 → #A855F7
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  // 位置和搜索栏（2:8比例布局）
                  Row(
                    children: [
                      // 左侧位置显示（2份）
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: widget.onLocationTap,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.currentLocation ?? HomeConstants.defaultLocationText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // 右侧搜索框（8份）
                      Expanded(
                        flex: 8,
                        child: GestureDetector(
                          onTap: () => _navigateToSearchPage(),
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.search,
                                  color: Color(0xFF9CA3AF),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '搜索词',
                                    style: const TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 搜索功能已移至专用搜索页面
          ],
        ),
      ),
    );
  }

  /// 跳转到搜索页面
  void _navigateToSearchPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchEntryPage(),
      ),
    );
  }
}

/// 🏷️ 分类网格组件
class _CategoryGridWidget extends StatelessWidget {
  final List<HomeCategoryModel> categories;
  final ValueChanged<HomeCategoryModel>? onCategoryTap;

  const _CategoryGridWidget({
    required this.categories,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: HomeConstants.categoryGridColumns,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 8,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () => onCategoryTap?.call(category),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color(category.color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Color(category.color).withOpacity(0.12),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    category.icon,
                    color: Color(category.color),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 💝 推荐卡片组件
class _RecommendationCardWidget extends StatelessWidget {
  final List<HomeUserModel> users;
  final String title;
  final DateTime? promoEndTime;
  final ValueChanged<HomeUserModel>? onUserTap;

  const _RecommendationCardWidget({
    required this.users,
    required this.title,
    this.promoEndTime,
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和标签
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8A65),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '优质陪玩',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  '更多',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 16,
                ),
              ],
            ),
          ),

          // 用户列表
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(0, 12, 16, 12),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return GestureDetector(
                  onTap: () => onUserTap?.call(user),
                  child: Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 三级父容器结构 - 垂直布局
                        // 第一级：最外层容器
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 第二级：中间容器
                              Container(
                                padding: const EdgeInsets.all(4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 第三级：内层容器 - 头像区域
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      child: Stack(
                                        children: [
                                          // 主头像容器 - 125x125
                                          Container(
                                            width: 125,
                                            height: 125,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.15),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Color(0xFFB39DDB),
                                                      Color(0xFF9C88D4),
                                                    ],
                                                  ),
                                                ),
                                                child: Stack(
                                                  fit: StackFit.expand,
                                                  children: [
                                                    // 模拟人物照片的渐变背景
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        gradient: RadialGradient(
                                                          center: const Alignment(0.3, -0.4),
                                                          radius: 0.8,
                                                          colors: [
                                                            const Color(0xFFE1BEE7).withOpacity(0.8),
                                                            const Color(0xFF9C88D4).withOpacity(0.9),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    // 人物轮廓
                                                    const Positioned(
                                                      bottom: 0,
                                                      left: 0,
                                                      right: 0,
                                                      child: Icon(
                                                        Icons.person,
                                                        color: Colors.white,
                                                        size: 70,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          // 底部标签 - 精确定位
                                          Positioned(
                                            bottom: 10,
                                            left: 6,
                                            right: 6,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.8),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                index % 3 == 0 ? '近期89人下单' : index % 3 == 1 ? '距离你最近' : '近期88',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 8),
                                    
                                    // 文字信息在头像下方 - 左对齐
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 昵称
                                        Text(
                                          '用户123',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          textAlign: TextAlign.left,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        
                                        const SizedBox(height: 4),
                                        
                                        // 地区标签
                                        Text(
                                          '微信区 荣耀王者',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          textAlign: TextAlign.left,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 👤 用户卡片组件
class _UserCardWidget extends StatelessWidget {
  final HomeUserModel user;
  final VoidCallback? onTap;

  const _UserCardWidget({
    required this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(HomeConstants.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 头像
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 30),
                ),
                if (user.isOnline)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // 用户信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user.nickname,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (user.isVerified)
                        const Icon(Icons.verified, color: Colors.blue, size: 16),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  if (user.age != null)
                    Text(
                      '${user.age}岁 ${user.genderText}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  
                  if (user.bio != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.bio!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // 标签
                  if (user.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: user.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(HomeConstants.primaryPurple).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(HomeConstants.primaryPurple),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            // 距离和最后活跃时间
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (user.distance != null)
                  Text(
                    user.distanceText,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  user.lastActiveText,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============== 7. PAGES ==============
/// 📱 页面定义
/// 
/// 本段包含主要的页面类：
/// - UnifiedHomePage: 首页主页面类
/// - _UnifiedHomePageState: 首页状态管理类
///
/// 页面功能：
/// - 多模块聚合展示（搜索、分类、推荐、用户列表）
/// - 响应式布局和交互
/// - 状态管理和生命周期处理
/// - 路由跳转和参数传递
///
/// 技术特性：
/// - 基于ValueNotifier的状态管理
/// - CustomScrollView实现复杂滚动布局
/// - RefreshIndicator支持下拉刷新
/// - 无限滚动加载更多数据

/// 🏠 统一首页
/// 
/// 应用主入口页面，聚合展示各功能模块
/// 包含：搜索、分类、推荐、用户列表等核心功能
class UnifiedHomePage extends StatefulWidget {
  const UnifiedHomePage({super.key});

  @override
  State<UnifiedHomePage> createState() => _UnifiedHomePageState();
}

/// 🏠 统一首页（无底部导航版本）
/// 
/// 用于MainTabPage中的IndexedStack，移除了内部的底部导航栏
/// 避免与主Tab页面的底部导航冲突
class UnifiedHomePageWithoutBottomNav extends StatefulWidget {
  const UnifiedHomePageWithoutBottomNav({super.key});

  @override
  State<UnifiedHomePageWithoutBottomNav> createState() => _UnifiedHomePageWithoutBottomNavState();
}

class _UnifiedHomePageState extends State<UnifiedHomePage> {
  late final _HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _HomeController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 设置状态栏样式（适配渐变紫色背景）
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 透明状态栏
      statusBarIconBrightness: Brightness.light, // 白色图标（适配紫色背景）
      statusBarBrightness: Brightness.dark, // iOS状态栏暗色模式
    ));
    
    return Scaffold(
      backgroundColor: const Color(HomeConstants.homeBackgroundColor),
      body: ValueListenableBuilder<HomeState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          if (state.isLoading && state.nearbyUsers.isEmpty) {
            return _buildLoadingView();
          }

          if (state.errorMessage != null && state.nearbyUsers.isEmpty) {
            return _buildErrorView(state.errorMessage!);
          }

          return _buildMainContent(state);
        },
      ),
      // 底部Tab导航栏
      bottomNavigationBar: _buildBottomNavigationBar(),
      // 发布动态浮动按钮
      floatingActionButton: FloatingActionButton(
        onPressed: _handlePublishContent,
        backgroundColor: const Color(HomeConstants.primaryPurple),
        foregroundColor: Colors.white,
        elevation: 6,
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// 构建加载视图
  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(HomeConstants.primaryPurple)),
      ),
    );
  }

  /// 构建错误视图
  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(errorMessage, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _controller.refresh(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(HomeConstants.primaryPurple),
              foregroundColor: Colors.white,
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  /// 构建主要内容
  Widget _buildMainContent(HomeState state) {
    return RefreshIndicator(
      color: const Color(HomeConstants.primaryPurple),
      onRefresh: _controller.refresh,
      child: CustomScrollView(
        controller: _controller.scrollController,
        slivers: [
          // 顶部导航区域（渐变紫色背景）
          SliverToBoxAdapter(
            child: _TopNavigationWidget(
              currentLocation: state.currentLocation?.name,
              onLocationTap: _handleLocationTap,
              onSearchSubmitted: null, // 搜索功能已移至专用搜索页面
            ),
          ),

          // 游戏推广横幅 (作为poster在功能服务网格上方)
          SliverToBoxAdapter(child: _buildGameBanner()),

          // 功能服务网格
          if (state.categories.isNotEmpty)
            SliverToBoxAdapter(
              child: _CategoryGridWidget(
                categories: state.categories,
                onCategoryTap: _handleCategoryTap,
              ),
            ),

          // 限时专享区域（紧跟功能服务区下方）
          SliverToBoxAdapter(
            child: _RecommendationCardWidget(
              users: state.recommendedUsers,
              title: '限时专享',
              promoEndTime: state.promoEndTime,
              onUserTap: _controller.selectUser,
            ),
          ),

          // 组队聚会横幅
          SliverToBoxAdapter(child: _buildTeamUpBanner()),

          // 附近/推荐标签
          SliverToBoxAdapter(child: _buildNearbyTabs(state)),

          // 附近用户列表
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < state.nearbyUsers.length) {
                  return _UserCardWidget(
                    user: state.nearbyUsers[index],
                    onTap: () => _controller.selectUser(state.nearbyUsers[index]),
                  );
                } else if (state.isLoadingMore) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(HomeConstants.primaryPurple)),
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
              childCount: state.nearbyUsers.length + (state.isLoadingMore ? 1 : 0),
            ),
          ),

          // 底部占位
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  /// 处理搜索栏点击 - 跳转到搜索入口页面
  void _handleSearchBarTap() {
    developer.log('首页: 点击搜索栏，跳转到搜索入口页面');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchEntryPage(),
      ),
    );
  }
  
  /// 处理搜索提交 - 直接跳转到搜索结果页面
  void _handleSearchSubmit(String keyword) {
    if (keyword.trim().isEmpty) return;
    
    developer.log('首页: 搜索提交，关键词: $keyword');
    
    // 调用控制器的搜索方法（保存历史等）
    _controller.search(keyword);
    
    // 跳转到搜索结果页面
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsPage(initialKeyword: keyword.trim()),
      ),
    );
  }
  
  /// 处理分类点击 - 跳转到对应服务页面
  void _handleCategoryTap(HomeCategoryModel category) {
    developer.log('首页: 点击分类，名称: ${category.name}');
    
    // 调用控制器的分类选择方法（保存历史等）
    _controller.selectCategory(category);
    
    // 根据分类名称映射到服务类型和具体服务
    final serviceMapping = _getServiceMapping(category.name);
    
    if (serviceMapping != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServiceFilterPage(
            serviceType: serviceMapping['serviceType'],
            serviceName: serviceMapping['serviceName'],
          ),
        ),
      );
    } else {
      // 默认跳转到搜索结果页面
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsPage(initialKeyword: category.name),
        ),
      );
    }
  }

  /// 获取服务映射 - 将分类名称映射到服务类型
  Map<String, dynamic>? _getServiceMapping(String categoryName) {
    switch (categoryName) {
      // 游戏服务
      case '王者荣耀':
        return {
          'serviceType': ServiceType.game,
          'serviceName': '王者荣耀陪练',
        };
      case '英雄联盟':
        return {
          'serviceType': ServiceType.game,
          'serviceName': '英雄联盟陪练',
        };
      case '和平精英':
        return {
          'serviceType': ServiceType.game,
          'serviceName': '和平精英陪练',
        };
      case '荒野乱斗':
        return {
          'serviceType': ServiceType.game,
          'serviceName': '荒野乱斗陪练',
        };
        
      // 娱乐服务
      case 'K歌':
        return {
          'serviceType': ServiceType.entertainment,
          'serviceName': 'K歌服务',
        };
      case '台球':
        return {
          'serviceType': ServiceType.entertainment,
          'serviceName': '台球服务',
        };
      case '私影':
        return {
          'serviceType': ServiceType.entertainment,
          'serviceName': '私影服务',
        };
      case '按摩':
        return {
          'serviceType': ServiceType.lifestyle,
          'serviceName': '按摩服务',
        };
      case '喝酒':
        return {
          'serviceType': ServiceType.entertainment,
          'serviceName': '喝酒陪伴',
        };
        
      // 生活服务  
      case '探店':
        return {
          'serviceType': ServiceType.lifestyle,
          'serviceName': '探店服务',
        };
        
      default:
        return null; // 不支持的分类，使用默认搜索
    }
  }
  
  /// 处理位置点击
  void _handleLocationTap() async {
    final result = await Navigator.push<LocationRegionModel>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerPage(
          currentLocation: _convertToLocationRegion(_controller.value.currentLocation),
          onLocationSelected: (location) {
            final homeLocation = HomeLocationModel(
              locationId: location.regionId,
              name: location.name,
              isHot: location.isHot,
            );
            _controller.changeLocation(homeLocation);
          },
        ),
      ),
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已切换到${result.name}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// 处理组局中心跳转
  void _handleTeamCenterTap() {
    developer.log('首页: 点击进入组局中心');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TeamCenterMainPage(),
      ),
    );
  }

  /// 转换位置模型
  LocationRegionModel? _convertToLocationRegion(HomeLocationModel? homeLocation) {
    if (homeLocation == null) return null;
    
    return LocationRegionModel(
      regionId: homeLocation.locationId,
      name: homeLocation.name,
      pinyin: homeLocation.name.toLowerCase(),
      firstLetter: homeLocation.name.isNotEmpty ? homeLocation.name[0].toUpperCase() : 'A',
      isHot: homeLocation.isHot,
      isCurrent: true,
    );
  }

  /// 构建游戏推广横幅
  Widget _buildGameBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // 背景纹理（模拟游戏场景）
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            
            // 左侧文案区域
            Positioned(
              left: 24,
              top: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 游戏信息标签
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '制霸信条·刺客里程',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // 主标题
                  const Text(
                    'FIGHTING LIKE A DEVIL DRESSED AS A MAN',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // 中文标语
                  const Text(
                    '"迎亲首友 已月玩真畅爽"',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // 右侧角色展示区域（模拟游戏角色）
            Positioned(
              right: 20,
              top: 20,
              bottom: 20,
              child: Container(
                width: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 角色头像
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '角色',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建组队聚会横幅
  Widget _buildTeamUpBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 16, 4, 12),
            child: Text(
              '组队聚会',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          
          // 组局中心卡片
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // 背景装饰
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  
                  // 左侧文字内容
                  const Positioned(
                    left: 24,
                    top: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '组局中心',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '找到志同道合的伙伴',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 右上角用户数量
                  const Positioned(
                    right: 20,
                    top: 20,
                    child: Text(
                      '+12',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  // 底部按钮和头像
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 进入组局按钮
                        GestureDetector(
                          onTap: _handleTeamCenterTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.groups, color: Color(0xFF6366F1), size: 16),
                                SizedBox(width: 6),
                                Text(
                                  '进入组局',
                                  style: TextStyle(
                                    color: Color(0xFF6366F1),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // 用户头像列表
                        Row(
                          children: List.generate(4, (index) {
                            return Container(
                              margin: EdgeInsets.only(left: index > 0 ? 4 : 0),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: _getAvatarColor(index),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.person, color: Colors.white, size: 14),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取头像颜色
  Color _getAvatarColor(int index) {
    final colors = [Colors.red, Colors.green, Colors.blue, Colors.orange];
    return colors[index % colors.length];
  }

  /// 构建附近/推荐标签
  Widget _buildNearbyTabs(HomeState state) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(HomeConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabItem('附近', isSelected: state.selectedTab == '附近', onTap: () => _controller.switchTab('附近')),
                _buildTabItem('推荐', isSelected: state.selectedTab == '推荐', onTap: () => _controller.switchTab('推荐')),
                _buildTabItem('最新', isSelected: state.selectedTab == '最新', onTap: () => _controller.switchTab('最新')),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 清除筛选按钮（仅在有筛选条件时显示）
                if (state.selectedRegion != null || state.activeFilters?.isNotEmpty == true)
                  GestureDetector(
                    onTap: _clearAllFilters,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[300]!, width: 1),
                      ),
                      child: Icon(
                        Icons.clear,
                        size: 12,
                        color: Colors.red[600],
                      ),
                    ),
                  ),
                if (state.selectedRegion != null || state.activeFilters?.isNotEmpty == true)
                  const SizedBox(width: 4),
                Flexible(
                  child: _buildDropdownFilter(
                    state.selectedRegion ?? '区域',
                    Icons.location_on,
                    onTap: _showLocationFilter,
                    isActive: state.selectedRegion != null,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: _buildDropdownFilter(
                    state.activeFilters?.isNotEmpty == true ? '筛选(${state.activeFilters!.length})' : '筛选',
                    Icons.filter_list,
                    onTap: _showMoreFilters,
                    isActive: state.activeFilters?.isNotEmpty == true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建标签项
  Widget _buildTabItem(String text, {required bool isSelected, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(HomeConstants.primaryPurple) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// 构建下拉筛选器
  Widget _buildDropdownFilter(String text, IconData icon, {VoidCallback? onTap, bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF8B5CF6).withValues(alpha: 0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: isActive ? Border.all(color: const Color(0xFF8B5CF6), width: 1) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: isActive ? const Color(0xFF8B5CF6) : Colors.grey[600],
            ),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: isActive ? const Color(0xFF8B5CF6) : Colors.grey[600],
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 1),
            Icon(
              Icons.keyboard_arrow_down,
              size: 12,
              color: isActive ? const Color(0xFF8B5CF6) : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  /// 显示位置筛选
  void _showLocationFilter() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const EnhancedLocationPickerPage(),
      ),
    );

    if (result != null) {
      // 更新控制器中的选中区域
      _controller.updateSelectedRegion(result);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已选择区域：$result')),
      );
    }
  }

  /// 显示更多筛选
  void _showMoreFilters() async {
    final result = await Navigator.push<FilterCriteria>(
      context,
      MaterialPageRoute(
        builder: (context) => const FilterPage(),
      ),
    );

    if (result != null) {
      // 将筛选条件转换为Map并应用到控制器
      final filterMap = _convertFilterCriteriaToMap(result);
      _controller.applyFilters(filterMap);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('筛选条件已应用')),
      );

      _applyFilterCriteria(result);
    }
  }

  /// 应用筛选条件
  void _applyFilterCriteria(FilterCriteria criteria) {
    // 这里可以将筛选条件传递给控制器
    // _controller.applyFilter(criteria);

    // 显示筛选条件摘要
    final summary = _buildFilterSummary(criteria);
    if (summary.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已应用筛选：$summary'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 构建筛选条件摘要
  String _buildFilterSummary(FilterCriteria criteria) {
    List<String> summaryParts = [];

    // 年龄范围
    if (criteria.ageRange.start > 18 || criteria.ageRange.end < 99) {
      summaryParts.add('年龄${criteria.ageRange.start.round()}-${criteria.ageRange.end.round()}岁');
    }

    // 性别
    if (criteria.gender != '全部') {
      summaryParts.add('性别${criteria.gender}');
    }

    // 状态
    if (criteria.status != '在线') {
      summaryParts.add('状态${criteria.status}');
    }

    // 类型
    if (criteria.type != '线上') {
      summaryParts.add('类型${criteria.type}');
    }

    // 技能
    if (criteria.skills.isNotEmpty) {
      summaryParts.add('技能${criteria.skills.length}项');
    }

    // 价格
    if (criteria.price.isNotEmpty) {
      summaryParts.add('价格${criteria.price}');
    }

    // 位置
    if (criteria.positions.isNotEmpty) {
      summaryParts.add('位置${criteria.positions.length}项');
    }

    // 标签
    if (criteria.tags.isNotEmpty) {
      summaryParts.add('标签${criteria.tags.length}项');
    }

    return summaryParts.join('、');
  }

  /// 将FilterCriteria转换为Map
  Map<String, dynamic> _convertFilterCriteriaToMap(FilterCriteria criteria) {
    return {
      'ageRange': {
        'start': criteria.ageRange.start,
        'end': criteria.ageRange.end,
      },
      'gender': criteria.gender,
      'status': criteria.status,
      'type': criteria.type,
      'skills': criteria.skills,
      'price': criteria.price,
      'positions': criteria.positions,
      'tags': criteria.tags,
    };
  }

  /// 清除所有筛选条件
  void _clearAllFilters() {
    _controller.clearFilters();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已清除所有筛选条件')),
    );
  }

  /// 处理发布动态按钮点击
  void _handlePublishContent() async {
    developer.log('首页: 点击发布动态按钮');
    
    try {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => const discovery.PublishContentPage(),
          // 全屏模态展示，从底部滑入
          fullscreenDialog: true,
        ),
      );
      
      // 如果发布成功，显示提示并刷新首页数据
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 发布成功！'),
            backgroundColor: Color(HomeConstants.primaryPurple),
            duration: Duration(seconds: 2),
          ),
        );
        
        // 刷新首页数据以显示最新内容
        _controller.refresh();
      }
    } catch (e) {
      developer.log('打开发布动态页面失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('打开发布页面失败，请重试'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 显示敬请期待对话框
  void _showComingSoonDialog(String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('敬请期待'),
        content: Text('$featureName正在开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 构建底部导航栏
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _buildBottomTabItem(0, Icons.home, '首页'),
              _buildBottomTabItem(1, Icons.explore, '发现'),
              _buildBottomTabItem(2, Icons.message, '消息'),
              _buildBottomTabItem(3, Icons.person, '我的'),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建底部Tab项
  Widget _buildBottomTabItem(int index, IconData icon, String label) {
    final isSelected = _controller.currentTabIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _handleTabTap(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected 
                    ? const Color(HomeConstants.primaryPurple) 
                    : Colors.grey[600],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected 
                      ? const Color(HomeConstants.primaryPurple) 
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 处理Tab点击
  void _handleTabTap(int index) {
    if (index == _controller.currentTabIndex) {
      // 如果点击的是当前Tab，可以执行刷新或回到顶部等操作
      if (index == 0) {
        // 首页Tab：滚动到顶部
        _controller.scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      return;
    }

    // 切换Tab
    _controller.switchBottomTab(index);
    
    // 根据Tab索引进行页面跳转
    switch (index) {
      case 0:
        // 首页 - 当前页面，无需跳转
        break;
      case 1:
        // 发现页面
        _navigateToDiscovery();
        break;
      case 2:
        // 消息页面
        _navigateToMessages();
        break;
      case 3:
        // 我的页面
        _navigateToProfile();
        break;
    }
  }

  /// 跳转到发现页面
  void _navigateToDiscovery() {
    developer.log('导航到发现页面');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const discovery.DiscoveryMainPage(),
      ),
    ).then((_) {
      // 返回时重置Tab状态
      _controller.switchBottomTab(0);
    });
  }

  /// 跳转到消息页面
  void _navigateToMessages() {
    developer.log('导航到消息页面');
    _showComingSoonDialog('消息功能');
    // 重置Tab状态
    _controller.switchBottomTab(0);
  }

  /// 跳转到个人中心页面
  void _navigateToProfile() {
    developer.log('导航到个人中心页面');
    _showComingSoonDialog('个人中心');
    // 重置Tab状态
    _controller.switchBottomTab(0);
  }
}

/// 🏠 统一首页（无底部导航版本）的状态管理类
class _UnifiedHomePageWithoutBottomNavState extends State<UnifiedHomePageWithoutBottomNav> {
  late final _HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _HomeController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 设置状态栏样式（适配渐变紫色背景）
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 透明状态栏
      statusBarIconBrightness: Brightness.light, // 白色图标（适配紫色背景）
      statusBarBrightness: Brightness.dark, // iOS状态栏暗色模式
    ));
    
    return Scaffold(
      backgroundColor: const Color(HomeConstants.homeBackgroundColor),
      body: ValueListenableBuilder<HomeState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          if (state.isLoading && state.nearbyUsers.isEmpty) {
            return _buildLoadingView();
          }

          if (state.errorMessage != null && state.nearbyUsers.isEmpty) {
            return _buildErrorView(state.errorMessage!);
          }

          return _buildMainContent(state);
        },
      ),
      // 注意：这里没有bottomNavigationBar和floatingActionButton
      // 它们由MainTabPage统一管理
    );
  }

  /// 构建加载视图
  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(HomeConstants.primaryPurple)),
      ),
    );
  }

  /// 构建错误视图
  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(errorMessage, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _controller.refresh(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(HomeConstants.primaryPurple),
              foregroundColor: Colors.white,
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  /// 构建主要内容
  Widget _buildMainContent(HomeState state) {
    return RefreshIndicator(
      color: const Color(HomeConstants.primaryPurple),
      onRefresh: _controller.refresh,
      child: CustomScrollView(
        controller: _controller.scrollController,
        slivers: [
          // 顶部导航区域（渐变紫色背景）
          SliverToBoxAdapter(
            child: _TopNavigationWidget(
              currentLocation: state.currentLocation?.name,
              onLocationTap: _handleLocationTap,
              onSearchSubmitted: null, // 搜索功能已移至专用搜索页面
            ),
          ),

          // 游戏推广横幅 (作为poster在功能服务网格上方)
          SliverToBoxAdapter(child: _buildGameBanner()),

          // 功能服务网格
          if (state.categories.isNotEmpty)
            SliverToBoxAdapter(
              child: _CategoryGridWidget(
                categories: state.categories,
                onCategoryTap: _handleCategoryTap,
              ),
            ),

          // 限时专享区域（紧跟功能服务区下方）
          SliverToBoxAdapter(
            child: _RecommendationCardWidget(
              users: state.recommendedUsers,
              title: '限时专享',
              promoEndTime: state.promoEndTime,
              onUserTap: _controller.selectUser,
            ),
          ),

          // 组队聚会横幅
          SliverToBoxAdapter(child: _buildTeamUpBanner()),

          // 附近/推荐标签
          SliverToBoxAdapter(child: _buildNearbyTabs(state)),

          // 附近用户列表
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < state.nearbyUsers.length) {
                  return _UserCardWidget(
                    user: state.nearbyUsers[index],
                    onTap: () => _controller.selectUser(state.nearbyUsers[index]),
                  );
                } else if (state.isLoadingMore) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(HomeConstants.primaryPurple)),
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
              childCount: state.nearbyUsers.length + (state.isLoadingMore ? 1 : 0),
            ),
          ),

          // 底部占位（为MainTabPage的底部导航留出空间）
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // 复用原有的所有辅助方法
  void _handleLocationTap() async {
    final result = await Navigator.push<LocationRegionModel>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerPage(
          currentLocation: _convertToLocationRegion(_controller.value.currentLocation),
          onLocationSelected: (location) {
            final homeLocation = HomeLocationModel(
              locationId: location.regionId,
              name: location.name,
              isHot: location.isHot,
            );
            _controller.changeLocation(homeLocation);
          },
        ),
      ),
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已切换到${result.name}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleCategoryTap(HomeCategoryModel category) {
    developer.log('首页: 点击分类，名称: ${category.name}');
    
    _controller.selectCategory(category);
    
    final serviceMapping = _getServiceMapping(category.name);
    
    if (serviceMapping != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServiceFilterPage(
            serviceType: serviceMapping['serviceType'],
            serviceName: serviceMapping['serviceName'],
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsPage(initialKeyword: category.name),
        ),
      );
    }
  }

  Map<String, dynamic>? _getServiceMapping(String categoryName) {
    switch (categoryName) {
      case '王者荣耀':
        return {
          'serviceType': ServiceType.game,
          'serviceName': '王者荣耀陪练',
        };
      case '英雄联盟':
        return {
          'serviceType': ServiceType.game,
          'serviceName': '英雄联盟陪练',
        };
      case '和平精英':
        return {
          'serviceType': ServiceType.game,
          'serviceName': '和平精英陪练',
        };
      case '荒野乱斗':
        return {
          'serviceType': ServiceType.game,
          'serviceName': '荒野乱斗陪练',
        };
      case 'K歌':
        return {
          'serviceType': ServiceType.entertainment,
          'serviceName': 'K歌服务',
        };
      case '台球':
        return {
          'serviceType': ServiceType.entertainment,
          'serviceName': '台球服务',
        };
      case '私影':
        return {
          'serviceType': ServiceType.entertainment,
          'serviceName': '私影服务',
        };
      case '按摩':
        return {
          'serviceType': ServiceType.lifestyle,
          'serviceName': '按摩服务',
        };
      case '喝酒':
        return {
          'serviceType': ServiceType.entertainment,
          'serviceName': '喝酒陪伴',
        };
      case '探店':
        return {
          'serviceType': ServiceType.lifestyle,
          'serviceName': '探店服务',
        };
      default:
        return null;
    }
  }

  LocationRegionModel? _convertToLocationRegion(HomeLocationModel? homeLocation) {
    if (homeLocation == null) return null;
    
    return LocationRegionModel(
      regionId: homeLocation.locationId,
      name: homeLocation.name,
      pinyin: homeLocation.name.toLowerCase(),
      firstLetter: homeLocation.name.isNotEmpty ? homeLocation.name[0].toUpperCase() : 'A',
      isHot: homeLocation.isHot,
      isCurrent: true,
    );
  }

  Widget _buildGameBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            
            Positioned(
              left: 24,
              top: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '制霸信条·刺客里程',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  const Text(
                    'FIGHTING LIKE A DEVIL DRESSED AS A MAN',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  const Text(
                    '"迎亲首友 已月玩真畅爽"',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Positioned(
              right: 20,
              top: 20,
              bottom: 20,
              child: Container(
                width: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '角色',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamUpBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 16, 4, 12),
            child: Text(
              '组队聚会',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  
                  const Positioned(
                    left: 24,
                    top: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '组局中心',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '找到志同道合的伙伴',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Positioned(
                    right: 20,
                    top: 20,
                    child: Text(
                      '+12',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: _handleTeamCenterTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.groups, color: Color(0xFF6366F1), size: 16),
                                SizedBox(width: 6),
                                Text(
                                  '进入组局',
                                  style: TextStyle(
                                    color: Color(0xFF6366F1),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        Row(
                          children: List.generate(4, (index) {
                            return Container(
                              margin: EdgeInsets.only(left: index > 0 ? 4 : 0),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: _getAvatarColor(index),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.person, color: Colors.white, size: 14),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAvatarColor(int index) {
    final colors = [Colors.red, Colors.green, Colors.blue, Colors.orange];
    return colors[index % colors.length];
  }

  void _handleTeamCenterTap() {
    developer.log('首页: 点击进入组局中心');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TeamCenterMainPage(),
      ),
    );
  }

  Widget _buildNearbyTabs(HomeState state) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(HomeConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabItem('附近', isSelected: state.selectedTab == '附近', onTap: () => _controller.switchTab('附近')),
                _buildTabItem('推荐', isSelected: state.selectedTab == '推荐', onTap: () => _controller.switchTab('推荐')),
                _buildTabItem('最新', isSelected: state.selectedTab == '最新', onTap: () => _controller.switchTab('最新')),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (state.selectedRegion != null || state.activeFilters?.isNotEmpty == true)
                  GestureDetector(
                    onTap: _clearAllFilters,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[300]!, width: 1),
                      ),
                      child: Icon(
                        Icons.clear,
                        size: 12,
                        color: Colors.red[600],
                      ),
                    ),
                  ),
                if (state.selectedRegion != null || state.activeFilters?.isNotEmpty == true)
                  const SizedBox(width: 4),
                Flexible(
                  child: _buildDropdownFilter(
                    state.selectedRegion ?? '区域',
                    Icons.location_on,
                    onTap: _showLocationFilter,
                    isActive: state.selectedRegion != null,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: _buildDropdownFilter(
                    state.activeFilters?.isNotEmpty == true ? '筛选(${state.activeFilters!.length})' : '筛选',
                    Icons.filter_list,
                    onTap: _showMoreFilters,
                    isActive: state.activeFilters?.isNotEmpty == true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String text, {required bool isSelected, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(HomeConstants.primaryPurple) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownFilter(String text, IconData icon, {VoidCallback? onTap, bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF8B5CF6).withValues(alpha: 0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: isActive ? Border.all(color: const Color(0xFF8B5CF6), width: 1) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: isActive ? const Color(0xFF8B5CF6) : Colors.grey[600],
            ),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: isActive ? const Color(0xFF8B5CF6) : Colors.grey[600],
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 1),
            Icon(
              Icons.keyboard_arrow_down,
              size: 12,
              color: isActive ? const Color(0xFF8B5CF6) : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationFilter() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const EnhancedLocationPickerPage(),
      ),
    );

    if (result != null) {
      _controller.updateSelectedRegion(result);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已选择区域：$result')),
      );
    }
  }

  void _showMoreFilters() async {
    final result = await Navigator.push<FilterCriteria>(
      context,
      MaterialPageRoute(
        builder: (context) => const FilterPage(),
      ),
    );

    if (result != null) {
      final filterMap = _convertFilterCriteriaToMap(result);
      _controller.applyFilters(filterMap);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('筛选条件已应用')),
      );
    }
  }

  Map<String, dynamic> _convertFilterCriteriaToMap(FilterCriteria criteria) {
    return {
      'ageRange': {
        'start': criteria.ageRange.start,
        'end': criteria.ageRange.end,
      },
      'gender': criteria.gender,
      'status': criteria.status,
      'type': criteria.type,
      'skills': criteria.skills,
      'price': criteria.price,
      'positions': criteria.positions,
      'tags': criteria.tags,
    };
  }

  void _clearAllFilters() {
    _controller.clearFilters();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已清除所有筛选条件')),
    );
  }
}

// ============== 8. EXPORTS ==============
/// 📤 导出定义
/// 
/// 本文件自动导出的公共类：
/// - UnifiedHomePage: 首页主页面（public class）
///
/// 私有类（不会被导出）：
/// - _HomeController: 首页控制器
/// - _CountdownWidget: 倒计时组件
/// - _SearchBarWidget: 搜索栏组件
/// - _CategoryGridWidget: 分类网格组件
/// - _RecommendationCardWidget: 推荐卡片组件
/// - _UserCardWidget: 用户卡片组件
/// - _UnifiedHomePageState: 首页状态类
/// - _HomePageConstants: 页面私有常量
///
/// 使用方式：
/// ```dart
/// import 'unified_home_page.dart';
/// 
/// // 在路由中使用
/// MaterialPageRoute(builder: (context) => const UnifiedHomePage())
/// ```
