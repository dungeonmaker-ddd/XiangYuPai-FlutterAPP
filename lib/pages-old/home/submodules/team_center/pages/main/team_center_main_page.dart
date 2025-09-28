// 🎯 组局中心主页面 - 单文件架构完整实现
// 基于Flutter单文件架构规范的8段式结构设计

// ============== 1. IMPORTS ==============
// Flutter核心库
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Dart核心库
import 'dart:async';
import 'dart:developer' as developer;

// 项目内部文件 - 按依赖关系排序
import '../../models/team_models.dart';      // 数据模型
import '../../services/team_services.dart';  // 业务服务
import '../../utils/constants.dart';         // 常量定义
import '../detail/team_detail_page.dart';    // 组局详情页面
import '../create/create_team_page.dart';    // 发布组局页面

// ============== 2. CONSTANTS ==============
/// 🎨 组局中心页面私有常量
class _TeamCenterPageConstants {
  // 私有构造函数，防止实例化
  const _TeamCenterPageConstants._();
  
  // 页面标识
  static const String pageTitle = '组局中心';

  // 性能配置
  static const double loadMoreThreshold = 200.0;

  // UI配置
  static const double cardHeight = 140.0;  // 更紧凑的卡片高度
  static const double filterBarHeight = 100.0;  // 更紧凑的筛选栏
}

// ============== 3. MODELS ==============
/// 📋 数据模型引用
/// 主要模型定义在 team_models.dart 中：
/// - TeamActivity: 组局活动模型
/// - TeamHost: 发起者模型
/// - TeamParticipant: 参与者模型
/// - TeamFilterOptions: 筛选条件模型
/// - TeamCenterState: 页面状态模型
/// - ActivityType: 活动类型枚举
/// - SortType: 排序类型枚举
/// - GenderFilter: 性别筛选枚举

// ============== 4. SERVICES ==============
/// 🔧 业务服务引用
/// 主要服务定义在 team_services.dart 中：
/// - TeamService: 组局数据服务
/// - TeamServiceFactory: 服务工厂
/// 
/// 服务功能包括：
/// - 组局数据获取和管理
/// - 筛选和排序逻辑
/// - 报名和状态处理
/// - API调用和错误处理

// ============== 5. CONTROLLERS ==============
/// 🧠 组局中心控制器
class _TeamCenterController extends ValueNotifier<TeamCenterState> {
  _TeamCenterController() : super(const TeamCenterState()) {
    _scrollController = ScrollController();
    _initialize();
  }

  late ScrollController _scrollController;
  late ITeamService _teamService;

  ScrollController get scrollController => _scrollController;

