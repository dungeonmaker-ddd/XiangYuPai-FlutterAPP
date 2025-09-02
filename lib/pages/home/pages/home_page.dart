import 'package:flutter/material.dart';
import 'dart:async';
import '../models/user_model.dart';
import '../models/category_model.dart';
import '../models/location_model.dart';
import '../services/home_service.dart';
import '../utils/home_routes.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/category_grid_widget.dart';
import '../widgets/recommendation_card_widget.dart';
import '../widgets/user_profile_card.dart';
import '../config/home_config.dart';

/// 🏠 首页页面
/// 探店APP的主要首页，包含搜索、分类、推荐等功能
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final IHomeService _homeService;
  late TabController _tabController;
  
  // 页面状态
  bool _isLoading = true;
  String? _errorMessage;
  LocationModel? _currentLocation;
  
  // 数据状态
  List<CategoryModel> _categories = [];
  List<UserModel> _recommendedUsers = [];
  List<UserModel> _nearbyUsers = [];
  
  // 分页状态
  int _currentPage = 1;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;
  
  // 滚动控制器
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _homeService = HomeServiceFactory.getInstance();
    _tabController = TabController(length: 4, vsync: this);
    
    // 初始化默认位置
    _currentLocation = LocationData.findById('shenzhen');
    
    // 初始化数据
    _initializeData();
    
    // 监听滚动，实现分页加载
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// 初始化页面数据
  Future<void> _initializeData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // 并发加载数据
      final results = await Future.wait([
        _homeService.getCategories(),
        _homeService.getRecommendedUsers(limit: 10),
        _homeService.getNearbyUsers(limit: 20),
      ]);

      if (mounted) {
        setState(() {
          _categories = results[0] as List<CategoryModel>;
          _recommendedUsers = results[1] as List<UserModel>;
          _nearbyUsers = results[2] as List<UserModel>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '加载失败，请重试';
          _isLoading = false;
        });
      }
    }
  }

  /// 滚动监听，实现分页加载
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  /// 加载更多数据
  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMoreData) return;

    try {
      setState(() {
        _isLoadingMore = true;
      });

      final moreUsers = await _homeService.getNearbyUsers(
        page: _currentPage + 1,
        limit: 20,
      );

      if (mounted) {
        setState(() {
          if (moreUsers.isNotEmpty) {
            _nearbyUsers.addAll(moreUsers);
            _currentPage++;
          } else {
            _hasMoreData = false;
          }
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  /// 下拉刷新
  Future<void> _onRefresh() async {
    _currentPage = 1;
    _hasMoreData = true;
    await _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(HomeConfig.homeBackgroundColor),
      body: _isLoading ? _buildLoadingView() : _buildMainContent(),
    );
  }

  /// 构建加载视图
  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(HomeConfig.primaryPurple)),
          ),
          SizedBox(height: 16),
          Text(
            '正在加载精彩内容...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建主要内容
  Widget _buildMainContent() {
    if (_errorMessage != null) {
      return _buildErrorView();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: Color(HomeConfig.primaryPurple),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // 搜索栏
          SliverToBoxAdapter(
            child: SearchBarWidget(
              currentLocation: _currentLocation?.name,
              onLocationTap: () async {
                final result = await HomeRoutes.toLocationPickerPage(
                  context,
                  selectedLocation: _currentLocation,
                );
                if (result != null) {
                  setState(() {
                    _currentLocation = result;
                  });
                  // 位置变更后重新加载数据
                  _onRefresh();
                }
              },
            ),
          ),

          // 游戏推广横幅
          SliverToBoxAdapter(
            child: _buildGameBanner(),
          ),

          // 分类网格
          SliverToBoxAdapter(
            child: CategoryGridWidget(
              categories: _categories,
            ),
          ),

          // 推荐用户区域
          if (_recommendedUsers.isNotEmpty)
            SliverToBoxAdapter(
              child: RecommendationCardWidget(
                users: _recommendedUsers,
                title: '限时专享',
              ),
            ),

          // 组队聚会横幅
          SliverToBoxAdapter(
            child: _buildTeamUpBanner(),
          ),

          // 附近推荐标签栏
          SliverToBoxAdapter(
            child: _buildNearbyTabs(),
          ),

          // 附近用户列表
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < _nearbyUsers.length) {
                  return UserProfileCard(
                    user: _nearbyUsers[index],
                  );
                } else if (_isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(HomeConfig.primaryPurple)),
                      ),
                    ),
                  );
                } else if (!_hasMoreData) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        '没有更多内容了',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              childCount: _nearbyUsers.length + (_isLoadingMore || !_hasMoreData ? 1 : 0),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建错误视图
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _initializeData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(HomeConfig.primaryPurple),
              foregroundColor: Colors.white,
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  /// 构建游戏推广横幅
  Widget _buildGameBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A237E),
            Color(0xFF3F51B5),
            Color(0xFF5C6BC0),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16,
            top: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '王者荣耀',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'FIGHTING LIKE A MAN, DISGUISED AS A MAN',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    '"独家首发 今日玩家实况"',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            bottom: 16,
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.videogame_asset,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建组队聚会横幅
  Widget _buildTeamUpBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color(HomeConfig.cardBackgroundColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text(
              '组队聚会',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(HomeConfig.textPrimaryColor),
              ),
            ),
          ),
          Container(
            height: 120,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE91E63),
                  Color(0xFFAD1457),
                  Color(0xFF880E4F),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                const Positioned(
                  left: 16,
                  top: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '组局中!!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '找到志同道合的伙伴',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 16,
                  bottom: 16,
                  child: Container(
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.groups,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建附近推荐标签栏
  Widget _buildNearbyTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color(HomeConfig.cardBackgroundColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: Color(HomeConfig.primaryPurple),
        labelColor: Color(HomeConfig.primaryPurple),
        unselectedLabelColor: Color(HomeConfig.textSecondaryColor),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Color(HomeConfig.primaryPurple).withValues(alpha: 0.1),
        ),
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        tabs: const [
          Tab(text: '附近'),
          Tab(text: '推荐'),
          Tab(text: '最新'),
          Tab(text: '区域'),
        ],
      ),
    );
  }
}
