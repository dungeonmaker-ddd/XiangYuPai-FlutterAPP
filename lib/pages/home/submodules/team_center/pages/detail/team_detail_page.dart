// 🎯 组局详情页面 - 单文件架构完整实现
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
import '../../services/team_services.dart';    // 业务服务
import '../../utils/constants.dart';         // 常量定义
import '../join/join_confirm_page.dart'; // 报名确认页面

// ============== 2. CONSTANTS ==============
/// 🎨 组局详情页面私有常量
class _TeamDetailPageConstants {
  // 私有构造函数，防止实例化
  const _TeamDetailPageConstants._();
  
  // 页面标识
  static const String pageTitle = '详情';
  static const String routeName = '/team_detail';
  
  // 动画时长
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // UI配置 - 更紧凑的设计
  static const double bannerHeight = 200.0;  // 减小横幅高度
  static const double avatarSize = 56.0;  // 减小头像尺寸
  static const double participantAvatarSize = 36.0;  // 减小参与者头像
  static const double bottomActionHeight = 70.0;  // 减小底部操作栏
}

// ============== 3. MODELS ==============
/// 📋 数据模型引用
/// 主要模型定义在 team_models.dart 中：
/// - TeamActivity: 组局活动模型
/// - TeamHost: 发起者模型
/// - TeamParticipant: 参与者模型

/// 组局详情页面状态模型
class TeamDetailState {
  final bool isLoading;
  final String? errorMessage;
  final TeamActivity? activity;
  final bool isJoining;
  final String? joinErrorMessage;

  const TeamDetailState({
    this.isLoading = false,
    this.errorMessage,
    this.activity,
    this.isJoining = false,
    this.joinErrorMessage,
  });

  TeamDetailState copyWith({
    bool? isLoading,
    String? errorMessage,
    TeamActivity? activity,
    bool? isJoining,
    String? joinErrorMessage,
  }) {
    return TeamDetailState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      activity: activity ?? this.activity,
      isJoining: isJoining ?? this.isJoining,
      joinErrorMessage: joinErrorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamDetailState &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        other.activity == activity &&
        other.isJoining == isJoining &&
        other.joinErrorMessage == joinErrorMessage;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^
        errorMessage.hashCode ^
        activity.hashCode ^
        isJoining.hashCode ^
        joinErrorMessage.hashCode;
  }
}

// ============== 4. SERVICES ==============
/// 🔧 业务服务引用
/// 主要服务定义在 team_services.dart 中：
/// - TeamService: 组局数据服务
/// - TeamServiceFactory: 服务工厂

// ============== 5. CONTROLLERS ==============
/// 🧠 组局详情控制器
class _TeamDetailController extends ValueNotifier<TeamDetailState> {
  final String activityId;
  late ITeamService _teamService;

  _TeamDetailController(this.activityId) : super(const TeamDetailState()) {
    _initialize();
  }

  /// 初始化数据
  Future<void> _initialize() async {
    try {
      _teamService = TeamServiceFactory.getInstance();
      value = value.copyWith(isLoading: true, errorMessage: null);

      final activity = await _teamService.getTeamActivity(activityId);

      value = value.copyWith(
        isLoading: false,
        activity: activity,
      );
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: '加载失败，请重试',
      );
      developer.log('组局详情加载失败: $e');
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    await _initialize();
  }

  /// 报名组局
  Future<void> joinActivity() async {
    if (value.activity == null || value.isJoining) return;

    try {
      value = value.copyWith(isJoining: true, joinErrorMessage: null);
      
      const currentUserId = 'current_user_123'; // 模拟当前用户ID
      
      await _teamService.joinTeamActivity(activityId, currentUserId);

      // 重新加载活动数据以获取最新状态
      await refresh();

      value = value.copyWith(isJoining: false);
      
      developer.log('报名成功');
    } catch (e) {
      value = value.copyWith(
        isJoining: false,
        joinErrorMessage: e.toString(),
      );
      developer.log('报名失败: $e');
    }
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
}

// ============== 6. WIDGETS ==============
/// 🧩 UI组件定义

/// 🔝 详情页导航栏
class _TeamDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onShare;

  const _TeamDetailAppBar({this.onShare});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        _TeamDetailPageConstants.pageTitle,
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

/// 🎥 活动背景横幅
class _ActivityBanner extends StatelessWidget {
  final TeamActivity activity;

  const _ActivityBanner({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _TeamDetailPageConstants.bannerHeight,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: Stack(
          children: [
            // 简约背景
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      activity.type.color.withOpacity(0.4),
                      activity.type.color.withOpacity(0.6),
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
                          color: activity.type.color.withOpacity(0.5),
                        ),
                      )
                    : Container(
                        color: activity.type.color.withOpacity(0.5),
                      ),
              ),
            ),
            
