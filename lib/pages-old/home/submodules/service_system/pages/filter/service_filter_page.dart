// 🔍 服务筛选页面 - 单文件架构完整实现
// 基于Flutter单文件架构规范的8段式结构设计
// 通用的服务筛选页面，支持多种服务类型

// ============== 1. IMPORTS ==============
// Flutter核心库
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Dart核心库
import 'dart:async';
import 'dart:developer' as developer;

// 项目内部文件
import '../../models/service_models.dart';        // 服务系统数据模型
import '../detail/service_detail_page.dart';      // 服务详情页面

// ============== 2. CONSTANTS ==============
/// 🎨 服务筛选页私有常量
class _ServiceFilterConstants {
  const _ServiceFilterConstants._();
  
  // UI配置
  static const double cardBorderRadius = 12.0;
  static const double tagBorderRadius = 16.0;
  static const double filterSheetHeight = 0.8;
  static const int defaultPageSize = 20;
  
  // 颜色配置
  static const int primaryPurple = 0xFF8B5CF6;
  static const int selectedTagColor = 0xFF8B5CF6;
  static const int unselectedTagColor = 0xFFF3F4F6;
}

// ============== 3. MODELS ==============
// 使用 service_models.dart 中定义的通用模型

// ============== 4. SERVICES ==============
/// 🔧 服务筛选服务
class _ServiceFilterService {
  /// 获取服务提供者列表
  static Future<List<ServiceProviderModel>> getProviders({
    required ServiceType serviceType,
    ServiceFilterModel? filter,
    int page = 1,
    int limit = 20,
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));
    
    // 生成模拟数据
    final providers = List.generate(limit, (index) {
      final baseIndex = (page - 1) * limit + index;
      return ServiceProviderModel(
        id: '${serviceType.name}_provider_$baseIndex',
        nickname: '服务${100 + baseIndex}',
        serviceType: serviceType,
        isOnline: baseIndex % 3 == 0,
        isVerified: baseIndex % 5 == 0,
        rating: 4.0 + (baseIndex % 10) * 0.1,
        reviewCount: 50 + baseIndex * 10,
        distance: 1.0 + (baseIndex % 20) * 0.5,
        tags: _getRandomTags(serviceType, baseIndex),
        description: _getServiceDescription(serviceType),
        pricePerService: 8.0 + (baseIndex % 15) * 2.0,
        lastActiveTime: DateTime.now().subtract(Duration(hours: baseIndex % 24)),
        gender: baseIndex % 3 == 0 ? '女' : '男',
        // 游戏特定字段
        gameType: serviceType == ServiceType.game ? GameType.lol : null,
        gameRank: serviceType == ServiceType.game ? _getRandomRank(baseIndex) : null,
        gameRegion: serviceType == ServiceType.game ? (baseIndex % 2 == 0 ? 'QQ区' : '微信区') : null,
        gamePosition: serviceType == ServiceType.game ? _getRandomPosition(baseIndex) : null,
      );
    });
    
