// 🔍 搜索模块数据模型 - 单文件架构完整实现
// 基于Flutter单文件架构规范的8段式结构设计

// ============== 1. IMPORTS ==============
// Flutter核心库
import 'package:flutter/material.dart';

// Dart核心库
import 'dart:convert';

// ============== 2. CONSTANTS ==============
/// 🎨 搜索模块常量配置
class SearchConstants {
  // 私有构造函数，防止实例化
  const SearchConstants._();
  
  // 搜索配置
  static const int maxHistoryCount = 10;          // 最大历史记录数量
  static const int maxSuggestionCount = 8;        // 最大建议数量
  static const int searchDebounceMs = 300;        // 搜索防抖时间(毫秒)
  static const int defaultPageSize = 20;          // 默认分页大小
  
  // UI配置
  static const double cardBorderRadius = 12.0;    // 卡片圆角
  static const double cardElevation = 2.0;        // 卡片阴影
  static const double listItemHeight = 80.0;      // 列表项高度
  static const double searchBarHeight = 56.0;     // 搜索栏高度
  
  // 颜色配置
  static const int primaryColor = 0xFF6A5ACD;     // 主色调
  static const int accentColor = 0xFF9575CD;      // 强调色
  static const int backgroundColor = 0xFFF5F5F5;   // 背景色
  static const int textColor = 0xFF333333;        // 文字色
  static const int hintColor = 0xFF999999;        // 提示色
  
  // 搜索类型
  static const String searchTypeAll = 'all';      // 全部
  static const String searchTypeUser = 'user';    // 用户
  static const String searchTypeOrder = 'order';  // 下单
  static const String searchTypeTopic = 'topic';  // 话题
  
  // 存储键名
  static const String historyStorageKey = 'search_history';
  static const String suggestionCacheKey = 'search_suggestions';
}

// ============== 3. MODELS ==============
/// 🔍 搜索状态模型
class SearchState {
  final String keyword;                    // 搜索关键词
  final SearchType selectedType;           // 选中的搜索类型
  final bool isLoading;                   // 是否加载中
  final bool isSearching;                 // 是否正在搜索
  final String? errorMessage;             // 错误信息
  final List<String> searchHistory;       // 搜索历史
  final List<String> suggestions;         // 搜索建议
  final SearchResultData? results;        // 搜索结果
  final bool hasMoreData;                 // 是否有更多数据
  final int currentPage;                  // 当前页码
  
  const SearchState({
    this.keyword = '',
    this.selectedType = SearchType.all,
    this.isLoading = false,
    this.isSearching = false,
    this.errorMessage,
    this.searchHistory = const [],
    this.suggestions = const [],
    this.results,
    this.hasMoreData = true,
    this.currentPage = 1,
  });
  