            // 更淡的渐变遮罩
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.4),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            
            // 活动信息居中显示
            Positioned.fill(
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 活动标题
                    Text(
                      activity.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // 活动类型标签
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        activity.type.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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
      ),
    );
  }
}

/// 👤 发起者信息卡片
class _HostInfoCard extends StatelessWidget {
  final TeamHost host;
  final VoidCallback? onContactTap;

  const _HostInfoCard({
    required this.host,
    this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),  // 稍微增加内边距
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),  // 更大的圆角
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),  // 稍微深一点的阴影
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 发起者头像 - 更简约的设计
          Container(
            width: _TeamDetailPageConstants.avatarSize,
            height: _TeamDetailPageConstants.avatarSize,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(_TeamDetailPageConstants.avatarSize / 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_TeamDetailPageConstants.avatarSize / 2),
              child: host.avatar != null
                  ? Image.network(
                      host.avatar!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                          Icon(Icons.person, color: Colors.grey[400], size: 28),
                    )
                  : Icon(Icons.person, color: Colors.grey[400], size: 28),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 发起者信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 昵称和认证状态
                Row(
                  children: [
                    Text(
                      host.nickname,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (host.isVerified) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '认证',
                          style: TextStyle(
                            color: Colors.orange[600],
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                
                // 标签
                if (host.tags.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    children: host.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getTagColor(tag).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: _getTagColor(tag),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 8),
                
                // 评分
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(
                        index < host.rating.floor() 
                            ? Icons.star 
                            : (index < host.rating ? Icons.star_half : Icons.star_border),
                        color: Colors.amber,
                        size: 14,
                      );
                    }),
                    const SizedBox(width: 6),
                    Text(
                      '${host.rating}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 私信按钮 - 更现代的设计
          Container(
            width: 80,
            height: 36,
            child: ElevatedButton(
              onPressed: onContactTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: TeamCenterConstants.primaryPurple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                '私信',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 获取标签颜色的辅助方法
  Color _getTagColor(String tag) {
    switch (tag) {
      case '高颜值':
        return Colors.blue;
      case '女神':
        return Colors.pink;
      case '认证':
        return Colors.orange;
      default:
        return TeamCenterConstants.primaryPurple;
    }
  }
}

/// 📝 活动描述卡片
class _ActivityDescriptionCard extends StatelessWidget {
  final TeamActivity activity;

  const _ActivityDescriptionCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),  // 减少垂直间距
      padding: const EdgeInsets.all(20),  // 稍微增加内边距
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),  // 更大的圆角
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),  // 更淡的阴影
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 活动详情标题
          Row(
            children: [
              Icon(
                Icons.article_outlined,
                size: 20,
                color: TeamCenterConstants.primaryPurple,
              ),
              const SizedBox(width: 8),
              Text(
                '活动详情',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 活动描述
          Text(
            activity.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,  // 增加行高，提升可读性
            ),
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
        Icon(icon, size: 18, color: TeamCenterConstants.primaryPurple),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

/// 👥 参与者状态卡片
class _ParticipantsCard extends StatelessWidget {
  final List<TeamParticipant> participants;
  final int maxParticipants;

  const _ParticipantsCard({
    required this.participants,
    required this.maxParticipants,
  });

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
          // 标题
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '参与者 (${participants.length}/$maxParticipants)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (participants.isNotEmpty)
                Text(
                  '等待发起者选择',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 参与者列表
          if (participants.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    '暂无人报名',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          else
            _buildParticipantsList(),
          
          const SizedBox(height: 12),
          
          // 报名提示
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TeamCenterConstants.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '报名更先锁的得金满',
              style: TextStyle(
                fontSize: 12,
                color: TeamCenterConstants.primaryPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsList() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: participants.map((participant) {
        return Column(
          children: [
            // 参与者头像
            Container(
              width: _TeamDetailPageConstants.participantAvatarSize,
              height: _TeamDetailPageConstants.participantAvatarSize,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(_TeamDetailPageConstants.participantAvatarSize / 2),
              ),
              child: participant.avatar != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(_TeamDetailPageConstants.participantAvatarSize / 2),
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
            
            // 参与者昵称
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
            
            // 状态指示
            Text(
              _getStatusText(participant.status),
              style: TextStyle(
                fontSize: 10,
                color: _getStatusColor(participant.status),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      }).toList(),
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

  String _getStatusText(JoinStatus status) {
    switch (status) {
      case JoinStatus.waiting:
        return '等待中';
      case JoinStatus.approved:
        return '已通过';
      case JoinStatus.rejected:
        return '未通过';
    }
  }
}

/// 🔻 底部操作栏
class _BottomActionBar extends StatelessWidget {
  final bool canJoin;
  final bool isJoining;
  final VoidCallback? onContactTap;
  final VoidCallback? onJoinTap;

  const _BottomActionBar({
    this.canJoin = true,
    this.isJoining = false,
    this.onContactTap,
    this.onJoinTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _TeamDetailPageConstants.bottomActionHeight,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),  // 调整内边距
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),  // 稍深的阴影
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 私信按钮 - 更简约的设计
            Container(
              width: 48,
              height: 48,
              child: OutlinedButton(
                onPressed: onContactTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: TeamCenterConstants.primaryPurple,
                  side: BorderSide(
                    color: TeamCenterConstants.primaryPurple.withOpacity(0.3),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: const Icon(
                  Icons.message_outlined,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // 报名按钮 - 更现代的设计
            Expanded(
              child: Container(
                height: 48,
                child: ElevatedButton(
                  onPressed: canJoin && !isJoining ? onJoinTap : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canJoin 
                        ? TeamCenterConstants.primaryPurple 
                        : Colors.grey[300],
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.grey[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: isJoining
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          canJoin ? '立即报名' : '报名已截止',
                          style: const TextStyle(
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
/// 📱 组局详情页面
class TeamDetailPage extends StatefulWidget {
  final String activityId;

  const TeamDetailPage({
    super.key,
    required this.activityId,
  });

  @override
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  late final _TeamDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _TeamDetailController(widget.activityId);
    
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
    
    // 处理报名错误
    if (state.joinErrorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.joinErrorMessage!),
          backgroundColor: Colors.red,
        ),
      );
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
      appBar: _TeamDetailAppBar(
        onShare: _controller.shareActivity,
      ),
      body: ValueListenableBuilder<TeamDetailState>(
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

          return _buildMainContent(state.activity!, state);
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<TeamDetailState>(
        valueListenable: _controller,
        builder: (context, state, child) {
          if (state.activity == null) return const SizedBox.shrink();
          
          return _BottomActionBar(
            canJoin: state.activity!.canJoin,
            isJoining: state.isJoining,
            onContactTap: _controller.contactHost,
            onJoinTap: _handleJoinTap,
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
          Text('组局不存在', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
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
  Widget _buildMainContent(TeamActivity activity, TeamDetailState state) {
    return RefreshIndicator(
      color: TeamCenterConstants.primaryPurple,
      onRefresh: _controller.refresh,
      child: CustomScrollView(
        slivers: [
          // 活动背景横幅
          SliverToBoxAdapter(
            child: _ActivityBanner(activity: activity),
          ),
          
          // 发起者信息卡片
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: _HostInfoCard(
                host: activity.host,
                onContactTap: _controller.contactHost,
              ),
            ),
          ),
          
          // 活动描述卡片
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: _ActivityDescriptionCard(activity: activity),
            ),
          ),
          
          // 参与者状态卡片
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: _ParticipantsCard(
                participants: activity.participants,
                maxParticipants: activity.maxParticipants,
              ),
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

  /// 处理报名点击
  void _handleJoinTap() async {
    final activity = _controller.value.activity;
    if (activity == null) return;

    // 跳转到报名确认页面
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => JoinConfirmPage(activityId: activity.id),
      ),
    );

    // 如果支付成功，刷新页面数据
    if (result == true) {
      _controller.refresh();
    }
  }
}

// ============== 8. EXPORTS ==============
/// 📤 导出定义
/// 
/// 本文件自动导出的公共类：
/// - TeamDetailPage: 组局详情页面（public class）
///
/// 私有类（不会被导出）：
/// - _TeamDetailController: 组局详情控制器
/// - _TeamDetailAppBar: 详情页导航栏
/// - _ActivityBanner: 活动背景横幅
/// - _HostInfoCard: 发起者信息卡片
/// - _ActivityDescriptionCard: 活动描述卡片
/// - _ParticipantsCard: 参与者状态卡片
/// - _BottomActionBar: 底部操作栏
/// - _TeamDetailPageState: 页面状态类
/// - _TeamDetailPageConstants: 页面私有常量
/// - TeamDetailState: 页面状态模型
///
/// 使用方式：
/// ```dart
/// import 'team_detail_page.dart';
/// 
/// // 在路由中使用
/// MaterialPageRoute(builder: (context) => TeamDetailPage(activityId: 'activity_123'))
/// ```