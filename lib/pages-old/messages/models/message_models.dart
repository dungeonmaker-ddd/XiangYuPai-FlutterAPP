// 🏗️ 消息系统数据模型
// 基于消息系统模块架构设计的完整数据模型定义

import 'dart:convert';

// ============== 1. 消息类型枚举 ==============

/// 💬 消息类型枚举
enum MessageType {
  text('text', '文字消息'),
  image('image', '图片消息'),
  voice('voice', '语音消息'),
  video('video', '视频消息'),
  system('system', '系统消息');

  const MessageType(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// 📋 消息分类类型枚举
enum MessageCategory {
  chat('chat', '私聊消息'),
  like('like', '赞和收藏'),
  comment('comment', '评论消息'),
  follow('follow', '粉丝消息'),
  system('system', '系统通知');

  const MessageCategory(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// 📊 消息状态枚举
enum MessageStatus {
  sending('sending', '发送中'),
  sent('sent', '已发送'),
  delivered('delivered', '已送达'),
  read('read', '已读'),
  failed('failed', '发送失败');

  const MessageStatus(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// 👤 用户在线状态枚举
enum UserOnlineStatus {
  online('online', '在线'),
  offline('offline', '离线'),
  away('away', '离开'),
  busy('busy', '忙碌');

  const UserOnlineStatus(this.value, this.displayName);
  final String value;
  final String displayName;
}

// ============== 2. 基础消息模型 ==============

/// 💬 消息基础模型
class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String? receiverId;
  final MessageType type;
  final MessageCategory category;
  final String content;
  final Map<String, dynamic>? metadata;
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? readAt;
  final bool isDeleted;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.receiverId,
    required this.type,
    required this.category,
    required this.content,
    this.metadata,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.readAt,
    this.isDeleted = false,
  });

  /// 创建文字消息
  factory Message.text({
    required String id,
    required String conversationId,
    required String senderId,
    String? receiverId,
    required String content,
    MessageCategory category = MessageCategory.chat,
  }) {
    return Message(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      receiverId: receiverId,
      type: MessageType.text,
      category: category,
      content: content,
      status: MessageStatus.sending,
      createdAt: DateTime.now(),
    );
  }

  /// 创建图片消息
  factory Message.image({
    required String id,
    required String conversationId,
    required String senderId,
    String? receiverId,
    required String imageUrl,
    String? caption,
    Map<String, dynamic>? imageMetadata,
  }) {
    return Message(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      receiverId: receiverId,
      type: MessageType.image,
      category: MessageCategory.chat,
      content: imageUrl,
      metadata: {
        'caption': caption,
        'width': imageMetadata?['width'],
        'height': imageMetadata?['height'],
        'size': imageMetadata?['size'],
        ...?imageMetadata,
      },
      status: MessageStatus.sending,
      createdAt: DateTime.now(),
    );
  }

  /// 创建系统通知消息
  factory Message.systemNotification({
    required String id,
    required String receiverId,
    required String title,
    required String content,
    String? actionUrl,
    Map<String, dynamic>? notificationMetadata,
  }) {
    return Message(
      id: id,
      conversationId: 'system_$receiverId',
      senderId: 'system',
      receiverId: receiverId,
      type: MessageType.system,
      category: MessageCategory.system,
      content: content,
      metadata: {
        'title': title,
        'actionUrl': actionUrl,
        'priority': notificationMetadata?['priority'] ?? 'normal',
        ...?notificationMetadata,
      },
      status: MessageStatus.sent,
      createdAt: DateTime.now(),
    );
  }

  /// 从JSON创建
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String?,
      type: MessageType.values.firstWhere(
        (e) => e.value == json['type'],
        orElse: () => MessageType.text,
      ),
      category: MessageCategory.values.firstWhere(
        (e) => e.value == json['category'],
        orElse: () => MessageCategory.chat,
      ),
      content: json['content'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      status: MessageStatus.values.firstWhere(
        (e) => e.value == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      readAt: json['read_at'] != null 
          ? DateTime.parse(json['read_at'] as String) 
          : null,
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'type': type.value,
      'category': category.value,
      'content': content,
      'metadata': metadata,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'is_deleted': isDeleted,
    };
  }

  /// 复制并修改
  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? receiverId,
    MessageType? type,
    MessageCategory? category,
    String? content,
    Map<String, dynamic>? metadata,
    MessageStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? readAt,
    bool? isDeleted,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
      category: category ?? this.category,
      content: content ?? this.content,
      metadata: metadata ?? this.metadata,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      readAt: readAt ?? this.readAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// 标记为已读
  Message markAsRead() {
    return copyWith(
      status: MessageStatus.read,
      readAt: DateTime.now(),
    );
  }

  /// 更新消息状态
  Message updateStatus(MessageStatus newStatus) {
    return copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );
  }

  /// 获取显示时间
  String get displayTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${createdAt.month}-${createdAt.day.toString().padLeft(2, '0')}';
    }
  }

