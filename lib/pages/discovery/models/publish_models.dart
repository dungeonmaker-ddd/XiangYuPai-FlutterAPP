// 📝 发布动态数据模型 - 基于Flutter单文件架构规范
// 定义发布动态页面相关的所有数据结构和枚举类型

// ============== 1. IMPORTS ==============
// Dart核心库
import 'dart:convert';

// ============== 2. CONSTANTS ==============
/// 🎨 发布动态全局常量
class PublishConstants {
  // 私有构造函数，防止实例化
  const PublishConstants._();
  
  // API端点
  static const String baseUrl = 'https://api.example.com/v1';
  static const String publishEndpoint = '/content/publish';
  static const String uploadEndpoint = '/media/upload';
  static const String draftEndpoint = '/content/draft';
  static const String topicEndpoint = '/topics';
  static const String locationEndpoint = '/locations';
  
  // 文件上传配置
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  static const int maxVideoSize = 100 * 1024 * 1024; // 100MB
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> supportedVideoFormats = ['mp4', 'mov', 'avi', 'mkv'];
  
  // 内容限制
  static const int maxTextLength = 2000;
  static const int maxImageCount = 9;
  static const int maxVideoCount = 1;
  static const int maxTopicCount = 5;
  static const int minTopicLength = 2;
  static const int maxTopicLength = 20;
  
  // 草稿配置
  static const Duration autoSaveInterval = Duration(seconds: 30);
  static const int maxDraftCount = 10;
  static const Duration draftExpiration = Duration(days: 30);
  static const int draftExpireDays = 30;
  
  // 地理位置配置
  static const double locationAccuracy = 100.0; // 米
  static const Duration locationTimeout = Duration(seconds: 10);
  
  // 压缩配置
  static const int imageQuality = 85;
  static const int thumbnailSize = 200;
  static const String videoCodec = 'h264';
  static const int videoBitrate = 2000; // kbps
  static const int chunkSize = 1024 * 1024; // 1MB
}

// ============== 3. ENUMS ==============
/// 媒体类型枚举
enum MediaType {
  image('image', '图片'),
  video('video', '视频');