    // 应用筛选条件
    return _applyFilters(providers, filter);
  }
  
  /// 应用筛选条件
  static List<ServiceProviderModel> _applyFilters(
    List<ServiceProviderModel> providers,
    ServiceFilterModel? filter,
  ) {
    if (filter == null) return providers;
    
    var filtered = providers.where((provider) {
      // 性别筛选
      if (filter.genderFilter == '只看女生' && provider.gender != '女') {
        return false;
      }
      if (filter.genderFilter == '只看男生' && provider.gender != '男') {
        return false;
      }
      
      // 状态筛选
      if (filter.statusFilter == '在线' && !provider.isOnline) {
        return false;
      }
      if (filter.statusFilter == '离线' && provider.isOnline) {
        return false;
      }
      
      // 价格筛选
      if (filter.priceRange != null) {
        final price = provider.pricePerService;
        switch (filter.priceRange) {
          case '4-9元':
            if (price < 4 || price > 9) return false;
            break;
          case '10-19元':
            if (price < 10 || price > 19) return false;
            break;
          case '20元以上':
            if (price < 20) return false;
            break;
        }
      }
      
      // 标签筛选
      if (filter.selectedTags.isNotEmpty) {
        final hasMatchingTag = filter.selectedTags.any(
          (tag) => provider.tags.contains(tag),
        );
        if (!hasMatchingTag) return false;
      }
      
      return true;
    }).toList();
    
    // 应用排序
    switch (filter.sortType) {
      case '音质排序':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case '最近排序':
        filtered.sort((a, b) => b.lastActiveTime.compareTo(a.lastActiveTime));
        break;
      case '人气排序':
        filtered.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
      case '智能排序':
      default:
        // 智能排序：综合评分、距离、活跃度
        filtered.sort((a, b) {
          final scoreA = a.rating * 0.4 + (1 / (a.distance + 1)) * 0.3 + 
                        (a.isOnline ? 1 : 0) * 0.3;
          final scoreB = b.rating * 0.4 + (1 / (b.distance + 1)) * 0.3 + 
                        (b.isOnline ? 1 : 0) * 0.3;
          return scoreB.compareTo(scoreA);
        });
        break;
    }
    
    return filtered;
  }
  
  /// 获取随机标签
  static List<String> _getRandomTags(ServiceType serviceType, int seed) {
    List<String> tags;
    switch (serviceType) {
      case ServiceType.game:
        tags = ['王者', '专业', '上分', '高质量', '认证'];
        break;
      case ServiceType.entertainment:
        tags = ['专业', '有趣', '经验丰富', '服务好', '推荐'];
        break;
      case ServiceType.lifestyle:
        tags = ['专业', '技术好', '服务佳', '性价比高', '推荐'];
        break;
      case ServiceType.work:
        tags = ['可靠', '专业', '经验丰富', '效率高', '推荐'];
        break;
    }
    final random = seed % 5;
    return tags.take(2 + random % 3).toList();
  }
  
  /// 获取服务描述
  static String _getServiceDescription(ServiceType serviceType) {
    switch (serviceType) {
      case ServiceType.game:
        return '专业陪练，技术过硬，声音甜美，带您上分';
      case ServiceType.entertainment:
        return '专业娱乐服务，经验丰富，让您享受美好时光';
      case ServiceType.lifestyle:
        return '专业生活服务，技术过硬，让您生活更便利';
      case ServiceType.work:
        return '专业工作服务，经验丰富，帮您解决工作难题';
    }
  }
  
  /// 获取随机段位（游戏专用）
  static String _getRandomRank(int seed) {
    final ranks = ['青铜', '白银', '黄金', '白金', '钻石', '星耀', '王者'];
    return ranks[seed % ranks.length];
  }
  
  /// 获取随机位置（游戏专用）
  static String _getRandomPosition(int seed) {
    final positions = ['打野', '上路', '中路', '下路', '辅助'];
    return positions[seed % positions.length];
  }
}

// ============== 5. CONTROLLERS ==============
/// 🧠 服务筛选页面控制器
class _ServiceFilterController extends ValueNotifier<ServicePageState> {
  _ServiceFilterController(this.serviceType, this.serviceName) 
      : super(ServicePageState(serviceType: serviceType)) {
    _scrollController = ScrollController();
    _initialize();
  }

  final ServiceType serviceType;
  final String serviceName;
  late ScrollController _scrollController;
  ScrollController get scrollController => _scrollController;

