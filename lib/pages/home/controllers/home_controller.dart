// 🧠 首页控制器 - 状态管理和业务逻辑
// 从unified_home_page.dart中提取的控制器逻辑

import 'package:flutter/material.dart';
import 'dart:developer' as developer;

// 项目内部导入
import '../home_models.dart';
import '../home_services.dart';
import '../search/index.dart';

/// 🧠 首页控制器
class HomeController extends ValueNotifier<HomeState> {
  HomeController() : super(const HomeState()) {
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
    const double loadMoreThreshold = 200.0;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - loadMoreThreshold) {
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