  const MediaType(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// 媒体来源枚举
enum MediaSource {
  camera('camera', '拍摄'),
  gallery('gallery', '相册'),
  file('file', '文件'),
  video('video', '视频');

  const MediaSource(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// 上传状态枚举
enum UploadStatus {
  pending('pending', '等待上传'),
  uploading('uploading', '上传中'),
  success('success', '上传成功'),
  completed('completed', '上传完成'),
  failed('failed', '上传失败'),
  cancelled('cancelled', '已取消');

  const UploadStatus(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// 发布状态枚举
enum PublishStatus {
  draft('draft', '草稿'),
  publishing('publishing', '发布中'),
  success('success', '发布成功'),
  failed('failed', '发布失败');

  const PublishStatus(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// 隐私级别枚举
enum PrivacyLevel {
  public('public', '公开'),
  followers('followers', '仅关注者'),
  private('private', '私密');

  const PrivacyLevel(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// 位置类型枚举
enum LocationType {
  gps('gps', 'GPS定位'),
  poi('poi', '兴趣点'),
  custom('custom', '自定义'),
  manual('manual', '手动');

  const LocationType(this.value, this.displayName);
  final String value;
  final String displayName;
}

// ============== 4. DATA MODELS ==============
/// 🖼️ 媒体文件模型
class MediaModel {
  final String id;
  final MediaType type;
  final MediaSource source;
  final String localPath;
  final String filePath;
  final String? remotePath;
  final String? url;
  final String? thumbnailPath;
  final int? width;
  final int? height;
  final int? duration; // 视频时长（秒）
  final int fileSize;
  final UploadStatus uploadStatus;
  final double uploadProgress;
  final String? errorMessage;
  final DateTime createdAt;

  const MediaModel({
    required this.id,
    required this.type,
    required this.source,
    required this.localPath,
    required this.filePath,
    this.remotePath,
    this.url,
    this.thumbnailPath,
    this.width,
    this.height,
    this.duration,
    required this.fileSize,
    this.uploadStatus = UploadStatus.pending,
    this.uploadProgress = 0.0,
    this.errorMessage,
    required this.createdAt,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'] as String,
      type: MediaType.values.firstWhere((e) => e.value == json['type']),
      source: MediaSource.values.firstWhere((e) => e.value == json['source']),
      localPath: json['local_path'] as String,
      filePath: json['file_path'] as String? ?? json['local_path'] as String,
      remotePath: json['remote_path'] as String?,
      url: json['url'] as String?,
      thumbnailPath: json['thumbnail_path'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      duration: json['duration'] as int?,
      fileSize: json['file_size'] as int,
      uploadStatus: UploadStatus.values.firstWhere(
        (e) => e.value == json['upload_status'],
        orElse: () => UploadStatus.pending,
      ),
      uploadProgress: (json['upload_progress'] as num?)?.toDouble() ?? 0.0,
      errorMessage: json['error_message'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'source': source.value,
      'local_path': localPath,
      'file_path': filePath,
      'remote_path': remotePath,
      'url': url,
      'thumbnail_path': thumbnailPath,
      'width': width,
      'height': height,
      'duration': duration,
      'file_size': fileSize,
      'upload_status': uploadStatus.value,
      'upload_progress': uploadProgress,
      'error_message': errorMessage,
      'created_at': createdAt.toIso8601String(),
    };
  }

  MediaModel copyWith({
    String? id,
    MediaType? type,
    MediaSource? source,
    String? localPath,
    String? filePath,
    String? remotePath,
    String? url,
    String? thumbnailPath,
    int? width,
    int? height,
    int? duration,
    int? fileSize,
    UploadStatus? uploadStatus,
    double? uploadProgress,
    String? errorMessage,
    DateTime? createdAt,
  }) {
    return MediaModel(
      id: id ?? this.id,
      type: type ?? this.type,
      source: source ?? this.source,
      localPath: localPath ?? this.localPath,
      filePath: filePath ?? this.filePath,
      remotePath: remotePath ?? this.remotePath,
      url: url ?? this.url,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      width: width ?? this.width,
      height: height ?? this.height,
      duration: duration ?? this.duration,
      fileSize: fileSize ?? this.fileSize,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'MediaModel(id: $id, type: $type, uploadStatus: $uploadStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 🏷️ 话题模型
class TopicModel {
  final String id;
  final String name;
  final String displayName;
  final String? description;
  final String? category;
  final int contentCount;
  final bool isHot;
  final bool isOfficial;
  final DateTime createdAt;

  const TopicModel({
    required this.id,
    required this.name,
    required this.displayName,
    this.description,
    this.category,
    this.contentCount = 0,
    this.isHot = false,
    this.isOfficial = false,
    required this.createdAt,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['display_name'] as String? ?? json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      contentCount: json['content_count'] as int? ?? 0,
      isHot: json['is_hot'] as bool? ?? false,
      isOfficial: json['is_official'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'description': description,
      'category': category,
      'content_count': contentCount,
      'is_hot': isHot,
      'is_official': isOfficial,
      'created_at': createdAt.toIso8601String(),
    };
  }

  TopicModel copyWith({
    String? id,
    String? name,
    String? displayName,
    String? description,
    String? category,
    int? contentCount,
    bool? isHot,
    bool? isOfficial,
    DateTime? createdAt,
  }) {
    return TopicModel(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      category: category ?? this.category,
      contentCount: contentCount ?? this.contentCount,
      isHot: isHot ?? this.isHot,
      isOfficial: isOfficial ?? this.isOfficial,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'TopicModel(id: $id, name: $name, contentCount: $contentCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TopicModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 📍 位置模型
class LocationModel {
  final String id;
  final String name;
  final String? address;
  final double latitude;
  final double longitude;
  final LocationType type;
  final String? category;
  final double? distance; // 距离用户的距离（km）
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const LocationModel({
    required this.id,
    required this.name,
    this.address,
    required this.latitude,
    required this.longitude,
    this.type = LocationType.gps,
    this.category,
    this.distance,
    this.metadata,
    required this.createdAt,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      type: LocationType.values.firstWhere(
        (e) => e.value == json['type'],
        orElse: () => LocationType.gps,
      ),
      category: json['category'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
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
      'type': type.value,
      'category': category,
      'distance': distance,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  LocationModel copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    LocationType? type,
    String? category,
    double? distance,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return LocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      category: category ?? this.category,
      distance: distance ?? this.distance,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'LocationModel(id: $id, name: $name, distance: ${distance?.toStringAsFixed(1)}km)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 📄 草稿模型
class DraftModel {
  final String id;
  final PublishContentModel content;
  final String textContent;
  final List<MediaModel> mediaFiles;
  final List<TopicModel> selectedTopics;
  final LocationModel? selectedLocation;
  final PrivacyLevel privacy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastModified;
  final bool isAutoSaved;
  final String? version;

  const DraftModel({
    required this.id,
    required this.content,
    required this.textContent,
    this.mediaFiles = const [],
    this.selectedTopics = const [],
    this.selectedLocation,
    this.privacy = PrivacyLevel.public,
    required this.createdAt,
    required this.updatedAt,
    required this.lastModified,
    this.isAutoSaved = true,
    this.version,
  });

  factory DraftModel.fromJson(Map<String, dynamic> json) {
    return DraftModel(
      id: json['id'] as String,
      content: PublishContentModel.fromJson(json['content'] as Map<String, dynamic>),
      textContent: json['text_content'] as String? ?? '',
      mediaFiles: (json['media_files'] as List<dynamic>?)
          ?.map((e) => MediaModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      selectedTopics: (json['selected_topics'] as List<dynamic>?)
          ?.map((e) => TopicModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      selectedLocation: json['selected_location'] != null
          ? LocationModel.fromJson(json['selected_location'] as Map<String, dynamic>)
          : null,
      privacy: PrivacyLevel.values.firstWhere(
        (e) => e.value == json['privacy'],
        orElse: () => PrivacyLevel.public,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastModified: DateTime.parse(json['last_modified'] as String? ?? json['updated_at'] as String),
      isAutoSaved: json['is_auto_saved'] as bool? ?? true,
      version: json['version'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content.toJson(),
      'text_content': textContent,
      'media_files': mediaFiles.map((e) => e.toJson()).toList(),
      'selected_topics': selectedTopics.map((e) => e.toJson()).toList(),
      'selected_location': selectedLocation?.toJson(),
      'privacy': privacy.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_modified': lastModified.toIso8601String(),
      'is_auto_saved': isAutoSaved,
      'version': version,
    };
  }

  DraftModel copyWith({
    String? id,
    PublishContentModel? content,
    String? textContent,
    List<MediaModel>? mediaFiles,
    List<TopicModel>? selectedTopics,
    LocationModel? selectedLocation,
    PrivacyLevel? privacy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastModified,
    bool? isAutoSaved,
    String? version,
  }) {
    return DraftModel(
      id: id ?? this.id,
      content: content ?? this.content,
      textContent: textContent ?? this.textContent,
      mediaFiles: mediaFiles ?? this.mediaFiles,
      selectedTopics: selectedTopics ?? this.selectedTopics,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      privacy: privacy ?? this.privacy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastModified: lastModified ?? this.lastModified,
      isAutoSaved: isAutoSaved ?? this.isAutoSaved,
      version: version ?? this.version,
    );
  }

  @override
  String toString() {
    return 'DraftModel(id: $id, updatedAt: $updatedAt, isAutoSaved: $isAutoSaved)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DraftModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 📝 发布内容模型
class PublishContentModel {
  final String id;
  final String text;
  final String textContent;
  final List<MediaModel> mediaItems;
  final List<MediaModel> mediaFiles;
  final List<TopicModel> topics;
  final LocationModel? location;
  final PrivacyLevel privacyLevel;
  final PublishUserModel user;
  final DateTime createdAt;

  const PublishContentModel({
    required this.id,
    required this.text,
    required this.textContent,
    this.mediaItems = const [],
    this.mediaFiles = const [],
    this.topics = const [],
    this.location,
    this.privacyLevel = PrivacyLevel.public,
    required this.user,
    required this.createdAt,
  });

  factory PublishContentModel.fromJson(Map<String, dynamic> json) {
    return PublishContentModel(
      id: json['id'] as String,
      text: json['text'] as String,
      textContent: json['text_content'] as String? ?? json['text'] as String,
      mediaItems: (json['media_items'] as List<dynamic>?)
          ?.map((e) => MediaModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      mediaFiles: (json['media_files'] as List<dynamic>?)
          ?.map((e) => MediaModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      topics: (json['topics'] as List<dynamic>?)
          ?.map((e) => TopicModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      location: json['location'] != null
          ? LocationModel.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      privacyLevel: PrivacyLevel.values.firstWhere(
        (e) => e.value == json['privacy_level'],
        orElse: () => PrivacyLevel.public,
      ),
      user: PublishUserModel.fromJson(json['user'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'text_content': textContent,
      'media_items': mediaItems.map((e) => e.toJson()).toList(),
      'media_files': mediaFiles.map((e) => e.toJson()).toList(),
      'topics': topics.map((e) => e.toJson()).toList(),
      'location': location?.toJson(),
      'privacy_level': privacyLevel.value,
      'user': user.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  PublishContentModel copyWith({
    String? id,
    String? text,
    String? textContent,
    List<MediaModel>? mediaItems,
    List<MediaModel>? mediaFiles,
    List<TopicModel>? topics,
    LocationModel? location,
    PrivacyLevel? privacyLevel,
    PublishUserModel? user,
    DateTime? createdAt,
  }) {
    return PublishContentModel(
      id: id ?? this.id,
      text: text ?? this.text,
      textContent: textContent ?? this.textContent,
      mediaItems: mediaItems ?? this.mediaItems,
      mediaFiles: mediaFiles ?? this.mediaFiles,
      topics: topics ?? this.topics,
      location: location ?? this.location,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'PublishContentModel(id: $id, mediaCount: ${mediaItems.length}, topicCount: ${topics.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PublishContentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 👤 发布用户模型
class PublishUserModel {
  final String id;
  final String nickname;
  final String avatar;
  final String avatarUrl;
  final bool isVerified;
  final int contentCount;

  const PublishUserModel({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.avatarUrl,
    this.isVerified = false,
    this.contentCount = 0,
  });

  factory PublishUserModel.fromJson(Map<String, dynamic> json) {
    return PublishUserModel(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String,
      avatarUrl: json['avatar_url'] as String? ?? json['avatar'] as String,
      isVerified: json['is_verified'] as bool? ?? false,
      contentCount: json['content_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatar': avatar,
      'avatar_url': avatarUrl,
      'is_verified': isVerified,
      'content_count': contentCount,
    };
  }

  PublishUserModel copyWith({
    String? id,
    String? nickname,
    String? avatar,
    String? avatarUrl,
    bool? isVerified,
    int? contentCount,
  }) {
    return PublishUserModel(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      contentCount: contentCount ?? this.contentCount,
    );
  }

  @override
  String toString() {
    return 'PublishUserModel(id: $id, nickname: $nickname, isVerified: $isVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PublishUserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 🏷️ 话题分类模型
class TopicCategoryModel {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final int topicCount;
  final bool isDefault;
  final int sortOrder;
  final DateTime createdAt;

  const TopicCategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.topicCount = 0,
    this.isDefault = false,
    this.sortOrder = 0,
    required this.createdAt,
  });

  factory TopicCategoryModel.fromJson(Map<String, dynamic> json) {
    return TopicCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      topicCount: json['topic_count'] as int? ?? 0,
      isDefault: json['is_default'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'topic_count': topicCount,
      'is_default': isDefault,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  TopicCategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    int? topicCount,
    bool? isDefault,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return TopicCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      topicCount: topicCount ?? this.topicCount,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'TopicCategoryModel(id: $id, name: $name, topicCount: $topicCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TopicCategoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ============== 5. STATE MODELS ==============
/// 📱 发布页面状态模型
class PublishState {
  final bool isLoading;
  final bool isPublishing;
  final bool isSavingDraft;
  final bool isUploadingMedia;
  final bool isMediaProcessing;
  final String text;
  final String textContent;
  final List<MediaModel> mediaItems;
  final List<MediaModel> mediaFiles;
  final List<TopicModel> selectedTopics;
  final List<TopicModel> detectedTopics;
  final LocationModel? selectedLocation;
  final LocationModel? currentLocation;
  final PrivacyLevel privacyLevel;
  final PrivacyLevel privacy;
  final PublishStatus? publishStatus;
  final String? publishedContentId;
  final String? errorMessage;
  final bool hasDraft;
  final String? draftId;
  final DateTime? lastSavedAt;
  final DateTime? lastSaved;
  final bool isTextValid;
  final int characterCount;
  final PublishUserModel? user;

  const PublishState({
    this.isLoading = false,
    this.isPublishing = false,
    this.isSavingDraft = false,
    this.isUploadingMedia = false,
    this.isMediaProcessing = false,
    this.text = '',
    this.textContent = '',
    this.mediaItems = const [],
    this.mediaFiles = const [],
    this.selectedTopics = const [],
    this.detectedTopics = const [],
    this.selectedLocation,
    this.currentLocation,
    this.privacyLevel = PrivacyLevel.public,
    this.privacy = PrivacyLevel.public,
    this.publishStatus,
    this.publishedContentId,
    this.errorMessage,
    this.hasDraft = false,
    this.draftId,
    this.lastSavedAt,
    this.lastSaved,
    this.isTextValid = false,
    this.characterCount = 0,
    this.user,
  });

  PublishState copyWith({
    bool? isLoading,
    bool? isPublishing,
    bool? isSavingDraft,
    bool? isUploadingMedia,
    bool? isMediaProcessing,
    String? text,
    String? textContent,
    List<MediaModel>? mediaItems,
    List<MediaModel>? mediaFiles,
    List<TopicModel>? selectedTopics,
    List<TopicModel>? detectedTopics,
    LocationModel? selectedLocation,
    LocationModel? currentLocation,
    PrivacyLevel? privacyLevel,
    PrivacyLevel? privacy,
    PublishStatus? publishStatus,
    String? publishedContentId,
    String? errorMessage,
    bool? hasDraft,
    String? draftId,
    DateTime? lastSavedAt,
    DateTime? lastSaved,
    bool? isTextValid,
    int? characterCount,
    PublishUserModel? user,
  }) {
    return PublishState(
      isLoading: isLoading ?? this.isLoading,
      isPublishing: isPublishing ?? this.isPublishing,
      isSavingDraft: isSavingDraft ?? this.isSavingDraft,
      isUploadingMedia: isUploadingMedia ?? this.isUploadingMedia,
      isMediaProcessing: isMediaProcessing ?? this.isMediaProcessing,
      text: text ?? this.text,
      textContent: textContent ?? this.textContent,
      mediaItems: mediaItems ?? this.mediaItems,
      mediaFiles: mediaFiles ?? this.mediaFiles,
      selectedTopics: selectedTopics ?? this.selectedTopics,
      detectedTopics: detectedTopics ?? this.detectedTopics,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      currentLocation: currentLocation ?? this.currentLocation,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      privacy: privacy ?? this.privacy,
      publishStatus: publishStatus ?? this.publishStatus,
      publishedContentId: publishedContentId ?? this.publishedContentId,
      errorMessage: errorMessage,
      hasDraft: hasDraft ?? this.hasDraft,
      draftId: draftId ?? this.draftId,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      lastSaved: lastSaved ?? this.lastSaved,
      isTextValid: isTextValid ?? this.isTextValid,
      characterCount: characterCount ?? this.characterCount,
      user: user ?? this.user,
    );
  }

  @override
  String toString() {
    return 'PublishState(isPublishing: $isPublishing, mediaCount: ${mediaItems.length}, topicCount: ${selectedTopics.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PublishState &&
        other.isLoading == isLoading &&
        other.isPublishing == isPublishing &&
        other.text == text &&
        other.mediaItems.length == mediaItems.length &&
        other.selectedTopics.length == selectedTopics.length;
  }

  @override
  int get hashCode => Object.hash(
    isLoading,
    isPublishing,
    text,
    mediaItems.length,
    selectedTopics.length,
  );
}

// ============== 6. RESPONSE MODELS ==============
/// 📤 发布响应模型
class PublishResponse {
  final bool success;
  final String? contentId;
  final String? errorMessage;
  final int? errorCode;
  final Map<String, dynamic>? metadata;

  const PublishResponse({
    required this.success,
    this.contentId,
    this.errorMessage,
    this.errorCode,
    this.metadata,
  });

  factory PublishResponse.fromJson(Map<String, dynamic> json) {
    return PublishResponse(
      success: json['success'] as bool,
      contentId: json['content_id'] as String?,
      errorMessage: json['error_message'] as String?,
      errorCode: json['error_code'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'content_id': contentId,
      'error_message': errorMessage,
      'error_code': errorCode,
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'PublishResponse(success: $success, contentId: $contentId, errorMessage: $errorMessage)';
  }
}

/// 📤 上传响应模型
class UploadResponse {
  final bool success;
  final String? mediaId;
  final String? url;
  final String? thumbnailUrl;
  final String? errorMessage;
  final int? errorCode;

  const UploadResponse({
    required this.success,
    this.mediaId,
    this.url,
    this.thumbnailUrl,
    this.errorMessage,
    this.errorCode,
  });

  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(
      success: json['success'] as bool,
      mediaId: json['media_id'] as String?,
      url: json['url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      errorMessage: json['error_message'] as String?,
      errorCode: json['error_code'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'media_id': mediaId,
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'error_message': errorMessage,
      'error_code': errorCode,
    };
  }

  @override
  String toString() {
    return 'UploadResponse(success: $success, mediaId: $mediaId, url: $url)';
  }
}

// ============== 7. UTILITY FUNCTIONS ==============
/// 工具函数：格式化文件大小
String formatFileSize(int bytes) {
  if (bytes < 1024) {
    return '${bytes}B';
  } else if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)}KB';
  } else if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  } else {
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}

/// 工具函数：格式化时长（秒转换为mm:ss格式）
String formatDuration(int seconds) {
  final minutes = seconds ~/ 60;
  final remainingSeconds = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}

/// 工具函数：验证文件类型
bool isValidFileType(String fileName, MediaType type) {
  final extension = fileName.split('.').last.toLowerCase();
  
  switch (type) {
    case MediaType.image:
      return PublishConstants.supportedImageFormats.contains(extension);
    case MediaType.video:
      return PublishConstants.supportedVideoFormats.contains(extension);
  }
}

/// 工具函数：验证文件大小
bool isValidFileSize(int fileSize, MediaType type) {
  switch (type) {
    case MediaType.image:
      return fileSize <= PublishConstants.maxImageSize;
    case MediaType.video:
      return fileSize <= PublishConstants.maxVideoSize;
  }
}

/// 工具函数：生成唯一ID
String generateUniqueId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final random = (timestamp * 1000 + DateTime.now().microsecond) % 1000000;
  return '${timestamp}_$random';
}

// ============== 8. EXPORTS ==============
/// 📤 导出定义
/// 
/// 本文件导出的公共类和枚举：
/// - PublishConstants: 发布动态全局常量
/// - MediaType: 媒体类型枚举
/// - MediaSource: 媒体来源枚举
/// - UploadStatus: 上传状态枚举
/// - PublishStatus: 发布状态枚举
/// - PrivacyLevel: 隐私级别枚举
/// - LocationType: 位置类型枚举
/// - MediaModel: 媒体文件模型
/// - TopicModel: 话题模型
/// - LocationModel: 位置模型
/// - DraftModel: 草稿模型
/// - PublishContentModel: 发布内容模型
/// - PublishUserModel: 发布用户模型
/// - TopicCategoryModel: 话题分类模型
/// - PublishState: 发布页面状态模型
/// - PublishResponse: 发布响应模型
/// - UploadResponse: 上传响应模型
/// 
/// 工具函数：
/// - formatFileSize: 格式化文件大小
/// - formatDuration: 格式化时长
/// - isValidFileType: 验证文件类型
/// - isValidFileSize: 验证文件大小
/// - generateUniqueId: 生成唯一ID
///
/// 使用方式：
/// ```dart
/// import '../models/publish_models.dart';
/// 
/// final media = MediaModel.fromJson(jsonData);
/// final formattedSize = formatFileSize(1024 * 1024); // "1.0MB"
/// ```