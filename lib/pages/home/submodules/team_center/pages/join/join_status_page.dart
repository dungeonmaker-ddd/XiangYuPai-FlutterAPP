// 🎯 报名状态页面 - 单文件架构完整实现
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

// ============== 2. CONSTANTS ==============
/// 🎨 报名状态页面私有常量
class _JoinStatusPageConstants {
  // 私有构造函数，防止实例化
  const _JoinStatusPageConstants._();
  
  // 页面标识
  static const String pageTitle = '详情';
  static const String routeName = '/join_status';
  
  // 状态相关
  static const Duration statusCheckInterval = Duration(seconds: 5);
  
  // UI配置
  static const double statusIconSize = 80.0;
  static const double participantAvatarSize = 40.0;
}

// ============== 3. MODELS ==============
/// 📋 数据模型引用
/// 主要模型定义在 team_models.dart 中：
/// - TeamActivity: 组局活动模型
/// - JoinStatus: 报名状态枚举

/// 报名状态页面状态模型
class JoinStatusState {
  final bool isLoading;
  final String? errorMessage;
  final TeamActivity? activity;
  final JoinStatus currentStatus;
  final String? statusMessage;
  final bool isRefreshing;

  const JoinStatusState({
    this.isLoading = false,
    this.errorMessage,
    this.activity,
    this.currentStatus = JoinStatus.waiting,
    this.statusMessage,
    this.isRefreshing = false,
  });

