// 🔍 发现页面数据模型 - 基于Flutter单文件架构规范
// 定义发现页面相关的所有数据结构和枚举类型

// ============== 1. IMPORTS ==============
// Dart核心库
import 'dart:convert';
import 'dart:math' as math;

// ============== 2. CONSTANTS ==============
/// 🎨 发现页面全局常量
class DiscoveryConstants {
  // 私有构造函数，防止实例化
  const DiscoveryConstants._();
  
  // API端点
  static const String baseUrl = 'https://api.example.com/v1';
  static const String followingEndpoint = '/discovery/following';
  static const String trendingEndpoint = '/discovery/trending';
  static const String nearbyEndpoint = '/discovery/nearby';
  static const String likeEndpoint = '/interactions/like';
  static const String followEndpoint = '/interactions/follow';
  
  // 缓存配置
  static const String cacheKeyPrefix = 'discovery_';
  static const Duration cacheExpiration = Duration(minutes: 30);
  static const int maxCacheSize = 100;
  
  // 分页配置
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;
  
  // 内容限制
  static const int maxImageCount = 9;
  static const int maxVideoCount = 1;
  static const int maxTopicCount = 5;
  static const int maxTextLength = 2000;
  
  // 地理位置配置
  static const double defaultRadius = 10.0; // km
  static const double maxRadius = 100.0; // km
  
  // 推荐算法配置
  static const Map<String, double> recommendationWeights = {
    'like': 0.3,
    'comment': 0.2,
    'share': 0.15,
    'follow': 0.25,
    'time': 0.1,
  };
}

// ============== 3. ENUMS ==============
/// 标签页类型枚举
enum TabType {
  following('following', '关注'),
  trending('trending', '热门'),
  nearby('nearby', '同城');

