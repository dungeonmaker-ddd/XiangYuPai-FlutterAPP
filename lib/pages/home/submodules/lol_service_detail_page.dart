// 📋 LOL服务详情页面 - 单文件架构完整实现
// 基于Flutter单文件架构规范的8段式结构设计
// 服务详情筛选下单模块的第二个子页面

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
import 'lol_service_filter_page.dart'; // 引用LOL筛选页面的模型

// ============== 2. CONSTANTS ==============
/// 🎨 LOL服务详情页私有常量
class _LOLDetailConstants {
  const _LOLDetailConstants._();
  
  // 页面标识
  static const String pageTitle = '详情';
  static const String routeName = '/lol-detail';
  
  // UI配置
  static const double gameBannerHeight = 200.0;
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
}

// ============== 3. MODELS ==============
/// 💬 评价模型
class LOLReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final double rating;
  final String content;
  final List<String> tags;
  final DateTime createdAt;
  final bool isHighlighted; // 是否精选评价
  
  const LOLReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.content,
    this.tags = const [],
    required this.createdAt,
    this.isHighlighted = false,
  });
  
  /// 获取评价时间文本
  String get timeText {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 30) {
      return '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}

/// 📊 服务详情页面状态模型
class LOLDetailPageState {
  final bool isLoading;
  final String? errorMessage;
  final LOLServiceProviderModel? provider;
  final List<LOLReviewModel> reviews;
  final String selectedReviewTag;
  final bool isLoadingReviews;
  final bool hasMoreReviews;
  final int reviewPage;
  
  const LOLDetailPageState({
    this.isLoading = false,
    this.errorMessage,
    this.provider,
    this.reviews = const [],
    this.selectedReviewTag = '精选',
    this.isLoadingReviews = false,
    this.hasMoreReviews = true,
    this.reviewPage = 1,
  });
  
  LOLDetailPageState copyWith({
    bool? isLoading,
    String? errorMessage,
    LOLServiceProviderModel? provider,
    List<LOLReviewModel>? reviews,
    String? selectedReviewTag,
    bool? isLoadingReviews,
    bool? hasMoreReviews,
    int? reviewPage,
  }) {
    return LOLDetailPageState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      provider: provider ?? this.provider,
      reviews: reviews ?? this.reviews,
      selectedReviewTag: selectedReviewTag ?? this.selectedReviewTag,
      isLoadingReviews: isLoadingReviews ?? this.isLoadingReviews,
      hasMoreReviews: hasMoreReviews ?? this.hasMoreReviews,
      reviewPage: reviewPage ?? this.reviewPage,
    );
  }
}

// ============== 4. SERVICES ==============
/// 🔧 LOL服务详情服务
class _LOLDetailService {
  /// 获取服务详情
  static Future<LOLServiceProviderModel> getProviderDetail(String providerId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // 模拟获取详细信息（比筛选页面更详细）
    return LOLServiceProviderModel(
      id: providerId,
      nickname: '服务123',
      isOnline: true,
      isVerified: true,
      rating: 4.8,
      reviewCount: 156,
      distance: 3.2,
      gameTags: ['王者', '专业', '上分', '高质量'],
      description: '王者野王带您上星耀，专业陪练，技术过硬，声音甜美。擅长打野位置，熟悉各种英雄，能够根据队友配置选择最合适的英雄。游戏态度认真，从不挂机，保证游戏体验。',
      rank: '王者',
      region: 'QQ区',
      position: '打野',
      pricePerGame: 12.0,
      lastActiveTime: DateTime.now().subtract(const Duration(minutes: 5)),
      gender: '女',
    );
  }
  