  JoinStatusState copyWith({
    bool? isLoading,
    String? errorMessage,
    TeamActivity? activity,
    JoinStatus? currentStatus,
    String? statusMessage,
    bool? isRefreshing,
  }) {
    return JoinStatusState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      activity: activity ?? this.activity,
      currentStatus: currentStatus ?? this.currentStatus,
      statusMessage: statusMessage ?? this.statusMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

// ============== 4. SERVICES ==============
/// 🔧 业务服务引用
/// 主要服务定义在 team_services.dart 中：
/// - TeamService: 组局数据服务
/// - TeamServiceFactory: 服务工厂

/// 状态模拟服务
class StatusSimulationService {
  static final StatusSimulationService _instance = StatusSimulationService._internal();
  factory StatusSimulationService() => _instance;
  StatusSimulationService._internal();

  Timer? _statusTimer;
  int _checkCount = 0;

  /// 开始模拟状态变化
  void startStatusSimulation(String activityId, Function(JoinStatus) onStatusChanged) {
    _checkCount = 0;
    _statusTimer?.cancel();
    
    _statusTimer = Timer.periodic(_JoinStatusPageConstants.statusCheckInterval, (timer) {
      _checkCount++;
      
      // 模拟状态变化逻辑
      if (_checkCount == 2) {
        // 10秒后模拟选择结果（随机成功或失败）
        final isSuccess = DateTime.now().millisecond % 2 == 0;
        onStatusChanged(isSuccess ? JoinStatus.approved : JoinStatus.rejected);
        timer.cancel();
      }
    });
  }

  /// 停止状态模拟
  void stopStatusSimulation() {
    _statusTimer?.cancel();
    _statusTimer = null;
    _checkCount = 0;
  }
}

// ============== 5. CONTROLLERS ==============
/// 🧠 报名状态控制器
class _JoinStatusController extends ValueNotifier<JoinStatusState> {
  _JoinStatusController(this.activityId, this.initialStatus) : super(JoinStatusState(currentStatus: initialStatus)) {
    _initialize();
  }

  final String activityId;
  final JoinStatus initialStatus;
  late ITeamService _teamService;
  late StatusSimulationService _statusService;

  /// 初始化数据
  Future<void> _initialize() async {
    try {
      _teamService = TeamServiceFactory.getInstance();
      _statusService = StatusSimulationService();
      
      value = value.copyWith(isLoading: true, errorMessage: null);

      final activity = await _teamService.getTeamActivity(activityId);

      value = value.copyWith(
        isLoading: false,
        activity: activity,
        statusMessage: _getStatusMessage(value.currentStatus),
      );

      // 如果是等待状态，开始模拟状态变化
      if (value.currentStatus == JoinStatus.waiting) {
        _statusService.startStatusSimulation(activityId, _onStatusChanged);
      }
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: '加载失败，请重试',
      );
      developer.log('报名状态初始化失败: $e');
    }
  }

  /// 状态变化回调
  void _onStatusChanged(JoinStatus newStatus) {
    value = value.copyWith(
      currentStatus: newStatus,
      statusMessage: _getStatusMessage(newStatus),
    );
    developer.log('状态变化: ${newStatus.displayName}');
  }

  /// 获取状态消息
  String _getStatusMessage(JoinStatus status) {
    switch (status) {
      case JoinStatus.waiting:
        return '等待对方选择中\n透露信息与选择过程可能需要金满';
      case JoinStatus.approved:
        return '恭喜您，报名成功！\n请按时参加活动，注意安全';
      case JoinStatus.rejected:
        return '很遗憾，本次报名未成功\n您的金币已自动退还';
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    value = value.copyWith(isRefreshing: true);
    await _initialize();
    value = value.copyWith(isRefreshing: false);
  }

  /// 私信发起者
  void contactHost() {
    if (value.activity == null) return;
    
    developer.log('私信发起者: ${value.activity!.host.nickname}');
    // TODO: 实现私信功能
  }

  /// 分享活动
  void shareActivity() {
    if (value.activity == null) return;
    
    developer.log('分享活动: ${value.activity!.title}');
    // TODO: 实现分享功能
  }

  @override
  void dispose() {
    _statusService.stopStatusSimulation();
    super.dispose();
  }
}

// ============== 6. WIDGETS ==============
/// 🧩 UI组件定义

/// 🔝 状态页面导航栏
class _JoinStatusAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onShare;

  const _JoinStatusAppBar({this.onShare});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        _JoinStatusPageConstants.pageTitle,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (onShare != null)
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: onShare,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// 🎥 活动背景展示
class _ActivityBackgroundDisplay extends StatelessWidget {
  final TeamActivity activity;

  const _ActivityBackgroundDisplay({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      child: Stack(
        children: [
          // 背景图片
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    activity.type.color.withOpacity(0.7),
                    activity.type.color.withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: activity.backgroundImage != null
                  ? Image.asset(
                      activity.backgroundImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: activity.type.color.withOpacity(0.7),
                      ),
                    )
                  : Container(
                      color: activity.type.color.withOpacity(0.7),
                    ),
            ),
          ),
          
          // 渐变遮罩
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black26,
                    Colors.black54,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          
          // 透明的AppBar区域
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: kToolbarHeight + MediaQuery.of(context).padding.top,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black45, Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ⭐ 状态指示卡片
class _StatusIndicatorCard extends StatelessWidget {
  final JoinStatus status;
  final String message;
  final List<TeamParticipant> participants;

  const _StatusIndicatorCard({
    required this.status,
    required this.message,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(TeamCenterConstants.cardBorderRadius),
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
          // 状态图标
          Container(
            width: _JoinStatusPageConstants.statusIconSize,
            height: _JoinStatusPageConstants.statusIconSize,
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(_JoinStatusPageConstants.statusIconSize / 2),
              border: Border.all(
                color: _getStatusColor(status),
                width: 3,
              ),
            ),
            child: Icon(
              _getStatusIcon(status),
              size: 40,
              color: _getStatusColor(status),
            ),
          ),
          const SizedBox(height: 16),
          
          // 状态标题
          Text(
            _getStatusTitle(status),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _getStatusColor(status),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // 状态消息
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          
          // 参与者展示
          if (participants.isNotEmpty) _buildParticipantsList(),
          
          // 等待动画
          if (status == JoinStatus.waiting) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(status)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildParticipantsList() {
    // 根据状态显示不同的参与者
    List<TeamParticipant> displayParticipants;
    
    switch (status) {
      case JoinStatus.waiting:
        // 等待状态显示所有等待中的参与者
        displayParticipants = participants.where((p) => p.status == JoinStatus.waiting).toList();
        break;
      case JoinStatus.approved:
        // 成功状态显示成功的参与者
        displayParticipants = participants.where((p) => p.status == JoinStatus.approved).toList();
        break;
      case JoinStatus.rejected:
        // 失败状态显示失败的参与者
        displayParticipants = participants.where((p) => p.status == JoinStatus.rejected).toList();
        break;
    }
    
    if (displayParticipants.isEmpty) return const SizedBox.shrink();
    
    return Column(
      children: [
        Text(
          _getParticipantTitle(status),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: displayParticipants.map((participant) {
            return Container(
              child: Column(
                children: [
                  // 参与者头像
                  Container(
                    width: _JoinStatusPageConstants.participantAvatarSize,
                    height: _JoinStatusPageConstants.participantAvatarSize,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(_JoinStatusPageConstants.participantAvatarSize / 2),
                      border: Border.all(
                        color: _getStatusColor(participant.status),
                        width: 2,
                      ),
                    ),
                    child: participant.avatar != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(_JoinStatusPageConstants.participantAvatarSize / 2 - 2),
                            child: Image.network(
                              participant.avatar!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => 
                                  const Icon(Icons.person, color: Colors.white, size: 20),
                            ),
                          )
                        : const Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  const SizedBox(height: 4),
                  
                  // 参与者昵称和状态
                  Text(
                    participant.nickname,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _getParticipantStatusText(participant.status),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getStatusColor(participant.status),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getStatusColor(JoinStatus status) {
    switch (status) {
      case JoinStatus.waiting:
        return Colors.orange;
      case JoinStatus.approved:
        return Colors.green;
      case JoinStatus.rejected:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(JoinStatus status) {
    switch (status) {
      case JoinStatus.waiting:
        return Icons.hourglass_empty;
      case JoinStatus.approved:
        return Icons.check_circle;
      case JoinStatus.rejected:
        return Icons.cancel;
    }
  }

  String _getStatusTitle(JoinStatus status) {
    switch (status) {
      case JoinStatus.waiting:
        return '等待选择中';
      case JoinStatus.approved:
        return '报名成功';
      case JoinStatus.rejected:
        return '报名未成功';
    }
  }

  String _getParticipantTitle(JoinStatus status) {
    switch (status) {
      case JoinStatus.waiting:
        return '等待选择的参与者';
      case JoinStatus.approved:
        return '报名成功的参与者';
      case JoinStatus.rejected:
        return '报名未成功的参与者';
    }
  }

  String _getParticipantStatusText(JoinStatus status) {
    switch (status) {
      case JoinStatus.waiting:
        return '等待中';
      case JoinStatus.approved:
        return '报名成功';
      case JoinStatus.rejected:
        return '报名未成功';
    }
  }
}

/// 📝 活动信息卡片
class _ActivityInfoCard extends StatelessWidget {
  final TeamActivity activity;

  const _ActivityInfoCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(TeamCenterConstants.cardBorderRadius),
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
          // 活动标题
          Text(
            activity.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          
          // 活动描述
          Text(
            activity.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          
          // 活动详细信息
          _buildInfoRow(Icons.schedule, '${activity.activityTimeText} ${activity.registrationDeadlineText}'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on, '${activity.location} ${activity.distanceText}'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.monetization_on, activity.priceText),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.group, '${activity.maxParticipants}人'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: TeamCenterConstants.primaryPurple),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

/// 🔻 底部操作栏
class _StatusBottomActionBar extends StatelessWidget {
  final JoinStatus status;
  final VoidCallback? onContactTap;
  final VoidCallback? onActionTap;

  const _StatusBottomActionBar({
    required this.status,
    this.onContactTap,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
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
              child: OutlinedButton.icon(
                onPressed: onContactTap,
                icon: const Icon(Icons.message, size: 18),
                label: const Text('私信'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: TeamCenterConstants.primaryPurple,
                  side: const BorderSide(color: TeamCenterConstants.primaryPurple),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // 状态按钮
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _getActionButtonEnabled(status) ? onActionTap : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getActionButtonColor(status),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
                child: Text(
                  _getActionButtonText(status),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _getActionButtonEnabled(JoinStatus status) {
    return status == JoinStatus.waiting;
  }

  Color _getActionButtonColor(JoinStatus status) {
    switch (status) {
      case JoinStatus.waiting:
        return TeamCenterConstants.primaryPurple;
      case JoinStatus.approved:
        return Colors.green;
      case JoinStatus.rejected:
        return Colors.grey[400]!;
    }
  }

  String _getActionButtonText(JoinStatus status) {
    switch (status) {
      case JoinStatus.waiting:
        return '等待选择';
      case JoinStatus.approved:
        return '报名成功';
      case JoinStatus.rejected:
        return '报名未成功';
    }
  }
}

// ============== 7. PAGES ==============
/// 📱 报名状态页面
class JoinStatusPage extends StatefulWidget {
  final String activityId;
  final JoinStatus initialStatus;

  const JoinStatusPage({
    super.key,
    required this.activityId,
    this.initialStatus = JoinStatus.waiting,
  });

  @override
  State<JoinStatusPage> createState() => _JoinStatusPageState();
}

class _JoinStatusPageState extends State<JoinStatusPage> {
  late final _JoinStatusController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _JoinStatusController(widget.activityId, widget.initialStatus);
    
    // 监听状态变化
    _controller.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    final state = _controller.value;
    
    // 状态变化时显示提示
    if (!state.isLoading && state.activity != null) {
      switch (state.currentStatus) {
        case JoinStatus.approved:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('恭喜！您的报名已被通过'),
              backgroundColor: Colors.green,
            ),
          );
          break;
        case JoinStatus.rejected:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('很遗憾，您的报名未被通过，金币已退还'),
              backgroundColor: Colors.orange,
            ),
          );
          break;
        default:
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 设置状态栏样式
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
    
    return Scaffold(
      backgroundColor: TeamCenterConstants.backgroundGray,
      extendBodyBehindAppBar: true,
      appBar: _JoinStatusAppBar(
        onShare: _controller.shareActivity,
      ),
      body: ValueListenableBuilder<JoinStatusState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          if (state.isLoading) {
            return _buildLoadingView();
          }

          if (state.errorMessage != null) {
            return _buildErrorView(state.errorMessage!);
          }

          if (state.activity == null) {
            return _buildNotFoundView();
          }

          return _buildMainContent(state);
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<JoinStatusState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          if (state.activity == null) return const SizedBox.shrink();
          
          return _StatusBottomActionBar(
            status: state.currentStatus,
            onContactTap: _controller.contactHost,
            onActionTap: _handleActionTap,
          );
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

  /// 构建未找到视图
  Widget _buildNotFoundView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('活动不存在', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: TeamCenterConstants.primaryPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('返回'),
          ),
        ],
      ),
    );
  }

  /// 构建主要内容
  Widget _buildMainContent(JoinStatusState state) {
    return RefreshIndicator(
      color: TeamCenterConstants.primaryPurple,
      onRefresh: _controller.refresh,
      child: CustomScrollView(
        slivers: [
          // 活动背景展示
          SliverToBoxAdapter(
            child: _ActivityBackgroundDisplay(activity: state.activity!),
          ),
          
          // 状态指示卡片
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: _StatusIndicatorCard(
                status: state.currentStatus,
                message: state.statusMessage ?? '',
                participants: state.activity!.participants,
              ),
            ),
          ),
          
          // 活动信息卡片
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: _ActivityInfoCard(activity: state.activity!),
            ),
          ),
          
          // 底部占位
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  /// 处理操作按钮点击
  void _handleActionTap() {
    final status = _controller.value.currentStatus;
    
    switch (status) {
      case JoinStatus.waiting:
        // 等待状态下可以取消报名
        _showCancelDialog();
        break;
      case JoinStatus.approved:
      case JoinStatus.rejected:
        // 其他状态暂无操作
        break;
    }
  }

  /// 显示取消报名对话框
  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('取消报名'),
        content: const Text('确定要取消报名吗？金币将退还到您的账户。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('继续等待'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // 关闭对话框
              // TODO: 实现取消报名逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('取消报名功能开发中')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('确认取消'),
          ),
        ],
      ),
    );
  }
}

// ============== 8. EXPORTS ==============
/// 📤 导出定义
/// 
/// 本文件自动导出的公共类：
/// - JoinStatusPage: 报名状态页面（public class）
///
/// 私有类（不会被导出）：
/// - _JoinStatusController: 报名状态控制器
/// - _JoinStatusAppBar: 状态页面导航栏
/// - _ActivityBackgroundDisplay: 活动背景展示
/// - _StatusIndicatorCard: 状态指示卡片
/// - _ActivityInfoCard: 活动信息卡片
/// - _StatusBottomActionBar: 底部操作栏
/// - _JoinStatusPageState: 页面状态类
/// - _JoinStatusPageConstants: 页面私有常量
/// - JoinStatusState: 页面状态模型
/// - StatusSimulationService: 状态模拟服务
///
/// 使用方式：
/// ```dart
/// import 'join_status_page.dart';
/// 
/// // 在路由中使用
/// MaterialPageRoute(builder: (context) => JoinStatusPage(
///   activityId: 'activity_id',
///   initialStatus: JoinStatus.waiting,
/// ))
/// ```
