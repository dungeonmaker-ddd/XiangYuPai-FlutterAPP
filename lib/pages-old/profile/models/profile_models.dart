// 🧑‍💼 个人信息模块数据模型
// 包含用户信息、交易统计、钱包、金币等核心数据模型

import 'dart:convert';
import 'package:flutter/foundation.dart';

// ============== 1. 用户信息模型 ==============

/// 👤 用户信息模型
@immutable
class UserProfile {
  final String id;
  final String username;
  final String nickname;
  final String? avatar;
  final String? bio;
  final String? phone;
  final String? email;
  final UserStatus status;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    required this.username,
    required this.nickname,
    this.avatar,
    this.bio,
    this.phone,
    this.email,
    this.status = UserStatus.offline,
    this.isVerified = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// 空用户构造函数
  UserProfile.empty()
      : id = '',
        username = '',
        nickname = '',
        avatar = null,
        bio = null,
        phone = null,
        email = null,
        status = UserStatus.offline,
        isVerified = false,
        createdAt = DateTime.now(),
        updatedAt = null;

  /// 从JSON创建
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      status: UserStatus.fromString(json['status'] as String? ?? 'offline'),
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nickname': nickname,
      'avatar': avatar,
      'bio': bio,
      'phone': phone,
      'email': email,
      'status': status.value,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// 复制并修改
  UserProfile copyWith({
    String? id,
    String? username,
    String? nickname,
    String? avatar,
    String? bio,
    String? phone,
    String? email,
    UserStatus? status,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      status: status ?? this.status,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// 获取显示名称
  String get displayName {
    if (nickname.isNotEmpty) return nickname;
    if (username.isNotEmpty) return username;
    return '用户${id.substring(0, 6)}';
  }

  /// 获取姓名首字母
  String get initials {
    final name = displayName;
    if (name.isEmpty) return '?';
    return name.substring(0, 1).toUpperCase();
  }

  /// 是否有头像
  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;

  /// 是否有简介
  bool get hasBio => bio != null && bio!.isNotEmpty;

  /// 获取简介或默认文字
  String get bioDisplay => hasBio ? bio! : '这个家伙很神秘，没有填写简介';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserProfile(id: $id, nickname: $nickname)';
}

/// 🔘 用户状态枚举
enum UserStatus {
  online('online', '在线', '🟢'),
  busy('busy', '忙碌', '🟡'),
  away('away', '离开', '🟠'),
  offline('offline', '离线', '⚫');

  const UserStatus(this.value, this.displayName, this.emoji);

  final String value;
  final String displayName;
  final String emoji;

  static UserStatus fromString(String value) {
    return UserStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => UserStatus.offline,
    );
  }
}

// ============== 2. 交易统计模型 ==============

/// 📊 交易统计模型
@immutable
class TransactionStats {
  final int publishCount;
  final int orderCount;
  final int purchaseCount;
  final int enrollmentCount;
  final double totalEarning;
  final double totalSpending;
  final DateTime updatedAt;

  const TransactionStats({
    this.publishCount = 0,
    this.orderCount = 0,
    this.purchaseCount = 0,
    this.enrollmentCount = 0,
    this.totalEarning = 0.0,
    this.totalSpending = 0.0,
    required this.updatedAt,
  });

  /// 空统计构造函数
  TransactionStats.empty()
      : publishCount = 0,
        orderCount = 0,
        purchaseCount = 0,
        enrollmentCount = 0,
        totalEarning = 0.0,
        totalSpending = 0.0,
        updatedAt = DateTime.now();

