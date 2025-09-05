// 🎯 等待选择状态页面 - 基于报名流程架构设计的等待状态页面
// 实现等待状态指示、动画效果、实时更新的完整等待体验

// ============== 1. IMPORTS ==============
// Flutter核心库
import 'package:flutter/material.dart';

// Dart核心库
import 'dart:async';
import 'dart:developer' as developer;

// 项目内部文件
import '../../models/team_models.dart';    // 基础团队模型
import '../../models/join_models.dart';    // 报名模型
import '../../services/join_services.dart';  // 报名服务
import '../../utils/constants.dart';       // 常量定义

// ============== 2. CONSTANTS ==============
/// 🎨 等待页面常量
class _WaitingPageConstants {
  const _WaitingPageConstants._();
  
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
  
  // 等待状态主题色
  static const Color waitingPrimary = warningOrange;
  static const Color waitingSecondary = Color(0xFFFEF3C7);
  
  // 动画配置
  static const Duration pulseAnimationDuration = Duration(seconds: 2);
  static const Duration rotateAnimationDuration = Duration(seconds: 3);
  static const Duration refreshInterval = Duration(seconds: 30);
  
  // UI配置
  static const double cardBorderRadius = 16.0;
  static const double sectionSpacing = 20.0;
  static const double waitingIconSize = 80.0;
}

// ============== 3. WIDGETS ==============
/// ⏳ 等待选择状态页面
class JoinWaitingPage extends StatefulWidget {
  final JoinRequest joinRequest;
  final TeamActivity activity;
  final VoidCallback? onBack;

  const JoinWaitingPage({
    super.key,
    required this.joinRequest,
    required this.activity,
    this.onBack,
  });

  @override
  State<JoinWaitingPage> createState() => _JoinWaitingPageState();
}

