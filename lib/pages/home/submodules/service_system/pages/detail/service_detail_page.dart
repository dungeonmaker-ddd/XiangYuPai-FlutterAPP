// 📋 通用服务详情页面 - 单文件架构完整实现
// 基于Flutter单文件架构规范的8段式结构设计
// 支持多种服务类型的详情展示页面

// ============== 1. IMPORTS ==============
// Flutter核心库
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Dart核心库
import 'dart:async';
import 'dart:developer' as developer;

// 项目内部文件
import '../../home_models.dart';      // 复用首页数据模型
import '../../home_services.dart';   // 复用首页服务
import 'service_models.dart';        // 服务系统数据模型
import 'order_confirm_page.dart';    // 订单确认页面

// ============== 2. CONSTANTS ==============
/// 🎨 服务详情页私有常量
class _ServiceDetailConstants {
  const _ServiceDetailConstants._();
  
  // 页面标识
  static const String pageTitle = '详情';
  static const String routeName = '/service-detail';
  
  // UI配置
  static const double bannerHeight = 200.0;
  static const double cardBorderRadius = 12.0;
  static const double avatarSize = 80.0;
  static const double tagBorderRadius = 12.0;
  static const double bottomBarHeight = 80.0;
  
  // 颜色配置
  static const int primaryPurple = 0xFF8B5CF6;
  static const int backgroundGray = 0xFFF9FAFB;
  static const int cardWhite = 0xFFFFFFFF;
  static const int textPrimary = 0xFF1F2937;
  static const int textSecondary = 0xFF6B7280;
  static const int successGreen = 0xFF10B981;
  static const int warningOrange = 0xFFF59E0B;
  static const int errorRed = 0xFFEF4444;
  
  // 评价标签
  static const List<String> reviewTags = ['精选', '声音好听', '技术好', '服务态度好', '性价比高'];
  
  // 服务类型对应的背景色
  static const Map<ServiceType, List<int>> serviceBackgrounds = {
    ServiceType.game: [0xFF1E3A8A, 0xFF3B82F6],        // 游戏：蓝色系
    ServiceType.entertainment: [0xFF7C3AED, 0xFFA855F7], // 娱乐：紫色系
    ServiceType.lifestyle: [0xFF059669, 0xFF10B981],     // 生活：绿色系
    ServiceType.work: [0xFFDC2626, 0xFFEF4444],         // 工作：红色系
  };
}

// ============== 3. MODELS ==============
// 使用 service_models.dart 中定义的通用模型

// ============== 4. SERVICES ==============
/// 🔧 服务详情服务
class _ServiceDetailService {
  /// 获取服务详情
  static Future<ServiceProviderModel> getProviderDetail(String providerId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // 这里应该从API获取详细信息，现在返回模拟数据
    // 实际实现中会根据providerId获取真实数据
    return ServiceProviderModel(
      id: providerId,
      nickname: '服务123',
      serviceType: ServiceType.game,
      isOnline: true,
      isVerified: true,
      rating: 4.8,
      reviewCount: 156,
      distance: 3.2,
      tags: ['专业', '技术好', '服务佳', '性价比高'],
      description: '专业服务提供者，技术过硬，服务态度好，能够根据您的需求提供最优质的服务体验。',
      pricePerService: 12.0,
      lastActiveTime: DateTime.now().subtract(const Duration(minutes: 5)),
      gender: '女',
      gameType: GameType.lol,
      gameRank: '王者',
      gameRegion: 'QQ区',
      gamePosition: '打野',
    );
  }
  