  /// 初始化数据
  Future<void> _initialize() async {
    try {
      value = value.copyWith(isLoading: true, errorMessage: null);
      
      final providers = await _ServiceFilterService.getProviders(
        serviceType: serviceType,
        filter: value.filter,
        page: 1,
        limit: _ServiceFilterConstants.defaultPageSize,
      );
      
      value = value.copyWith(
        isLoading: false,
        providers: providers,
        currentPage: 1,
      );
      
      // 设置滚动监听
      _scrollController.addListener(_onScroll);
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: '加载失败，请重试',
      );
      developer.log('服务筛选页初始化失败: $e');
    }
  }

  /// 滚动监听 - 无限滚动加载更多
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      loadMore();
    }
  }

  /// 加载更多数据
  Future<void> loadMore() async {
    if (value.isLoadingMore || !value.hasMoreData) return;

    try {
      value = value.copyWith(isLoadingMore: true);

      final moreProviders = await _ServiceFilterService.getProviders(
        serviceType: serviceType,
        filter: value.filter,
        page: value.currentPage + 1,
        limit: _ServiceFilterConstants.defaultPageSize,
      );

      if (moreProviders.isNotEmpty) {
        final updatedProviders = List<ServiceProviderModel>.from(value.providers)
          ..addAll(moreProviders);
        
        value = value.copyWith(
          isLoadingMore: false,
          providers: updatedProviders,
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
      developer.log('加载更多服务者失败: $e');
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
  Future<void> updateFilter(ServiceFilterModel newFilter) async {
    if (value.filter == newFilter) return;
    
    value = value.copyWith(filter: newFilter);
    await refresh();
  }

  /// 重置筛选条件
  Future<void> resetFilters() async {
    final resetFilter = ServiceFilterModel(serviceType: serviceType);
    await updateFilter(resetFilter);
  }

  /// 点击服务者卡片 - 跳转到服务详情页面
  void selectProvider(ServiceProviderModel provider, BuildContext context) {
    developer.log('选择服务者: ${provider.nickname}');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailPage(provider: provider),
      ),
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
/// 🏷️ 快速筛选标签栏组件
class _QuickFilterBar extends StatelessWidget {
  final ServiceFilterModel filter;
  final ValueChanged<ServiceFilterModel>? onFilterChanged;
  final VoidCallback? onAdvancedFilterTap;

  const _QuickFilterBar({
    required this.filter,
    this.onFilterChanged,
    this.onAdvancedFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        children: [
          // 智能排序标签
          Expanded(
            child: _FilterTag(
              text: filter.sortType,
              isSelected: true,
              onTap: () => _showSortOptions(context),
            ),
          ),
          const SizedBox(width: 12),
          
          // 性别筛选标签
          Expanded(
            child: _FilterTag(
              text: filter.genderFilter,
              isSelected: filter.genderFilter != '不限性别',
              onTap: () => _showGenderOptions(context),
            ),
          ),
          const SizedBox(width: 12),
          
          // 状态标签
          Expanded(
            child: _FilterTag(
              text: filter.statusFilter ?? '状态',
              isSelected: filter.statusFilter != null,
              onTap: () => _showStatusOptions(context),
            ),
          ),
          const SizedBox(width: 12),
          
          // 高级筛选按钮
          _FilterTag(
            text: '筛选',
            isSelected: filter.hasAdvancedFilters,
            showCount: filter.hasAdvancedFilters ? filter.filterCount : null,
            onTap: onAdvancedFilterTap,
          ),
        ],
      ),
    );
  }

  /// 显示排序选项
  void _showSortOptions(BuildContext context) {
    _showOptionsBottomSheet(
      context,
      title: '排序方式',
      options: const ['智能排序', '音质排序', '最近排序', '人气排序'],
      selectedOption: filter.sortType,
      onSelected: (option) {
        onFilterChanged?.call(filter.copyWith(sortType: option));
      },
    );
  }

  /// 显示性别选项
  void _showGenderOptions(BuildContext context) {
    _showOptionsBottomSheet(
      context,
      title: '性别筛选',
      options: const ['不限性别', '只看女生', '只看男生'],
      selectedOption: filter.genderFilter,
      onSelected: (option) {
        onFilterChanged?.call(filter.copyWith(genderFilter: option));
      },
    );
  }

  /// 显示状态选项
  void _showStatusOptions(BuildContext context) {
    _showOptionsBottomSheet(
      context,
      title: '状态筛选',
      options: const ['不限', '在线', '离线'],
      selectedOption: filter.statusFilter ?? '不限',
      onSelected: (option) {
        final statusFilter = option == '不限' ? null : option;
        onFilterChanged?.call(filter.copyWith(statusFilter: statusFilter));
      },
    );
  }

  /// 显示选项底部弹窗
  void _showOptionsBottomSheet(
    BuildContext context, {
    required String title,
    required List<String> options,
    required String selectedOption,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ...options.map((option) => ListTile(
              title: Text(option),
              trailing: selectedOption == option
                  ? const Icon(Icons.check, color: Color(_ServiceFilterConstants.primaryPurple))
                  : null,
              onTap: () {
                Navigator.pop(context);
                onSelected(option);
              },
            )),
          ],
        ),
      ),
    );
  }
}

/// 🏷️ 筛选标签组件
class _FilterTag extends StatelessWidget {
  final String text;
  final bool isSelected;
  final int? showCount;
  final VoidCallback? onTap;