  /// 从JSON创建
  factory TransactionStats.fromJson(Map<String, dynamic> json) {
    return TransactionStats(
      publishCount: json['publish_count'] as int? ?? 0,
      orderCount: json['order_count'] as int? ?? 0,
      purchaseCount: json['purchase_count'] as int? ?? 0,
      enrollmentCount: json['enrollment_count'] as int? ?? 0,
      totalEarning: (json['total_earning'] as num?)?.toDouble() ?? 0.0,
      totalSpending: (json['total_spending'] as num?)?.toDouble() ?? 0.0,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'publish_count': publishCount,
      'order_count': orderCount,
      'purchase_count': purchaseCount,
      'enrollment_count': enrollmentCount,
      'total_earning': totalEarning,
      'total_spending': totalSpending,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 复制并修改
  TransactionStats copyWith({
    int? publishCount,
    int? orderCount,
    int? purchaseCount,
    int? enrollmentCount,
    double? totalEarning,
    double? totalSpending,
    DateTime? updatedAt,
  }) {
    return TransactionStats(
      publishCount: publishCount ?? this.publishCount,
      orderCount: orderCount ?? this.orderCount,
      purchaseCount: purchaseCount ?? this.purchaseCount,
      enrollmentCount: enrollmentCount ?? this.enrollmentCount,
      totalEarning: totalEarning ?? this.totalEarning,
      totalSpending: totalSpending ?? this.totalSpending,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// 获取总交易数
  int get totalTransactions => publishCount + orderCount + purchaseCount + enrollmentCount;

  /// 获取净收益
  double get netEarning => totalEarning - totalSpending;

  @override
  String toString() => 'TransactionStats(total: $totalTransactions, net: $netEarning)';
}

// ============== 3. 钱包模型 ==============

/// 💰 钱包模型
@immutable
class Wallet {
  final String id;
  final String userId;
  final double balance;
  final double frozenBalance;
  final int coinBalance;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Wallet({
    required this.id,
    required this.userId,
    this.balance = 0.0,
    this.frozenBalance = 0.0,
    this.coinBalance = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 空钱包构造函数
  Wallet.empty(String userId)
      : id = '',
        userId = userId,
        balance = 0.0,
        frozenBalance = 0.0,
        coinBalance = 0,
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  /// 从JSON创建
  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      frozenBalance: (json['frozen_balance'] as num?)?.toDouble() ?? 0.0,
      coinBalance: json['coin_balance'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'balance': balance,
      'frozen_balance': frozenBalance,
      'coin_balance': coinBalance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 复制并修改
  Wallet copyWith({
    String? id,
    String? userId,
    double? balance,
    double? frozenBalance,
    int? coinBalance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wallet(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      frozenBalance: frozenBalance ?? this.frozenBalance,
      coinBalance: coinBalance ?? this.coinBalance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// 获取可用余额
  double get availableBalance => balance - frozenBalance;

  /// 是否有足够余额
  bool hasEnoughBalance(double amount) => availableBalance >= amount;

  /// 是否有足够金币
  bool hasEnoughCoins(int amount) => coinBalance >= amount;

  /// 格式化余额显示
  String get balanceDisplay => '¥${balance.toStringAsFixed(2)}';

  /// 格式化金币显示
  String get coinDisplay => coinBalance.toString();

  @override
  String toString() => 'Wallet(balance: $balanceDisplay, coins: $coinDisplay)';
}

// ============== 4. 功能配置模型 ==============

/// 🛠️ 功能配置模型
@immutable
class FeatureConfig {
  final String key;
  final String name;
  final String icon;
  final String description;
  final bool enabled;
  final Map<String, dynamic>? metadata;

  const FeatureConfig({
    required this.key,
    required this.name,
    required this.icon,
    this.description = '',
    this.enabled = true,
    this.metadata,
  });

  /// 从JSON创建
  factory FeatureConfig.fromJson(Map<String, dynamic> json) {
    return FeatureConfig(
      key: json['key'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'icon': icon,
      'description': description,
      'enabled': enabled,
      'metadata': metadata,
    };
  }

  @override
  String toString() => 'FeatureConfig(key: $key, name: $name)';
}

// ============== 5. 个人资料更新请求模型 ==============

/// 📝 个人资料更新请求
@immutable
class ProfileUpdateRequest {
  final String? nickname;
  final String? bio;
  final String? avatar;
  final UserStatus? status;

  const ProfileUpdateRequest({
    this.nickname,
    this.bio,
    this.avatar,
    this.status,
  });

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (nickname != null) map['nickname'] = nickname;
    if (bio != null) map['bio'] = bio;
    if (avatar != null) map['avatar'] = avatar;
    if (status != null) map['status'] = status!.value;
    return map;
  }

  /// 是否为空请求
  bool get isEmpty => nickname == null && bio == null && avatar == null && status == null;

  @override
  String toString() => 'ProfileUpdateRequest(${toJson()})';
}

// ============== 6. 数据状态模型 ==============

/// 📊 数据加载状态
enum DataLoadState {
  initial,
  loading,
  loaded,
  error,
}

/// 🔄 分页数据模型
@immutable
class PaginatedData<T> {
  final List<T> items;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;

  const PaginatedData({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  /// 空数据构造函数
  PaginatedData.empty()
      : items = const [],
        total = 0,
        page = 1,
        pageSize = 20,
        hasMore = false;

  /// 从JSON创建
  factory PaginatedData.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final items = (json['items'] as List<dynamic>?)
            ?.map((item) => fromJsonT(item as Map<String, dynamic>))
            .toList() ??
        <T>[];

    return PaginatedData<T>(
      items: items,
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
      hasMore: json['has_more'] as bool? ?? false,
    );
  }

  /// 追加数据
  PaginatedData<T> appendData(PaginatedData<T> newData) {
    return PaginatedData<T>(
      items: [...items, ...newData.items],
      total: newData.total,
      page: newData.page,
      pageSize: pageSize,
      hasMore: newData.hasMore,
    );
  }

  @override
  String toString() => 'PaginatedData(items: ${items.length}, total: $total)';
}
