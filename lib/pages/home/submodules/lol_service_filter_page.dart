// 🎮 英雄联盟服务筛选页面 - 单文件架构完整实现
// 基于Flutter单文件架构规范的8段式结构设计
// 服务详情筛选下单模块的第一个子页面

// ============== 1. IMPORTS ==============
// Flutter核心库
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Dart核心库
import 'dart:async';
import 'dart:developer' as developer;

// 项目内部文件
import '../home_models.dart';      // 复用首页数据模型
import '../home_services.dart';   // 复用首页服务
import 'lol_advanced_filter_page.dart'; // 高级筛选页面
import 'lol_service_detail_page.dart';  // 服务详情页面

// ============== 2. CONSTANTS ==============
/// 🎨 LOL筛选页私有常量
class _LOLFilterConstants {
  const _LOLFilterConstants._();
  
  // 页面标识
  static const String pageTitle = '英雄联盟';
  static const String routeName = '/lol-filter';
  
  // 筛选选项
  static const List<String> sortOptions = ['智能排序', '音质排序', '最近排序', '人气排序'];
  static const List<String> genderOptions = ['不限时别', '只看女生', '只看男生'];
  static const List<String> statusOptions = ['在线', '离线'];
  static const List<String> regionOptions = ['QQ区', '微信区'];
  static const List<String> rankOptions = ['青铜白金', '永恒钻石', '至尊星耀', '最强王者'];
  static const List<String> priceOptions = ['4-9元', '10-19元', '20元以上'];
  static const List<String> positionOptions = ['打野', '上路', '中路', '下路', '辅助', '全部'];
  static const List<String> tagOptions = ['英雄王者', '大神认证', '高质量', '专精上分', '暴力认证', '声音甜美'];
  
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
/// 🎮 LOL服务提供者模型
class LOLServiceProviderModel {
  final String id;
  final String nickname;
  final String? avatar;
  final bool isOnline;
  final bool isVerified;
  final double rating;
  final int reviewCount;
  final double distance;
  final List<String> gameTags;     // 游戏标签：王者、专业、上分等
  final String description;        // 服务描述
  final String rank;              // 游戏段位
  final String region;            // 游戏大区
  final String position;          // 游戏位置
  final double pricePerGame;      // 单局价格
  final String currency;          // 货币类型
  final DateTime lastActiveTime;  // 最后活跃时间
  final String gender;            // 性别
  
  const LOLServiceProviderModel({
    required this.id,
    required this.nickname,
    this.avatar,
    required this.isOnline,
    this.isVerified = false,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.gameTags,
    required this.description,
    required this.rank,
    required this.region,
    required this.position,
    required this.pricePerGame,
    this.currency = '金币',
    required this.lastActiveTime,
    this.gender = '未知',
  });
  
  /// 获取标签颜色
  Color getTagColor(int index) {
    final colors = [
      const Color(0xFF10B981), // 绿色 - 王者
      const Color(0xFFEF4444), // 红色 - 专业  
      const Color(0xFFF59E0B), // 黄色 - 上分
      const Color(0xFF3B82F6), // 蓝色 - 其他
    ];
    return colors[index % colors.length];
  }
  
  /// 获取距离文本
  String get distanceText {
    if (distance < 1) {
      return '${(distance * 1000).toInt()}m';
    } else {
      return '${distance.toStringAsFixed(1)}km';
    }
  }
  
  /// 获取价格文本
  String get priceText => '$pricePerGame $currency/局';
  
  /// 获取评价文本
  String get reviewText => '($reviewCount+) 好评率${(rating * 20).toInt()}%';
}

/// 🔍 LOL筛选条件模型
class LOLFilterModel {
  final String sortType;           // 排序类型
  final String genderFilter;      // 性别筛选
  final String? statusFilter;     // 状态筛选
  final String? regionFilter;     // 大区筛选
  final String? rankFilter;       // 段位筛选
  final String? priceRange;       // 价格范围
  final String? positionFilter;   // 位置筛选
  final List<String> selectedTags; // 选中的标签
  final bool isLocal;             // 是否同城
  
  const LOLFilterModel({
    this.sortType = '智能排序',
    this.genderFilter = '不限时别',
    this.statusFilter,
    this.regionFilter,
    this.rankFilter,
    this.priceRange,
    this.positionFilter,
    this.selectedTags = const [],
    this.isLocal = false,
  });
  
  LOLFilterModel copyWith({
    String? sortType,
    String? genderFilter,
    String? statusFilter,
    String? regionFilter,
    String? rankFilter,
    String? priceRange,
    String? positionFilter,
    List<String>? selectedTags,
    bool? isLocal,
  }) {
    return LOLFilterModel(
      sortType: sortType ?? this.sortType,
      genderFilter: genderFilter ?? this.genderFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      regionFilter: regionFilter ?? this.regionFilter,
      rankFilter: rankFilter ?? this.rankFilter,
      priceRange: priceRange ?? this.priceRange,
      positionFilter: positionFilter ?? this.positionFilter,
      selectedTags: selectedTags ?? this.selectedTags,
      isLocal: isLocal ?? this.isLocal,
    );
  }
  