  const _FilterTag({
    required this.text,
    this.isSelected = false,
    this.showCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(_ServiceFilterConstants.selectedTagColor)
              : const Color(_ServiceFilterConstants.unselectedTagColor),
          borderRadius: BorderRadius.circular(_ServiceFilterConstants.tagBorderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showCount != null) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  showCount.toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isSelected ? Colors.white : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}

/// 👤 服务提供者卡片组件
class _ServiceProviderCard extends StatelessWidget {
  final ServiceProviderModel provider;
  final VoidCallback? onTap;

  const _ServiceProviderCard({
    required this.provider,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_ServiceFilterConstants.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像区域
            _buildAvatar(),
            const SizedBox(width: 12),
            
            // 信息区域
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNameAndStatus(),
                  const SizedBox(height: 8),
                  _buildTags(),
                  const SizedBox(height: 8),
                  _buildDescription(),
                  const SizedBox(height: 8),
                  _buildRatingAndDistance(),
                ],
              ),
            ),
            
            // 价格区域
            _buildPriceArea(),
          ],
        ),
      ),
    );
  }

  /// 构建头像
  Widget _buildAvatar() {
    return Stack(
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
        if (provider.isOnline)
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
    );
  }

  /// 构建姓名和状态
  Widget _buildNameAndStatus() {
    return Row(
      children: [
        Text(
          provider.nickname,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        if (provider.isVerified)
          const Icon(Icons.verified, color: Colors.blue, size: 16),
        const Spacer(),
        if (provider.isOnline)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '在线',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  /// 构建标签
  Widget _buildTags() {
    return Wrap(
      spacing: 6,
      children: provider.tags.asMap().entries.map((entry) {
        final index = entry.key;
        final tag = entry.value;
        final color = _getTagColor(index);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 获取标签颜色
  Color _getTagColor(int index) {
    final colors = [
      const Color(0xFF10B981), // 绿色
      const Color(0xFFEF4444), // 红色  
      const Color(0xFFF59E0B), // 黄色
      const Color(0xFF3B82F6), // 蓝色
    ];
    return colors[index % colors.length];
  }

  /// 构建描述
  Widget _buildDescription() {
    return Text(
      provider.description,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 构建评分和距离
  Widget _buildRatingAndDistance() {
    return Row(
      children: [
        Icon(Icons.star, size: 14, color: Colors.amber[600]),
        const SizedBox(width: 2),
        Text(
          '(${provider.reviewCount}+) 好评率${(provider.rating * 20).toInt()}%',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 2),
        Text(
          provider.distanceText,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// 构建价格区域
  Widget _buildPriceArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          provider.priceText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFEF4444),
          ),
        ),
        const SizedBox(height: 4),
        if (provider.pricePerService <= 10)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '最低价',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

// ============== 7. PAGES ==============
/// 🔍 通用服务筛选页面
class ServiceFilterPage extends StatefulWidget {
  final ServiceType serviceType;
  final String serviceName;

  const ServiceFilterPage({
    super.key,
    required this.serviceType,
    required this.serviceName,
  });

  @override
  State<ServiceFilterPage> createState() => _ServiceFilterPageState();
}

class _ServiceFilterPageState extends State<ServiceFilterPage> {
  late final _ServiceFilterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _ServiceFilterController(widget.serviceType, widget.serviceName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(widget.serviceName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _handleSearch,
          ),
        ],
      ),
      body: ValueListenableBuilder<ServicePageState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          return Column(
            children: [
              // 快速筛选标签栏
              _QuickFilterBar(
                filter: state.effectiveFilter,
                onFilterChanged: _controller.updateFilter,
                onAdvancedFilterTap: _showAdvancedFilter,
              ),
              
              // 服务者列表
              Expanded(
                child: _buildProvidersList(state),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 构建服务者列表
  Widget _buildProvidersList(ServicePageState state) {
    if (state.isLoading && state.providers.isEmpty) {
      return _buildLoadingView();
    }

    if (state.errorMessage != null && state.providers.isEmpty) {
      return _buildErrorView(state.errorMessage!);
    }

    if (state.providers.isEmpty) {
      return _buildEmptyView();
    }

    return RefreshIndicator(
      color: const Color(_ServiceFilterConstants.primaryPurple),
      onRefresh: _controller.refresh,
      child: ListView.builder(
        controller: _controller.scrollController,
        itemCount: state.providers.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < state.providers.length) {
            return _ServiceProviderCard(
              provider: state.providers[index],
              onTap: () => _controller.selectProvider(state.providers[index], context),
            );
          } else {
            return _buildLoadingMoreView();
          }
        },
      ),
    );
  }

  /// 构建加载视图
  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(_ServiceFilterConstants.primaryPurple)),
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
            onPressed: _controller.refresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(_ServiceFilterConstants.primaryPurple),
              foregroundColor: Colors.white,
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  /// 构建空状态视图
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('暂无符合条件的服务者', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _controller.resetFilters,
            child: const Text('重置筛选条件'),
          ),
        ],
      ),
    );
  }

  /// 构建加载更多视图
  Widget _buildLoadingMoreView() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(_ServiceFilterConstants.primaryPurple)),
        ),
      ),
    );
  }

  /// 显示高级筛选
  void _showAdvancedFilter() {
    // TODO: 实现高级筛选弹窗
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('高级筛选功能开发中')),
    );
  }

  /// 处理搜索
  void _handleSearch() {
    // TODO: 实现搜索功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('搜索功能开发中')),
    );
  }
}

// ============== 8. EXPORTS ==============
/// 📤 导出定义