  /// 获取评价列表
  static Future<List<LOLReviewModel>> getReviews({
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
        '技术很好，带我上了一个大段位，人也很nice，推荐！',
        '声音超甜，游戏技术也不错，玩得很开心',
        '专业陪练，很有耐心，会教一些游戏技巧',
        '准时上线，游戏态度认真，值得推荐',
        '性价比很高，服务态度也很好，会再来的',
      ];
      final userNames = ['用户${100 + baseIndex}', '玩家${200 + baseIndex}', '召唤师${300 + baseIndex}'];
      final tagsList = [
        ['技术好', '专业'],
        ['声音甜美', '服务好'],
        ['有耐心', '会教学'],
        ['准时', '认真'],
        ['性价比高', '态度好'],
      ];
      
      return LOLReviewModel(
        id: 'review_$baseIndex',
        userId: 'user_$baseIndex',
        userName: userNames[baseIndex % userNames.length],
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
/// 🧠 LOL服务详情控制器
class _LOLDetailController extends ValueNotifier<LOLDetailPageState> {
  _LOLDetailController(this.providerId) : super(const LOLDetailPageState()) {
    _scrollController = ScrollController();
    _initialize();
  }

  final String providerId;
  late ScrollController _scrollController;
  ScrollController get scrollController => _scrollController;

  /// 初始化数据
  Future<void> _initialize() async {
    try {
      value = value.copyWith(isLoading: true, errorMessage: null);
      
      // 并发加载服务者详情和评价
      final results = await Future.wait([
        _LOLDetailService.getProviderDetail(providerId),
        _LOLDetailService.getReviews(
          providerId: providerId,
          tag: value.selectedReviewTag,
          page: 1,
        ),
      ]);
      
      value = value.copyWith(
        isLoading: false,
        provider: results[0] as LOLServiceProviderModel,
        reviews: results[1] as List<LOLReviewModel>,
        reviewPage: 1,
      );
      
      // 设置滚动监听
      _scrollController.addListener(_onScroll);
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: '加载失败，请重试',
      );
      developer.log('LOL服务详情初始化失败: $e');
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

      final moreReviews = await _LOLDetailService.getReviews(
        providerId: providerId,
        tag: value.selectedReviewTag,
        page: value.reviewPage + 1,
      );

      if (moreReviews.isNotEmpty) {
        final updatedReviews = List<LOLReviewModel>.from(value.reviews)
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
      
      final reviews = await _LOLDetailService.getReviews(
        providerId: providerId,
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
  void contactProvider() {
    if (value.provider == null) return;
    developer.log('私信服务者: ${value.provider!.nickname}');
    // TODO: 跳转到私信页面
  }

  /// 下单服务
  void orderService() {
    if (value.provider == null) return;
    developer.log('下单服务: ${value.provider!.nickname}');
    // TODO: 跳转到下单确认页面
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
}

// ============== 6. WIDGETS ==============
/// 🎮 游戏展示区域组件
class _GameBannerWidget extends StatelessWidget {
  const _GameBannerWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _LOLDetailConstants.gameBannerHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E3A8A), // 深蓝色
            Color(0xFF3B82F6), // 蓝色
          ],
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
          
          // 游戏信息
          const Positioned(
            left: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '英雄联盟',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '专业陪练 · 技术过硬',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          // 游戏图标
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
              child: const Icon(
                Icons.sports_esports,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 👤 服务者信息卡片组件
class _ProviderInfoCard extends StatelessWidget {
  final LOLServiceProviderModel provider;

  const _ProviderInfoCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(_LOLDetailConstants.cardWhite),
        borderRadius: BorderRadius.circular(_LOLDetailConstants.cardBorderRadius),
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
                    _buildGameTags(),
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
          width: _LOLDetailConstants.avatarSize,
          height: _LOLDetailConstants.avatarSize,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(_LOLDetailConstants.avatarSize / 2),
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
                color: const Color(_LOLDetailConstants.successGreen),
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
            color: Color(_LOLDetailConstants.textPrimary),
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
              color: const Color(_LOLDetailConstants.successGreen),
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

  /// 构建游戏标签
  Widget _buildGameTags() {
    return Wrap(
      spacing: 8,
      children: provider.gameTags.asMap().entries.map((entry) {
        final index = entry.key;
        final tag = entry.value;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: provider.getTagColor(index).withOpacity(0.1),
            borderRadius: BorderRadius.circular(_LOLDetailConstants.tagBorderRadius),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 12,
              color: provider.getTagColor(index),
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
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
            color: Color(_LOLDetailConstants.errorRed),
          ),
        ),
        const SizedBox(width: 8),
        if (provider.pricePerGame <= 10)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(_LOLDetailConstants.errorRed).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '最低价',
              style: TextStyle(
                fontSize: 10,
                color: Color(_LOLDetailConstants.errorRed),
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
        color: const Color(_LOLDetailConstants.backgroundGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('评分', '${provider.rating}', Icons.star, Colors.amber),
          _buildStatItem('评价', '${provider.reviewCount}+', Icons.comment, Colors.blue),
          _buildStatItem('距离', provider.distanceText, Icons.location_on, Colors.green),
          _buildStatItem('段位', provider.rank, Icons.emoji_events, Colors.purple),
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
            color: Color(_LOLDetailConstants.textPrimary),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(_LOLDetailConstants.textSecondary),
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
        color: const Color(_LOLDetailConstants.cardWhite),
        borderRadius: BorderRadius.circular(_LOLDetailConstants.cardBorderRadius),
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
              color: Color(_LOLDetailConstants.textPrimary),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Color(_LOLDetailConstants.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// 💬 评价展示区域组件
class _ReviewSection extends StatelessWidget {
  final LOLServiceProviderModel provider;
  final List<LOLReviewModel> reviews;
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
        color: const Color(_LOLDetailConstants.cardWhite),
        borderRadius: BorderRadius.circular(_LOLDetailConstants.cardBorderRadius),
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
                color: Color(_LOLDetailConstants.textPrimary),
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
      child: Row(
        children: _LOLDetailConstants.reviewTags.map((tag) {
          final isSelected = selectedTag == tag;
          return GestureDetector(
            onTap: () => onTagChanged?.call(tag),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(_LOLDetailConstants.primaryPurple)
                    : const Color(_LOLDetailConstants.backgroundGray),
                borderRadius: BorderRadius.circular(_LOLDetailConstants.tagBorderRadius),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected 
                      ? Colors.white 
                      : const Color(_LOLDetailConstants.textSecondary),
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
  final LOLReviewModel review;

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
                        color: Color(_LOLDetailConstants.textPrimary),
                      ),
                    ),
                    Text(
                      review.timeText,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(_LOLDetailConstants.textSecondary),
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
              color: Color(_LOLDetailConstants.textPrimary),
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
                    color: const Color(_LOLDetailConstants.primaryPurple).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(_LOLDetailConstants.primaryPurple),
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
      height: _LOLDetailConstants.bottomBarHeight,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: const Color(_LOLDetailConstants.cardWhite),
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
                      color: Color(_LOLDetailConstants.primaryPurple),
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
                      color: Color(_LOLDetailConstants.primaryPurple),
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
                    backgroundColor: const Color(_LOLDetailConstants.primaryPurple),
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
/// 📋 LOL服务详情页面
class LOLServiceDetailPage extends StatefulWidget {
  final LOLServiceProviderModel provider;

  const LOLServiceDetailPage({
    super.key,
    required this.provider,
  });

  @override
  State<LOLServiceDetailPage> createState() => _LOLServiceDetailPageState();
}

class _LOLServiceDetailPageState extends State<LOLServiceDetailPage> {
  late final _LOLDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _LOLDetailController(widget.provider.id);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(_LOLDetailConstants.backgroundGray),
      appBar: AppBar(
        title: const Text(_LOLDetailConstants.pageTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ValueListenableBuilder<LOLDetailPageState>(
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
      bottomNavigationBar: ValueListenableBuilder<LOLDetailPageState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          if (state.provider == null) return const SizedBox.shrink();
          
          return _BottomActionBar(
            onContactTap: _controller.contactProvider,
            onOrderTap: _controller.orderService,
          );
        },
      ),
    );
  }

  /// 构建主要内容
  Widget _buildMainContent(LOLDetailPageState state) {
    final provider = state.provider!;
    
    return RefreshIndicator(
      color: const Color(_LOLDetailConstants.primaryPurple),
      onRefresh: _controller.refresh,
      child: CustomScrollView(
        controller: _controller.scrollController,
        slivers: [
          // 游戏展示区域
          const SliverToBoxAdapter(
            child: _GameBannerWidget(),
          ),
          
          // 服务者信息卡片
          SliverToBoxAdapter(
            child: _ProviderInfoCard(provider: provider),
          ),
          
          // 服务描述
          SliverToBoxAdapter(
            child: _ServiceDescriptionCard(
              title: '王者野王带您上星耀',
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

  /// 构建加载视图
  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(_LOLDetailConstants.primaryPurple)),
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
              backgroundColor: const Color(_LOLDetailConstants.primaryPurple),
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
/// 
/// 本文件导出的公共类：
/// - LOLServiceDetailPage: LOL服务详情页面（public class）
///
/// 使用方式：
/// ```dart
/// import 'lol_service_detail_page.dart';
/// 
/// // 在路由中使用
/// MaterialPageRoute(builder: (context) => LOLServiceDetailPage(provider: provider))
/// ```
