// 🎯 报名成功状态页面 - 基于报名流程架构设计的成功状态页面
// 实现成功指示、后续指引、活动管理的完整成功体验

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
/// 🎨 成功页面常量
class _SuccessPageConstants {
  const _SuccessPageConstants._();
  
  // 颜色配置
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color backgroundGray = Color(0xFFF5F5F7);
  static const Color cardWhite = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderGray = Color(0xFFE5E7EB);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  
  // 成功状态主题色
  static const Color successPrimary = successGreen;
  static const Color successSecondary = Color(0xFFD1FAE5);
  
  // 动画配置
  static const Duration celebrationDuration = Duration(milliseconds: 1500);
  static const Duration bounceAnimationDuration = Duration(milliseconds: 800);
  
  // UI配置
  static const double cardBorderRadius = 16.0;
  static const double sectionSpacing = 20.0;
  static const double successIconSize = 100.0;
}

// ============== 3. MODELS ==============
/// 🎁 奖励项目模型
class RewardItem {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int amount;

  const RewardItem({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.amount,
  });

  static const List<RewardItem> defaultRewards = [
    RewardItem(
      name: '积分奖励',
      description: '参与活动获得积分',
      icon: Icons.stars,
      color: _SuccessPageConstants.warningOrange,
      amount: 50,
    ),
    RewardItem(
      name: '经验值',
      description: '提升用户等级',
      icon: Icons.trending_up,
      color: _SuccessPageConstants.primaryPurple,
      amount: 25,
    ),
    RewardItem(
      name: '优惠券',
      description: '下次活动可用',
      icon: Icons.local_offer,
      color: _SuccessPageConstants.successGreen,
      amount: 1,
    ),
  ];
}

/// 📅 后续指引项目模型
class GuideItem {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? action;

  const GuideItem({
    required this.title,
    required this.description,
    required this.icon,
    this.action,
  });
}

// ============== 4. WIDGETS ==============
/// ✅ 报名成功状态页面
class JoinSuccessPage extends StatefulWidget {
  final JoinRequest joinRequest;
  final TeamActivity activity;
  final VoidCallback? onBack;

  const JoinSuccessPage({
    super.key,
    required this.joinRequest,
    required this.activity,
    this.onBack,
  });

  @override
  State<JoinSuccessPage> createState() => _JoinSuccessPageState();
}

