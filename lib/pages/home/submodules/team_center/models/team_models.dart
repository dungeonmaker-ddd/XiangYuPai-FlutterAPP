// 🎯 组局中心数据模型
// 定义组局相关的所有数据结构

import 'package:flutter/material.dart';

/// 活动类型枚举
enum ActivityType {
  all('全部', '🏠', Colors.purple),
  store('探店', '🏪', Colors.orange),
  movie('私影', '🎬', Colors.pink),
  billiards('台球', '🎱', Colors.blue),
  ktv('K歌', '🎤', Colors.red),
  drink('喝酒', '🍺', Colors.green),
  massage('按摩', '💆', Colors.amber);

  const ActivityType(this.displayName, this.icon, this.color);
  
  final String displayName;
  final String icon;
  final Color color;
}

/// 组局状态枚举
enum TeamStatus {
  recruiting('招募中'),
  waiting('等待选择'),
  confirmed('已确认'),
  completed('已完成'),
  cancelled('已取消');

  const TeamStatus(this.displayName);
  final String displayName;
}

/// 报名状态枚举
enum JoinStatus {
  waiting('等待选择中'),
  approved('报名成功'),
  rejected('报名未成功');

  const JoinStatus(this.displayName);
  final String displayName;
}

/// 排序方式枚举
enum SortType {
  smart('智能排序'),
  newest('最新发布'),
  nearest('距离最近'),
  cheapest('价格最低');

  const SortType(this.displayName);
  final String displayName;
}

/// 性别筛选枚举
enum GenderFilter {
  all('不限性别'),
  female('只看女生'),
  male('只看男生');

  const GenderFilter(this.displayName);
  final String displayName;
}

/// 组局发起者模型
class TeamHost {
  final String id;
  final String nickname;
  final String? avatar;
  final bool isOnline;
  final bool isVerified;
  final List<String> tags;
  final double rating;
  final int completedTeams;
  final String? introduction;

  const TeamHost({
    required this.id,
    required this.nickname,
    this.avatar,
    this.isOnline = false,
    this.isVerified = false,
    this.tags = const [],
    this.rating = 5.0,
    this.completedTeams = 0,
    this.introduction,
  });

  factory TeamHost.fromJson(Map<String, dynamic> json) {
    return TeamHost(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      completedTeams: json['completed_teams'] as int? ?? 0,
      introduction: json['introduction'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatar': avatar,
      'is_online': isOnline,
      'is_verified': isVerified,
      'tags': tags,
      'rating': rating,
      'completed_teams': completedTeams,
      'introduction': introduction,
    };
  }
}

/// 组局参与者模型
class TeamParticipant {
  final String id;
  final String nickname;
  final String? avatar;
  final JoinStatus status;
  final DateTime joinTime;

  const TeamParticipant({
    required this.id,
    required this.nickname,
    this.avatar,
    required this.status,
    required this.joinTime,
  });

  factory TeamParticipant.fromJson(Map<String, dynamic> json) {
    return TeamParticipant(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String?,
      status: JoinStatus.values.byName(json['status'] ?? 'waiting'),
      joinTime: DateTime.parse(json['join_time']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatar': avatar,
      'status': status.name,
      'join_time': joinTime.toIso8601String(),
    };
  }
}

/// 组局活动模型
class TeamActivity {
  final String id;
  final String title;
  final String description;
  final ActivityType type;
  final TeamHost host;
  final List<TeamParticipant> participants;
  final DateTime activityTime;
  final DateTime registrationDeadline;
  final String location;
  final double distance;
  final int pricePerHour;
  final int maxParticipants;
  final TeamStatus status;
  final DateTime createdAt;
  final String? backgroundImage;

  const TeamActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.host,
    this.participants = const [],
    required this.activityTime,
    required this.registrationDeadline,
    required this.location,
    this.distance = 0.0,
    required this.pricePerHour,
    required this.maxParticipants,
    this.status = TeamStatus.recruiting,
    required this.createdAt,
    this.backgroundImage,
  });

