// 💬 评价反馈页面 - 单文件架构完整实现
// 基于Flutter单文件架构规范的8段式结构设计
// 完整的评价展示和反馈管理系统

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

// ============== 2. CONSTANTS ==============
/// 🎨 评价反馈页私有常量
class _ReviewFeedbackConstants {
  const _ReviewFeedbackConstants._();
  
  // 页面标识
  static const String pageTitle = '评价反馈';
  static const String routeName = '/review-feedback';
  
  // UI配置
  static const double cardBorderRadius = 12.0;
  static const double sectionSpacing = 16.0;
  static const double ratingStarSize = 32.0;
  static const double tagBorderRadius = 16.0;
  static const int maxReviewLength = 500;
  
  // 颜色配置
  static const int primaryPurple = 0xFF8B5CF6;
  static const int backgroundGray = 0xFFF9FAFB;
  static const int cardWhite = 0xFFFFFFFF;
  static const int textPrimary = 0xFF1F2937;
  static const int textSecondary = 0xFF6B7280;
  static const int successGreen = 0xFF10B981;
  static const int errorRed = 0xFFEF4444;
  static const int borderGray = 0xFFE5E7EB;
  static const int warningOrange = 0xFFF59E0B;
  static const int starYellow = 0xFFFBBF24;
  
  // 评价标签
  static const List<String> positiveReviewTags = [
    '技术好', '声音甜美', '服务态度好', '专业', '有耐心', '准时', '性价比高', '推荐'
  ];
  
  static const List<String> negativeReviewTags = [
    '技术一般', '服务态度差', '不够专业', '经常迟到', '价格偏高', '体验不佳'
  ];
  
  // 评分描述
  static const Map<int, String> ratingDescriptions = {
    1: '非常不满意',
    2: '不满意',
    3: '一般',
    4: '满意',
    5: '非常满意',
  };
}

// ============== 3. MODELS ==============
/// 📝 评价反馈页面状态模型
class ReviewFeedbackPageState {
  final bool isLoading;
  final String? errorMessage;
  final ServiceOrderModel? order;
  final double rating;
  final String reviewContent;
  final List<String> selectedTags;
  final bool isSubmitting;
  final bool isSubmitted;
  
  const ReviewFeedbackPageState({
    this.isLoading = false,
    this.errorMessage,
    this.order,
    this.rating = 5.0,
    this.reviewContent = '',
    this.selectedTags = const [],
    this.isSubmitting = false,
    this.isSubmitted = false,
  });
  
  ReviewFeedbackPageState copyWith({
    bool? isLoading,
    String? errorMessage,
    ServiceOrderModel? order,
    double? rating,
    String? reviewContent,
    List<String>? selectedTags,
    bool? isSubmitting,
    bool? isSubmitted,
  }) {
    return ReviewFeedbackPageState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      order: order ?? this.order,
      rating: rating ?? this.rating,
      reviewContent: reviewContent ?? this.reviewContent,
      selectedTags: selectedTags ?? this.selectedTags,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
  
  /// 获取评价标签列表
  List<String> get availableTags {
    return rating >= 4.0 
        ? _ReviewFeedbackConstants.positiveReviewTags
        : _ReviewFeedbackConstants.negativeReviewTags;
  }
  
  /// 获取评分描述
  String get ratingDescription {
    return _ReviewFeedbackConstants.ratingDescriptions[rating.toInt()] ?? '满意';
  }
  
  /// 检查是否可以提交
  bool get canSubmit {
    return !isSubmitting && 
           !isSubmitted && 
           rating > 0 && 
           reviewContent.trim().isNotEmpty;
  }
}

// ============== 4. SERVICES ==============
/// 🔧 评价反馈服务
class _ReviewFeedbackService {
  /// 获取订单信息
  static Future<ServiceOrderModel> getOrderInfo(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 模拟获取订单信息
    // 实际实现中应该从API获取真实订单数据
    final provider = ServiceProviderModel(
      id: 'provider_123',
      nickname: '服务123',
      serviceType: ServiceType.game,
      isOnline: true,
      isVerified: true,
      rating: 4.8,
      reviewCount: 156,
      distance: 3.2,
      tags: ['专业', '技术好', '服务佳'],
      description: '专业服务提供者',
      pricePerService: 12.0,
      lastActiveTime: DateTime.now().subtract(const Duration(hours: 1)),
      gender: '女',
      gameType: GameType.lol,
      gameRank: '王者',
      gameRegion: 'QQ区',
      gamePosition: '打野',
    );
    
    return ServiceOrderModel(
      id: orderId,
      serviceProviderId: provider.id,
      serviceProvider: provider,
      serviceType: ServiceType.game,
      gameType: GameType.lol,
      quantity: 3,
      unitPrice: 12.0,
      totalPrice: 36.0,
      currency: '金币',
      status: OrderStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      completedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    );
  }
  