  /// 是否有高级筛选条件
  bool get hasAdvancedFilters {
    return statusFilter != null ||
           regionFilter != null ||
           rankFilter != null ||
           priceRange != null ||
           positionFilter != null ||
           selectedTags.isNotEmpty ||
           isLocal;
  }
  
  /// 获取筛选条件数量
  int get filterCount {
    int count = 0;
    if (statusFilter != null) count++;
    if (regionFilter != null) count++;
    if (rankFilter != null) count++;
    if (priceRange != null) count++;
    if (positionFilter != null) count++;
    count += selectedTags.length;
    if (isLocal) count++;
    return count;
  }
}

/// 📊 LOL筛选页面状态模型
class LOLFilterPageState {
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final List<LOLServiceProviderModel> providers;
  final LOLFilterModel filter;
  final bool hasMoreData;
  final int currentPage;
  final bool showFilterSheet;
  
  const LOLFilterPageState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.providers = const [],
    this.filter = const LOLFilterModel(),
    this.hasMoreData = true,
    this.currentPage = 1,
    this.showFilterSheet = false,
  });
  
  LOLFilterPageState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    List<LOLServiceProviderModel>? providers,
    LOLFilterModel? filter,
    bool? hasMoreData,
    int? currentPage,
    bool? showFilterSheet,
  }) {
    return LOLFilterPageState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      providers: providers ?? this.providers,
      filter: filter ?? this.filter,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
      showFilterSheet: showFilterSheet ?? this.showFilterSheet,
    );
  }
}

// ============== 4. SERVICES ==============
/// 🔧 LOL筛选服务
class _LOLFilterService {
  /// 获取LOL服务提供者列表
  static Future<List<LOLServiceProviderModel>> getProviders({
    LOLFilterModel? filter,
    int page = 1,
    int limit = 20,
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));
    
    // 生成模拟数据
    final providers = List.generate(limit, (index) {
      final baseIndex = (page - 1) * limit + index;
      return LOLServiceProviderModel(
        id: 'lol_provider_$baseIndex',
        nickname: '服务${100 + baseIndex}',
        isOnline: baseIndex % 3 == 0,
        isVerified: baseIndex % 5 == 0,
        rating: 4.0 + (baseIndex % 10) * 0.1,
        reviewCount: 50 + baseIndex * 10,
        distance: 1.0 + (baseIndex % 20) * 0.5,
        gameTags: _getRandomTags(baseIndex),
        description: '王者野王带您上星耀，专业陪练，技术过硬，声音甜美',
        rank: _getRandomRank(baseIndex),
        region: baseIndex % 2 == 0 ? 'QQ区' : '微信区',
        position: _getRandomPosition(baseIndex),
        pricePerGame: 8.0 + (baseIndex % 15) * 2.0,
        lastActiveTime: DateTime.now().subtract(Duration(hours: baseIndex % 24)),
        gender: baseIndex % 3 == 0 ? '女' : '男',
      );
    });
    