  /// 初始化数据
  Future<void> _initialize() async {
    try {
      _teamService = TeamServiceFactory.getInstance();
      value = value.copyWith(isLoading: true, errorMessage: null);

      // 加载组局列表
      final activities = await _teamService.getTeamActivities(
        page: 1,
        limit: TeamCenterConstants.defaultPageSize,
        filterOptions: value.filterOptions,
      );

      value = value.copyWith(
        isLoading: false,
        activities: activities,
        currentPage: 1,
        hasMoreData: activities.length >= TeamCenterConstants.defaultPageSize,
      );

      // 设置滚动监听
      _scrollController.addListener(_onScroll);
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: '加载失败，请重试',
      );
      developer.log('组局中心初始化失败: $e');
    }
  }

  /// 滚动监听
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - _TeamCenterPageConstants.loadMoreThreshold) {
      loadMoreActivities();
    }
  }

  /// 加载更多组局
  Future<void> loadMoreActivities() async {
    if (value.isLoadingMore || !value.hasMoreData) return;

    try {
      value = value.copyWith(isLoadingMore: true);

      final moreActivities = await _teamService.getTeamActivities(
        page: value.currentPage + 1,
        limit: TeamCenterConstants.defaultPageSize,
        filterOptions: value.filterOptions,
      );

      if (moreActivities.isNotEmpty) {
        final updatedActivities = List<TeamActivity>.from(value.activities)
          ..addAll(moreActivities);
        
        value = value.copyWith(
          isLoadingMore: false,
          activities: updatedActivities,
          currentPage: value.currentPage + 1,
          hasMoreData: moreActivities.length >= TeamCenterConstants.defaultPageSize,
        );
      } else {
        value = value.copyWith(
          isLoadingMore: false,
          hasMoreData: false,
        );
      }
    } catch (e) {
      value = value.copyWith(isLoadingMore: false);
      developer.log('加载更多组局失败: $e');
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

  /// 更新筛选条件
  Future<void> updateFilter(TeamFilterOptions newOptions) async {
    if (value.filterOptions == newOptions) return;

    try {
      value = value.copyWith(
        isLoading: true,
        filterOptions: newOptions,
        currentPage: 1,
        hasMoreData: true,
      );

      final activities = await _teamService.getTeamActivities(
        page: 1,
        limit: TeamCenterConstants.defaultPageSize,
        filterOptions: newOptions,
      );

      value = value.copyWith(
        isLoading: false,
        activities: activities,
        hasMoreData: activities.length >= TeamCenterConstants.defaultPageSize,
      );
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: '筛选失败，请重试',
      );
      developer.log('更新筛选条件失败: $e');
    }
  }

  /// 选择排序方式
  void selectSortType(SortType sortType) {
    final newOptions = value.filterOptions.copyWith(sortType: sortType);
    updateFilter(newOptions);
  }

  /// 选择性别筛选
  void selectGenderFilter(GenderFilter genderFilter) {
    final newOptions = value.filterOptions.copyWith(genderFilter: genderFilter);
    updateFilter(newOptions);
  }

  /// 选择活动类型
  void selectActivityType(ActivityType activityType) {
    final newOptions = value.filterOptions.copyWith(activityType: activityType);
    updateFilter(newOptions);
  }

  /// 选择组局活动
  void selectActivity(TeamActivity activity) {
    developer.log('选择组局活动: ${activity.title}');
    // 跳转到组局详情页面的逻辑将在页面层处理
  }

  /// 发布组局
  void createTeamActivity() {
    developer.log('发布组局');
    // 跳转到发布组局页面的逻辑将在页面层处理
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

/// 🔝 顶部导航栏组件
class _TeamCenterAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onCreateTeam;

  const _TeamCenterAppBar({this.onCreateTeam});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        _TeamCenterPageConstants.pageTitle,
        style: TextStyle(
          fontSize: 17,  // 稍小的标题
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: TextButton(
            onPressed: onCreateTeam,
            style: TextButton.styleFrom(
              backgroundColor: TeamCenterConstants.primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),  // 更紧凑
              minimumSize: const Size(70, 32),  // 固定最小尺寸
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),  // 更小的圆角
              ),
            ),
            child: const Text(
              '发布组局',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),  // 更小的字体
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// 🏷️ 筛选标签栏组件
class _FilterTabBar extends StatelessWidget {
  final TeamFilterOptions filterOptions;
  final ValueChanged<SortType>? onSortTypeChanged;
  final ValueChanged<GenderFilter>? onGenderFilterChanged;
  final ValueChanged<ActivityType>? onActivityTypeChanged;
  final VoidCallback? onAdvancedFilter;

  const _FilterTabBar({
    required this.filterOptions,
    this.onSortTypeChanged,
    this.onGenderFilterChanged,
    this.onActivityTypeChanged,
    this.onAdvancedFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _TeamCenterPageConstants.filterBarHeight,
      color: Colors.white,
      child: Column(
        children: [
          // 快速筛选标签
          Container(
            height: 44,  // 更紧凑
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                // 智能排序下拉
                _buildDropdownFilter(
                  context,
                  filterOptions.sortType.displayName,
                  () => _showSortBottomSheet(context),
                ),
                const SizedBox(width: 8),  // 减少间距
                
                // 性别筛选下拉
                _buildDropdownFilter(
                  context,
                  filterOptions.genderFilter.displayName,
                  () => _showGenderBottomSheet(context),
                ),
                const Spacer(),
                
                // 高级筛选按钮
                _buildAdvancedFilterButton(),
              ],
            ),
          ),
          
          const Divider(height: 1, color: Color(0xFFF0F0F0)),  // 更浅的分割线
          
          // 活动类型标签
          Container(
            height: 44,  // 更紧凑
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: ActivityType.values.length,
              itemBuilder: (context, index) {
                final type = ActivityType.values[index];
                final isSelected = filterOptions.activityType == type;
                
                return GestureDetector(
                  onTap: () => onActivityTypeChanged?.call(type),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),  // 减少间距
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),  // 更小的内边距
                    decoration: BoxDecoration(
                      color: isSelected ? TeamCenterConstants.primaryPurple : Colors.grey[50],  // 更浅的背景
                      borderRadius: BorderRadius.circular(16),  // 更小的圆角
                      border: isSelected ? null : Border.all(
                        color: Colors.grey.shade200,  // 更浅的边框
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      type.displayName,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,  // 更深的文字色
                        fontSize: 13,  // 稍小的字体
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
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

  Widget _buildDropdownFilter(BuildContext context, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),  // 更小的内边距
        decoration: BoxDecoration(
          color: Colors.grey[50],  // 更浅的背景
          borderRadius: BorderRadius.circular(12),  // 更小的圆角
          border: Border.all(
            color: Colors.grey.shade200,  // 添加边框
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: Colors.black87,  // 更深的文字色
                fontSize: 13,  // 稍小的字体
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 3),  // 减少间距
            Icon(
              Icons.keyboard_arrow_down,
              size: 14,  // 更小的图标
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedFilterButton() {
    final hasFilters = filterOptions.hasAdvancedFilters;
    
    return GestureDetector(
      onTap: onAdvancedFilter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),  // 更小的内边距
        decoration: BoxDecoration(
          color: hasFilters ? TeamCenterConstants.primaryPurple.withValues(alpha: 0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),  // 更小的圆角
          border: Border.all(
            color: hasFilters ? TeamCenterConstants.primaryPurple.withValues(alpha: 0.3) : Colors.grey.shade200,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune,  // 更现代的筛选图标
              size: 14,  // 更小的图标
              color: hasFilters ? TeamCenterConstants.primaryPurple : Colors.grey[600],
            ),
            const SizedBox(width: 3),  // 减少间距
            Text(
              '筛选',
              style: TextStyle(
                color: hasFilters ? TeamCenterConstants.primaryPurple : Colors.black87,
                fontSize: 13,  // 稍小的字体
                fontWeight: FontWeight.w500,
              ),
            ),
            if (hasFilters) ...[
              const SizedBox(width: 3),
              Container(
                width: 16,  // 固定大小
                height: 16,
                decoration: const BoxDecoration(
                  color: TeamCenterConstants.primaryPurple,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${filterOptions.filterCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _SortBottomSheet(
        currentSort: filterOptions.sortType,
        onSortSelected: (sortType) {
          onSortTypeChanged?.call(sortType);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showGenderBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _GenderBottomSheet(
        currentGender: filterOptions.genderFilter,
        onGenderSelected: (genderFilter) {
          onGenderFilterChanged?.call(genderFilter);
          Navigator.pop(context);
        },
      ),
    );
  }
}

/// 📋 排序选择底部弹窗
class _SortBottomSheet extends StatelessWidget {
  final SortType currentSort;
  final ValueChanged<SortType> onSortSelected;

  const _SortBottomSheet({
    required this.currentSort,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: SortType.values.map((sortType) {
          final isSelected = currentSort == sortType;
          
          return ListTile(
            title: Text(
              sortType.displayName,
              style: TextStyle(
                color: isSelected ? TeamCenterConstants.primaryPurple : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            trailing: isSelected 
                ? const Icon(Icons.check, color: TeamCenterConstants.primaryPurple)
                : null,
            onTap: () => onSortSelected(sortType),
          );
        }).toList(),
      ),
    );
  }
}

/// 👥 性别筛选底部弹窗
class _GenderBottomSheet extends StatelessWidget {
  final GenderFilter currentGender;
  final ValueChanged<GenderFilter> onGenderSelected;

  const _GenderBottomSheet({
    required this.currentGender,
    required this.onGenderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: GenderFilter.values.map((genderFilter) {
          final isSelected = currentGender == genderFilter;
          
          return ListTile(
            title: Text(
              genderFilter.displayName,
              style: TextStyle(
                color: isSelected ? TeamCenterConstants.primaryPurple : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            trailing: isSelected 
                ? const Icon(Icons.check, color: TeamCenterConstants.primaryPurple)
                : null,
            onTap: () => onGenderSelected(genderFilter),
          );
        }).toList(),
      ),
    );
  }
}

/// 🎯 组局活动卡片组件
class _TeamActivityCard extends StatelessWidget {
  final TeamActivity activity;
  final VoidCallback? onTap;

  const _TeamActivityCard({
    required this.activity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),  // 减少垂直间距
        height: _TeamCenterPageConstants.cardHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),  // 统一圆角
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),  // 更淡的阴影
              blurRadius: 8,  // 更小的模糊半径
              offset: const Offset(0, 1),  // 更小的偏移
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Row(  // 改为横向布局，更紧凑
            children: [
              // 左侧背景图片区域
              _buildLeftImageSection(),
              
              // 右侧信息区域
              Expanded(
                child: _buildRightInfoSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 左侧头像区域 - 更简约的设计
  Widget _buildLeftImageSection() {
    return Container(
      width: 80,  // 更小的宽度，更紧凑
      height: double.infinity,
      padding: const EdgeInsets.all(16),  // 内边距
      child: Center(
        child: Container(
          width: 48,  // 稍大的头像
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: activity.host.avatar != null
                ? Image.network(
                    activity.host.avatar!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                        Container(
                          color: Colors.grey[100],
                          child: const Icon(Icons.person, color: Colors.grey, size: 24),
                        ),
                  )
                : Container(
                    color: Colors.grey[100],
                    child: const Icon(Icons.person, color: Colors.grey, size: 24),
                  ),
          ),
        ),
      ),
    );
  }

  // 右侧信息区域 - 贴近设计图的布局
  Widget _buildRightInfoSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 16, 12),  // 左侧无内边距，右侧留边距
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部：标题行
          Row(
            children: [
              Expanded(
                child: Text(
                  activity.title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,  // 稍小的标题
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // 右上角标签
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.pink.withValues(alpha: 0.1),  // 粉色标签，符合设计图
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '女神',  // 固定标签，符合设计图
                  style: TextStyle(
                    color: Colors.pink[400],
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 6),
          
          // 第二行：活动标签（模拟设计图中的蓝色和黄色标签）
          Row(
            children: [
              // 蓝色标签
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '高颜值',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              
              // 黄色标签
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '认证',
                  style: TextStyle(
                    color: Colors.orange[600],
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              const Spacer(),
              
              // 右侧价格标签（红色突出显示）
              Text(
                '300',
                style: const TextStyle(
                  color: Color(0xFFFF4444),  // 红色价格
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                ' 金币/小时',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 时间信息行
          _buildCompactInfoRow(
            Icons.access_time_outlined,
            '6月10日18:00  12小时前截止报名',
            Colors.grey[600]!,
          ),
          
          const SizedBox(height: 6),
          
          // 地点信息行
          _buildCompactInfoRow(
            Icons.location_on_outlined,
            '福田区下沙KKF ONE商城  2.3km',
            Colors.grey[600]!,
          ),
          
          const Spacer(),  // 让内容向上靠拢
        ],
      ),
    );
  }

  // 紧凑信息行组件 - 符合设计图样式
  Widget _buildCompactInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,  // 更小的字体
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }


}

// ============== 7. PAGES ==============
/// 📱 组局中心主页面
class TeamCenterMainPage extends StatefulWidget {
  const TeamCenterMainPage({super.key});

  @override
  State<TeamCenterMainPage> createState() => _TeamCenterMainPageState();
}

class _TeamCenterMainPageState extends State<TeamCenterMainPage> {
  late final _TeamCenterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _TeamCenterController();
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
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
    
    return Scaffold(
      backgroundColor: TeamCenterConstants.backgroundGray,
      appBar: _TeamCenterAppBar(
        onCreateTeam: _handleCreateTeam,
      ),
      body: ValueListenableBuilder<TeamCenterState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          if (state.isLoading && state.activities.isEmpty) {
            return _buildLoadingView();
          }

          if (state.errorMessage != null && state.activities.isEmpty) {
            return _buildErrorView(state.errorMessage!);
          }

          return _buildMainContent(state);
        },
      ),
    );
  }

  /// 构建加载视图
  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(TeamCenterConstants.primaryPurple),
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
              backgroundColor: TeamCenterConstants.primaryPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  /// 构建主要内容
  Widget _buildMainContent(TeamCenterState state) {
    return Column(
      children: [
        // 筛选标签栏
        _FilterTabBar(
          filterOptions: state.filterOptions,
          onSortTypeChanged: _controller.selectSortType,
          onGenderFilterChanged: _controller.selectGenderFilter,
          onActivityTypeChanged: _controller.selectActivityType,
          onAdvancedFilter: _showAdvancedFilter,
        ),
        
        // 组局列表
        Expanded(
          child: RefreshIndicator(
            color: TeamCenterConstants.primaryPurple,
            onRefresh: _controller.refresh,
            child: ListView.builder(
              controller: _controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.activities.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < state.activities.length) {
                  return _TeamActivityCard(
                    activity: state.activities[index],
                    onTap: () => _handleActivityTap(state.activities[index]),
                  );
                } else {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(TeamCenterConstants.primaryPurple),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 处理活动点击
  void _handleActivityTap(TeamActivity activity) {
    developer.log('点击组局活动: ${activity.title}');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamDetailPage(activityId: activity.id),
      ),
    );
  }

  /// 处理发布组局
  void _handleCreateTeam() async {
    developer.log('点击发布组局');
    
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateTeamPage(),
      ),
    );
    
    // 如果发布成功，刷新列表
    if (result == true) {
      _controller.refresh();
    }
  }

  /// 显示高级筛选页面
  void _showAdvancedFilter() {
    developer.log('显示高级筛选页面');
    // TODO: 实现高级筛选页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('高级筛选功能开发中')),
    );
  }
}

// ============== 8. EXPORTS ==============
/// 📤 导出定义
/// 
/// 本文件自动导出的公共类：
/// - TeamCenterMainPage: 组局中心主页面（public class）
///
/// 私有类（不会被导出）：
/// - _TeamCenterController: 组局中心控制器
/// - _TeamCenterAppBar: 顶部导航栏
/// - _FilterTabBar: 筛选标签栏
/// - _SortBottomSheet: 排序选择弹窗
/// - _GenderBottomSheet: 性别筛选弹窗
/// - _TeamActivityCard: 组局活动卡片
/// - _TeamCenterMainPageState: 页面状态类
/// - _TeamCenterPageConstants: 页面私有常量
///
/// 使用方式：
/// ```dart
/// import 'team_center_main_page.dart';
/// 
/// // 在路由中使用
/// MaterialPageRoute(builder: (context) => const TeamCenterMainPage())
/// ```
