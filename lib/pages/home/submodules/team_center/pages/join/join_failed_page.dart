// 🎯 报名失败状态页面 - 基于报名流程架构设计的失败状态页面
// 实现失败原因、补救建议、替代选择的完整失败处理体验

// ============== 1. IMPORTS ==============
// Flutter核心库
import 'package:flutter/material.dart';

// Dart核心库
import 'dart:developer' as developer;

// 项目内部文件
import '../../models/team_models.dart';    // 基础团队模型
import '../../models/join_models.dart';    // 报名模型
import '../../services/join_services.dart';  // 报名服务
import '../../utils/constants.dart';       // 常量定义

// ============== 2. CONSTANTS ==============
/// 🎨 失败页面常量
class _FailedPageConstants {
  const _FailedPageConstants._();
  
  // 颜色配置
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color backgroundGray = Color(0xFFF5F5F7);
  static const Color cardWhite = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderGray = Color(0xFFE5E7EB);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  
  // 失败状态主题色
  static const Color failedPrimary = errorRed;
  static const Color failedSecondary = Color(0xFFFEE2E2);
  
  // 动画配置
  static const Duration shakeAnimationDuration = Duration(milliseconds: 600);
  static const Duration fadeAnimationDuration = Duration(milliseconds: 1000);
  
  // UI配置
  static const double cardBorderRadius = 16.0;
  static const double sectionSpacing = 20.0;
  static const double failedIconSize = 80.0;
}

// ============== 3. MODELS ==============
/// 💡 建议操作模型
class SuggestionAction {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback? action;

  const SuggestionAction({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.action,
  });
}

/// 🔍 推荐活动模型
class RecommendedActivity {
  final String id;
  final String title;
  final String hostName;
  final String location;
  final DateTime activityTime;
  final int pricePerHour;
  final int maxParticipants;
  final int currentParticipants;
  final double distance;

  const RecommendedActivity({
    required this.id,
    required this.title,
    required this.hostName,
    required this.location,
    required this.activityTime,
    required this.pricePerHour,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.distance,
  });

  int get availableSpots => maxParticipants - currentParticipants;
  bool get hasSpots => availableSpots > 0;
}

// ============== 4. WIDGETS ==============
/// ❌ 报名失败状态页面
class JoinFailedPage extends StatefulWidget {
  final JoinRequest joinRequest;
  final TeamActivity activity;
  final VoidCallback? onBack;

  const JoinFailedPage({
    super.key,
    required this.joinRequest,
    required this.activity,
    this.onBack,
  });

  @override
  State<JoinFailedPage> createState() => _JoinFailedPageState();
}

