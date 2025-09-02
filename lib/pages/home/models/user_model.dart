/// 👤 用户数据模型
/// 首页用户信息相关的数据结构

class UserModel {
  /// 用户ID
  final String userId;
  
  /// 用户昵称
  final String nickname;
  
  /// 头像URL
  final String? avatarUrl;
  
  /// 性别 (0: 未知, 1: 男, 2: 女)
  final int gender;
  
  /// 年龄
  final int? age;
  
  /// 个人简介
  final String? bio;
  
  /// 所在城市
  final String? city;
  
  /// 在线状态
  final bool isOnline;
  
  /// 距离（米）
  final double? distance;
  
  /// 标签列表
  final List<String> tags;
  
  /// 认证状态
  final bool isVerified;
  
  /// 最后活跃时间
  final DateTime? lastActiveAt;

  const UserModel({
    required this.userId,
    required this.nickname,
    this.avatarUrl,
    this.gender = 0,
    this.age,
    this.bio,
    this.city,
    this.isOnline = false,
    this.distance,
    this.tags = const [],
    this.isVerified = false,
    this.lastActiveAt,
  });

  /// 工厂方法：从JSON创建
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as String,
      nickname: json['nickname'] as String,
      avatarUrl: json['avatar_url'] as String?,
      gender: json['gender'] as int? ?? 0,
      age: json['age'] as int?,
      bio: json['bio'] as String?,
      city: json['city'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      distance: (json['distance'] as num?)?.toDouble(),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isVerified: json['is_verified'] as bool? ?? false,
      lastActiveAt: json['last_active_at'] != null 
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'nickname': nickname,
      'avatar_url': avatarUrl,
      'gender': gender,
      'age': age,
      'bio': bio,
      'city': city,
      'is_online': isOnline,
      'distance': distance,
      'tags': tags,
      'is_verified': isVerified,
      'last_active_at': lastActiveAt?.toIso8601String(),
    };
  }

  /// 获取性别文本
  String get genderText {
    switch (gender) {
      case 1:
        return '男';
      case 2:
        return '女';
      default:
        return '未知';
    }
  }

  /// 获取距离文本
  String get distanceText {
    if (distance == null) return '';
    
    if (distance! < 1000) {
      return '${distance!.toInt()}m';
    } else {
      return '${(distance! / 1000).toStringAsFixed(1)}km';
    }
  }

  /// 获取最后活跃时间文本
  String get lastActiveText {
    if (lastActiveAt == null) return '很久以前';
    
    final now = DateTime.now();
    final diff = now.difference(lastActiveAt!);
    
    if (diff.inMinutes < 1) {
      return '刚刚';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return '很久以前';
    }
  }

  /// 复制并修改部分属性
  UserModel copyWith({
    String? userId,
    String? nickname,
    String? avatarUrl,
    int? gender,
    int? age,
    String? bio,
    String? city,
    bool? isOnline,
    double? distance,
    List<String>? tags,
    bool? isVerified,
    DateTime? lastActiveAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      bio: bio ?? this.bio,
      city: city ?? this.city,
      isOnline: isOnline ?? this.isOnline,
      distance: distance ?? this.distance,
      tags: tags ?? this.tags,
      isVerified: isVerified ?? this.isVerified,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  @override
  String toString() => 'UserModel(userId: $userId, nickname: $nickname)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}