class _JoinWaitingPageState extends State<JoinWaitingPage>
    with TickerProviderStateMixin {
  late final IJoinService _joinService;
  late final AnimationController _pulseController;
  late final AnimationController _rotateController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _rotateAnimation;
  
  StreamSubscription<JoinRequest>? _statusSubscription;
  Timer? _refreshTimer;
  JoinRequest? _currentRequest;
  ParticipantStats? _participantStats;
  NotificationConfig _notificationConfig = const NotificationConfig();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _joinService = JoinServiceFactory.getInstance();
    _currentRequest = widget.joinRequest;
    
    // 初始化动画控制器
    _pulseController = AnimationController(
      duration: _WaitingPageConstants.pulseAnimationDuration,
      vsync: this,
    );
    _rotateController = AnimationController(
      duration: _WaitingPageConstants.rotateAnimationDuration,
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));
    
    // 启动动画
    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
    
    // 初始化数据和监听
    _initializeData();
    _startStatusMonitoring();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _statusSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      final stats = await _joinService.getParticipantStats(widget.activity.id);
      if (mounted) {
        setState(() {
          _participantStats = stats;
        });
      }
    } catch (e) {
      developer.log('初始化数据失败: $e');
    }
  }

  void _startStatusMonitoring() {
    _statusSubscription = _joinService.watchJoinStatus(_currentRequest!.id).listen(
      (updatedRequest) {
        if (mounted) {
          setState(() {
            _currentRequest = updatedRequest;
          });
          
          // 如果状态已变为最终状态，导航到相应页面
          if (updatedRequest.status.isFinalStatus) {
            _handleStatusChange(updatedRequest);
          }
        }
      },
      onError: (error) {
        developer.log('状态监听错误: $error');
      },
    );
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(_WaitingPageConstants.refreshInterval, (timer) {
      if (mounted) {
        _refreshData();
      }
    });
  }

  void _handleStatusChange(JoinRequest request) {
    // 根据状态变化导航到相应页面
    if (request.status == JoinRequestStatus.approved) {
      // 导航到成功页面
      _navigateToSuccessPage(request);
    } else if (request.status.isFailureStatus) {
      // 导航到失败页面
      _navigateToFailurePage(request);
    }
  }

  void _navigateToSuccessPage(JoinRequest request) {
    // TODO: 导航到成功状态页面
    developer.log('导航到成功页面');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('恭喜！报名成功！'),
        backgroundColor: _WaitingPageConstants.successGreen,
      ),
    );
  }

  void _navigateToFailurePage(JoinRequest request) {
    // TODO: 导航到失败状态页面
    developer.log('导航到失败页面');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('报名失败：${request.failureReason?.description ?? "未知原因"}'),
        backgroundColor: _WaitingPageConstants.errorRed,
      ),
    );
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });
    
    try {
      final [updatedRequest, stats] = await Future.wait([
        _joinService.getJoinRequest(widget.activity.id, _currentRequest!.userId),
        _joinService.getParticipantStats(widget.activity.id),
      ]);
      
      if (mounted) {
        setState(() {
          if (updatedRequest != null) {
            _currentRequest = updatedRequest as JoinRequest;
          }
          _participantStats = stats as ParticipantStats;
        });
      }
    } catch (e) {
      developer.log('刷新数据失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _WaitingPageConstants.backgroundGray,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 活动信息展示区域
              _buildActivityInfoSection(),
              
              const SizedBox(height: _WaitingPageConstants.sectionSpacing),
              
              // 等待状态指示区域
              _buildWaitingStatusSection(),
              
              const SizedBox(height: _WaitingPageConstants.sectionSpacing),
              
              // 等待队列信息
              if (_participantStats != null)
                _buildWaitingQueueSection(),
              
              const SizedBox(height: _WaitingPageConstants.sectionSpacing),
              
              // 等待说明信息
              _buildWaitingInstructionsSection(),
              
              const SizedBox(height: _WaitingPageConstants.sectionSpacing),
              
              // 通知设置
              _buildNotificationSection(),
              
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
      backgroundColor: _WaitingPageConstants.cardWhite,
      elevation: 0,
      leading: IconButton(
        onPressed: widget.onBack ?? () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios),
        color: _WaitingPageConstants.textPrimary,
      ),
      title: Text(
        '详情',
        style: TextStyle(
          color: _WaitingPageConstants.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: _refreshData,
          icon: _isRefreshing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _WaitingPageConstants.textSecondary,
                    ),
                  ),
                )
              : const Icon(Icons.refresh),
          color: _WaitingPageConstants.textSecondary,
        ),
      ],
    );
  }

  Widget _buildActivityInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _WaitingPageConstants.cardWhite,
        borderRadius: BorderRadius.circular(_WaitingPageConstants.cardBorderRadius),
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
              color: _WaitingPageConstants.textPrimary,
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
                    color: _WaitingPageConstants.primaryPurple,
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
                        color: _WaitingPageConstants.backgroundGray,
                        child: Icon(
                          Icons.person,
                          color: _WaitingPageConstants.textSecondary,
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
                        color: _WaitingPageConstants.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '发起者',
                      style: TextStyle(
                        fontSize: 12,
                        color: _WaitingPageConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.activity.host.isOnline)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _WaitingPageConstants.successGreen,
                    borderRadius: BorderRadius.circular(4),
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
          color: _WaitingPageConstants.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: _WaitingPageConstants.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: _WaitingPageConstants.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingStatusSection() {
    final remainingTime = _currentRequest?.remainingTime;
    final waitingDuration = _currentRequest?.waitingDuration ?? Duration.zero;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _WaitingPageConstants.cardWhite,
        borderRadius: BorderRadius.circular(_WaitingPageConstants.cardBorderRadius),
        border: Border.all(
          color: _WaitingPageConstants.waitingPrimary.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _WaitingPageConstants.waitingPrimary.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 等待图标和动画
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: _WaitingPageConstants.waitingIconSize,
                  height: _WaitingPageConstants.waitingIconSize,
                  decoration: BoxDecoration(
                    color: _WaitingPageConstants.waitingSecondary,
                    borderRadius: BorderRadius.circular(_WaitingPageConstants.waitingIconSize / 2),
                    border: Border.all(
                      color: _WaitingPageConstants.waitingPrimary,
                      width: 3,
                    ),
                  ),
                  child: AnimatedBuilder(
                    animation: _rotateAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotateAnimation.value * 2 * 3.14159,
                        child: Icon(
                          Icons.hourglass_empty,
                          size: 40,
                          color: _WaitingPageConstants.waitingPrimary,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // 状态标题
          Text(
            '等待对方选择中',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _WaitingPageConstants.waitingPrimary,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 等待时长
          Text(
            '已等待 ${_formatDuration(waitingDuration)}',
            style: TextStyle(
              fontSize: 14,
              color: _WaitingPageConstants.textSecondary,
            ),
          ),
          
          // 剩余时间
          if (remainingTime != null && remainingTime > Duration.zero) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _WaitingPageConstants.waitingPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '剩余 ${_formatDuration(remainingTime)}',
                style: TextStyle(
                  fontSize: 12,
                  color: _WaitingPageConstants.waitingPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWaitingQueueSection() {
    final stats = _participantStats!;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _WaitingPageConstants.cardWhite,
        borderRadius: BorderRadius.circular(_WaitingPageConstants.cardBorderRadius),
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
                Icons.queue,
                color: _WaitingPageConstants.primaryPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '等待队列',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _WaitingPageConstants.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 统计信息
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '总申请',
                  '${stats.totalApplicants}人',
                  _WaitingPageConstants.primaryPurple,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '等待中',
                  '${stats.waitingCount}人',
                  _WaitingPageConstants.waitingPrimary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '已通过',
                  '${stats.approvedCount}人',
                  _WaitingPageConstants.successGreen,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 活动热度
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _WaitingPageConstants.backgroundGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 16,
                  color: _WaitingPageConstants.errorRed,
                ),
                const SizedBox(width: 8),
                Text(
                  '活动热度：${stats.popularityDescription}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _WaitingPageConstants.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: _WaitingPageConstants.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingInstructionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _WaitingPageConstants.cardWhite,
        borderRadius: BorderRadius.circular(_WaitingPageConstants.cardBorderRadius),
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
                Icons.info_outline,
                color: _WaitingPageConstants.primaryPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '等待说明',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _WaitingPageConstants.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildInstructionItem(
            '发起者正在审核您的申请，请耐心等待',
            Icons.person_search,
          ),
          const SizedBox(height: 12),
          _buildInstructionItem(
            '您可以主动私信发起者增加被选中的几率',
            Icons.chat_bubble_outline,
          ),
          const SizedBox(height: 12),
          _buildInstructionItem(
            '如报名失败，支付的费用将自动退还',
            Icons.security,
          ),
          const SizedBox(height: 12),
          _buildInstructionItem(
            '您将第一时间收到结果通知',
            Icons.notifications_active,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _WaitingPageConstants.primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 14,
            color: _WaitingPageConstants.primaryPurple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: _WaitingPageConstants.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _WaitingPageConstants.cardWhite,
        borderRadius: BorderRadius.circular(_WaitingPageConstants.cardBorderRadius),
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
                Icons.notifications_outlined,
                color: _WaitingPageConstants.primaryPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '通知设置',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _WaitingPageConstants.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 通知开关
          _buildNotificationToggle(
            '状态变更通知',
            '选择结果将第一时间通知您',
            _notificationConfig.enableStatusChange,
            (value) {
              setState(() {
                _notificationConfig = _notificationConfig.copyWith(
                  enableStatusChange: value,
                );
              });
            },
          ),
          
          const SizedBox(height: 12),
          
          _buildNotificationToggle(
            '活动提醒',
            '活动开始前提醒您准备',
            _notificationConfig.enableActivityReminder,
            (value) {
              setState(() {
                _notificationConfig = _notificationConfig.copyWith(
                  enableActivityReminder: value,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _WaitingPageConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: _WaitingPageConstants.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: _WaitingPageConstants.primaryPurple,
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: _WaitingPageConstants.cardWhite,
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
                  foregroundColor: _WaitingPageConstants.primaryPurple,
                  side: BorderSide(color: _WaitingPageConstants.primaryPurple),
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
                onPressed: null, // 等待状态下不可点击
                icon: AnimatedBuilder(
                  animation: _rotateAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotateAnimation.value * 2 * 3.14159,
                      child: const Icon(Icons.hourglass_empty, size: 18),
                    );
                  },
                ),
                label: const Text('等待选择'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _WaitingPageConstants.waitingPrimary.withOpacity(0.3),
                  foregroundColor: _WaitingPageConstants.waitingPrimary,
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

  void _handleContactHost() {
    // TODO: 实现私信发起者功能
    developer.log('联系发起者');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('私信功能即将上线')),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}天${duration.inHours % 24}小时';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}小时${duration.inMinutes % 60}分钟';
    } else {
      return '${duration.inMinutes}分钟';
    }
  }
}

// ============== 8. EXPORTS ==============
/// 📤 导出定义
/// 
/// 本文件自动导出的公共类：
/// - JoinWaitingPage: 等待选择状态页面（public class）
///
/// 使用方式：
/// ```dart
/// import 'join_waiting_page.dart';
/// 
/// // 导航到等待状态页面
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => JoinWaitingPage(
///       joinRequest: joinRequest,
///       activity: activity,
///     ),
///   ),
/// );
/// ```