    // 应用筛选条件
    return _applyFilters(providers, filter);
  }
  
  /// 应用筛选条件
  static List<LOLServiceProviderModel> _applyFilters(
    List<LOLServiceProviderModel> providers,
    LOLFilterModel? filter,
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
      
      // 大区筛选
      if (filter.regionFilter != null && provider.region != filter.regionFilter) {
        return false;
      }
      
      // 段位筛选
      if (filter.rankFilter != null && !provider.rank.contains(filter.rankFilter!.split('').first)) {
        return false;
      }
      
      // 价格筛选
      if (filter.priceRange != null) {
        final price = provider.pricePerGame;
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
      
      // 位置筛选
      if (filter.positionFilter != null && 
          filter.positionFilter != '全部' && 
          provider.position != filter.positionFilter) {
        return false;
      }
      
      // 标签筛选
      if (filter.selectedTags.isNotEmpty) {
        final hasMatchingTag = filter.selectedTags.any(
          (tag) => provider.gameTags.contains(tag),
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
  static List<String> _getRandomTags(int seed) {
    final tags = ['王者', '专业', '上分', '高质量', '认证'];
    final random = seed % 5;
    return tags.take(2 + random % 3).toList();
  }
  
  /// 获取随机段位
  static String _getRandomRank(int seed) {
    final ranks = ['青铜', '白银', '黄金', '白金', '钻石', '星耀', '王者'];
    return ranks[seed % ranks.length];
  }
  
  /// 获取随机位置
  static String _getRandomPosition(int seed) {
    final positions = ['打野', '上路', '中路', '下路', '辅助'];
    return positions[seed % positions.length];
  }
}

// ============== 5. CONTROLLERS ==============
/// 🧠 LOL筛选页面控制器
class _LOLFilterController extends ValueNotifier<LOLFilterPageState> {
  _LOLFilterController() : super(const LOLFilterPageState()) {
    _scrollController = ScrollController();
    _initialize();
  }

  late ScrollController _scrollController;
  ScrollController get scrollController => _scrollController;

  /// 初始化数据
  Future<void> _initialize() async {
    try {
      value = value.copyWith(isLoading: true, errorMessage: null);
      
      final providers = await _LOLFilterService.getProviders(
        filter: value.filter,
        page: 1,
        limit: _LOLFilterConstants.defaultPageSize,
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
      developer.log('LOL筛选页初始化失败: $e');
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

      final moreProviders = await _LOLFilterService.getProviders(
        filter: value.filter,
        page: value.currentPage + 1,
        limit: _LOLFilterConstants.defaultPageSize,
      );

      if (moreProviders.isNotEmpty) {
        final updatedProviders = List<LOLServiceProviderModel>.from(value.providers)
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
      developer.log('加载更多LOL服务者失败: $e');
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
  Future<void> updateFilter(LOLFilterModel newFilter) async {
    if (value.filter == newFilter) return;
    
    value = value.copyWith(filter: newFilter);
    await refresh();
  }

  /// 显示高级筛选页面
  Future<void> showAdvancedFilter(BuildContext context) async {
    final result = await Navigator.push<LOLFilterModel>(
      context,
      MaterialPageRoute(
        builder: (context) => LOLAdvancedFilterPage(
          initialFilter: value.filter,
          onFilterChanged: (filter) {
            // 这个回调在页面内部处理
          },
        ),
      ),
    );
    
    if (result != null) {
      await updateFilter(result);
    }
  }

  /// 重置筛选条件
  Future<void> resetFilters() async {
    const resetFilter = LOLFilterModel();
    await updateFilter(resetFilter);
  }

  /// 点击服务者卡片 - 跳转到服务详情页面
  void selectProvider(LOLServiceProviderModel provider, BuildContext context) {
    developer.log('选择LOL服务者: ${provider.nickname}');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LOLServiceDetailPage(provider: provider),
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
  final LOLFilterModel filter;
  final ValueChanged<LOLFilterModel>? onFilterChanged;
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
              isSelected: filter.genderFilter != '不限时别',
              onTap: () => _showGenderOptions(context),
            ),
          ),
          const SizedBox(width: 12),
          
          // 情况标签（状态筛选）
          Expanded(
            child: _FilterTag(
              text: filter.statusFilter ?? '情况',
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
      options: _LOLFilterConstants.sortOptions,
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
      options: _LOLFilterConstants.genderOptions,
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
      options: ['不限', ..._LOLFilterConstants.statusOptions],
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
                  ? const Icon(Icons.check, color: Color(_LOLFilterConstants.primaryPurple))
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
              ? const Color(_LOLFilterConstants.selectedTagColor)
              : const Color(_LOLFilterConstants.unselectedTagColor),
          borderRadius: BorderRadius.circular(_LOLFilterConstants.tagBorderRadius),
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

/// 👤 LOL服务者卡片组件
class _LOLProviderCard extends StatelessWidget {
  final LOLServiceProviderModel provider;
  final VoidCallback? onTap;

  const _LOLProviderCard({
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
          borderRadius: BorderRadius.circular(_LOLFilterConstants.cardBorderRadius),
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
                  _buildGameTags(),
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

  /// 构建游戏标签
  Widget _buildGameTags() {
    return Wrap(
      spacing: 6,
      children: provider.gameTags.asMap().entries.map((entry) {
        final index = entry.key;
        final tag = entry.value;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: provider.getTagColor(index).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 10,
              color: provider.getTagColor(index),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
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
          provider.reviewText,
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
        if (provider.pricePerGame <= 10)
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
/// 🎮 LOL服务筛选页面
class LOLServiceFilterPage extends StatefulWidget {
  const LOLServiceFilterPage({super.key});

  @override
  State<LOLServiceFilterPage> createState() => _LOLServiceFilterPageState();
}

class _LOLServiceFilterPageState extends State<LOLServiceFilterPage> {
  late final _LOLFilterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _LOLFilterController();
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
        title: const Text(_LOLFilterConstants.pageTitle),
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
      body: ValueListenableBuilder<LOLFilterPageState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          return Column(
            children: [
              // 快速筛选标签栏
              _QuickFilterBar(
                filter: state.filter,
                onFilterChanged: _controller.updateFilter,
                onAdvancedFilterTap: () => _controller.showAdvancedFilter(context),
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
  Widget _buildProvidersList(LOLFilterPageState state) {
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
      color: const Color(_LOLFilterConstants.primaryPurple),
      onRefresh: _controller.refresh,
      child: ListView.builder(
        controller: _controller.scrollController,
        itemCount: state.providers.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < state.providers.length) {
            return _LOLProviderCard(
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
        valueColor: AlwaysStoppedAnimation<Color>(Color(_LOLFilterConstants.primaryPurple)),
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
              backgroundColor: const Color(_LOLFilterConstants.primaryPurple),
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
          valueColor: AlwaysStoppedAnimation<Color>(Color(_LOLFilterConstants.primaryPurple)),
        ),
      ),
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
/// 
/// 本文件导出的公共类：
/// - LOLServiceFilterPage: LOL服务筛选页面（public class）
///
/// 使用方式：
/// ```dart
/// import 'lol_service_filter_page.dart';
/// 
/// // 在路由中使用
/// MaterialPageRoute(builder: (context) => const LOLServiceFilterPage())
/// ```
