// 🏠 首页统一页面 - 重构后的精简版本
// 基于模块化组件架构的轻量级实现

// ============== 1. IMPORTS ==============
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

// 项目内部导入
import 'home_models.dart';
import 'location_picker_page.dart';
import 'search/index.dart';
import 'submodules/service_system/index.dart';
import 'submodules/team_center/index.dart';
import 'submodules/filter_system/enhanced_location_picker_page.dart';
import 'submodules/filter_system/filter_page.dart';
import '../discovery/index.dart' as discovery;

// 组件和控制器导入
import 'controllers/home_controller.dart';
import 'widgets/index.dart';
import 'utils/home_page_utils.dart';

// ============== 2. CONSTANTS ==============
/// 🎨 首页私有常量（页面级别）
class _HomePageConstants {
  const _HomePageConstants._();
  
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const double loadMoreThreshold = 200.0;
  static const double gamebannerHeight = 160.0;
  static const double teamUpBannerHeight = 140.0;
  static const double userListHeight = 140.0;
}

// ============== 3. PAGES ==============
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
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _setSystemUIOverlayStyle();
    
    return Scaffold(
      backgroundColor: const Color(HomeConstants.homeBackgroundColor),
      body: ValueListenableBuilder<HomeState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          if (state.isLoading && state.nearbyUsers.isEmpty) {
            return LoadingStates.buildLoadingView();
          }

          if (state.errorMessage != null && state.nearbyUsers.isEmpty) {
            return LoadingStates.buildErrorView(
              state.errorMessage!,
              () => _controller.refresh(),
            );
          }

          return _buildMainContent(state);
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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

  /// 设置系统UI样式
  void _setSystemUIOverlayStyle() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
  }

  /// 构建主要内容
  Widget _buildMainContent(HomeState state) {
    return RefreshIndicator(
      color: const Color(HomeConstants.primaryPurple),
      onRefresh: _controller.refresh,
      child: CustomScrollView(
        controller: _controller.scrollController,
        slivers: [
          // 顶部导航区域
          SliverToBoxAdapter(
            child: TopNavigationWidget(
              currentLocation: state.currentLocation?.name,
              onLocationTap: _handleLocationTap,
            ),
          ),

          // 游戏推广横幅
          SliverToBoxAdapter(
            child: GameBannerWidget(),
          ),

          // 功能服务网格
          if (state.categories.isNotEmpty)
            SliverToBoxAdapter(
              child: CategoryGridWidget(
                categories: state.categories,
                onCategoryTap: (category) => HomePageUtils.handleCategoryNavigation(
                  context,
                  category,
                  _controller.selectCategory,
                ),
              ),
            ),

          // 限时专享区域
          SliverToBoxAdapter(
            child: RecommendationCardWidget(
              users: state.recommendedUsers,
              title: '限时专享',
              promoEndTime: state.promoEndTime,
              onUserTap: _controller.selectUser,
            ),
          ),

          // 组队聚会横幅
          SliverToBoxAdapter(
            child: TeamUpBannerWidget(
              onButtonTap: _handleTeamCenterTap,
            ),
          ),

          // 附近/推荐标签
          SliverToBoxAdapter(
            child: NearbyTabsWidget(
              state: state,
              onTabChanged: _controller.switchTab,
              onLocationFilter: _showLocationFilter,
              onMoreFilters: _showMoreFilters,
              onClearFilters: _clearAllFilters,
            ),
          ),

          // 附近用户列表
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < state.nearbyUsers.length) {
                  return UserCardWidget(
                    user: state.nearbyUsers[index],
                    onTap: () => _controller.selectUser(state.nearbyUsers[index]),
                  );
                } else if (state.isLoadingMore) {
                  return LoadingStates.buildLoadMoreIndicator();
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

  /// 处理位置点击
  void _handleLocationTap() async {
    final result = await Navigator.push<LocationRegionModel>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerPage(
          currentLocation: HomePageUtils.convertToLocationRegion(_controller.value.currentLocation),
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
      HomePageUtils.showSuccessSnackBar(context, '已切换到${result.name}');
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

  /// 显示位置筛选
  void _showLocationFilter() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const EnhancedLocationPickerPage(),
      ),
    );

    if (result != null) {
      _controller.updateSelectedRegion(result);
      HomePageUtils.showSuccessSnackBar(context, '已选择区域：$result');
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
      final filterMap = HomePageUtils.convertFilterCriteriaToMap(result);
      _controller.applyFilters(filterMap);
      HomePageUtils.showSuccessSnackBar(context, '筛选条件已应用');
    }
  }

  /// 清除所有筛选条件
  void _clearAllFilters() {
    _controller.clearFilters();
    HomePageUtils.showSuccessSnackBar(context, '已清除所有筛选条件');
  }

  /// 处理发布动态按钮点击
  void _handlePublishContent() async {
    developer.log('首页: 点击发布动态按钮');
    
    try {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => const discovery.PublishContentPage(),
          fullscreenDialog: true,
        ),
      );
      
      if (result == true) {
        HomePageUtils.showSuccessSnackBar(context, '🎉 发布成功！');
        _controller.refresh();
      }
    } catch (e) {
      developer.log('打开发布动态页面失败: $e');
      HomePageUtils.showErrorSnackBar(context, '打开发布页面失败，请重试');
    }
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
      if (index == 0) {
        _controller.scrollController.animateTo(
          0,
          duration: _HomePageConstants.animationDuration,
          curve: Curves.easeInOut,
        );
      }
      return;
    }

    _controller.switchBottomTab(index);
    
    switch (index) {
      case 0:
        break;
      case 1:
        _navigateToDiscovery();
        break;
      case 2:
        _navigateToMessages();
        break;
      case 3:
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
      _controller.switchBottomTab(0);
    });
  }

  /// 跳转到消息页面
  void _navigateToMessages() {
    developer.log('导航到消息页面');
    HomePageUtils.showComingSoonDialog(context, '消息功能');
    _controller.switchBottomTab(0);
  }

  /// 跳转到个人中心页面
  void _navigateToProfile() {
    developer.log('导航到个人中心页面');
    HomePageUtils.showComingSoonDialog(context, '个人中心');
    _controller.switchBottomTab(0);
  }
}

