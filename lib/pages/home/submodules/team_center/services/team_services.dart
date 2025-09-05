// 🔧 组局中心服务层
// 处理组局相关的数据获取和业务逻辑

import 'dart:async';
import 'dart:developer' as developer;
import '../models/team_models.dart';

/// 组局服务接口
abstract class ITeamService {
  Future<List<TeamActivity>> getTeamActivities({
    int page = 1,
    int limit = 10,
    TeamFilterOptions? filterOptions,
  });
  
  Future<TeamActivity> getTeamActivity(String id);
  Future<TeamActivity> createTeamActivity(TeamActivity activity);
  Future<TeamActivity> updateTeamActivity(TeamActivity activity);
  Future<void> deleteTeamActivity(String id);
  Future<void> joinTeamActivity(String activityId, String userId);
}

/// 组局服务实现
class TeamService implements ITeamService {
  static final TeamService _instance = TeamService._internal();
  factory TeamService() => _instance;
  TeamService._internal();

  // 模拟数据存储
  final List<TeamActivity> _activities = [];
  bool _isInitialized = false;

  /// 初始化模拟数据
  void _initializeMockData() {
    if (_isInitialized) return;
    
    final now = DateTime.now();
    
    // 创建模拟发起者
    final hosts = [
      TeamHost(
        id: 'host1',
        nickname: '昵称123',
        avatar: null,
        isOnline: true,
        isVerified: true,
        tags: ['高质量', '人人'],
        rating: 4.8,
        completedTeams: 15,
        introduction: '专业K歌达人，带你嗨翻全场',
      ),
      TeamHost(
        id: 'host2',
        nickname: '探店小王子',
        isOnline: false,
        isVerified: true,
        tags: ['探店达人', '美食家'],
        rating: 4.9,
        completedTeams: 23,
      ),
      TeamHost(
        id: 'host3',
        nickname: '台球高手',
        isOnline: true,
        tags: ['台球高手'],
        rating: 4.7,
        completedTeams: 8,
      ),
    ];

    // 创建模拟参与者
    final participants = [
      TeamParticipant(
        id: 'user1',
        nickname: '用户A',
        status: JoinStatus.waiting,
        joinTime: now.subtract(const Duration(hours: 2)),
      ),
      TeamParticipant(
        id: 'user2',
        nickname: '用户B',
        status: JoinStatus.approved,
        joinTime: now.subtract(const Duration(hours: 1)),
      ),
      TeamParticipant(
        id: 'user3',
        nickname: '用户C',
        status: JoinStatus.waiting,
        joinTime: now.subtract(const Duration(minutes: 30)),
      ),
    ];

    // 创建模拟组局活动
    _activities.addAll([
      TeamActivity(
        id: 'activity1',
        title: 'K歌两小时',
        description: '这里是探店活动的详情 这里是探店活动详情 这里是探店活动的详情 这里是探店活动详情 这里是探店活动详情',
        type: ActivityType.ktv,
        host: hosts[0],
        participants: participants,
        activityTime: now.add(const Duration(hours: 6)),
        registrationDeadline: now.add(const Duration(hours: 2)),
        location: '福田区下沙KK ONE海底捞',
        distance: 2.3,
        pricePerHour: 300,
        maxParticipants: 4,
        status: TeamStatus.recruiting,
        createdAt: now.subtract(const Duration(hours: 3)),
        backgroundImage: 'assets/images/ktv_background.jpg',
      ),
      TeamActivity(
        id: 'activity2',
        title: '网红探店之旅',
        description: '一起去探索最新的网红餐厅，品尝美食，拍照打卡，记录美好时光',
        type: ActivityType.store,
        host: hosts[1],
        participants: participants.take(2).toList(),
        activityTime: now.add(const Duration(days: 1, hours: 2)),
        registrationDeadline: now.add(const Duration(hours: 8)),
        location: '南山区海岸城购物中心',
        distance: 1.8,
        pricePerHour: 150,
        maxParticipants: 6,
        status: TeamStatus.recruiting,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      TeamActivity(
        id: 'activity3',
        title: '台球友谊赛',
        description: '台球爱好者聚会，切磋球技，结交朋友，享受竞技乐趣',
        type: ActivityType.billiards,
        host: hosts[2],
        participants: [participants[0]],
        activityTime: now.add(const Duration(hours: 4)),
        registrationDeadline: now.add(const Duration(hours: 1)),
        location: '罗湖区东门步行街台球厅',
        distance: 3.5,
        pricePerHour: 80,
        maxParticipants: 8,
        status: TeamStatus.recruiting,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      TeamActivity(
        id: 'activity4',
        title: '私人影院观影',
        description: '包场私人影院，一起观看最新大片，享受专属观影体验',
        type: ActivityType.movie,
        host: hosts[0],
        participants: participants.take(3).toList(),
        activityTime: now.add(const Duration(days: 2)),
        registrationDeadline: now.add(const Duration(days: 1)),
        location: '宝安区西乡大道影院',
        distance: 5.2,
        pricePerHour: 200,
        maxParticipants: 6,
        status: TeamStatus.recruiting,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      TeamActivity(
        id: 'activity5',
        title: '周末聚会喝酒',
        description: '周末放松时光，找个好地方喝酒聊天，释放工作压力',
        type: ActivityType.drink,
        host: hosts[1],
        participants: participants.take(4).toList(),
        activityTime: now.add(const Duration(days: 3)),
        registrationDeadline: now.add(const Duration(days: 2)),
        location: '福田区酒吧街',
        distance: 1.2,
        pricePerHour: 120,
        maxParticipants: 5,
        status: TeamStatus.recruiting,
        createdAt: now.subtract(const Duration(minutes: 45)),
      ),
      TeamActivity(
        id: 'activity6',
        title: '舒缓按摩体验',
        description: '专业按摩师服务，缓解疲劳，放松身心，享受健康生活',
        type: ActivityType.massage,
        host: hosts[2],
        participants: [participants[1], participants[2]],
        activityTime: now.add(const Duration(hours: 8)),
        registrationDeadline: now.add(const Duration(hours: 4)),
        location: '南山区按摩会所',
        distance: 4.1,
        pricePerHour: 180,
        maxParticipants: 3,
        status: TeamStatus.recruiting,
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
    ]);
    
    _isInitialized = true;
    developer.log('TeamService: 模拟数据初始化完成，共${_activities.length}个活动');
  }

  @override
  Future<List<TeamActivity>> getTeamActivities({
    int page = 1,
    int limit = 10,
    TeamFilterOptions? filterOptions,
  }) async {
    _initializeMockData();
    
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));
    
    developer.log('TeamService: 获取组局列表 - 页码:$page, 限制:$limit');
    
    List<TeamActivity> filteredActivities = List.from(_activities);
    
    // 应用筛选条件
    if (filterOptions != null) {
      filteredActivities = _applyFilters(filteredActivities, filterOptions);
    }
    
    // 应用排序
    filteredActivities = _applySorting(filteredActivities, filterOptions?.sortType ?? SortType.smart);
    
    // 分页处理
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    
    if (startIndex >= filteredActivities.length) {
      return [];
    }
    
    final result = filteredActivities.sublist(
      startIndex,
      endIndex > filteredActivities.length ? filteredActivities.length : endIndex,
    );
    
    developer.log('TeamService: 返回${result.length}个活动');
    return result;
  }

  @override
  Future<TeamActivity> getTeamActivity(String id) async {
    _initializeMockData();
    
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));
    
    final activity = _activities.firstWhere(
      (a) => a.id == id,
      orElse: () => throw Exception('组局活动不存在'),
    );
    
    developer.log('TeamService: 获取组局详情 - ID:$id');
    return activity;
  }