  /// 获取消息预览文本
  String get previewText {
    switch (type) {
      case MessageType.text:
        return content;
      case MessageType.image:
        final caption = metadata?['caption'] as String?;
        return caption?.isNotEmpty == true ? '[图片] $caption' : '[图片]';
      case MessageType.voice:
        return '[语音]';
      case MessageType.video:
        return '[视频]';
      case MessageType.system:
        return content;
    }
  }

  /// 是否为自己发送的消息
  bool isSentByMe(String currentUserId) {
    return senderId == currentUserId;
  }

  /// 是否未读
  bool get isUnread {
    return status != MessageStatus.read && readAt == null;
  }

  @override
  String toString() {
    return 'Message(id: $id, type: ${type.value}, content: $content, status: ${status.value})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ============== 3. 对话模型 ==============

/// 💬 对话模型
class Conversation {
  final String id;
  final String? title;
  final List<String> participantIds;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isMuted;
  final bool isPinned;
  final Map<String, dynamic>? metadata;

  const Conversation({
    required this.id,
    this.title,
    required this.participantIds,
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.isMuted = false,
    this.isPinned = false,
    this.metadata,
  });

  /// 从JSON创建
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String?,
      participantIds: List<String>.from(json['participant_ids'] as List),
      lastMessage: json['last_message'] != null 
          ? Message.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      isMuted: json['is_muted'] as bool? ?? false,
      isPinned: json['is_pinned'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'participant_ids': participantIds,
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_muted': isMuted,
      'is_pinned': isPinned,
      'metadata': metadata,
    };
  }

  /// 复制并修改
  Conversation copyWith({
    String? id,
    String? title,
    List<String>? participantIds,
    Message? lastMessage,
    int? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isMuted,
    bool? isPinned,
    Map<String, dynamic>? metadata,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      participantIds: participantIds ?? this.participantIds,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isMuted: isMuted ?? this.isMuted,
      isPinned: isPinned ?? this.isPinned,
      metadata: metadata ?? this.metadata,
    );
  }

  /// 更新最后一条消息
  Conversation updateLastMessage(Message message) {
    return copyWith(
      lastMessage: message,
      updatedAt: message.createdAt,
      unreadCount: message.isSentByMe(participantIds.first) ? unreadCount : unreadCount + 1,
    );
  }

  /// 标记所有消息为已读
  Conversation markAllAsRead() {
    return copyWith(
      unreadCount: 0,
      updatedAt: DateTime.now(),
    );
  }

  /// 切换静音状态
  Conversation toggleMute() {
    return copyWith(
      isMuted: !isMuted,
      updatedAt: DateTime.now(),
    );
  }

  /// 切换置顶状态
  Conversation togglePin() {
    return copyWith(
      isPinned: !isPinned,
      updatedAt: DateTime.now(),
    );
  }

  /// 获取对话对方用户ID（私聊场景）
  String? getOtherParticipantId(String currentUserId) {
    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  /// 获取显示标题
  String getDisplayTitle(String currentUserId, {String? otherUserName}) {
    if (title != null && title!.isNotEmpty) {
      return title!;
    }
    
    // 私聊场景，返回对方用户名
    if (participantIds.length == 2) {
      return otherUserName ?? '未知用户';
    }
    
    // 群聊场景
    return '群聊 (${participantIds.length}人)';
  }

  /// 是否有未读消息
  bool get hasUnreadMessages => unreadCount > 0;

  /// 获取排序权重（置顶 > 最新消息时间）
  int getSortWeight() {
    if (isPinned) return 1000000 + (updatedAt?.millisecondsSinceEpoch ?? 0);
    return updatedAt?.millisecondsSinceEpoch ?? createdAt.millisecondsSinceEpoch;
  }

  @override
  String toString() {
    return 'Conversation(id: $id, participants: $participantIds, unread: $unreadCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Conversation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ============== 4. 用户模型 ==============

/// 👤 消息系统用户模型
class MessageUser {
  final String id;
  final String nickname;
  final String? avatar;
  final UserOnlineStatus onlineStatus;
  final DateTime? lastSeenAt;
  final String? signature;
  final Map<String, dynamic>? profile;

  const MessageUser({
    required this.id,
    required this.nickname,
    this.avatar,
    this.onlineStatus = UserOnlineStatus.offline,
    this.lastSeenAt,
    this.signature,
    this.profile,
  });

  /// 从JSON创建
  factory MessageUser.fromJson(Map<String, dynamic> json) {
    return MessageUser(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String?,
      onlineStatus: UserOnlineStatus.values.firstWhere(
        (e) => e.value == json['online_status'],
        orElse: () => UserOnlineStatus.offline,
      ),
      lastSeenAt: json['last_seen_at'] != null 
          ? DateTime.parse(json['last_seen_at'] as String) 
          : null,
      signature: json['signature'] as String?,
      profile: json['profile'] as Map<String, dynamic>?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatar': avatar,
      'online_status': onlineStatus.value,
      'last_seen_at': lastSeenAt?.toIso8601String(),
      'signature': signature,
      'profile': profile,
    };
  }

  /// 复制并修改
  MessageUser copyWith({
    String? id,
    String? nickname,
    String? avatar,
    UserOnlineStatus? onlineStatus,
    DateTime? lastSeenAt,
    String? signature,
    Map<String, dynamic>? profile,
  }) {
    return MessageUser(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      onlineStatus: onlineStatus ?? this.onlineStatus,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      signature: signature ?? this.signature,
      profile: profile ?? this.profile,
    );
  }

  /// 更新在线状态
  MessageUser updateOnlineStatus(UserOnlineStatus status) {
    return copyWith(
      onlineStatus: status,
      lastSeenAt: status == UserOnlineStatus.offline ? DateTime.now() : null,
    );
  }

  /// 获取显示名称
  String get displayName {
    return nickname.isNotEmpty ? nickname : '用户$id';
  }

  /// 获取名称首字母
  String get initials {
    if (nickname.isEmpty) return '?';
    final parts = nickname.trim().split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  /// 是否在线
  bool get isOnline => onlineStatus == UserOnlineStatus.online;

  /// 获取在线状态显示文本
  String get onlineStatusText {
    switch (onlineStatus) {
      case UserOnlineStatus.online:
        return '在线';
      case UserOnlineStatus.away:
        return '离开';
      case UserOnlineStatus.busy:
        return '忙碌';
      case UserOnlineStatus.offline:
        if (lastSeenAt != null) {
          final difference = DateTime.now().difference(lastSeenAt!);
          if (difference.inMinutes < 60) {
            return '${difference.inMinutes}分钟前在线';
          } else if (difference.inHours < 24) {
            return '${difference.inHours}小时前在线';
          } else {
            return '${difference.inDays}天前在线';
          }
        }
        return '离线';
    }
  }

  /// 是否有头像
  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;

  @override
  String toString() {
    return 'MessageUser(id: $id, nickname: $nickname, status: ${onlineStatus.value})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ============== 5. 通知消息模型 ==============

/// 🔔 通知消息模型
class NotificationMessage {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String? actionUrl;
  final String? imageUrl;
  final String priority; // high, normal, low
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic>? metadata;

  const NotificationMessage({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.actionUrl,
    this.imageUrl,
    this.priority = 'normal',
    this.isRead = false,
    required this.createdAt,
    this.readAt,
    this.metadata,
  });

  /// 从JSON创建
  factory NotificationMessage.fromJson(Map<String, dynamic> json) {
    return NotificationMessage(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      actionUrl: json['action_url'] as String?,
      imageUrl: json['image_url'] as String?,
      priority: json['priority'] as String? ?? 'normal',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null 
          ? DateTime.parse(json['read_at'] as String) 
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'action_url': actionUrl,
      'image_url': imageUrl,
      'priority': priority,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// 复制并修改
  NotificationMessage copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? actionUrl,
    String? imageUrl,
    String? priority,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationMessage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      actionUrl: actionUrl ?? this.actionUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// 标记为已读
  NotificationMessage markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  /// 获取优先级颜色
  String get priorityColor {
    switch (priority) {
      case 'high':
        return '#FF4444';
      case 'normal':
        return '#FFA500';
      case 'low':
        return '#4CAF50';
      default:
        return '#9E9E9E';
    }
  }

  /// 获取显示时间
  String get displayTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${createdAt.month}-${createdAt.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  String toString() {
    return 'NotificationMessage(id: $id, title: $title, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ============== 6. 消息统计模型 ==============

/// 📊 消息统计模型
class MessageStats {
  final int totalUnreadCount;
  final int chatUnreadCount;
  final int likeUnreadCount;
  final int commentUnreadCount;
  final int followUnreadCount;
  final int systemUnreadCount;
  final DateTime lastUpdatedAt;

  const MessageStats({
    this.totalUnreadCount = 0,
    this.chatUnreadCount = 0,
    this.likeUnreadCount = 0,
    this.commentUnreadCount = 0,
    this.followUnreadCount = 0,
    this.systemUnreadCount = 0,
    required this.lastUpdatedAt,
  });

  /// 从JSON创建
  factory MessageStats.fromJson(Map<String, dynamic> json) {
    return MessageStats(
      totalUnreadCount: json['total_unread_count'] as int? ?? 0,
      chatUnreadCount: json['chat_unread_count'] as int? ?? 0,
      likeUnreadCount: json['like_unread_count'] as int? ?? 0,
      commentUnreadCount: json['comment_unread_count'] as int? ?? 0,
      followUnreadCount: json['follow_unread_count'] as int? ?? 0,
      systemUnreadCount: json['system_unread_count'] as int? ?? 0,
      lastUpdatedAt: DateTime.parse(json['last_updated_at'] as String),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'total_unread_count': totalUnreadCount,
      'chat_unread_count': chatUnreadCount,
      'like_unread_count': likeUnreadCount,
      'comment_unread_count': commentUnreadCount,
      'follow_unread_count': followUnreadCount,
      'system_unread_count': systemUnreadCount,
      'last_updated_at': lastUpdatedAt.toIso8601String(),
    };
  }

  /// 复制并修改
  MessageStats copyWith({
    int? totalUnreadCount,
    int? chatUnreadCount,
    int? likeUnreadCount,
    int? commentUnreadCount,
    int? followUnreadCount,
    int? systemUnreadCount,
    DateTime? lastUpdatedAt,
  }) {
    return MessageStats(
      totalUnreadCount: totalUnreadCount ?? this.totalUnreadCount,
      chatUnreadCount: chatUnreadCount ?? this.chatUnreadCount,
      likeUnreadCount: likeUnreadCount ?? this.likeUnreadCount,
      commentUnreadCount: commentUnreadCount ?? this.commentUnreadCount,
      followUnreadCount: followUnreadCount ?? this.followUnreadCount,
      systemUnreadCount: systemUnreadCount ?? this.systemUnreadCount,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  /// 获取分类的未读数量
  int getUnreadCountByCategory(MessageCategory category) {
    switch (category) {
      case MessageCategory.chat:
        return chatUnreadCount;
      case MessageCategory.like:
        return likeUnreadCount;
      case MessageCategory.comment:
        return commentUnreadCount;
      case MessageCategory.follow:
        return followUnreadCount;
      case MessageCategory.system:
        return systemUnreadCount;
    }
  }

  /// 是否有未读消息
  bool get hasUnreadMessages => totalUnreadCount > 0;

  @override
  String toString() {
    return 'MessageStats(total: $totalUnreadCount, chat: $chatUnreadCount, like: $likeUnreadCount, comment: $commentUnreadCount, follow: $followUnreadCount, system: $systemUnreadCount)';
  }
}

// ============== 7. 工具函数 ==============

/// 📋 消息模型工具类
class MessageModelUtils {
  /// 生成消息ID
  static String generateMessageId() {
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000).toString().padLeft(3, '0')}';
  }

  /// 生成对话ID
  static String generateConversationId(List<String> participantIds) {
    final sortedIds = List<String>.from(participantIds)..sort();
    return 'conv_${sortedIds.join('_')}';
  }

  /// 格式化未读数量显示
  static String formatUnreadCount(int count) {
    if (count <= 0) return '';
    if (count <= 99) return count.toString();
    return '99+';
  }

  /// 解析消息内容中的链接
  static List<String> extractUrls(String content) {
    final urlRegex = RegExp(
      r'https?://[^\s]+',
      caseSensitive: false,
    );
    return urlRegex.allMatches(content).map((m) => m.group(0)!).toList();
  }

  /// 检查消息内容是否包含敏感词
  static bool containsSensitiveWords(String content) {
    // 简单的敏感词检测，实际项目中应该使用更完善的过滤系统
    const sensitiveWords = ['spam', 'advertisement', '广告'];
    final lowerContent = content.toLowerCase();
    return sensitiveWords.any((word) => lowerContent.contains(word));
  }

  /// 创建消息列表的JSON
  static Map<String, dynamic> messagesToJson(List<Message> messages) {
    return {
      'messages': messages.map((m) => m.toJson()).toList(),
      'count': messages.length,
      'last_updated': DateTime.now().toIso8601String(),
    };
  }

  /// 从JSON创建消息列表
  static List<Message> messagesFromJson(Map<String, dynamic> json) {
    final messagesList = json['messages'] as List?;
    if (messagesList == null) return [];
    
    return messagesList
        .map((m) => Message.fromJson(m as Map<String, dynamic>))
        .toList();
  }
}
