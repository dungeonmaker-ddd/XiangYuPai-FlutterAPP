// 🔍 搜索结果页面 - 单文件架构完整实现
// 基于Flutter单文件架构规范的8段式结构设计

// ============== 1. IMPORTS ==============
// Flutter核心库
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Dart核心库
import 'dart:async';
import 'dart:developer' as developer;

// 项目内部文件
import '../models/search_models.dart';
import '../services/search_services.dart';
import '../widgets/search_widgets.dart';

// ============== 2. CONSTANTS ==============
/// 🎨 搜索结果页面私有常量
class _SearchResultsPageConstants {
  const _SearchResultsPageConstants._();
  
  // UI配置
  static const double tabBarHeight = 48.0;
  static const double cardMargin = 8.0;
  static const double loadMoreThreshold = 200.0;
  
  // 瀑布流配置
  static const int waterfallColumns = 2;
  static const double waterfallSpacing = 8.0;
  static const double waterfallAspectRatio = 0.75;
  
  // 动画配置
  static const Duration tabSwitchDuration = Duration(milliseconds: 200);
  static const Duration loadingDelay = Duration(milliseconds: 500);
}

// ============== 3. MODELS ==============
/// 📊 搜索结果页面状态模型
class _SearchResultsState {
  final String keyword;
  final SearchType selectedType;
  final SearchResultData? results;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMoreData;
  final int currentPage;
  final String? errorMessage;
  
  const _SearchResultsState({
    this.keyword = '',
    this.selectedType = SearchType.all,
    this.results,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMoreData = true,
    this.currentPage = 1,
    this.errorMessage,
  });
  
  _SearchResultsState copyWith({
    String? keyword,
    SearchType? selectedType,
    SearchResultData? results,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMoreData,
    int? currentPage,
    String? errorMessage,
  }) {
    return _SearchResultsState(
      keyword: keyword ?? this.keyword,
      selectedType: selectedType ?? this.selectedType,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage,
    );
  }
}

// ============== 4. SERVICES ==============
// 服务在 search_services.dart 中定义

// ============== 5. CONTROLLERS ==============
/// 🧠 搜索结果控制器
class _SearchResultsController extends ValueNotifier<_SearchResultsState> {
  _SearchResultsController(String initialKeyword) : super(_SearchResultsState(keyword: initialKeyword)) {
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _performInitialSearch();
  }
  
  late final ScrollController _scrollController;
  final SearchService _searchService = SearchService();
  final SearchAnalyticsService _analyticsService = SearchAnalyticsService();
  
  ScrollController get scrollController => _scrollController;
  
  /// 执行初始搜索
  Future<void> _performInitialSearch() async {
    if (value.keyword.isEmpty) return;
    
    final stopwatch = Stopwatch()..start();
    
    try {
      value = value.copyWith(isLoading: true, errorMessage: null);
      
      final request = SearchRequest(
        keyword: value.keyword,
        type: value.selectedType,
        page: 1,
      );
      
      final response = await _searchService.search(request);
      
      value = value.copyWith(
        isLoading: false,
        results: response.data,
        hasMoreData: response.hasMore,
        currentPage: 1,
      );
      
      // 记录搜索行为
      stopwatch.stop();
      _analyticsService.trackSearchBehavior(
        keyword: value.keyword,
        type: value.selectedType,
        resultCount: response.totalCount,
        searchDuration: stopwatch.elapsed,
      );
      
      developer.log('SearchResultsController: 搜索完成 - ${value.keyword}');
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: '搜索失败，请重试',
      );
      developer.log('SearchResultsController: 搜索失败 - $e');
    }
  }
  
  /// 滚动监听
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - _SearchResultsPageConstants.loadMoreThreshold) {
      loadMore();
    }
  }
  
  /// 加载更多
  Future<void> loadMore() async {
    if (value.isLoadingMore || !value.hasMoreData || value.isLoading) return;
    
    try {
      value = value.copyWith(isLoadingMore: true);
      
      final request = SearchRequest(
        keyword: value.keyword,
        type: value.selectedType,
        page: value.currentPage + 1,
      );
      
      final response = await _searchService.search(request);
      
      // 合并结果
      final currentResults = value.results ?? const SearchResultData();
      final mergedResults = _mergeSearchResults(currentResults, response.data);
      
      value = value.copyWith(
        isLoadingMore: false,
        results: mergedResults,
        hasMoreData: response.hasMore,
        currentPage: value.currentPage + 1,
      );
      
      developer.log('SearchResultsController: 加载更多完成');
    } catch (e) {
      value = value.copyWith(isLoadingMore: false);
      developer.log('SearchResultsController: 加载更多失败 - $e');
    }
  }
  
  /// 切换搜索类型
  Future<void> switchSearchType(SearchType type) async {
    if (value.selectedType == type) return;
    
    value = value.copyWith(
      selectedType: type,
      currentPage: 1,
      hasMoreData: true,
    );
    
    await _performInitialSearch();
  }
  
  /// 刷新搜索
  Future<void> refresh() async {
    value = value.copyWith(
      currentPage: 1,
      hasMoreData: true,
    );
    await _performInitialSearch();
  }
  
  /// 新的关键词搜索
  Future<void> searchWithKeyword(String keyword) async {
    if (keyword.trim().isEmpty) return;
    
    value = value.copyWith(
      keyword: keyword,
      selectedType: SearchType.all,
      currentPage: 1,
      hasMoreData: true,
      results: null,
    );
    
    await _performInitialSearch();
  }
  
  /// 记录结果点击
  void trackResultClick(String resultId, int position) {
    _analyticsService.trackResultClick(
      keyword: value.keyword,
      type: value.selectedType,
      resultId: resultId,
      position: position,
    );
  }
  
  /// 合并搜索结果
  SearchResultData _mergeSearchResults(SearchResultData current, SearchResultData newData) {
    return SearchResultData(
      allResults: [...current.allResults, ...newData.allResults],
      userResults: [...current.userResults, ...newData.userResults],
      orderResults: [...current.orderResults, ...newData.orderResults],
      topicResults: [...current.topicResults, ...newData.topicResults],
      totalCount: newData.totalCount,
      hasMore: newData.hasMore,
    );
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
}