  /// 获取评价列表
  static Future<List<ServiceReviewModel>> getReviews({
    required String providerId,
    String tag = '精选',
    int page = 1,
    int limit = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    // 生成模拟评价数据
    final reviews = List.generate(limit, (index) {
      final baseIndex = (page - 1) * limit + index;
      final ratings = [4.0, 4.5, 5.0, 4.8, 4.2];
      final contents = [
        '技术很好，服务态度也很棒，非常满意！',
        '专业度很高，体验很好，会推荐给朋友',
        '服务质量不错，价格也合理，值得推荐',
        '非常专业，服务周到，下次还会选择',
        '性价比很高，服务态度也很好，推荐',
      ];
      final userNames = ['用户${100 + baseIndex}', '玩家${200 + baseIndex}', '顾客${300 + baseIndex}'];
      final tagsList = [
        ['技术好', '专业'],
        ['声音好听', '服务好'],
        ['有耐心', '认真'],
        ['准时', '可靠'],
        ['性价比高', '推荐'],
      ];
      
      return ServiceReviewModel(
        id: 'review_$baseIndex',
        userId: 'user_$baseIndex',
        userName: userNames[baseIndex % userNames.length],
        serviceProviderId: providerId,
        rating: ratings[baseIndex % ratings.length],
        content: contents[baseIndex % contents.length],
        tags: tagsList[baseIndex % tagsList.length],
        createdAt: DateTime.now().subtract(Duration(days: baseIndex % 30)),
        isHighlighted: tag == '精选' && baseIndex % 3 == 0,
      );
    });
    
    return reviews;
  }
}

// ============== 5. CONTROLLERS ==============
/// 🧠 服务详情控制器
class _ServiceDetailController extends ValueNotifier<ServiceDetailPageState> {
  _ServiceDetailController(this.provider) : super(const ServiceDetailPageState()) {
    _scrollController = ScrollController();
    _initialize();
  }

  final ServiceProviderModel provider;
  late ScrollController _scrollController;
  ScrollController get scrollController => _scrollController;

  /// 初始化数据
  Future<void> _initialize() async {
    try {
      value = value.copyWith(isLoading: true, errorMessage: null);
      
      // 并发加载服务者详情和评价
      final results = await Future.wait([
        _ServiceDetailService.getProviderDetail(provider.id),
        _ServiceDetailService.getReviews(
          providerId: provider.id,
          tag: value.selectedReviewTag,
          page: 1,
        ),
      ]);
      
      value = value.copyWith(
        isLoading: false,
        provider: results[0] as ServiceProviderModel,
        reviews: results[1] as List<ServiceReviewModel>,
        reviewPage: 1,
      );
      
      // 设置滚动监听
      _scrollController.addListener(_onScroll);
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: '加载失败，请重试',
      );
      developer.log('服务详情初始化失败: $e');
    }
  }