  const TabType(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// 内容类型枚举
enum ContentType {
  text('text', '文字'),
  image('image', '图片'),
  video('video', '视频'),
  mixed('mixed', '混合'),
  activity('activity', '活动');

  const ContentType(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// 互动类型枚举
enum InteractionType {
  like('like', '点赞'),
  comment('comment', '评论'),
  share('share', '分享'),
  follow('follow', '关注');

  const InteractionType(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// 内容状态枚举
enum ContentStatus {
  normal('normal', '正常'),
  hidden('hidden', '隐藏'),
  deleted('deleted', '已删除'),
  reported('reported', '举报中');

  const ContentStatus(this.value, this.displayName);
  final String value;
  final String displayName;
}

// ============== 4. DATA MODELS ==============
/// 🖼️ 发现页面图片模型
class DiscoveryImage {
  final String id;
  final String url;
  final String? thumbnailUrl;
  final int width;
  final int height;
  final int size;
  final String? alt;
  final DateTime createdAt;
  final DateTime uploadedAt;

  const DiscoveryImage({
    required this.id,
    required this.url,
    this.thumbnailUrl,
    required this.width,
    required this.height,
    this.size = 0,
    this.alt,
    required this.createdAt,
    required this.uploadedAt,
  });

  factory DiscoveryImage.fromJson(Map<String, dynamic> json) {
    return DiscoveryImage(
      id: json['id'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      width: json['width'] as int,
      height: json['height'] as int,
      size: json['size'] as int? ?? 0,
      alt: json['alt'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      uploadedAt: DateTime.parse(json['uploaded_at'] as String? ?? json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'width': width,
      'height': height,
      'size': size,
      'alt': alt,
      'created_at': createdAt.toIso8601String(),
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }

  DiscoveryImage copyWith({
    String? id,
    String? url,
    String? thumbnailUrl,
    int? width,
    int? height,
    int? size,
    String? alt,
    DateTime? createdAt,
    DateTime? uploadedAt,
  }) {
    return DiscoveryImage(
      id: id ?? this.id,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      width: width ?? this.width,
      height: height ?? this.height,
      size: size ?? this.size,
      alt: alt ?? this.alt,
      createdAt: createdAt ?? this.createdAt,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  @override
  String toString() {
    return 'DiscoveryImage(id: $id, url: $url, width: $width, height: $height)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiscoveryImage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 👤 发现页面用户模型
class DiscoveryUser {
  final String id;
  final String nickname;
  final String avatar;
  final String avatarUrl;
  final bool isVerified;
  final bool isFollowed;
  final bool isFollowing;
  final int followerCount;
  final int followingCount;
  final String? bio;
  final String? location;
  final DateTime createdAt;

  const DiscoveryUser({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.avatarUrl,
    this.isVerified = false,
    this.isFollowed = false,
    this.isFollowing = false,
    this.followerCount = 0,
    this.followingCount = 0,
    this.bio,
    this.location,
    required this.createdAt,
  });

  factory DiscoveryUser.fromJson(Map<String, dynamic> json) {
    return DiscoveryUser(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String,
      avatarUrl: json['avatar_url'] as String? ?? json['avatar'] as String,
      isVerified: json['is_verified'] as bool? ?? false,
      isFollowed: json['is_followed'] as bool? ?? false,
      isFollowing: json['is_following'] as bool? ?? false,
      followerCount: json['follower_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatar': avatar,
      'avatar_url': avatarUrl,
      'is_verified': isVerified,
      'is_followed': isFollowed,
      'is_following': isFollowing,
      'follower_count': followerCount,
      'following_count': followingCount,
      'bio': bio,
      'location': location,
      'created_at': createdAt.toIso8601String(),
    };
  }

  DiscoveryUser copyWith({
    String? id,
    String? nickname,
    String? avatar,
    String? avatarUrl,
    bool? isVerified,
    bool? isFollowed,
    bool? isFollowing,
    int? followerCount,
    int? followingCount,
    String? bio,
    String? location,
    DateTime? createdAt,
  }) {
    return DiscoveryUser(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      isFollowed: isFollowed ?? this.isFollowed,
      isFollowing: isFollowing ?? this.isFollowing,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'DiscoveryUser(id: $id, nickname: $nickname, isVerified: $isVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiscoveryUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 🏷️ 发现页面话题模型
class DiscoveryTopic {
  final String id;
  final String name;
  final String? description;
  final int contentCount;
  final int postCount;
  final bool isHot;
  final String? category;
  final DateTime createdAt;

  const DiscoveryTopic({
    required this.id,
    required this.name,
    this.description,
    this.contentCount = 0,
    this.postCount = 0,
    this.isHot = false,
    this.category,
    required this.createdAt,
  });

  factory DiscoveryTopic.fromJson(Map<String, dynamic> json) {
    return DiscoveryTopic(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      contentCount: json['content_count'] as int? ?? 0,
      isHot: json['is_hot'] as bool? ?? false,
      category: json['category'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'content_count': contentCount,
      'is_hot': isHot,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }

  DiscoveryTopic copyWith({
    String? id,
    String? name,
    String? description,
    int? contentCount,
    bool? isHot,
    String? category,
    DateTime? createdAt,
  }) {
    return DiscoveryTopic(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      contentCount: contentCount ?? this.contentCount,
      isHot: isHot ?? this.isHot,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'DiscoveryTopic(id: $id, name: $name, contentCount: $contentCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiscoveryTopic && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 📍 发现页面位置模型
class DiscoveryLocation {
  final String id;
  final String name;
  final String? address;
  final double latitude;
  final double longitude;
  final double? distance; // 距离用户的距离（km）
  final String? category;
  final String? city;
  final DateTime createdAt;

  const DiscoveryLocation({
    required this.id,
    required this.name,
    this.address,
    required this.latitude,
    required this.longitude,
    this.distance,
    this.category,
    this.city,
    required this.createdAt,
  });

  factory DiscoveryLocation.fromJson(Map<String, dynamic> json) {
    return DiscoveryLocation(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distance: (json['distance'] as num?)?.toDouble(),
      category: json['category'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }

  DiscoveryLocation copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    double? distance,
    String? category,
    DateTime? createdAt,
  }) {
    return DiscoveryLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'DiscoveryLocation(id: $id, name: $name, distance: ${distance?.toStringAsFixed(1)}km)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiscoveryLocation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 📝 发现页面内容模型
class DiscoveryContent {
  final String id;
  final String text;
  final List<DiscoveryImage> images;
  final String videoUrl;
  final String? videoThumbnail;
  final String? videoThumbnailUrl;
  final int? videoDuration; // 秒
  final List<DiscoveryTopic> topics;
  final DiscoveryLocation? location;
  final DiscoveryUser user;
  final ContentType type;
  final ContentStatus status;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isLiked;
  final bool isFavorited;
  final String createdAt; // 格式化后的时间字符串
  final DateTime createdAtRaw;

  const DiscoveryContent({
    required this.id,
    required this.text,
    this.images = const [],
    this.videoUrl = '',
    this.videoThumbnail,
    this.videoThumbnailUrl,
    this.videoDuration,
    this.topics = const [],
    this.location,
    required this.user,
    required this.type,
    this.status = ContentStatus.normal,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.isLiked = false,
    this.isFavorited = false,
    required this.createdAt,
    required this.createdAtRaw,
  });

  factory DiscoveryContent.fromJson(Map<String, dynamic> json) {
    return DiscoveryContent(
      id: json['id'] as String,
      text: json['text'] as String,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => DiscoveryImage.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      videoUrl: json['video_url'] as String? ?? '',
      videoThumbnail: json['video_thumbnail'] as String?,
      videoDuration: json['video_duration'] as int?,
      topics: (json['topics'] as List<dynamic>?)
          ?.map((e) => DiscoveryTopic.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      location: json['location'] != null 
          ? DiscoveryLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      user: DiscoveryUser.fromJson(json['user'] as Map<String, dynamic>),
      type: ContentType.values.firstWhere(
        (e) => e.value == json['type'],
        orElse: () => ContentType.text,
      ),
      status: ContentStatus.values.firstWhere(
        (e) => e.value == json['status'],
        orElse: () => ContentStatus.normal,
      ),
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      shareCount: json['share_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      isFavorited: json['is_favorited'] as bool? ?? false,
      createdAt: json['created_at_formatted'] as String,
      createdAtRaw: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'images': images.map((e) => e.toJson()).toList(),
      'video_url': videoUrl,
      'video_thumbnail': videoThumbnail,
      'video_duration': videoDuration,
      'topics': topics.map((e) => e.toJson()).toList(),
      'location': location?.toJson(),
      'user': user.toJson(),
      'type': type.value,
      'status': status.value,
      'like_count': likeCount,
      'comment_count': commentCount,
      'share_count': shareCount,
      'is_liked': isLiked,
      'is_favorited': isFavorited,
      'created_at_formatted': createdAt,
      'created_at': createdAtRaw.toIso8601String(),
    };
  }

  DiscoveryContent copyWith({
    String? id,
    String? text,
    List<DiscoveryImage>? images,
    String? videoUrl,
    String? videoThumbnail,
    int? videoDuration,
    List<DiscoveryTopic>? topics,
    DiscoveryLocation? location,
    DiscoveryUser? user,
    ContentType? type,
    ContentStatus? status,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    bool? isLiked,
    bool? isFavorited,
    String? createdAt,
    DateTime? createdAtRaw,
  }) {
    return DiscoveryContent(
      id: id ?? this.id,
      text: text ?? this.text,
      images: images ?? this.images,
      videoUrl: videoUrl ?? this.videoUrl,
      videoThumbnail: videoThumbnail ?? this.videoThumbnail,
      videoDuration: videoDuration ?? this.videoDuration,
      topics: topics ?? this.topics,
      location: location ?? this.location,
      user: user ?? this.user,
      type: type ?? this.type,
      status: status ?? this.status,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      isLiked: isLiked ?? this.isLiked,
      isFavorited: isFavorited ?? this.isFavorited,
      createdAt: createdAt ?? this.createdAt,
      createdAtRaw: createdAtRaw ?? this.createdAtRaw,
    );
  }

  @override
  String toString() {
    return 'DiscoveryContent(id: $id, type: $type, likeCount: $likeCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiscoveryContent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ============== 5. STATE MODELS ==============
/// 瀑布流项目位置信息
class MasonryItemPosition {
  final double x;
  final double y;
  final double width;
  final double height;
  final String column; // 'left' or 'right'

  const MasonryItemPosition({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.column,
  });

  MasonryItemPosition copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    String? column,
  }) {
    return MasonryItemPosition(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      column: column ?? this.column,
    );
  }

  @override
  String toString() {
    return 'MasonryItemPosition(x: $x, y: $y, width: $width, height: $height, column: $column)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MasonryItemPosition &&
        other.x == x &&
        other.y == y &&
        other.width == width &&
        other.height == height &&
        other.column == column;
  }

  @override
  int get hashCode => Object.hash(x, y, width, height, column);
}

// ============== 6. UTILITY FUNCTIONS ==============
/// 工具函数：格式化时间显示
String formatCreatedAt(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 1) {
    return '刚刚';
  } else if (difference.inHours < 1) {
    return '${difference.inMinutes}分钟前';
  } else if (difference.inDays < 1) {
    return '${difference.inHours}小时前';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}天前';
  } else {
    return '${dateTime.month}月${dateTime.day}日';
  }
}

/// 工具函数：格式化数字显示（如点赞数）
String formatCount(int count) {
  if (count < 1000) {
    return count.toString();
  } else if (count < 10000) {
    return '${(count / 1000).toStringAsFixed(1)}k';
  } else if (count < 100000) {
    return '${(count / 10000).toStringAsFixed(1)}万';
  } else {
    return '${(count / 10000).toInt()}万+';
  }
}

/// 工具函数：计算两个地理位置之间的距离
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  // 使用Haversine公式计算距离（简化版）
  const double earthRadius = 6371; // 地球半径（公里）
  
  final double dLat = (lat2 - lat1) * (3.14159265359 / 180);
  final double dLon = (lon2 - lon1) * (3.14159265359 / 180);
  
  final double a = 0.5 - math.cos(dLat / 2) + math.cos(lat1) * math.cos(lat2) * (1 - math.cos(dLon / 2)) / 2;
  
  return earthRadius * 2 * math.asin(math.sqrt(a));
}

// ============== 7. EXPORTS ==============
/// 📤 导出定义
/// 
/// 本文件导出的公共类和枚举：
/// - DiscoveryConstants: 发现页面全局常量
/// - TabType: 标签页类型枚举
/// - ContentType: 内容类型枚举
/// - InteractionType: 互动类型枚举
/// - ContentStatus: 内容状态枚举
/// - DiscoveryImage: 图片模型
/// - DiscoveryUser: 用户模型
/// - DiscoveryTopic: 话题模型
/// - DiscoveryLocation: 位置模型
/// - DiscoveryContent: 内容模型
/// - MasonryItemPosition: 瀑布流项目位置信息
/// 
/// 工具函数：
/// - formatCreatedAt: 格式化时间显示
/// - formatCount: 格式化数字显示
/// - calculateDistance: 计算地理距离
///
/// 使用方式：
/// ```dart
/// import '../models/discovery_models.dart';
/// 
/// final content = DiscoveryContent.fromJson(jsonData);
/// final formattedTime = formatCreatedAt(DateTime.now());
/// ```