// ============== 6. WIDGETS ==============
/// 🔍 搜索结果页面搜索栏
class _SearchResultsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String keyword;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onBack;
  
  const _SearchResultsAppBar({
    required this.keyword,
    this.onSearch,
    this.onBack,
  });
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(SearchConstants.primaryColor),
      elevation: 0,
      leading: IconButton(
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      title: Container(
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: TextField(
          controller: TextEditingController(text: keyword),
          decoration: const InputDecoration(
            hintText: '搜索...',
            prefixIcon: Icon(Icons.search, size: 20),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          ),
          style: const TextStyle(fontSize: 14),
          onSubmitted: onSearch,
        ),
      ),
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// 🏷️ 搜索类型标签栏
class _SearchTypeTabBar extends StatelessWidget {
  final SearchType selectedType;
  final ValueChanged<SearchType>? onTypeChanged;
  
  const _SearchTypeTabBar({
    required this.selectedType,
    this.onTypeChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: _SearchResultsPageConstants.tabBarHeight,
      color: Colors.white,
      child: Row(
        children: SearchType.values.map((type) {
          final isSelected = type == selectedType;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTypeChanged?.call(type),
              child: AnimatedContainer(
                duration: _SearchResultsPageConstants.tabSwitchDuration,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(SearchConstants.primaryColor) : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Center(
                  child: Text(
                    type.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.white : const Color(SearchConstants.textColor),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// 📋 搜索结果内容区域
class _SearchResultsContent extends StatelessWidget {
  final _SearchResultsState state;
  final VoidCallback? onRefresh;
  final Function(String, int)? onResultTap;
  
  const _SearchResultsContent({
    required this.state,
    this.onRefresh,
    this.onResultTap,
  });
  
  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.results == null) {
      return SearchLoadingSkeleton(
        type: state.selectedType,
        itemCount: 6,
      );
    }
    
    if (state.errorMessage != null && state.results == null) {
      return _buildErrorView();
    }
    
    if (state.results == null || _isEmpty(state.results!)) {
      return _buildEmptyView();
    }
    
    return RefreshIndicator(
      onRefresh: () async => onRefresh?.call(),
      color: const Color(SearchConstants.primaryColor),
      child: _buildResultsList(),
    );
  }
  
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            state.errorMessage ?? '搜索失败',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRefresh,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '没有找到相关内容',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            '试试其他关键词吧',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
  
  Widget _buildResultsList() {
    switch (state.selectedType) {
      case SearchType.all:
        return _buildAllResultsList();
      case SearchType.user:
        return _buildUserResultsList();
      case SearchType.order:
        return _buildOrderResultsList();
      case SearchType.topic:
        return _buildTopicResultsList();
    }
  }
  
  Widget _buildAllResultsList() {
    final results = state.results!.allResults;
    
    return CustomScrollView(
      slivers: [
        // 瀑布流内容
        SliverPadding(
          padding: const EdgeInsets.all(8),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _SearchResultsPageConstants.waterfallColumns,
              crossAxisSpacing: _SearchResultsPageConstants.waterfallSpacing,
              mainAxisSpacing: _SearchResultsPageConstants.waterfallSpacing,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= results.length) {
                  return const SizedBox.shrink();
                }
                
                final item = results[index];
                return SearchContentCard(
                  item: item,
                  searchKeyword: state.keyword,
                  onTap: () => onResultTap?.call(item.id, index),
                  onAuthorTap: (authorId) {
                    developer.log('点击作者: $authorId');
                    // TODO: 跳转到作者页面
                  },
                  onLike: (contentId) {
                    developer.log('点赞内容: $contentId');
                    // TODO: 实现点赞功能
                  },
                );
              },
              childCount: results.length,
            ),
          ),
        ),
        
        // 加载更多指示器
        if (state.isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else if (!state.hasMoreData && results.isNotEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  '已经到底了',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildUserResultsList() {
    final results = state.results!.userResults;
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: results.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= results.length) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(SearchConstants.primaryColor)),
            ),
          ));
        }
        
        final item = results[index];
        return SearchUserCard(
          user: item,
          searchKeyword: state.keyword,
          onTap: () => onResultTap?.call(item.id, index),
          onFollow: () {
            developer.log('关注用户: ${item.id}');
            // TODO: 实现关注功能
          },
        );
      },
    );
  }
  
  Widget _buildOrderResultsList() {
    final results = state.results!.orderResults;
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: results.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= results.length) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(SearchConstants.primaryColor)),
            ),
          ));
        }
        
        final item = results[index];
        return SearchOrderCard(
          order: item,
          searchKeyword: state.keyword,
          onTap: () => onResultTap?.call(item.id, index),
          onOrder: () {
            developer.log('下单服务: ${item.id}');
            // TODO: 实现下单功能
          },
        );
      },
    );
  }
  
  Widget _buildTopicResultsList() {
    final results = state.results!.topicResults;
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: results.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= results.length) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(SearchConstants.primaryColor)),
            ),
          ));
        }
        
        final item = results[index];
        return SearchTopicCard(
          topic: item,
          searchKeyword: state.keyword,
          onTap: () => onResultTap?.call(item.id, index),
          onFollow: () {
            developer.log('关注话题: ${item.id}');
            // TODO: 实现关注话题功能
          },
        );
      },
    );
  }
  
  
  
  
  
  bool _isEmpty(SearchResultData results) {
    return results.allResults.isEmpty &&
           results.userResults.isEmpty &&
           results.orderResults.isEmpty &&
           results.topicResults.isEmpty;
  }
}