  /// 提交评价
  static Future<ServiceReviewModel> submitReview({
    required String orderId,
    required String serviceProviderId,
    required double rating,
    required String content,
    required List<String> tags,
  }) async {
    // 模拟网络请求延迟
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // 模拟提交失败的情况（10%概率）
    if (DateTime.now().millisecond % 10 == 0) {
      throw '评价提交失败，请重试';
    }
    
    // 生成评价ID
    final reviewId = 'review_${DateTime.now().millisecondsSinceEpoch}';
    
    return ServiceReviewModel(
      id: reviewId,
      userId: 'current_user_id',
      userName: '当前用户',
      serviceProviderId: serviceProviderId,
      rating: rating,
      content: content,
      tags: tags,
      createdAt: DateTime.now(),
      isHighlighted: rating >= 4.5,
    );
  }
  
  /// 检查是否已经评价过
  static Future<bool> hasReviewed(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    // 模拟检查结果（实际应该查询后端）
    return false; // 假设还未评价
  }
}

// ============== 5. CONTROLLERS ==============
/// 🧠 评价反馈页面控制器
class _ReviewFeedbackController extends ValueNotifier<ReviewFeedbackPageState> {
  _ReviewFeedbackController(this.orderId) : super(const ReviewFeedbackPageState()) {
    _initialize();
  }

  final String orderId;
  final TextEditingController reviewController = TextEditingController();

  /// 初始化数据
  Future<void> _initialize() async {
    try {
      value = value.copyWith(isLoading: true, errorMessage: null);
      
      // 并发检查是否已评价和获取订单信息
      final results = await Future.wait([
        _ReviewFeedbackService.hasReviewed(orderId),
        _ReviewFeedbackService.getOrderInfo(orderId),
      ]);
      
      final hasReviewed = results[0] as bool;
      final order = results[1] as ServiceOrderModel;
      
      if (hasReviewed) {
        value = value.copyWith(
          isLoading: false,
          isSubmitted: true,
          order: order,
          errorMessage: '您已经对此订单进行过评价',
        );
      } else {
        value = value.copyWith(
          isLoading: false,
          order: order,
        );
      }
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: '加载失败: $e',
      );
      developer.log('评价反馈页初始化失败: $e');
    }
  }

  /// 更新评分
  void updateRating(double newRating) {
    if (value.isSubmitted) return;
    
    value = value.copyWith(
      rating: newRating,
      selectedTags: [], // 清空已选标签，因为标签列表可能会变化
      errorMessage: null,
    );
  }

  /// 更新评价内容
  void updateReviewContent(String content) {
    if (value.isSubmitted) return;
    
    // 限制字符长度
    if (content.length > _ReviewFeedbackConstants.maxReviewLength) {
      content = content.substring(0, _ReviewFeedbackConstants.maxReviewLength);
      reviewController.text = content;
      reviewController.selection = TextSelection.fromPosition(
        TextPosition(offset: content.length),
      );
    }
    
    value = value.copyWith(
      reviewContent: content,
      errorMessage: null,
    );
  }

  /// 切换标签选择状态
  void toggleTag(String tag) {
    if (value.isSubmitted) return;
    
    final currentTags = List<String>.from(value.selectedTags);
    
    if (currentTags.contains(tag)) {
      currentTags.remove(tag);
    } else {
      // 限制最多选择5个标签
      if (currentTags.length < 5) {
        currentTags.add(tag);
      }
    }
    
    value = value.copyWith(
      selectedTags: currentTags,
      errorMessage: null,
    );
  }