  /// 滚动监听 - 评价列表无限滚动
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      loadMoreReviews();
    }
  }

  /// 加载更多评价
  Future<void> loadMoreReviews() async {
    if (value.isLoadingReviews || !value.hasMoreReviews) return;

    try {
      value = value.copyWith(isLoadingReviews: true);

      final moreReviews = await _ServiceDetailService.getReviews(
        providerId: provider.id,
        tag: value.selectedReviewTag,
        page: value.reviewPage + 1,
      );

      if (moreReviews.isNotEmpty) {
        final updatedReviews = List<ServiceReviewModel>.from(value.reviews)
          ..addAll(moreReviews);
        
        value = value.copyWith(
          isLoadingReviews: false,
          reviews: updatedReviews,
          reviewPage: value.reviewPage + 1,
        );
      } else {
        value = value.copyWith(
          isLoadingReviews: false,
          hasMoreReviews: false,
        );
      }
    } catch (e) {
      value = value.copyWith(isLoadingReviews: false);
      developer.log('加载更多评价失败: $e');
    }
  }

  /// 切换评价标签
  Future<void> switchReviewTag(String tag) async {
    if (value.selectedReviewTag == tag) return;
    
    try {
      value = value.copyWith(
        selectedReviewTag: tag,
        isLoadingReviews: true,
        reviewPage: 1,
        hasMoreReviews: true,
      );
      
      final reviews = await _ServiceDetailService.getReviews(
        providerId: provider.id,
        tag: tag,
        page: 1,
      );
      
      value = value.copyWith(
        isLoadingReviews: false,
        reviews: reviews,
      );
    } catch (e) {
      value = value.copyWith(isLoadingReviews: false);
      developer.log('切换评价标签失败: $e');
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    value = value.copyWith(
      reviewPage: 1,
      hasMoreReviews: true,
    );
    await _initialize();
  }

  /// 私信服务者
  void contactProvider(BuildContext context) {
    if (value.provider == null) return;
    developer.log('私信服务者: ${value.provider!.nickname}');
    
    // TODO: 跳转到私信页面
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('私信 ${value.provider!.nickname} 功能开发中')),
    );
  }

  /// 下单服务
  void orderService(BuildContext context) {
    if (value.provider == null) return;
    developer.log('下单服务: ${value.provider!.nickname}');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmPage(provider: value.provider!),
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
/// 🎮 服务展示横幅组件
class _ServiceBannerWidget extends StatelessWidget {
  final ServiceProviderModel provider;

  const _ServiceBannerWidget({required this.provider});

  @override
  Widget build(BuildContext context) {
    final colors = _ServiceDetailConstants.serviceBackgrounds[provider.serviceType] ?? 
                   _ServiceDetailConstants.serviceBackgrounds[ServiceType.game]!;
    
    return Container(
      height: _ServiceDetailConstants.bannerHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(colors[0]), Color(colors[1])],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // 背景图案
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          
          // 服务信息
          Positioned(
            left: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.serviceType.displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getServiceSubtitle(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          // 服务图标
          Positioned(
            right: 20,
            bottom: 20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Icon(
                _getServiceIcon(),
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取服务副标题
  String _getServiceSubtitle() {
    switch (provider.serviceType) {
      case ServiceType.game:
        return '专业陪练 · 技术过硬';
      case ServiceType.entertainment:
        return '专业娱乐 · 品质服务';
      case ServiceType.lifestyle:
        return '生活服务 · 贴心便利';
      case ServiceType.work:
        return '工作兼职 · 专业可靠';
    }
  }

  /// 获取服务图标
  IconData _getServiceIcon() {
    switch (provider.serviceType) {
      case ServiceType.game:
        return Icons.sports_esports;
      case ServiceType.entertainment:
        return Icons.celebration;
      case ServiceType.lifestyle:
        return Icons.home_repair_service;
      case ServiceType.work:
        return Icons.work;
    }
  }
}

/// 👤 服务者信息卡片组件
class _ProviderInfoCard extends StatelessWidget {
  final ServiceProviderModel provider;

  const _ProviderInfoCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(_ServiceDetailConstants.cardWhite),
        borderRadius: BorderRadius.circular(_ServiceDetailConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 头像区域
              _buildAvatar(),
              const SizedBox(width: 16),
              
              // 基本信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNameAndStatus(),
                    const SizedBox(height: 8),
                    _buildServiceTags(),
                    const SizedBox(height: 8),
                    _buildPriceInfo(),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 服务统计信息
          _buildServiceStats(),
        ],
      ),
    );
  }

  /// 构建头像
  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: _ServiceDetailConstants.avatarSize,
          height: _ServiceDetailConstants.avatarSize,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(_ServiceDetailConstants.avatarSize / 2),
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 40),
        ),
        if (provider.isOnline)
          Positioned(
            right: 4,
            bottom: 4,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(_ServiceDetailConstants.successGreen),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 3),
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(_ServiceDetailConstants.textPrimary),
          ),
        ),
        const SizedBox(width: 8),
        if (provider.isVerified)
          const Icon(Icons.verified, color: Colors.blue, size: 20),
        const Spacer(),
        if (provider.isOnline)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(_ServiceDetailConstants.successGreen),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '在线',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  /// 构建服务标签
  Widget _buildServiceTags() {
    return Wrap(
      spacing: 8,
      children: provider.tags.asMap().entries.map((entry) {
        final index = entry.key;
        final tag = entry.value;
        final color = _getTagColor(index);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(_ServiceDetailConstants.tagBorderRadius),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
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

  /// 构建价格信息
  Widget _buildPriceInfo() {
    return Row(
      children: [
        Text(
          provider.priceText,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(_ServiceDetailConstants.errorRed),
          ),
        ),
        const SizedBox(width: 8),
        if (provider.pricePerService <= 10)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(_ServiceDetailConstants.errorRed).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '最低价',
              style: TextStyle(
                fontSize: 10,
                color: Color(_ServiceDetailConstants.errorRed),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  /// 构建服务统计
  Widget _buildServiceStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(_ServiceDetailConstants.backgroundGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('评分', '${provider.rating}', Icons.star, Colors.amber),
          _buildStatItem('评价', '${provider.reviewCount}+', Icons.comment, Colors.blue),
          _buildStatItem('距离', provider.distanceText, Icons.location_on, Colors.green),
          if (provider.gameRank != null)
            _buildStatItem('段位', provider.gameRank!, Icons.emoji_events, Colors.purple),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(_ServiceDetailConstants.textPrimary),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(_ServiceDetailConstants.textSecondary),
          ),
        ),
      ],
    );
  }
}

/// 📝 服务描述卡片组件
class _ServiceDescriptionCard extends StatelessWidget {
  final String title;
  final String description;

  const _ServiceDescriptionCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(_ServiceDetailConstants.cardWhite),
        borderRadius: BorderRadius.circular(_ServiceDetailConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(_ServiceDetailConstants.textPrimary),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Color(_ServiceDetailConstants.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// 💬 评价展示区域组件
class _ReviewSection extends StatelessWidget {
  final ServiceProviderModel provider;
  final List<ServiceReviewModel> reviews;
  final String selectedTag;
  final bool isLoading;
  final ValueChanged<String>? onTagChanged;

  const _ReviewSection({
    required this.provider,
    required this.reviews,
    required this.selectedTag,
    this.isLoading = false,
    this.onTagChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(_ServiceDetailConstants.cardWhite),
        borderRadius: BorderRadius.circular(_ServiceDetailConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 评价统计标题
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              '评价 (${provider.reviewCount}+) 好评率${(provider.rating * 20).toInt()}%',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(_ServiceDetailConstants.textPrimary),
              ),
            ),
          ),
          
          // 评价标签栏
          _buildReviewTags(),
          
          // 评价列表
          if (isLoading && reviews.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (reviews.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('暂无评价'),
              ),
            )
          else
            ...reviews.map((review) => _ReviewCard(review: review)),
        ],
      ),
    );
  }

  /// 构建评价标签
  Widget _buildReviewTags() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: _ServiceDetailConstants.reviewTags.map((tag) {
          final isSelected = selectedTag == tag;
          return GestureDetector(
            onTap: () => onTagChanged?.call(tag),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(_ServiceDetailConstants.primaryPurple)
                    : const Color(_ServiceDetailConstants.backgroundGray),
                borderRadius: BorderRadius.circular(_ServiceDetailConstants.tagBorderRadius),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected 
                      ? Colors.white 
                      : const Color(_ServiceDetailConstants.textSecondary),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// 💬 评价卡片组件
class _ReviewCard extends StatelessWidget {
  final ServiceReviewModel review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息和评分
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(_ServiceDetailConstants.textPrimary),
                      ),
                    ),
                    Text(
                      review.timeText,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(_ServiceDetailConstants.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              // 星级评分
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber,
                  );
                }),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 评价内容
          Text(
            review.content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(_ServiceDetailConstants.textPrimary),
            ),
          ),
          
          // 评价标签
          if (review.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: review.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(_ServiceDetailConstants.primaryPurple).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(_ServiceDetailConstants.primaryPurple),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// 🔻 底部操作栏组件
class _BottomActionBar extends StatelessWidget {
  final VoidCallback? onContactTap;
  final VoidCallback? onOrderTap;

  const _BottomActionBar({
    this.onContactTap,
    this.onOrderTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _ServiceDetailConstants.bottomBarHeight,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: const Color(_ServiceDetailConstants.cardWhite),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 私信按钮
            Expanded(
              flex: 1,
              child: Container(
                height: 48,
                margin: const EdgeInsets.only(right: 12),
                child: OutlinedButton(
                  onPressed: onContactTap,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(_ServiceDetailConstants.primaryPurple),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '私信',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(_ServiceDetailConstants.primaryPurple),
                    ),
                  ),
                ),
              ),
            ),
            
            // 下单按钮
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: onOrderTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(_ServiceDetailConstants.primaryPurple),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '下单',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============== 7. PAGES ==============
/// 📋 通用服务详情页面
class ServiceDetailPage extends StatefulWidget {
  final ServiceProviderModel provider;

  const ServiceDetailPage({
    super.key,
    required this.provider,
  });

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  late final _ServiceDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _ServiceDetailController(widget.provider);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(_ServiceDetailConstants.backgroundGray),
      appBar: AppBar(
        title: const Text(_ServiceDetailConstants.pageTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ValueListenableBuilder<ServiceDetailPageState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          if (state.isLoading && state.provider == null) {
            return _buildLoadingView();
          }

          if (state.errorMessage != null && state.provider == null) {
            return _buildErrorView(state.errorMessage!);
          }

          if (state.provider == null) {
            return _buildEmptyView();
          }

          return _buildMainContent(state);
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<ServiceDetailPageState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          if (state.provider == null) return const SizedBox.shrink();
          
          return _BottomActionBar(
            onContactTap: () => _controller.contactProvider(context),
            onOrderTap: () => _controller.orderService(context),
          );
        },
      ),
    );
  }

  /// 构建主要内容
  Widget _buildMainContent(ServiceDetailPageState state) {
    final provider = state.provider!;
    
    return RefreshIndicator(
      color: const Color(_ServiceDetailConstants.primaryPurple),
      onRefresh: _controller.refresh,
      child: CustomScrollView(
        controller: _controller.scrollController,
        slivers: [
          // 服务展示横幅
          SliverToBoxAdapter(
            child: _ServiceBannerWidget(provider: provider),
          ),
          
          // 服务者信息卡片
          SliverToBoxAdapter(
            child: _ProviderInfoCard(provider: provider),
          ),
          
          // 服务描述
          SliverToBoxAdapter(
            child: _ServiceDescriptionCard(
              title: _getServiceTitle(provider),
              description: provider.description,
            ),
          ),
          
          // 评价展示区域
          SliverToBoxAdapter(
            child: _ReviewSection(
              provider: provider,
              reviews: state.reviews,
              selectedTag: state.selectedReviewTag,
              isLoading: state.isLoadingReviews,
              onTagChanged: _controller.switchReviewTag,
            ),
          ),
          
          // 加载更多指示器
          if (state.isLoadingReviews && state.reviews.isNotEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          
          // 底部占位
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  /// 获取服务标题
  String _getServiceTitle(ServiceProviderModel provider) {
    switch (provider.serviceType) {
      case ServiceType.game:
        return '${provider.gameType?.displayName ?? '游戏'} 专业陪练';
      case ServiceType.entertainment:
        return '专业娱乐服务';
      case ServiceType.lifestyle:
        return '贴心生活服务';
      case ServiceType.work:
        return '专业工作服务';
    }
  }

  /// 构建加载视图
  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(_ServiceDetailConstants.primaryPurple)),
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
              backgroundColor: const Color(_ServiceDetailConstants.primaryPurple),
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
          Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('服务者信息不存在', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

// ============== 8. EXPORTS ==============
/// 📤 导出定义
