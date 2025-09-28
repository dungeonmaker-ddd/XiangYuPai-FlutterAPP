// 📱 内容详情页数据模型 - 基于Flutter单文件架构规范
// 定义内容详情页相关的所有数据结构和枚举类型

// ============== 1. IMPORTS ==============
// Dart核心库
import 'dart:convert';

// ============== 2. CONSTANTS ==============
/// 🎨 内容详情页全局常量
class DetailConstants {
  // 私有构造函数，防止实例化
  const DetailConstants._();
  
  // API端点
  static const String baseUrl = 'https://api.example.com/v1';
  static const String contentDetailEndpoint = '/content/detail';
  static const String commentsEndpoint = '/content/comments';
  static const String likeEndpoint = '/interactions/like';
  static const String favoriteEndpoint = '/interactions/favorite';
  static const String followEndpoint = '/interactions/follow';
  static const String shareEndpoint = '/interactions/share';
  static const String reportEndpoint = '/content/report';
  
  // 分页配置
  static const int defaultCommentPageSize = 20;
  static const int maxCommentPageSize = 50;
  static const int maxCommentDepth = 3; // 最大评论嵌套层级
  
  // 内容限制
  static const int maxCommentLength = 500;
  static const int minCommentLength = 1;
  
  // UI配置
  static const double maxImageAspectRatio = 3.0; // 图片最大宽高比
  static const double minImageAspectRatio = 0.33; // 图片最小宽高比
  static const double defaultVideoAspectRatio = 16.0 / 9.0; // 默认视频比例
  
  // 缓存配置
  static const Duration cacheExpiration = Duration(minutes: 15);
  static const String cacheKeyPrefix = 'content_detail_';
  
  // 分享配置
  static const Map<String, String> shareTemplates = {
    'text': '我在{APP_NAME}发现了一个有趣的内容：{CONTENT_PREVIEW}',
    'link': '{CONTENT_URL}',
    'hashtag': '#{APP_NAME}',
  };
  
  // 举报类型
  static const List<String> reportTypes = [
    '垃圾信息',
    '不实信息',
    '违法违规',
    '涉嫌诈骗',
    '色情内容',
    '暴力内容',
    '侵犯版权',
    '其他',
  ];
}

// ============== 3. ENUMS ==============
/// 媒体类型枚举
enum MediaType {
  image('image', '图片'),
  video('video', '视频'),
  audio('audio', '音频');