  /// 提交评价
  Future<void> submitReview(BuildContext context) async {
    if (!value.canSubmit || value.order == null) return;
    
    try {
      value = value.copyWith(isSubmitting: true, errorMessage: null);
      
      // 验证评价内容
      final content = value.reviewContent.trim();
      if (content.isEmpty) {
        throw '请填写评价内容';
      }
      
      if (content.length < 10) {
        throw '评价内容至少需要10个字符';
      }
      
      // 提交评价
      final review = await _ReviewFeedbackService.submitReview(
        orderId: orderId,
        serviceProviderId: value.order!.serviceProviderId,
        rating: value.rating,
        content: content,
        tags: value.selectedTags,
      );
      
      value = value.copyWith(
        isSubmitting: false,
        isSubmitted: true,
      );
      
      // 显示成功提示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('评价提交成功！'),
            backgroundColor: Color(_ReviewFeedbackConstants.successGreen),
          ),
        );
        
        // 延迟返回上一页
        Timer(const Duration(seconds: 2), () {
          if (context.mounted) {
            Navigator.pop(context, review);
          }
        });
      }
    } catch (e) {
      value = value.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      developer.log('提交评价失败: $e');
    }
  }

  /// 返回上一页
  void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }
}

// ============== 6. WIDGETS ==============
/// 📋 订单信息卡片
class _OrderInfoCard extends StatelessWidget {
  final ServiceOrderModel order;

  const _OrderInfoCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(_ReviewFeedbackConstants.cardWhite),
        borderRadius: BorderRadius.circular(_ReviewFeedbackConstants.cardBorderRadius),
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
          // 标题
          const Text(
            '服务订单',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(_ReviewFeedbackConstants.textPrimary),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 服务者信息
          Row(
            children: [
              // 头像
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 28),
              ),
              
              const SizedBox(width: 12),
              
              // 基本信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          order.serviceProvider.nickname,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(_ReviewFeedbackConstants.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (order.serviceProvider.isVerified)
                          const Icon(Icons.verified, color: Colors.blue, size: 16),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.serviceType.displayName}${order.gameType != null ? ' · ${order.gameType!.displayName}' : ''}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(_ReviewFeedbackConstants.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 订单状态
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(_ReviewFeedbackConstants.successGreen).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.status.displayName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(_ReviewFeedbackConstants.successGreen),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 订单详情
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(_ReviewFeedbackConstants.backgroundGray),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildOrderDetailRow('服务数量', '${order.quantity} ${order.serviceUnit}'),
                const SizedBox(height: 8),
                _buildOrderDetailRow('订单金额', '${order.totalPrice} ${order.currency}'),
                const SizedBox(height: 8),
                _buildOrderDetailRow('完成时间', _formatDateTime(order.completedAt)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建订单详情行
  Widget _buildOrderDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(_ReviewFeedbackConstants.textSecondary),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(_ReviewFeedbackConstants.textPrimary),
          ),
        ),
      ],
    );
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '未知';
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// ⭐ 评分选择组件
class _RatingSelector extends StatelessWidget {
  final double rating;
  final String description;
  final bool isEnabled;
  final ValueChanged<double>? onRatingChanged;

  const _RatingSelector({
    required this.rating,
    required this.description,
    this.isEnabled = true,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(_ReviewFeedbackConstants.cardWhite),
        borderRadius: BorderRadius.circular(_ReviewFeedbackConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 标题
          const Text(
            '服务评分',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(_ReviewFeedbackConstants.textPrimary),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 星级评分
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starRating = index + 1;
              final isFilled = starRating <= rating;
              
              return GestureDetector(
                onTap: isEnabled ? () => onRatingChanged?.call(starRating.toDouble()) : null,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    isFilled ? Icons.star : Icons.star_border,
                    size: _ReviewFeedbackConstants.ratingStarSize,
                    color: isFilled 
                        ? const Color(_ReviewFeedbackConstants.starYellow)
                        : const Color(_ReviewFeedbackConstants.borderGray),
                  ),
                ),
              );
            }),
          ),
          
          const SizedBox(height: 12),
          
          // 评分描述
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _getRatingColor(rating),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取评分对应的颜色
  Color _getRatingColor(double rating) {
    if (rating >= 4.0) {
      return const Color(_ReviewFeedbackConstants.successGreen);
    } else if (rating >= 3.0) {
      return const Color(_ReviewFeedbackConstants.warningOrange);
    } else {
      return const Color(_ReviewFeedbackConstants.errorRed);
    }
  }
}