class _JoinSuccessPageState extends State<JoinSuccessPage>
    with TickerProviderStateMixin {
  late final AnimationController _celebrationController;
  late final AnimationController _bounceController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _bounceAnimation;
  
  ParticipantStats? _participantStats;
  List<JoinRequest> _successfulParticipants = [];
  bool _isShareExpanded = false;

  @override
  void initState() {
    super.initState();
    
    // 初始化动画控制器
    _celebrationController = AnimationController(
      duration: _SuccessPageConstants.celebrationDuration,
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: _SuccessPageConstants.bounceAnimationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.easeInOut,
    ));
    
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.bounceOut,
    ));
    
    // 启动庆祝动画
    _startCelebrationAnimation();
    
    // 加载数据
    _loadData();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _startCelebrationAnimation() async {
    await _celebrationController.forward();
    _bounceController.repeat(reverse: true);
  }

  Future<void> _loadData() async {
    try {
      final [stats, participants] = await Future.wait([
        JoinServiceFactory.getInstance().getParticipantStats(widget.activity.id),
        JoinServiceFactory.getInstance().getActivityJoinRequests(widget.activity.id),
      ]);
      
      if (mounted) {
        setState(() {
          _participantStats = stats as ParticipantStats;
          _successfulParticipants = (participants as List<JoinRequest>)
              .where((r) => r.status == JoinRequestStatus.approved)
              .toList();
        });
      }
    } catch (e) {
      developer.log('加载数据失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _SuccessPageConstants.backgroundGray,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 活动信息展示区域
            _buildActivityInfoSection(),
            
            const SizedBox(height: _SuccessPageConstants.sectionSpacing),
            
            // 成功状态指示区域
            _buildSuccessStatusSection(),
            
            const SizedBox(height: _SuccessPageConstants.sectionSpacing),
            
            // 成功参与者展示
            if (_successfulParticipants.isNotEmpty)
              _buildSuccessfulParticipantsSection(),
            
            const SizedBox(height: _SuccessPageConstants.sectionSpacing),
            
            // 成功奖励信息
            _buildSuccessRewardsSection(),
            
            const SizedBox(height: _SuccessPageConstants.sectionSpacing),
            
            // 后续指引
            _buildGuidanceSection(),
            
            const SizedBox(height: 100), // 为底部按钮留出空间
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _SuccessPageConstants.cardWhite,
      elevation: 0,
      leading: IconButton(
        onPressed: widget.onBack ?? () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios),
        color: _SuccessPageConstants.textPrimary,
      ),
      title: Text(
        '详情',
        style: TextStyle(
          color: _SuccessPageConstants.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: _handleShare,
          icon: const Icon(Icons.share),
          color: _SuccessPageConstants.textSecondary,
        ),
      ],
    );
  }

  Widget _buildActivityInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _SuccessPageConstants.cardWhite,
        borderRadius: BorderRadius.circular(_SuccessPageConstants.cardBorderRadius),
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
          // 活动标题
          Text(
            widget.activity.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _SuccessPageConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          // 发起者信息
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _SuccessPageConstants.successPrimary,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    widget.activity.host.avatar ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: _SuccessPageConstants.backgroundGray,
                        child: Icon(
                          Icons.person,
                          color: _SuccessPageConstants.textSecondary,
                        ),
                      );
                    },
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
                        color: _SuccessPageConstants.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '发起者',
                      style: TextStyle(
                        fontSize: 12,
                        color: _SuccessPageConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _SuccessPageConstants.successSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified,
                      size: 14,
                      color: _SuccessPageConstants.successPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '认证',
                      style: TextStyle(
                        fontSize: 12,
                        color: _SuccessPageConstants.successPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 活动基本信息
          _buildActivityDetailsRow(),
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
          color: _SuccessPageConstants.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: _SuccessPageConstants.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: _SuccessPageConstants.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessStatusSection() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: _SuccessPageConstants.cardWhite,
              borderRadius: BorderRadius.circular(_SuccessPageConstants.cardBorderRadius),
              border: Border.all(
                color: _SuccessPageConstants.successPrimary.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _SuccessPageConstants.successPrimary.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // 成功图标和动画
                AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Container(
                      width: _SuccessPageConstants.successIconSize,
                      height: _SuccessPageConstants.successIconSize,
                      decoration: BoxDecoration(
                        color: _SuccessPageConstants.successSecondary,
                        borderRadius: BorderRadius.circular(_SuccessPageConstants.successIconSize / 2),
                        border: Border.all(
                          color: _SuccessPageConstants.successPrimary,
                          width: 4,
                        ),
                      ),
                      child: AnimatedBuilder(
                        animation: _bounceAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_bounceAnimation.value * 0.1),
                            child: Icon(
                              Icons.check_circle,
                              size: 50,
                              color: _SuccessPageConstants.successPrimary,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // 成功标题
                Text(
                  '报名成功！',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _SuccessPageConstants.successPrimary,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // 成功描述
                Text(
                  '恭喜您成功报名参与活动',
                  style: TextStyle(
                    fontSize: 16,
                    color: _SuccessPageConstants.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 确认时间
                if (widget.joinRequest.confirmedAt != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _SuccessPageConstants.successPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '确认时间：${_formatDateTime(widget.joinRequest.confirmedAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: _SuccessPageConstants.successPrimary,
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

  Widget _buildSuccessfulParticipantsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _SuccessPageConstants.cardWhite,
        borderRadius: BorderRadius.circular(_SuccessPageConstants.cardBorderRadius),
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
                Icons.group,
                color: _SuccessPageConstants.successPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '成功参与者',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _SuccessPageConstants.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${_successfulParticipants.length}人',
                style: TextStyle(
                  fontSize: 14,
                  color: _SuccessPageConstants.successPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 参与者列表
          ...(_successfulParticipants.take(5).map((participant) {
            final isCurrentUser = participant.userId == widget.joinRequest.userId;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrentUser 
                    ? _SuccessPageConstants.successSecondary
                    : _SuccessPageConstants.backgroundGray,
                borderRadius: BorderRadius.circular(12),
                border: isCurrentUser 
                    ? Border.all(color: _SuccessPageConstants.successPrimary, width: 1)
                    : null,
              ),
              child: Row(
                children: [
                  // 头像
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isCurrentUser 
                            ? _SuccessPageConstants.successPrimary
                            : _SuccessPageConstants.borderGray,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        participant.userAvatar,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: _SuccessPageConstants.backgroundGray,
                            child: Icon(
                              Icons.person,
                              color: _SuccessPageConstants.textSecondary,
                              size: 20,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // 用户信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              participant.userNickname,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _SuccessPageConstants.textPrimary,
                              ),
                            ),
                            if (isCurrentUser) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _SuccessPageConstants.successPrimary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '我',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_formatDateTime(participant.confirmedAt!)} 报名成功',
                          style: TextStyle(
                            fontSize: 12,
                            color: _SuccessPageConstants.successPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 成功标识
                  Icon(
                    Icons.check_circle,
                    color: _SuccessPageConstants.successPrimary,
                    size: 20,
                  ),
                ],
              ),
            );
          })).toList(),
          
          // 更多参与者提示
          if (_successfulParticipants.length > 5) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                '还有 ${_successfulParticipants.length - 5} 位参与者...',
                style: TextStyle(
                  fontSize: 12,
                  color: _SuccessPageConstants.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuccessRewardsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _SuccessPageConstants.cardWhite,
        borderRadius: BorderRadius.circular(_SuccessPageConstants.cardBorderRadius),
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
                Icons.card_giftcard,
                color: _SuccessPageConstants.warningOrange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '成功奖励',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _SuccessPageConstants.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 奖励列表
          ...RewardItem.defaultRewards.map((reward) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: reward.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: reward.color.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: reward.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      reward.icon,
                      color: reward.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reward.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _SuccessPageConstants.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          reward.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: _SuccessPageConstants.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '+${reward.amount}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: reward.color,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildGuidanceSection() {
    final guideItems = [
      GuideItem(
        title: '添加到日历',
        description: '将活动添加到您的日历中',
        icon: Icons.calendar_today,
        action: _handleAddToCalendar,
      ),
      GuideItem(
        title: '设置提醒',
        description: '活动开始前提醒您',
        icon: Icons.notifications,
        action: _handleSetReminder,
      ),
      GuideItem(
        title: '查看路线',
        description: '查看前往活动地点的路线',
        icon: Icons.directions,
        action: _handleViewRoute,
      ),
      GuideItem(
        title: '联系其他参与者',
        description: '建立活动群聊',
        icon: Icons.group_add,
        action: _handleContactParticipants,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _SuccessPageConstants.cardWhite,
        borderRadius: BorderRadius.circular(_SuccessPageConstants.cardBorderRadius),
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
                color: _SuccessPageConstants.primaryPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '后续指引',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _SuccessPageConstants.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 指引列表
          ...guideItems.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: item.action,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _SuccessPageConstants.borderGray),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _SuccessPageConstants.primaryPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            item.icon,
                            color: _SuccessPageConstants.primaryPurple,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _SuccessPageConstants.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _SuccessPageConstants.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: _SuccessPageConstants.textSecondary,
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
        color: _SuccessPageConstants.cardWhite,
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
                onPressed: _handleContactParticipants,
                icon: const Icon(Icons.group),
                label: const Text('群聊'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _SuccessPageConstants.primaryPurple,
                  side: BorderSide(color: _SuccessPageConstants.primaryPurple),
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
                onPressed: _handleViewActivityDetail,
                icon: const Icon(Icons.event, size: 18),
                label: const Text('活动管理'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _SuccessPageConstants.successPrimary,
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

  void _handleShare() {
    // TODO: 实现分享功能
    developer.log('分享成功状态');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('分享功能即将上线')),
    );
  }

  void _handleAddToCalendar() {
    // TODO: 实现添加到日历功能
    developer.log('添加到日历');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已添加到日历')),
    );
  }

  void _handleSetReminder() {
    // TODO: 实现设置提醒功能
    developer.log('设置提醒');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('提醒已设置')),
    );
  }

  void _handleViewRoute() {
    // TODO: 实现查看路线功能
    developer.log('查看路线');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('打开地图导航')),
    );
  }

  void _handleContactParticipants() {
    // TODO: 实现联系参与者功能
    developer.log('联系参与者');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('创建活动群聊')),
    );
  }

  void _handleViewActivityDetail() {
    // TODO: 实现查看活动详情功能
    developer.log('查看活动详情');
    Navigator.pop(context);
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}月${dateTime.day}日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// ============== 8. EXPORTS ==============
/// 📤 导出定义
/// 
/// 本文件自动导出的公共类：
/// - JoinSuccessPage: 报名成功状态页面（public class）
/// - RewardItem: 奖励项目模型（public class）
/// - GuideItem: 后续指引项目模型（public class）
///
/// 使用方式：
/// ```dart
/// import 'join_success_page.dart';
/// 
/// // 导航到成功状态页面
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => JoinSuccessPage(
///       joinRequest: joinRequest,
///       activity: activity,
///     ),
///   ),
/// );
/// ```