  factory TeamActivity.fromJson(Map<String, dynamic> json) {
    return TeamActivity(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: ActivityType.values.byName(json['type'] ?? 'ktv'),
      host: TeamHost.fromJson(json['host']),
      participants: (json['participants'] as List<dynamic>?)
          ?.map((p) => TeamParticipant.fromJson(p))
          .toList() ?? [],
      activityTime: DateTime.parse(json['activity_time']),
      registrationDeadline: DateTime.parse(json['registration_deadline']),
      location: json['location'] as String,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      pricePerHour: json['price_per_hour'] as int,
      maxParticipants: json['max_participants'] as int,
      status: TeamStatus.values.byName(json['status'] ?? 'recruiting'),
      createdAt: DateTime.parse(json['created_at']),
      backgroundImage: json['background_image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'host': host.toJson(),
      'participants': participants.map((p) => p.toJson()).toList(),
      'activity_time': activityTime.toIso8601String(),
      'registration_deadline': registrationDeadline.toIso8601String(),
      'location': location,
      'distance': distance,
      'price_per_hour': pricePerHour,
      'max_participants': maxParticipants,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'background_image': backgroundImage,
    };
  }

  /// 获取活动时间格式化文本
  String get activityTimeText {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final activityDate = DateTime(activityTime.year, activityTime.month, activityTime.day);
    
    String dateText;
    if (activityDate == today) {
      dateText = '今天';
    } else if (activityDate == today.add(const Duration(days: 1))) {
      dateText = '明天';
    } else {
      dateText = '${activityTime.month}月${activityTime.day}日';
    }
    
    final timeText = '${activityTime.hour.toString().padLeft(2, '0')}:${activityTime.minute.toString().padLeft(2, '0')}';
    
    return '$dateText$timeText';
  }

  /// 获取报名截止时间提示
  String get registrationDeadlineText {
    final now = DateTime.now();
    final remaining = registrationDeadline.difference(now);
    
    if (remaining.isNegative) {
      return '报名已截止';
    } else if (remaining.inHours < 1) {
      return '${remaining.inMinutes}分钟前截止报名';
    } else if (remaining.inDays < 1) {
      return '${remaining.inHours}小时前截止报名';
    } else {
      return '${remaining.inDays}天前截止报名';
    }
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
  String get priceText {
    return '$pricePerHour金币/小时/人';
  }

  /// 获取参与者统计文本
  String get participantStatusText {
    final waitingCount = participants.where((p) => p.status == JoinStatus.waiting).length;
    if (waitingCount > 0) {
      return '等${waitingCount}多位达人报名...';
    } else if (participants.isNotEmpty) {
      return '已有${participants.length}人参与';
    } else {
      return '暂无人报名';
    }
  }

  /// 是否可以报名
  bool get canJoin {
    return status == TeamStatus.recruiting && 
           DateTime.now().isBefore(registrationDeadline) &&
           participants.length < maxParticipants;
  }
}

/// 筛选条件模型
class TeamFilterOptions {
  final SortType sortType;
  final GenderFilter genderFilter;
  final ActivityType activityType;
  final List<String> priceRanges;
  final List<String> distanceRanges;
  final List<String> timeRanges;

  const TeamFilterOptions({
    this.sortType = SortType.smart,
    this.genderFilter = GenderFilter.all,
    this.activityType = ActivityType.all,
    this.priceRanges = const [],
    this.distanceRanges = const [],
    this.timeRanges = const [],
  });

  TeamFilterOptions copyWith({
    SortType? sortType,
    GenderFilter? genderFilter,
    ActivityType? activityType,
    List<String>? priceRanges,
    List<String>? distanceRanges,
    List<String>? timeRanges,
  }) {
    return TeamFilterOptions(
      sortType: sortType ?? this.sortType,
      genderFilter: genderFilter ?? this.genderFilter,
      activityType: activityType ?? this.activityType,
      priceRanges: priceRanges ?? this.priceRanges,
      distanceRanges: distanceRanges ?? this.distanceRanges,
      timeRanges: timeRanges ?? this.timeRanges,
    );
  }

  /// 是否有高级筛选条件
  bool get hasAdvancedFilters {
    return priceRanges.isNotEmpty ||
           distanceRanges.isNotEmpty ||
           timeRanges.isNotEmpty;
  }

  /// 获取筛选条件数量
  int get filterCount {
    int count = 0;
    if (sortType != SortType.smart) count++;
    if (genderFilter != GenderFilter.all) count++;
    if (activityType != ActivityType.all) count++;
    count += priceRanges.length;
    count += distanceRanges.length;
    count += timeRanges.length;
    return count;
  }
}

/// 组局中心页面状态模型
class TeamCenterState {
  final bool isLoading;
  final String? errorMessage;
  final List<TeamActivity> activities;
  final TeamFilterOptions filterOptions;
  final int currentPage;
  final bool hasMoreData;
  final bool isLoadingMore;

  const TeamCenterState({
    this.isLoading = false,
    this.errorMessage,
    this.activities = const [],
    this.filterOptions = const TeamFilterOptions(),
    this.currentPage = 1,
    this.hasMoreData = true,
    this.isLoadingMore = false,
  });

  TeamCenterState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<TeamActivity>? activities,
    TeamFilterOptions? filterOptions,
    int? currentPage,
    bool? hasMoreData,
    bool? isLoadingMore,
  }) {
    return TeamCenterState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      activities: activities ?? this.activities,
      filterOptions: filterOptions ?? this.filterOptions,
      currentPage: currentPage ?? this.currentPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

// TeamCenterConstants 已移动到 utils/constants.dart 中