class _JoinFailedPageState extends State<JoinFailedPage>
    with TickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final AnimationController _fadeController;
  late final Animation<double> _shakeAnimation;
  late final Animation<double> _fadeAnimation;
  
  List<RecommendedActivity> _recommendedActivities = [];
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    
    // 初始化动画控制器
    _shakeController = AnimationController(
      duration: _FailedPageConstants.shakeAnimationDuration,
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: _FailedPageConstants.fadeAnimationDuration,
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    // 启动动画
    _startFailedAnimation();
    
    // 加载推荐活动
    _loadRecommendedActivities();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startFailedAnimation() async {
    await _shakeController.forward();
    _fadeController.forward();
  }

  Future<void> _loadRecommendedActivities() async {
    try {
      // 模拟加载推荐活动
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        setState(() {
          _recommendedActivities = [
            RecommendedActivity(
              id: 'rec_001',
              title: '英雄联盟5V5排位赛',
              hostName: '游戏达人',
              location: '朝阳区网吧',
              activityTime: DateTime.now().add(const Duration(hours: 3)),
              pricePerHour: 150,
              maxParticipants: 5,
              currentParticipants: 2,
              distance: 1.2,
            ),
            RecommendedActivity(
              id: 'rec_002',
              title: '王者荣耀开黑',
              hostName: '段位小王子',
              location: '海淀区咖啡厅',
              activityTime: DateTime.now().add(const Duration(hours: 6)),
              pricePerHour: 120,
              maxParticipants: 4,
              currentParticipants: 1,
              distance: 2.5,
            ),
          ];
        });
      }
    } catch (e) {
      developer.log('加载推荐活动失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _FailedPageConstants.backgroundGray,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 活动信息展示区域（灰色滤镜）
              _buildActivityInfoSection(),
              
              const SizedBox(height: _FailedPageConstants.sectionSpacing),
              
              // 失败状态指示区域
              _buildFailedStatusSection(),
              
              const SizedBox(height: _FailedPageConstants.sectionSpacing),
              
              // 失败原因说明
              _buildFailureReasonSection(),
              
              const SizedBox(height: _FailedPageConstants.sectionSpacing),
              
              // 后续建议操作
              _buildSuggestionActionsSection(),
              
              const SizedBox(height: _FailedPageConstants.sectionSpacing),
              
              // 推荐其他活动
              if (_recommendedActivities.isNotEmpty)
                _buildRecommendedActivitiesSection(),
              
              const SizedBox(height: 100), // 为底部按钮留出空间
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _FailedPageConstants.cardWhite,
      elevation: 0,
      leading: IconButton(
        onPressed: widget.onBack ?? () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios),
        color: _FailedPageConstants.textPrimary,
      ),
      title: Text(
        '详情',
        style: TextStyle(
          color: _FailedPageConstants.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: _handleRetry,
          icon: const Icon(Icons.refresh),
          color: _FailedPageConstants.textSecondary,
        ),
      ],
    );
  }

  Widget _buildActivityInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _FailedPageConstants.cardWhite,
        borderRadius: BorderRadius.circular(_FailedPageConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 活动标题（灰色滤镜效果）
          Opacity(
            opacity: 0.6,
            child: Text(
              widget.activity.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _FailedPageConstants.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // 发起者信息
          Opacity(
            opacity: 0.6,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _FailedPageConstants.borderGray,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Colors.grey,
                        BlendMode.saturation,
                      ),
                      child: Image.network(
                        widget.activity.host.avatar ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: _FailedPageConstants.backgroundGray,
                            child: Icon(
                              Icons.person,
                              color: _FailedPageConstants.textSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.activity.host.nickname,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _FailedPageConstants.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '发起者',
                        style: TextStyle(
                          fontSize: 12,
                          color: _FailedPageConstants.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 活动基本信息
          Opacity(
            opacity: 0.6,
            child: _buildActivityDetailsRow(),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityDetailsRow() {
    return Column(
      children: [
        _buildDetailItem(
          Icons.schedule,
          '时间',
          '${widget.activity.activityTime.month}月${widget.activity.activityTime.day}日 ${widget.activity.activityTime.hour.toString().padLeft(2, '0')}:${widget.activity.activityTime.minute.toString().padLeft(2, '0')}',
        ),
        const SizedBox(height: 8),
        _buildDetailItem(
          Icons.location_on,
          '地点',
          '${widget.activity.location} • ${widget.activity.distance.toStringAsFixed(1)}km',
        ),
        const SizedBox(height: 8),
        _buildDetailItem(
          Icons.monetization_on,
          '价格',
          '${widget.activity.pricePerHour}金币/小时',
        ),
        const SizedBox(height: 8),
        _buildDetailItem(
          Icons.group,
          '人数',
          '${widget.activity.maxParticipants}人',
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: _FailedPageConstants.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: _FailedPageConstants.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: _FailedPageConstants.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFailedStatusSection() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final shake = _shakeAnimation.value;
        final offset = Offset(
          10 * shake * (1 - shake) * 4,
          0,
        );
        
        return Transform.translate(
          offset: offset,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _FailedPageConstants.cardWhite,
              borderRadius: BorderRadius.circular(_FailedPageConstants.cardBorderRadius),
              border: Border.all(
                color: _FailedPageConstants.failedPrimary.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _FailedPageConstants.failedPrimary.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // 失败图标
                Container(
                  width: _FailedPageConstants.failedIconSize,
                  height: _FailedPageConstants.failedIconSize,
                  decoration: BoxDecoration(
                    color: _FailedPageConstants.failedSecondary,
                    borderRadius: BorderRadius.circular(_FailedPageConstants.failedIconSize / 2),
                    border: Border.all(
                      color: _FailedPageConstants.failedPrimary,
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    Icons.cancel,
                    size: 40,
                    color: _FailedPageConstants.failedPrimary,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 失败标题
                Text(
                  '报名失败',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _FailedPageConstants.failedPrimary,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // 失败描述
                Text(
                  widget.joinRequest.failureReason?.description ?? '很遗憾，您的报名申请未能通过',
                  style: TextStyle(
                    fontSize: 14,
                    color: _FailedPageConstants.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // 失败时间
                if (widget.joinRequest.updatedAt != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _FailedPageConstants.failedPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '失败时间：${_formatDateTime(widget.joinRequest.updatedAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: _FailedPageConstants.failedPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFailureReasonSection() {
    final reason = widget.joinRequest.failureReason ?? FailureReason.systemError;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _FailedPageConstants.cardWhite,
        borderRadius: BorderRadius.circular(_FailedPageConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: _FailedPageConstants.failedPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '失败原因',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _FailedPageConstants.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 原因详情
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _FailedPageConstants.failedSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _FailedPageConstants.failedPrimary.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      reason.statusIcon,
                      color: _FailedPageConstants.failedPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      reason.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _FailedPageConstants.failedPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  reason.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: _FailedPageConstants.textSecondary,
                    height: 1.4,
                  ),
                ),
                
                // 主机回复（如有）
                if (widget.joinRequest.hostReply != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '发起者回复：',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _FailedPageConstants.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.joinRequest.hostReply!,
                          style: TextStyle(
                            fontSize: 13,
                            color: _FailedPageConstants.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionActionsSection() {
    final reason = widget.joinRequest.failureReason ?? FailureReason.systemError;
    
    final suggestions = <SuggestionAction>[
      if (reason.canRetry)
        SuggestionAction(
          title: '重新尝试',
          description: '重新提交报名申请',
          icon: Icons.refresh,
          color: _FailedPageConstants.primaryPurple,
          action: _handleRetry,
        ),
      if (reason == FailureReason.insufficientBalance)
        SuggestionAction(
          title: '充值金币',
          description: '增加账户余额后重新报名',
          icon: Icons.account_balance_wallet,
          color: _FailedPageConstants.warningOrange,
          action: _handleRecharge,
        ),
      SuggestionAction(
        title: '私信发起者',
        description: '询问具体原因或请求重新考虑',
        icon: Icons.chat_bubble_outline,
        color: _FailedPageConstants.primaryPurple,
        action: _handleContactHost,
      ),
      SuggestionAction(
        title: '寻找类似活动',
        description: '浏览其他相似的活动',
        icon: Icons.search,
        color: _FailedPageConstants.successGreen,
        action: _handleSearchSimilar,
      ),
      SuggestionAction(
        title: '联系客服',
        description: '如有疑问请联系客服',
        icon: Icons.support_agent,
        color: _FailedPageConstants.textSecondary,
        action: _handleContactSupport,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _FailedPageConstants.cardWhite,
        borderRadius: BorderRadius.circular(_FailedPageConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: _FailedPageConstants.primaryPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '建议操作',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _FailedPageConstants.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 建议列表
          ...suggestions.map((suggestion) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: suggestion.action,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _FailedPageConstants.borderGray),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: suggestion.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            suggestion.icon,
                            color: suggestion.color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                suggestion.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _FailedPageConstants.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                suggestion.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _FailedPageConstants.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: _FailedPageConstants.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRecommendedActivitiesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _FailedPageConstants.cardWhite,
        borderRadius: BorderRadius.circular(_FailedPageConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.recommend,
                color: _FailedPageConstants.successGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '推荐活动',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _FailedPageConstants.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${_recommendedActivities.length}个',
                style: TextStyle(
                  fontSize: 12,
                  color: _FailedPageConstants.textSecondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 推荐活动列表
          ..._recommendedActivities.map((activity) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _handleViewRecommendedActivity(activity),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _FailedPageConstants.borderGray),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 活动标题和主机
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                activity.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _FailedPageConstants.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: activity.hasSpots
                                    ? _FailedPageConstants.successGreen.withOpacity(0.1)
                                    : _FailedPageConstants.borderGray,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${activity.availableSpots}个名额',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: activity.hasSpots
                                      ? _FailedPageConstants.successGreen
                                      : _FailedPageConstants.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // 活动详情
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 12,
                              color: _FailedPageConstants.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              activity.hostName,
                              style: TextStyle(
                                fontSize: 12,
                                color: _FailedPageConstants.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: _FailedPageConstants.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${activity.distance.toStringAsFixed(1)}km',
                              style: TextStyle(
                                fontSize: 12,
                                color: _FailedPageConstants.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.monetization_on,
                              size: 12,
                              color: _FailedPageConstants.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${activity.pricePerHour}金币/小时',
                              style: TextStyle(
                                fontSize: 12,
                                color: _FailedPageConstants.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${activity.activityTime.month}月${activity.activityTime.day}日 ${activity.activityTime.hour.toString().padLeft(2, '0')}:${activity.activityTime.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: _FailedPageConstants.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: _FailedPageConstants.cardWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _handleContactHost,
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('私信'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _FailedPageConstants.primaryPurple,
                  side: BorderSide(color: _FailedPageConstants.primaryPurple),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _handleSearchSimilar,
                icon: const Icon(Icons.search, size: 18),
                label: const Text('寻找其他'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _FailedPageConstants.successGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRetry() async {
    if (_isRetrying) return;
    
    setState(() {
      _isRetrying = true;
    });
    
    try {
      // TODO: 实现重试逻辑
      developer.log('重试报名');
      await Future.delayed(const Duration(seconds: 2));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('重新报名功能即将上线')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    }
  }

  void _handleRecharge() {
    // TODO: 实现充值功能
    developer.log('充值金币');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('充值功能即将上线')),
    );
  }

  void _handleContactHost() {
    // TODO: 实现联系发起者功能
    developer.log('联系发起者');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('私信功能即将上线')),
    );
  }

  void _handleSearchSimilar() {
    // TODO: 实现搜索类似活动功能
    developer.log('搜索类似活动');
    Navigator.pop(context);
  }

  void _handleContactSupport() {
    // TODO: 实现联系客服功能
    developer.log('联系客服');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('客服功能即将上线')),
    );
  }

  void _handleViewRecommendedActivity(RecommendedActivity activity) {
    // TODO: 实现查看推荐活动功能
    developer.log('查看推荐活动: ${activity.id}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('查看活动：${activity.title}')),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}月${dateTime.day}日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// ============== 8. EXPORTS ==============
/// 📤 导出定义
/// 
/// 本文件自动导出的公共类：
/// - JoinFailedPage: 报名失败状态页面（public class）
/// - SuggestionAction: 建议操作模型（public class）
/// - RecommendedActivity: 推荐活动模型（public class）
///
/// 使用方式：
/// ```dart
/// import 'join_failed_page.dart';
/// 
/// // 导航到失败状态页面
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => JoinFailedPage(
///       joinRequest: joinRequest,
///       activity: activity,
///     ),
///   ),
/// );
/// ```