  @override
  Future<TeamActivity> createTeamActivity(TeamActivity activity) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));
    
    final newActivity = TeamActivity(
      id: 'activity_${DateTime.now().millisecondsSinceEpoch}',
      title: activity.title,
      description: activity.description,
      type: activity.type,
      host: activity.host,
      participants: [],
      activityTime: activity.activityTime,
      registrationDeadline: activity.registrationDeadline,
      location: activity.location,
      distance: activity.distance,
      pricePerHour: activity.pricePerHour,
      maxParticipants: activity.maxParticipants,
      status: TeamStatus.recruiting,
      createdAt: DateTime.now(),
      backgroundImage: activity.backgroundImage,
    );
    
    _activities.insert(0, newActivity);
    developer.log('TeamService: 创建组局活动成功 - ID:${newActivity.id}');
    return newActivity;
  }

  @override
  Future<TeamActivity> updateTeamActivity(TeamActivity activity) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 600));
    
    final index = _activities.indexWhere((a) => a.id == activity.id);
    if (index == -1) {
      throw Exception('组局活动不存在');
    }
    
    _activities[index] = activity;
    developer.log('TeamService: 更新组局活动成功 - ID:${activity.id}');
    return activity;
  }

  @override
  Future<void> deleteTeamActivity(String id) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));
    
    _activities.removeWhere((a) => a.id == id);
    developer.log('TeamService: 删除组局活动成功 - ID:$id');
  }

  @override
  Future<void> joinTeamActivity(String activityId, String userId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));
    
    final activityIndex = _activities.indexWhere((a) => a.id == activityId);
    if (activityIndex == -1) {
      throw Exception('组局活动不存在');
    }
    
    final activity = _activities[activityIndex];
    
    // 检查是否已经报名
    if (activity.participants.any((p) => p.id == userId)) {
      throw Exception('您已经报名过此活动');
    }
    
    // 检查人数限制
    if (activity.participants.length >= activity.maxParticipants) {
      throw Exception('活动人数已满');
    }
    
    // 检查报名截止时间
    if (DateTime.now().isAfter(activity.registrationDeadline)) {
      throw Exception('报名已截止');
    }
    
    // 添加参与者
    final newParticipant = TeamParticipant(
      id: userId,
      nickname: '用户$userId',
      status: JoinStatus.waiting,
      joinTime: DateTime.now(),
    );
    
    final updatedParticipants = List<TeamParticipant>.from(activity.participants)
      ..add(newParticipant);
    
    final updatedActivity = TeamActivity(
      id: activity.id,
      title: activity.title,
      description: activity.description,
      type: activity.type,
      host: activity.host,
      participants: updatedParticipants,
      activityTime: activity.activityTime,
      registrationDeadline: activity.registrationDeadline,
      location: activity.location,
      distance: activity.distance,
      pricePerHour: activity.pricePerHour,
      maxParticipants: activity.maxParticipants,
      status: activity.status,
      createdAt: activity.createdAt,
      backgroundImage: activity.backgroundImage,
    );
    
    _activities[activityIndex] = updatedActivity;
    developer.log('TeamService: 用户$userId报名活动$activityId成功');
  }

  /// 应用筛选条件
  List<TeamActivity> _applyFilters(List<TeamActivity> activities, TeamFilterOptions options) {
    return activities.where((activity) {
      // 活动类型筛选
      if (options.activityType != ActivityType.all && activity.type != options.activityType) {
        return false;
      }
      
      // 价格筛选
      if (options.priceRanges.isNotEmpty) {
        bool matchesPrice = false;
        for (String range in options.priceRanges) {
          switch (range) {
            case '100以下':
              if (activity.pricePerHour < 100) matchesPrice = true;
              break;
            case '100-200':
              if (activity.pricePerHour >= 100 && activity.pricePerHour <= 200) matchesPrice = true;
              break;
            case '200-500':
              if (activity.pricePerHour > 200 && activity.pricePerHour <= 500) matchesPrice = true;
              break;
            case '500以上':
              if (activity.pricePerHour > 500) matchesPrice = true;
              break;
          }
        }
        if (!matchesPrice) return false;
      }
      
      // 距离筛选
      if (options.distanceRanges.isNotEmpty) {
        bool matchesDistance = false;
        for (String range in options.distanceRanges) {
          switch (range) {
            case '1km内':
              if (activity.distance <= 1.0) matchesDistance = true;
              break;
            case '3km内':
              if (activity.distance <= 3.0) matchesDistance = true;
              break;
            case '5km内':
              if (activity.distance <= 5.0) matchesDistance = true;
              break;
            case '不限距离':
              matchesDistance = true;
              break;
          }
        }
        if (!matchesDistance) return false;
      }
      
      // 时间筛选
      if (options.timeRanges.isNotEmpty) {
        bool matchesTime = false;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final activityDate = DateTime(activity.activityTime.year, activity.activityTime.month, activity.activityTime.day);
        
        for (String range in options.timeRanges) {
          switch (range) {
            case '今天':
              if (activityDate == today) matchesTime = true;
              break;
            case '明天':
              if (activityDate == today.add(const Duration(days: 1))) matchesTime = true;
              break;
            case '本周内':
              final weekEnd = today.add(Duration(days: 7 - today.weekday));
              if (activityDate.isBefore(weekEnd) && activityDate.isAfter(today.subtract(const Duration(days: 1)))) {
                matchesTime = true;
              }
              break;
            case '下周内':
              final nextWeekStart = today.add(Duration(days: 7 - today.weekday + 1));
              final nextWeekEnd = nextWeekStart.add(const Duration(days: 6));
              if (activityDate.isAfter(nextWeekStart.subtract(const Duration(days: 1))) && 
                  activityDate.isBefore(nextWeekEnd.add(const Duration(days: 1)))) {
                matchesTime = true;
              }
              break;
          }
        }
        if (!matchesTime) return false;
      }
      
      return true;
    }).toList();
  }

  /// 应用排序
  List<TeamActivity> _applySorting(List<TeamActivity> activities, SortType sortType) {
    switch (sortType) {
      case SortType.smart:
        // 智能排序：综合考虑时间、距离、热度等因素
        activities.sort((a, b) {
          final aScore = _calculateSmartScore(a);
          final bScore = _calculateSmartScore(b);
          return bScore.compareTo(aScore);
        });
        break;
      case SortType.newest:
        // 最新发布
        activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortType.nearest:
        // 距离最近
        activities.sort((a, b) => a.distance.compareTo(b.distance));
        break;
      case SortType.cheapest:
        // 价格最低
        activities.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
        break;
    }
    
    return activities;
  }

  /// 计算智能排序分数
  double _calculateSmartScore(TeamActivity activity) {
    double score = 0;
    
    // 距离因子（距离越近分数越高）
    score += (10 - activity.distance).clamp(0, 10) * 0.3;
    
    // 时间因子（时间越近分数越高）
    final hoursUntilActivity = activity.activityTime.difference(DateTime.now()).inHours;
    score += (24 - hoursUntilActivity.clamp(0, 24)) / 24 * 0.2;
    
    // 热度因子（参与人数越多分数越高）
    score += activity.participants.length * 0.3;
    
    // 发起者评分因子
    score += activity.host.rating * 0.2;
    
    return score;
  }
}

/// 组局服务工厂
class TeamServiceFactory {
  static ITeamService getInstance() {
    return TeamService();
  }
}