  const MediaType(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// 分享平台枚举
enum SharePlatform {
  wechat('wechat', '微信'),
  wechatMoments('wechat_moments', '朋友圈'),
  moments('moments', '朋友圈'),
  qq('qq', 'QQ'),
  qzone('qzone', 'QQ空间'),
  weibo('weibo', '微博'),
  douyin('douyin', '抖音'),
  link('link', '复制链接'),
  copyLink('copy_link', '复制链接'),
  saveImage('save_image', '保存图片'),
  more('more', '更多');

  const SharePlatform(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// 内容状态枚举
enum ContentStatus {
  normal('normal', '正常'),
  hidden('hidden', '隐藏'),
  deleted('deleted', '已删除'),
  reported('reported', '举报中'),
  blocked('blocked', '已屏蔽');

  const ContentStatus(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// 评论状态枚举
enum CommentStatus {
  normal('normal', '正常'),
  hidden('hidden', '隐藏'),
  deleted('deleted', '已删除'),
  reported('reported', '举报中');

  const CommentStatus(this.value, this.displayName);
  final String value;
  final String displayName;
}

// ============== 4. DATA MODELS ==============
/// 🖼️ 媒体项目模型
class MediaItemModel {
  final String id;
  final MediaType type;
  final String url;
  final String? thumbnailUrl;
  final int? width;
  final int? height;
  final int? duration; // 视频/音频时长（秒）
  final String? alt;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const MediaItemModel({
    required this.id,
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.duration,
    this.alt,
    this.metadata,
    required this.createdAt,
  });

  factory MediaItemModel.fromJson(Map<String, dynamic> json) {
    return MediaItemModel(
      id: json['id'] as String,
      type: MediaType.values.firstWhere((e) => e.value == json['type']),
      url: json['url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      duration: json['duration'] as int?,
      alt: json['alt'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'width': width,
      'height': height,
      'duration': duration,
      'alt': alt,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  MediaItemModel copyWith({
    String? id,
    MediaType? type,
    String? url,
    String? thumbnailUrl,
    int? width,
    int? height,
    int? duration,
    String? alt,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return MediaItemModel(
      id: id ?? this.id,
      type: type ?? this.type,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      width: width ?? this.width,
      height: height ?? this.height,
      duration: duration ?? this.duration,
      alt: alt ?? this.alt,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 计算显示宽高比
  double get aspectRatio {
    if (width != null && height != null && width! > 0 && height! > 0) {
      final ratio = width! / height!;
      return ratio.clamp(
        DetailConstants.minImageAspectRatio,
        DetailConstants.maxImageAspectRatio,
      );
    }
    return type == MediaType.video 
        ? DetailConstants.defaultVideoAspectRatio 
        : 1.0;
  }

  /// 创建空的媒体项目
  static MediaItemModel empty() {
    return MediaItemModel(
      id: '',
      type: MediaType.image,
      url: '',
      createdAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'MediaItemModel(id: $id, type: $type, url: $url)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaItemModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 👤 用户详情模型
class UserDetailModel {
  final String id;
  final String nickname;
  final String avatar;
  final String avatarUrl;
  final String? bio;
  final bool isVerified;
  final bool isFollowed;
  final bool isBlocked;
  final int followerCount;
  final int followingCount;
  final int contentCount;
  final DateTime joinedAt;
  final String publishTime;

  const UserDetailModel({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.avatarUrl,
    this.bio,
    this.isVerified = false,
    this.isFollowed = false,
    this.isBlocked = false,
    this.followerCount = 0,
    this.followingCount = 0,
    this.contentCount = 0,
    required this.joinedAt,
    required this.publishTime,
  });

  factory UserDetailModel.fromJson(Map<String, dynamic> json) {
    return UserDetailModel(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String,
      avatarUrl: json['avatar_url'] as String? ?? json['avatar'] as String,
      bio: json['bio'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      isFollowed: json['is_followed'] as bool? ?? false,
      isBlocked: json['is_blocked'] as bool? ?? false,
      followerCount: json['follower_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      contentCount: json['content_count'] as int? ?? 0,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      publishTime: json['publish_time'] as String? ?? '刚刚',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatar': avatar,
      'avatar_url': avatarUrl,
      'bio': bio,
      'is_verified': isVerified,
      'is_followed': isFollowed,
      'is_blocked': isBlocked,
      'follower_count': followerCount,
      'following_count': followingCount,
      'content_count': contentCount,
      'joined_at': joinedAt.toIso8601String(),
      'publish_time': publishTime,
    };
  }

  UserDetailModel copyWith({
    String? id,
    String? nickname,
    String? avatar,
    String? avatarUrl,
    String? bio,
    bool? isVerified,
    bool? isFollowed,
    bool? isBlocked,
    int? followerCount,
    int? followingCount,
    int? contentCount,
    DateTime? joinedAt,
    String? publishTime,
  }) {
    return UserDetailModel(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      isVerified: isVerified ?? this.isVerified,
      isFollowed: isFollowed ?? this.isFollowed,
      isBlocked: isBlocked ?? this.isBlocked,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      contentCount: contentCount ?? this.contentCount,
      joinedAt: joinedAt ?? this.joinedAt,
      publishTime: publishTime ?? this.publishTime,
    );
  }

  @override
  String toString() {
    return 'UserDetailModel(id: $id, nickname: $nickname, isVerified: $isVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserDetailModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 💬 评论模型
class CommentModel {
  final String id;
  final String content;
  final UserDetailModel user;
  final CommentModel? replyTo; // 回复的评论
  final List<CommentModel> replies; // 子评论
  final int likeCount;
  final bool isLiked;
  final CommentStatus status;
  final String createdAt; // 格式化后的时间字符串
  final DateTime createdAtRaw;

  const CommentModel({
    required this.id,
    required this.content,
    required this.user,
    this.replyTo,
    this.replies = const [],
    this.likeCount = 0,
    this.isLiked = false,
    this.status = CommentStatus.normal,
    required this.createdAt,
    required this.createdAtRaw,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      content: json['content'] as String,
      user: UserDetailModel.fromJson(json['user'] as Map<String, dynamic>),
      replyTo: json['reply_to'] != null
          ? CommentModel.fromJson(json['reply_to'] as Map<String, dynamic>)
          : null,
      replies: (json['replies'] as List<dynamic>?)
          ?.map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      likeCount: json['like_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      status: CommentStatus.values.firstWhere(
        (e) => e.value == json['status'],
        orElse: () => CommentStatus.normal,
      ),
      createdAt: json['created_at_formatted'] as String,
      createdAtRaw: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'user': user.toJson(),
      'reply_to': replyTo?.toJson(),
      'replies': replies.map((e) => e.toJson()).toList(),
      'like_count': likeCount,
      'is_liked': isLiked,
      'status': status.value,
      'created_at_formatted': createdAt,
      'created_at': createdAtRaw.toIso8601String(),
    };
  }

  CommentModel copyWith({
    String? id,
    String? content,
    UserDetailModel? user,
    CommentModel? replyTo,
    List<CommentModel>? replies,
    int? likeCount,
    bool? isLiked,
    CommentStatus? status,
    String? createdAt,
    DateTime? createdAtRaw,
  }) {
    return CommentModel(
      id: id ?? this.id,
      content: content ?? this.content,
      user: user ?? this.user,
      replyTo: replyTo ?? this.replyTo,
      replies: replies ?? this.replies,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      createdAtRaw: createdAtRaw ?? this.createdAtRaw,
    );
  }

  /// 获取评论层级深度
  int get depth {
    if (replyTo == null) return 0;
    return replyTo!.depth + 1;
  }

  /// 获取顶级评论ID
  String get rootCommentId {
    if (replyTo == null) return id;
    return replyTo!.rootCommentId;
  }

  @override
  String toString() {
    return 'CommentModel(id: $id, content: ${content.substring(0, content.length.clamp(0, 20))}, likeCount: $likeCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 📝 内容详情模型
class ContentDetailModel {
  final String id;
  final String text;
  final String textContent;
  final List<MediaItemModel> mediaItems;
  final List<String> topics; // 话题标签
  final String? locationName;
  final UserDetailModel user;
  final UserDetailModel author;
  final ContentStatus status;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int favoriteCount;
  final bool isLiked;
  final bool isFavorited;
  final bool isFollowingUser;
  final String createdAt; // 格式化后的时间字符串
  final DateTime createdAtRaw;
  final Map<String, dynamic>? metadata;

  const ContentDetailModel({
    required this.id,
    required this.text,
    required this.textContent,
    this.mediaItems = const [],
    this.topics = const [],
    this.locationName,
    required this.user,
    required this.author,
    this.status = ContentStatus.normal,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.favoriteCount = 0,
    this.isLiked = false,
    this.isFavorited = false,
    this.isFollowingUser = false,
    required this.createdAt,
    required this.createdAtRaw,
    this.metadata,
  });

  factory ContentDetailModel.fromJson(Map<String, dynamic> json) {
    final user = UserDetailModel.fromJson(json['user'] as Map<String, dynamic>);
    return ContentDetailModel(
      id: json['id'] as String,
      text: json['text'] as String,
      textContent: json['text_content'] as String? ?? json['text'] as String,
      mediaItems: (json['media_items'] as List<dynamic>?)
          ?.map((e) => MediaItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      topics: (json['topics'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      locationName: json['location_name'] as String?,
      user: user,
      author: UserDetailModel.fromJson(json['author'] as Map<String, dynamic>? ?? json['user'] as Map<String, dynamic>),
      status: ContentStatus.values.firstWhere(
        (e) => e.value == json['status'],
        orElse: () => ContentStatus.normal,
      ),
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      shareCount: json['share_count'] as int? ?? 0,
      favoriteCount: json['favorite_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      isFavorited: json['is_favorited'] as bool? ?? false,
      isFollowingUser: json['is_following_user'] as bool? ?? false,
      createdAt: json['created_at_formatted'] as String,
      createdAtRaw: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'text_content': textContent,
      'media_items': mediaItems.map((e) => e.toJson()).toList(),
      'topics': topics,
      'location_name': locationName,
      'user': user.toJson(),
      'author': author.toJson(),
      'status': status.value,
      'like_count': likeCount,
      'comment_count': commentCount,
      'share_count': shareCount,
      'favorite_count': favoriteCount,
      'is_liked': isLiked,
      'is_favorited': isFavorited,
      'is_following_user': isFollowingUser,
      'created_at_formatted': createdAt,
      'created_at': createdAtRaw.toIso8601String(),
      'metadata': metadata,
    };
  }

  ContentDetailModel copyWith({
    String? id,
    String? text,
    String? textContent,
    List<MediaItemModel>? mediaItems,
    List<String>? topics,
    String? locationName,
    UserDetailModel? user,
    UserDetailModel? author,
    ContentStatus? status,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    int? favoriteCount,
    bool? isLiked,
    bool? isFavorited,
    bool? isFollowingUser,
    String? createdAt,
    DateTime? createdAtRaw,
    Map<String, dynamic>? metadata,
  }) {
    return ContentDetailModel(
      id: id ?? this.id,
      text: text ?? this.text,
      textContent: textContent ?? this.textContent,
      mediaItems: mediaItems ?? this.mediaItems,
      topics: topics ?? this.topics,
      locationName: locationName ?? this.locationName,
      user: user ?? this.user,
      author: author ?? this.author,
      status: status ?? this.status,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      isLiked: isLiked ?? this.isLiked,
      isFavorited: isFavorited ?? this.isFavorited,
      isFollowingUser: isFollowingUser ?? this.isFollowingUser,
      createdAt: createdAt ?? this.createdAt,
      createdAtRaw: createdAtRaw ?? this.createdAtRaw,
      metadata: metadata ?? this.metadata,
    );
  }

  /// 是否包含图片
  bool get hasImages => mediaItems.any((item) => item.type == MediaType.image);

  /// 是否包含视频
  bool get hasVideos => mediaItems.any((item) => item.type == MediaType.video);

  /// 获取第一张图片
  MediaItemModel? get firstImage => mediaItems.firstWhere(
    (item) => item.type == MediaType.image,
    orElse: () => mediaItems.first,
  );

  /// 获取第一个视频
  MediaItemModel? get firstVideo => mediaItems.firstWhere(
    (item) => item.type == MediaType.video,
    orElse: () => mediaItems.first,
  );

  @override
  String toString() {
    return 'ContentDetailModel(id: $id, likeCount: $likeCount, commentCount: $commentCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContentDetailModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ============== 5. STATE MODELS ==============
/// 📱 互动状态模型
class InteractionState {
  final bool isLiking;
  final bool isFavoriting;
  final bool isFollowing;
  final bool isSharing;
  final bool isCommenting;
  final bool isReporting;
  final bool isLiked;
  final bool isFavorited;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int favoriteCount;
  final int viewCount;

  const InteractionState({
    this.isLiking = false,
    this.isFavoriting = false,
    this.isFollowing = false,
    this.isSharing = false,
    this.isCommenting = false,
    this.isReporting = false,
    this.isLiked = false,
    this.isFavorited = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.favoriteCount = 0,
    this.viewCount = 0,
  });

  InteractionState copyWith({
    bool? isLiking,
    bool? isFavoriting,
    bool? isFollowing,
    bool? isSharing,
    bool? isCommenting,
    bool? isReporting,
    bool? isLiked,
    bool? isFavorited,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    int? favoriteCount,
    int? viewCount,
  }) {
    return InteractionState(
      isLiking: isLiking ?? this.isLiking,
      isFavoriting: isFavoriting ?? this.isFavoriting,
      isFollowing: isFollowing ?? this.isFollowing,
      isSharing: isSharing ?? this.isSharing,
      isCommenting: isCommenting ?? this.isCommenting,
      isReporting: isReporting ?? this.isReporting,
      isLiked: isLiked ?? this.isLiked,
      isFavorited: isFavorited ?? this.isFavorited,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      viewCount: viewCount ?? this.viewCount,
    );
  }

  /// 是否有任何操作正在进行
  bool get hasActiveOperation => isLiking || isFavoriting || isFollowing || isSharing || isCommenting || isReporting;

  @override
  String toString() {
    return 'InteractionState(isLiking: $isLiking, isFavoriting: $isFavoriting, isFollowing: $isFollowing)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InteractionState &&
        other.isLiking == isLiking &&
        other.isFavoriting == isFavoriting &&
        other.isFollowing == isFollowing &&
        other.isSharing == isSharing &&
        other.isCommenting == isCommenting &&
        other.isReporting == isReporting &&
        other.isLiked == isLiked &&
        other.isFavorited == isFavorited &&
        other.likeCount == likeCount &&
        other.commentCount == commentCount &&
        other.shareCount == shareCount &&
        other.favoriteCount == favoriteCount &&
        other.viewCount == viewCount;
  }

  @override
  int get hashCode => Object.hash(
    isLiking,
    isFavoriting,
    isFollowing,
    isSharing,
    isCommenting,
    isReporting,
    isLiked,
    isFavorited,
    likeCount,
    commentCount,
    shareCount,
    favoriteCount,
    viewCount,
  );
}

/// 📤 分享内容模型
class ShareContent {
  final String title;
  final String description;
  final String url;
  final String? imageUrl;
  final Map<String, String>? platformSpecificData;

  const ShareContent({
    required this.title,
    required this.description,
    required this.url,
    this.imageUrl,
    this.platformSpecificData,
  });

  ShareContent copyWith({
    String? title,
    String? description,
    String? url,
    String? imageUrl,
    Map<String, String>? platformSpecificData,
  }) {
    return ShareContent(
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      platformSpecificData: platformSpecificData ?? this.platformSpecificData,
    );
  }

  @override
  String toString() {
    return 'ShareContent(title: $title, url: $url)';
  }
}

/// 📱 详情页面状态模型
class DetailPageState {
  final bool isLoading;
  final bool isLoadingComments;
  final bool isLoadingMoreComments;
  final ContentDetailModel? contentDetail;
  final List<CommentModel> comments;
  final InteractionState interactionState;
  final String? errorMessage;
  final String? successMessage;
  final bool hasMoreComments;
  final int currentCommentPage;
  final String? replyingToCommentId; // 正在回复的评论ID
  final bool showFullText; // 是否展开显示全文
  final bool isCommentExpanded; // 评论输入框是否展开
  final bool isCommentPublishing; // 是否正在发布评论
  final bool isLikeAnimating; // 点赞动画状态
  final bool isFavoriteAnimating; // 收藏动画状态
  final bool isFollowAnimating; // 关注动画状态
  final bool isSharePanelVisible; // 分享面板是否可见
  final bool isMoreActionsVisible; // 更多操作菜单是否可见
  final bool isVideoReady; // 视频是否准备就绪
  final Duration? videoPosition; // 视频播放位置
  final Duration? videoDuration; // 视频总时长
  final bool isVideoPlaying; // 视频是否正在播放

  const DetailPageState({
    this.isLoading = false,
    this.isLoadingComments = false,
    this.isLoadingMoreComments = false,
    this.contentDetail,
    this.comments = const [],
    this.interactionState = const InteractionState(),
    this.errorMessage,
    this.successMessage,
    this.hasMoreComments = true,
    this.currentCommentPage = 1,
    this.replyingToCommentId,
    this.showFullText = false,
    this.isCommentExpanded = false,
    this.isCommentPublishing = false,
    this.isLikeAnimating = false,
    this.isFavoriteAnimating = false,
    this.isFollowAnimating = false,
    this.isSharePanelVisible = false,
    this.isMoreActionsVisible = false,
    this.isVideoReady = false,
    this.videoPosition,
    this.videoDuration,
    this.isVideoPlaying = false,
  });

  DetailPageState copyWith({
    bool? isLoading,
    bool? isLoadingComments,
    bool? isLoadingMoreComments,
    ContentDetailModel? contentDetail,
    List<CommentModel>? comments,
    InteractionState? interactionState,
    String? errorMessage,
    String? successMessage,
    bool? hasMoreComments,
    int? currentCommentPage,
    String? replyingToCommentId,
    bool? showFullText,
    bool? isCommentExpanded,
    bool? isCommentPublishing,
    bool? isLikeAnimating,
    bool? isFavoriteAnimating,
    bool? isFollowAnimating,
    bool? isSharePanelVisible,
    bool? isMoreActionsVisible,
    bool? isVideoReady,
    Duration? videoPosition,
    Duration? videoDuration,
    bool? isVideoPlaying,
  }) {
    return DetailPageState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingComments: isLoadingComments ?? this.isLoadingComments,
      isLoadingMoreComments: isLoadingMoreComments ?? this.isLoadingMoreComments,
      contentDetail: contentDetail ?? this.contentDetail,
      comments: comments ?? this.comments,
      interactionState: interactionState ?? this.interactionState,
      errorMessage: errorMessage,
      successMessage: successMessage,
      hasMoreComments: hasMoreComments ?? this.hasMoreComments,
      currentCommentPage: currentCommentPage ?? this.currentCommentPage,
      replyingToCommentId: replyingToCommentId,
      showFullText: showFullText ?? this.showFullText,
      isCommentExpanded: isCommentExpanded ?? this.isCommentExpanded,
      isCommentPublishing: isCommentPublishing ?? this.isCommentPublishing,
      isLikeAnimating: isLikeAnimating ?? this.isLikeAnimating,
      isFavoriteAnimating: isFavoriteAnimating ?? this.isFavoriteAnimating,
      isFollowAnimating: isFollowAnimating ?? this.isFollowAnimating,
      isSharePanelVisible: isSharePanelVisible ?? this.isSharePanelVisible,
      isMoreActionsVisible: isMoreActionsVisible ?? this.isMoreActionsVisible,
      isVideoReady: isVideoReady ?? this.isVideoReady,
      videoPosition: videoPosition ?? this.videoPosition,
      videoDuration: videoDuration ?? this.videoDuration,
      isVideoPlaying: isVideoPlaying ?? this.isVideoPlaying,
    );
  }

  @override
  String toString() {
    return 'DetailPageState(isLoading: $isLoading, commentCount: ${comments.length}, hasContent: ${contentDetail != null})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DetailPageState &&
        other.isLoading == isLoading &&
        other.contentDetail?.id == contentDetail?.id &&
        other.comments.length == comments.length;
  }

  @override
  int get hashCode => Object.hash(
    isLoading,
    contentDetail?.id,
    comments.length,
  );
}

// ============== 6. UTILITY FUNCTIONS ==============
/// 工具函数：格式化时间显示
String formatDetailCreatedAt(DateTime dateTime) {
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
  } else if (difference.inDays < 30) {
    return '${(difference.inDays / 7).floor()}周前';
  } else if (difference.inDays < 365) {
    return '${(difference.inDays / 30).floor()}个月前';
  } else {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日';
  }
}

/// 工具函数：格式化数字显示（详情页专用，更精确）
String formatDetailCount(int count) {
  if (count < 1000) {
    return count.toString();
  } else if (count < 10000) {
    return '${(count / 1000).toStringAsFixed(1)}k';
  } else if (count < 100000) {
    return '${(count / 10000).toStringAsFixed(1)}万';
  } else if (count < 1000000) {
    return '${(count / 10000).toInt()}万';
  } else {
    return '${(count / 1000000).toStringAsFixed(1)}百万';
  }
}

/// 工具函数：格式化视频时长
String formatVideoDuration(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final remainingSeconds = seconds % 60;

  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  } else {
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

/// 工具函数：提取文本预览（用于分享）
String extractTextPreview(String text, {int maxLength = 50}) {
  if (text.length <= maxLength) return text;
  
  // 尝试在句号、感叹号、问号处截断
  final sentenceEnds = RegExp(r'[。！？.!?]');
  final match = sentenceEnds.firstMatch(text.substring(0, maxLength));
  
  if (match != null) {
    return text.substring(0, match.end);
  }
  
  // 否则直接截断并添加省略号
  return '${text.substring(0, maxLength)}...';
}

/// 工具函数：验证评论内容
bool isValidCommentContent(String content) {
  final trimmed = content.trim();
  return trimmed.length >= DetailConstants.minCommentLength && 
         trimmed.length <= DetailConstants.maxCommentLength;
}

/// 工具函数：生成分享链接
String generateShareUrl(String contentId, {String? platform}) {
  final baseUrl = DetailConstants.baseUrl.replaceAll('/v1', '');
  final url = '$baseUrl/content/$contentId';
  
  if (platform != null) {
    return '$url?from=$platform';
  }
  
  return url;
}

// ============== 7. EXPORTS ==============
/// 📤 导出定义
/// 
/// 本文件导出的公共类和枚举：
/// - DetailConstants: 内容详情页全局常量
/// - MediaType: 媒体类型枚举
/// - SharePlatform: 分享平台枚举
/// - ContentStatus: 内容状态枚举
/// - CommentStatus: 评论状态枚举
/// - MediaItemModel: 媒体项目模型
/// - UserDetailModel: 用户详情模型
/// - CommentModel: 评论模型
/// - ContentDetailModel: 内容详情模型
/// - InteractionState: 互动状态模型
/// - ShareContent: 分享内容模型
/// - DetailPageState: 详情页面状态模型
/// 
/// 工具函数：
/// - formatDetailCreatedAt: 格式化时间显示
/// - formatDetailCount: 格式化数字显示
/// - formatVideoDuration: 格式化视频时长
/// - extractTextPreview: 提取文本预览
/// - isValidCommentContent: 验证评论内容
/// - generateShareUrl: 生成分享链接
///
/// 使用方式：
/// ```dart
/// import '../models/content_detail_models.dart';
/// 
/// final content = ContentDetailModel.fromJson(jsonData);
/// final formattedTime = formatDetailCreatedAt(DateTime.now());
/// ```