  SearchState copyWith({
    String? keyword,
    SearchType? selectedType,
    bool? isLoading,
    bool? isSearching,
    String? errorMessage,
    List<String>? searchHistory,
    List<String>? suggestions,
    SearchResultData? results,
    bool? hasMoreData,
    int? currentPage,
  }) {
    return SearchState(
      keyword: keyword ?? this.keyword,
      selectedType: selectedType ?? this.selectedType,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      errorMessage: errorMessage ?? this.errorMessage,
      searchHistory: searchHistory ?? this.searchHistory,
      suggestions: suggestions ?? this.suggestions,
      results: results ?? this.results,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// 🏷️ 搜索类型枚举
enum SearchType {
  all('全部'),
  user('用户'),
  order('下单'),
  topic('话题');
  
  const SearchType(this.displayName);
  final String displayName;
  
  String get value {
    switch (this) {
      case SearchType.all:
        return SearchConstants.searchTypeAll;
      case SearchType.user:
        return SearchConstants.searchTypeUser;
      case SearchType.order:
        return SearchConstants.searchTypeOrder;
      case SearchType.topic:
        return SearchConstants.searchTypeTopic;
    }
  }
}

/// 📊 搜索结果数据模型
class SearchResultData {
  final List<SearchContentItem> allResults;    // 全部结果
  final List<SearchUserItem> userResults;      // 用户结果
  final List<SearchOrderItem> orderResults;    // 下单结果
  final List<SearchTopicItem> topicResults;    // 话题结果
  final int totalCount;                        // 总数量
  final bool hasMore;                          // 是否有更多
  
  const SearchResultData({
    this.allResults = const [],
    this.userResults = const [],
    this.orderResults = const [],
    this.topicResults = const [],
    this.totalCount = 0,
    this.hasMore = false,
  });
  
  factory SearchResultData.fromJson(Map<String, dynamic> json) {
    return SearchResultData(
      allResults: (json['all_results'] as List<dynamic>?)
          ?.map((item) => SearchContentItem.fromJson(item))
          .toList() ?? [],
      userResults: (json['user_results'] as List<dynamic>?)
          ?.map((item) => SearchUserItem.fromJson(item))
          .toList() ?? [],
      orderResults: (json['order_results'] as List<dynamic>?)
          ?.map((item) => SearchOrderItem.fromJson(item))
          .toList() ?? [],
      topicResults: (json['topic_results'] as List<dynamic>?)
          ?.map((item) => SearchTopicItem.fromJson(item))
          .toList() ?? [],
      totalCount: json['total_count'] as int? ?? 0,
      hasMore: json['has_more'] as bool? ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'all_results': allResults.map((item) => item.toJson()).toList(),
      'user_results': userResults.map((item) => item.toJson()).toList(),
      'order_results': orderResults.map((item) => item.toJson()).toList(),
      'topic_results': topicResults.map((item) => item.toJson()).toList(),
      'total_count': totalCount,
      'has_more': hasMore,
    };
  }
}

/// 🖼️ 搜索内容项模型（全部结果）
class SearchContentItem {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final List<String> images;
  final String? videoUrl;
  final String? videoThumbnail;
  final ContentType type;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final bool isLiked;
  
  const SearchContentItem({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    this.images = const [],
    this.videoUrl,
    this.videoThumbnail,
    required this.type,
    this.likeCount = 0,
    this.commentCount = 0,
    required this.createdAt,
    this.isLiked = false,
  });
  
  factory SearchContentItem.fromJson(Map<String, dynamic> json) {
    return SearchContentItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String,
      authorAvatar: json['author_avatar'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      videoUrl: json['video_url'] as String?,
      videoThumbnail: json['video_thumbnail'] as String?,
      type: ContentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ContentType.image,
      ),
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author_id': authorId,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'images': images,
      'video_url': videoUrl,
      'video_thumbnail': videoThumbnail,
      'type': type.name,
      'like_count': likeCount,
      'comment_count': commentCount,
      'created_at': createdAt.toIso8601String(),
      'is_liked': isLiked,
    };
  }
}

/// 🎬 内容类型枚举
enum ContentType {
  image('图片'),
  video('视频'),
  text('文字');
  
  const ContentType(this.displayName);
  final String displayName;
}

/// 👤 搜索用户项模型
class SearchUserItem {
  final String id;
  final String nickname;
  final String avatar;
  final String? bio;
  final List<String> tags;
  final bool isOnline;
  final double? distance;
  final UserGender gender;
  final int? age;
  final bool isVerified;
  final DateTime lastActiveAt;
  
  const SearchUserItem({
    required this.id,
    required this.nickname,
    required this.avatar,
    this.bio,
    this.tags = const [],
    this.isOnline = false,
    this.distance,
    this.gender = UserGender.unknown,
    this.age,
    this.isVerified = false,
    required this.lastActiveAt,
  });
  
  factory SearchUserItem.fromJson(Map<String, dynamic> json) {
    return SearchUserItem(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String? ?? '',
      bio: json['bio'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isOnline: json['is_online'] as bool? ?? false,
      distance: (json['distance'] as num?)?.toDouble(),
      gender: UserGender.values.firstWhere(
        (e) => e.name == json['gender'],
        orElse: () => UserGender.unknown,
      ),
      age: json['age'] as int?,
      isVerified: json['is_verified'] as bool? ?? false,
      lastActiveAt: DateTime.parse(json['last_active_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatar': avatar,
      'bio': bio,
      'tags': tags,
      'is_online': isOnline,
      'distance': distance,
      'gender': gender.name,
      'age': age,
      'is_verified': isVerified,
      'last_active_at': lastActiveAt.toIso8601String(),
    };
  }
  
  String get distanceText {
    if (distance == null) return '';
    if (distance! < 1) return '${(distance! * 1000).toInt()}m';
    return '${distance!.toStringAsFixed(1)}km';
  }
  
  String get lastActiveText {
    final now = DateTime.now();
    final diff = now.difference(lastActiveAt);
    
    if (diff.inMinutes < 1) return '刚刚活跃';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前活跃';
    if (diff.inDays < 1) return '${diff.inHours}小时前活跃';
    if (diff.inDays < 7) return '${diff.inDays}天前活跃';
    return '一周前活跃';
  }
}

/// 🚻 用户性别枚举
enum UserGender {
  male('男'),
  female('女'),
  unknown('未知');
  
  const UserGender(this.displayName);
  final String displayName;
}

/// 📋 搜索订单项模型
class SearchOrderItem {
  final String id;
  final String title;
  final String description;
  final String providerId;
  final String providerName;
  final String providerAvatar;
  final double price;
  final String currency;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final String location;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  const SearchOrderItem({
    required this.id,
    required this.title,
    required this.description,
    required this.providerId,
    required this.providerName,
    required this.providerAvatar,
    required this.price,
    this.currency = 'CNY',
    this.rating = 0.0,
    this.reviewCount = 0,
    this.tags = const [],
    required this.location,
    this.status = OrderStatus.available,
    required this.createdAt,
    this.updatedAt,
  });
  
  factory SearchOrderItem.fromJson(Map<String, dynamic> json) {
    return SearchOrderItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      providerId: json['provider_id'] as String,
      providerName: json['provider_name'] as String,
      providerAvatar: json['provider_avatar'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'CNY',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      location: json['location'] as String? ?? '',
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.available,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'provider_id': providerId,
      'provider_name': providerName,
      'provider_avatar': providerAvatar,
      'price': price,
      'currency': currency,
      'rating': rating,
      'review_count': reviewCount,
      'tags': tags,
      'location': location,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  String get priceText {
    return '¥${price.toStringAsFixed(2)}';
  }
  
  String get ratingText {
    if (rating == 0.0) return '暂无评分';
    return '${rating.toStringAsFixed(1)}分';
  }
}

/// 📋 订单状态枚举
enum OrderStatus {
  available('可预约'),
  busy('忙碌中'),
  offline('离线');
  
  const OrderStatus(this.displayName);
  final String displayName;
}

/// 🏷️ 搜索话题项模型
class SearchTopicItem {
  final String id;
  final String name;
  final String description;
  final String? icon;
  final String? cover;
  final TopicCategory category;
  final int memberCount;
  final int postCount;
  final double hotIndex;
  final DateTime lastActiveAt;
  final bool isFollowing;
  final bool isOfficial;
  final DateTime createdAt;
  
  const SearchTopicItem({
    required this.id,
    required this.name,
    required this.description,
    this.icon,
    this.cover,
    required this.category,
    this.memberCount = 0,
    this.postCount = 0,
    this.hotIndex = 0.0,
    required this.lastActiveAt,
    this.isFollowing = false,
    this.isOfficial = false,
    required this.createdAt,
  });
  
  factory SearchTopicItem.fromJson(Map<String, dynamic> json) {
    return SearchTopicItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String?,
      cover: json['cover'] as String?,
      category: TopicCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TopicCategory.other,
      ),
      memberCount: json['member_count'] as int? ?? 0,
      postCount: json['post_count'] as int? ?? 0,
      hotIndex: (json['hot_index'] as num?)?.toDouble() ?? 0.0,
      lastActiveAt: DateTime.parse(json['last_active_at'] as String),
      isFollowing: json['is_following'] as bool? ?? false,
      isOfficial: json['is_official'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'cover': cover,
      'category': category.name,
      'member_count': memberCount,
      'post_count': postCount,
      'hot_index': hotIndex,
      'last_active_at': lastActiveAt.toIso8601String(),
      'is_following': isFollowing,
      'is_official': isOfficial,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  String get memberCountText {
    if (memberCount < 1000) return '$memberCount人';
    if (memberCount < 10000) return '${(memberCount / 1000).toStringAsFixed(1)}k人';
    return '${(memberCount / 10000).toStringAsFixed(1)}w人';
  }
  
  String get hotIndexText {
    if (hotIndex < 1000) return '热度${hotIndex.toInt()}';
    if (hotIndex < 10000) return '热度${(hotIndex / 1000).toStringAsFixed(1)}k';
    return '热度${(hotIndex / 10000).toStringAsFixed(1)}w';
  }
}

/// 🏷️ 话题分类枚举
enum TopicCategory {
  game('游戏'),
  entertainment('娱乐'),
  lifestyle('生活'),
  technology('科技'),
  sports('体育'),
  music('音乐'),
  food('美食'),
  travel('旅行'),
  other('其他');
  
  const TopicCategory(this.displayName);
  final String displayName;
}

// ============== 4. SERVICES ==============
// 服务在 search_services.dart 中定义

// ============== 5. CONTROLLERS ==============
// 控制器在各页面文件中定义

// ============== 6. WIDGETS ==============
// 组件在 widgets 文件夹中定义

// ============== 7. PAGES ==============
// 页面在 pages 文件夹中定义

// ============== 8. EXPORTS ==============
/// 📤 导出定义
/// 
/// 本文件自动导出的公共类：
/// - SearchConstants: 搜索模块常量
/// - SearchState: 搜索状态模型
/// - SearchType: 搜索类型枚举
/// - SearchResultData: 搜索结果数据模型
/// - SearchContentItem: 搜索内容项模型
/// - SearchUserItem: 搜索用户项模型
/// - SearchOrderItem: 搜索订单项模型
/// - SearchTopicItem: 搜索话题项模型
/// - ContentType: 内容类型枚举
/// - UserGender: 用户性别枚举
/// - OrderStatus: 订单状态枚举
/// - TopicCategory: 话题分类枚举
///
/// 使用方式：
/// ```dart
/// import 'search_models.dart';
/// 
/// // 创建搜索状态
/// final state = SearchState(keyword: '王者荣耀');
/// ```