/// 🏠 统一首页（无底部导航版本）的状态管理类
class _UnifiedHomePageWithoutBottomNavState extends State<UnifiedHomePageWithoutBottomNav> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _setSystemUIOverlayStyle();
    
    return Scaffold(
      backgroundColor: const Color(HomeConstants.homeBackgroundColor),
      body: ValueListenableBuilder<HomeState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          if (state.isLoading && state.nearbyUsers.isEmpty) {
            return LoadingStates.buildLoadingView();
          }

          if (state.errorMessage != null && state.nearbyUsers.isEmpty) {
            return LoadingStates.buildErrorView(
              state.errorMessage!,
              () => _controller.refresh(),
            );
          }

          return _buildMainContent(state);
        },
      ),
      // 注意：这里没有bottomNavigationBar和floatingActionButton
      // 它们由MainTabPage统一管理
    );
  }

  void _setSystemUIOverlayStyle() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
  }

  Widget _buildMainContent(HomeState state) {
    return RefreshIndicator(
      color: const Color(HomeConstants.primaryPurple),
      onRefresh: _controller.refresh,
      child: CustomScrollView(
        controller: _controller.scrollController,
        slivers: [
          // 顶部导航区域
          SliverToBoxAdapter(
            child: TopNavigationWidget(
              currentLocation: state.currentLocation?.name,
              onLocationTap: _handleLocationTap,
            ),
          ),

          // 游戏推广横幅
          SliverToBoxAdapter(
            child: GameBannerWidget(),
          ),

          // 功能服务网格
          if (state.categories.isNotEmpty)
            SliverToBoxAdapter(
              child: CategoryGridWidget(
                categories: state.categories,
                onCategoryTap: (category) => HomePageUtils.handleCategoryNavigation(
                  context,
                  category,
                  _controller.selectCategory,
                ),
              ),
            ),

          // 限时专享区域
          SliverToBoxAdapter(
            child: RecommendationCardWidget(
              users: state.recommendedUsers,
              title: '限时专享',
              promoEndTime: state.promoEndTime,
              onUserTap: _controller.selectUser,
            ),
          ),

          // 组队聚会横幅
          SliverToBoxAdapter(
            child: TeamUpBannerWidget(
              onButtonTap: _handleTeamCenterTap,
            ),
          ),

          // 附近/推荐标签
          SliverToBoxAdapter(
            child: NearbyTabsWidget(
              state: state,
              onTabChanged: _controller.switchTab,
              onLocationFilter: _showLocationFilter,
              onMoreFilters: _showMoreFilters,
              onClearFilters: _clearAllFilters,
            ),
          ),

          // 附近用户列表
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < state.nearbyUsers.length) {
                  return UserCardWidget(
                    user: state.nearbyUsers[index],
                    onTap: () => _controller.selectUser(state.nearbyUsers[index]),
                  );
                } else if (state.isLoadingMore) {
                  return LoadingStates.buildLoadMoreIndicator();
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

  void _handleLocationTap() async {
    final result = await Navigator.push<LocationRegionModel>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerPage(
          currentLocation: HomePageUtils.convertToLocationRegion(_controller.value.currentLocation),
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
      HomePageUtils.showSuccessSnackBar(context, '已切换到${result.name}');
    }
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

  void _showLocationFilter() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const EnhancedLocationPickerPage(),
      ),
    );

    if (result != null) {
      _controller.updateSelectedRegion(result);
      HomePageUtils.showSuccessSnackBar(context, '已选择区域：$result');
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
      final filterMap = HomePageUtils.convertFilterCriteriaToMap(result);
      _controller.applyFilters(filterMap);
      HomePageUtils.showSuccessSnackBar(context, '筛选条件已应用');
    }
  }

  void _clearAllFilters() {
    _controller.clearFilters();
    HomePageUtils.showSuccessSnackBar(context, '已清除所有筛选条件');
  }
}