/// 🏷️ 评价标签选择组件
class _ReviewTagSelector extends StatelessWidget {
  final List<String> availableTags;
  final List<String> selectedTags;
  final bool isEnabled;
  final ValueChanged<String>? onTagToggle;

  const _ReviewTagSelector({
    required this.availableTags,
    required this.selectedTags,
    this.isEnabled = true,
    this.onTagToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(_ReviewFeedbackConstants.cardWhite),
        borderRadius: BorderRadius.circular(_ReviewFeedbackConstants.cardBorderRadius),
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
          // 标题
          Row(
            children: [
              const Text(
                '评价标签',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(_ReviewFeedbackConstants.textPrimary),
                ),
              ),
              const Spacer(),
              Text(
                '${selectedTags.length}/5',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(_ReviewFeedbackConstants.textSecondary),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          const Text(
            '选择最多5个标签来描述此次服务',
            style: TextStyle(
              fontSize: 12,
              color: Color(_ReviewFeedbackConstants.textSecondary),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 标签网格
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableTags.map((tag) {
              final isSelected = selectedTags.contains(tag);
              final canSelect = isEnabled && (isSelected || selectedTags.length < 5);
              
              return GestureDetector(
                onTap: canSelect ? () => onTagToggle?.call(tag) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(_ReviewFeedbackConstants.primaryPurple)
                        : const Color(_ReviewFeedbackConstants.backgroundGray),
                    borderRadius: BorderRadius.circular(_ReviewFeedbackConstants.tagBorderRadius),
                    border: isSelected ? null : Border.all(
                      color: const Color(_ReviewFeedbackConstants.borderGray),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected 
                          ? Colors.white
                          : canSelect 
                              ? const Color(_ReviewFeedbackConstants.textPrimary)
                              : const Color(_ReviewFeedbackConstants.textSecondary),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// 📝 评价内容输入组件
class _ReviewContentInput extends StatelessWidget {
  final TextEditingController controller;
  final String content;
  final bool isEnabled;
  final ValueChanged<String>? onChanged;

  const _ReviewContentInput({
    required this.controller,
    required this.content,
    this.isEnabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(_ReviewFeedbackConstants.cardWhite),
        borderRadius: BorderRadius.circular(_ReviewFeedbackConstants.cardBorderRadius),
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
          // 标题
          Row(
            children: [
              const Text(
                '详细评价',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(_ReviewFeedbackConstants.textPrimary),
                ),
              ),
              const Spacer(),
              Text(
                '${content.length}/${_ReviewFeedbackConstants.maxReviewLength}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(_ReviewFeedbackConstants.textSecondary),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          const Text(
            '分享您的服务体验，帮助其他用户做出选择',
            style: TextStyle(
              fontSize: 12,
              color: Color(_ReviewFeedbackConstants.textSecondary),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 文本输入框
          TextField(
            controller: controller,
            onChanged: onChanged,
            enabled: isEnabled,
            maxLines: 6,
            maxLength: _ReviewFeedbackConstants.maxReviewLength,
            decoration: InputDecoration(
              hintText: '请详细描述您的服务体验...',
              hintStyle: const TextStyle(
                color: Color(_ReviewFeedbackConstants.textSecondary),
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(_ReviewFeedbackConstants.borderGray)),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(_ReviewFeedbackConstants.primaryPurple)),
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(12),
              counterText: '', // 隐藏默认计数器
            ),
          ),
        ],
      ),
    );
  }
}

/// ✅ 提交成功组件
class _SubmitSuccessWidget extends StatelessWidget {
  const _SubmitSuccessWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(_ReviewFeedbackConstants.cardWhite),
        borderRadius: BorderRadius.circular(_ReviewFeedbackConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 成功图标
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(_ReviewFeedbackConstants.successGreen).withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(_ReviewFeedbackConstants.successGreen),
              size: 48,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 成功标题
          const Text(
            '评价提交成功',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(_ReviewFeedbackConstants.textPrimary),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 成功描述
          const Text(
            '感谢您的反馈，您的评价将帮助其他用户做出更好的选择',
            style: TextStyle(
              fontSize: 14,
              color: Color(_ReviewFeedbackConstants.textSecondary),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// 🔻 底部提交按钮
class _BottomSubmitButton extends StatelessWidget {
  final bool canSubmit;
  final bool isSubmitting;
  final VoidCallback? onSubmit;

  const _BottomSubmitButton({
    required this.canSubmit,
    this.isSubmitting = false,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: const Color(_ReviewFeedbackConstants.cardWhite),
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
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: canSubmit && !isSubmitting ? onSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(_ReviewFeedbackConstants.primaryPurple),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    '提交评价',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ============== 7. PAGES ==============
/// 💬 评价反馈页面
class ReviewFeedbackPage extends StatefulWidget {
  final String orderId;

  const ReviewFeedbackPage({
    super.key,
    required this.orderId,
  });

  @override
  State<ReviewFeedbackPage> createState() => _ReviewFeedbackPageState();
}

class _ReviewFeedbackPageState extends State<ReviewFeedbackPage> {
  late final _ReviewFeedbackController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _ReviewFeedbackController(widget.orderId);
    _controller.reviewController.addListener(() {
      _controller.updateReviewContent(_controller.reviewController.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(_ReviewFeedbackConstants.backgroundGray),
      appBar: AppBar(
        title: const Text(_ReviewFeedbackConstants.pageTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _controller.goBack(context),
        ),
      ),
      body: ValueListenableBuilder<ReviewFeedbackPageState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          if (state.isLoading) {
            return _buildLoadingView();
          }

          if (state.errorMessage != null && state.order == null) {
            return _buildErrorView(state.errorMessage!);
          }

          if (state.order == null) {
            return _buildEmptyView();
          }

          return _buildMainContent(state);
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<ReviewFeedbackPageState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          if (state.isSubmitted || state.order == null) {
            return const SizedBox.shrink();
          }
          
          return _BottomSubmitButton(
            canSubmit: state.canSubmit,
            isSubmitting: state.isSubmitting,
            onSubmit: () => _controller.submitReview(context),
          );
        },
      ),
    );
  }

  /// 构建主要内容
  Widget _buildMainContent(ReviewFeedbackPageState state) {
    if (state.isSubmitted) {
      return const SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 40),
            _SubmitSuccessWidget(),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // 订单信息
          _OrderInfoCard(order: state.order!),
          
          // 评分选择
          _RatingSelector(
            rating: state.rating,
            description: state.ratingDescription,
            isEnabled: !state.isSubmitted,
            onRatingChanged: _controller.updateRating,
          ),
          
          // 评价标签选择
          _ReviewTagSelector(
            availableTags: state.availableTags,
            selectedTags: state.selectedTags,
            isEnabled: !state.isSubmitted,
            onTagToggle: _controller.toggleTag,
          ),
          
          // 评价内容输入
          _ReviewContentInput(
            controller: _controller.reviewController,
            content: state.reviewContent,
            isEnabled: !state.isSubmitted,
            onChanged: _controller.updateReviewContent,
          ),
          
          // 错误提示
          if (state.errorMessage != null && !state.isSubmitted)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(_ReviewFeedbackConstants.errorRed).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(_ReviewFeedbackConstants.errorRed).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(_ReviewFeedbackConstants.errorRed),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(_ReviewFeedbackConstants.errorRed),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // 底部占位
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  /// 构建加载视图
  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(_ReviewFeedbackConstants.primaryPurple)),
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
            onPressed: () => _controller._initialize(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(_ReviewFeedbackConstants.primaryPurple),
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
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('订单信息不存在', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

// ============== 8. EXPORTS ==============
/// 📤 导出定义