// ============== 7. PAGES ==============
/// 🔍 搜索结果页面
/// 
/// 展示多维度搜索结果，支持分类切换和无限滚动
class SearchResultsPage extends StatefulWidget {
  final String initialKeyword;
  
  const SearchResultsPage({
    super.key,
    required this.initialKeyword,
  });
  
  static const String routeName = '/search/results';
  
  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late final _SearchResultsController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = _SearchResultsController(widget.initialKeyword);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // 设置状态栏样式
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 透明状态栏
      statusBarIconBrightness: Brightness.light, // 浅色图标（因为AppBar是紫色）
      statusBarBrightness: Brightness.dark, // iOS状态栏亮度
    ));
    
    return ValueListenableBuilder<_SearchResultsState>(
      valueListenable: _controller,
      builder: (context, state, child) {
        return Scaffold(
          backgroundColor: const Color(SearchConstants.backgroundColor),
          appBar: _SearchResultsAppBar(
            keyword: state.keyword,
            onSearch: _controller.searchWithKeyword,
            onBack: () => Navigator.pop(context),
          ),
          body: Column(
            children: [
              // 搜索类型标签栏
              _SearchTypeTabBar(
                selectedType: state.selectedType,
                onTypeChanged: _controller.switchSearchType,
              ),
              
              // 搜索结果内容
              Expanded(
                child: _SearchResultsContent(
                  state: state,
                  onRefresh: _controller.refresh,
                  onResultTap: _controller.trackResultClick,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============== 8. EXPORTS ==============
/// 📤 导出定义
/// 
/// 本文件自动导出的公共类：
/// - SearchResultsPage: 搜索结果页面（public class）
///
/// 私有类（不会被导出）：
/// - _SearchResultsController: 搜索结果控制器
/// - _SearchResultsAppBar: 搜索结果页面应用栏
/// - _SearchTypeTabBar: 搜索类型标签栏
/// - _SearchResultsContent: 搜索结果内容区域
/// - _SearchResultsPageConstants: 页面私有常量
/// - _SearchResultsState: 页面状态模型
///
/// 使用方式：
/// ```dart
/// import 'search_results_page.dart';
/// 
/// // 在路由中使用
/// Navigator.push(context, MaterialPageRoute(
///   builder: (context) => SearchResultsPage(initialKeyword: 'keyword'),
/// ));
/// ```
