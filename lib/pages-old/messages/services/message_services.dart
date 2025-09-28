// 🔧 消息系统服务层
// 提供消息的网络请求、本地存储、推送等服务

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

import '../models/message_models.dart';

// ============== 1. 消息API服务 ==============

/// 🌐 消息API服务
class MessageApiService {
  static const String _baseUrl = 'https://api.xiangyupai.com/v1';
  static const Duration _timeout = Duration(seconds: 30);

  // 模拟网络延迟
  static Future<void> _simulateNetworkDelay() async {
    if (kDebugMode) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// 获取对话列表
  static Future<List<Conversation>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    await _simulateNetworkDelay();
    
    try {
      // 模拟API响应数据
      final mockData = _generateMockConversations();
      developer.log('MessageApiService: 获取对话列表成功，数量: ${mockData.length}');
      return mockData;
    } catch (e) {
      developer.log('MessageApiService: 获取对话列表失败: $e');
      rethrow;
    }
  }

  /// 获取对话消息
  static Future<List<Message>> getConversationMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
    String? beforeMessageId,
  }) async {
    await _simulateNetworkDelay();
    
    try {
      // 模拟API响应数据
      final mockData = _generateMockMessages(conversationId);
      developer.log('MessageApiService: 获取对话消息成功，对话ID: $conversationId，消息数量: ${mockData.length}');
      return mockData;
    } catch (e) {
      developer.log('MessageApiService: 获取对话消息失败: $e');
      rethrow;
    }
  }

  /// 发送消息
  static Future<Message> sendMessage({
    required String conversationId,
    required String content,
    required MessageType type,
    Map<String, dynamic>? metadata,
  }) async {
    await _simulateNetworkDelay();
    
    try {
      // 创建消息
      final message = Message.text(
        id: MessageModelUtils.generateMessageId(),
        conversationId: conversationId,
        senderId: 'current_user_id', // 实际项目中从用户状态获取
        content: content,
      ).updateStatus(MessageStatus.sent);

      developer.log('MessageApiService: 发送消息成功: ${message.id}');
      return message;
    } catch (e) {
      developer.log('MessageApiService: 发送消息失败: $e');
      rethrow;
    }
  }

  /// 标记消息为已读
  static Future<void> markMessagesAsRead({
    required String conversationId,
    required List<String> messageIds,
  }) async {
    await _simulateNetworkDelay();
    
    try {
      developer.log('MessageApiService: 标记消息已读成功，对话ID: $conversationId，消息数量: ${messageIds.length}');
    } catch (e) {
      developer.log('MessageApiService: 标记消息已读失败: $e');
      rethrow;
    }
  }

  /// 获取分类消息（赞和收藏、评论、粉丝）
  static Future<List<Message>> getCategoryMessages({
    required MessageCategory category,
    int page = 1,
    int limit = 20,
  }) async {
    await _simulateNetworkDelay();
    
    try {
      final mockData = _generateMockCategoryMessages(category);
      developer.log('MessageApiService: 获取分类消息成功，类型: ${category.value}，数量: ${mockData.length}');
      return mockData;
    } catch (e) {
      developer.log('MessageApiService: 获取分类消息失败: $e');
      rethrow;
    }
  }

  /// 获取系统通知
  static Future<List<NotificationMessage>> getSystemNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    await _simulateNetworkDelay();
    
    try {
      final mockData = _generateMockNotifications();
      developer.log('MessageApiService: 获取系统通知成功，数量: ${mockData.length}');
      return mockData;
    } catch (e) {
      developer.log('MessageApiService: 获取系统通知失败: $e');
      rethrow;
    }
  }

  /// 获取消息统计
  static Future<MessageStats> getMessageStats() async {
    await _simulateNetworkDelay();
    
    try {
      final stats = MessageStats(
        totalUnreadCount: 8,
        chatUnreadCount: 3,
        likeUnreadCount: 2,
        commentUnreadCount: 1,
        followUnreadCount: 1,
        systemUnreadCount: 1,
        lastUpdatedAt: DateTime.now(),
      );
      
      developer.log('MessageApiService: 获取消息统计成功: ${stats.totalUnreadCount} 条未读');
      return stats;
    } catch (e) {
      developer.log('MessageApiService: 获取消息统计失败: $e');
      rethrow;
    }
  }

  /// 获取用户信息
  static Future<MessageUser> getUserInfo(String userId) async {
    await _simulateNetworkDelay();
    
    try {
      final user = MessageUser(
        id: userId,
        nickname: '用户$userId',
        avatar: 'https://picsum.photos/100/100?random=$userId',
        onlineStatus: UserOnlineStatus.values[userId.hashCode % UserOnlineStatus.values.length],
        signature: '这是用户的个性签名...',
      );
      
      developer.log('MessageApiService: 获取用户信息成功: ${user.nickname}');
      return user;
    } catch (e) {
      developer.log('MessageApiService: 获取用户信息失败: $e');
      rethrow;
    }
  }

  // ============== 模拟数据生成 ==============

  /// 生成模拟对话数据
  static List<Conversation> _generateMockConversations() {
    return [
      Conversation(
        id: 'conv_1',
        participantIds: ['current_user_id', 'user_1'],
        lastMessage: Message.text(
          id: 'msg_1',
          conversationId: 'conv_1',
          senderId: 'user_1',
          content: '你的作品好棒，可以加个微信吗...',
        ),
        unreadCount: 1,
        createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      Conversation(
        id: 'conv_2',
        participantIds: ['current_user_id', 'user_2'],
        lastMessage: Message.text(
          id: 'msg_2',
          conversationId: 'conv_2',
          senderId: 'current_user_id',
          content: '你的作品好棒。',
        ).updateStatus(MessageStatus.read),
        unreadCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Conversation(
        id: 'conv_3',
        participantIds: ['current_user_id', 'user_3'],
        lastMessage: Message.text(
          id: 'msg_3',
          conversationId: 'conv_3',
          senderId: 'user_3',
          content: '你的作品好棒，可以加个微信吗...',
        ),
        unreadCount: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];
  }

  /// 生成模拟消息数据
  static List<Message> _generateMockMessages(String conversationId) {
    return [
      Message.text(
        id: 'msg_${conversationId}_1',
        conversationId: conversationId,
        senderId: 'user_1',
        content: '什么时候有空能接我的订单',
      ).updateStatus(MessageStatus.read),
      Message.text(
        id: 'msg_${conversationId}_2',
        conversationId: conversationId,
        senderId: 'current_user_id',
        content: '现在就可以',
      ).updateStatus(MessageStatus.read),
      Message.image(
        id: 'msg_${conversationId}_3',
        conversationId: conversationId,
        senderId: 'current_user_id',
        imageUrl: 'https://picsum.photos/400/300?random=$conversationId',
        caption: '请你们看雪',
        imageMetadata: {'width': 400, 'height': 300},
      ).updateStatus(MessageStatus.read),
    ];
  }

  /// 生成模拟分类消息数据
  static List<Message> _generateMockCategoryMessages(MessageCategory category) {
    switch (category) {
      case MessageCategory.like:
        return [
          Message(
            id: 'like_msg_1',
            conversationId: 'likes',
            senderId: 'user_1',
            type: MessageType.system,
            category: MessageCategory.like,
            content: '点赞了你的评论',
            metadata: {
              'action_type': 'like',
              'target_type': 'comment',
              'target_id': 'comment_123',
              'target_content': '这里是评论 这里是评论 这里是评论',
              'target_image': 'https://picsum.photos/100/100?random=1',
            },
            status: MessageStatus.sent,
            createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
          ),
          Message(
            id: 'like_msg_2',
            conversationId: 'likes',
            senderId: 'user_2',
            type: MessageType.system,
            category: MessageCategory.like,
            content: '收藏了你的作品',
            metadata: {
              'action_type': 'favorite',
              'target_type': 'post',
              'target_id': 'post_456',
              'target_content': '这里是作品标题',
              'target_image': 'https://picsum.photos/100/100?random=2',
            },
            status: MessageStatus.sent,
            createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          ),
        ];
      
      case MessageCategory.comment:
        return [
          Message(
            id: 'comment_msg_1',
            conversationId: 'comments',
            senderId: 'user_3',
            type: MessageType.system,
            category: MessageCategory.comment,
            content: '评论了你的作品',
            metadata: {
              'action_type': 'comment',
              'target_type': 'post',
              'target_id': 'post_789',
              'comment_content': '这里是作品标题',
              'target_image': 'https://picsum.photos/100/100?random=3',
            },
            status: MessageStatus.sent,
            createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
          ),
        ];
      
      case MessageCategory.follow:
        return [
          Message(
            id: 'follow_msg_1',
            conversationId: 'follows',
            senderId: 'user_4',
            type: MessageType.system,
            category: MessageCategory.follow,
            content: '关注了你',
            metadata: {
              'action_type': 'follow',
              'user_signature': '这里是用户的个性签名...',
              'follow_status': 'not_following', // following, not_following, mutual
            },
            status: MessageStatus.sent,
            createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
          ),
          Message(
            id: 'follow_msg_2',
            conversationId: 'follows',
            senderId: 'user_5',
            type: MessageType.system,
            category: MessageCategory.follow,
            content: '关注了你',
            metadata: {
              'action_type': 'follow',
              'user_signature': '这里是用户的个性签名...',
              'follow_status': 'not_following',
            },
            status: MessageStatus.sent,
            createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
          ),
        ];
      
      default:
        return [];
    }
  }

  /// 生成模拟系统通知数据
  static List<NotificationMessage> _generateMockNotifications() {
    return [
      NotificationMessage(
        id: 'notif_1',
        userId: 'current_user_id',
        title: '完善个人资料',
        content: '您的账号尚未完善个人资料，前往主页完善资料可以获得更多曝光，更快认识新朋友！',
        priority: 'normal',
        createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
        metadata: {
          'action_type': 'profile_completion',
          'action_url': '/profile/edit',
        },
      ),
      NotificationMessage(
        id: 'notif_2',
        userId: 'current_user_id',
        title: '报名已通过',
        content: '您的报名已经通过，请准时在约定的时间前往地点哦',
        priority: 'high',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        metadata: {
          'action_type': 'booking_approved',
          'booking_id': 'booking_123',
          'action_url': '/bookings/booking_123',
        },
      ),
    ];
  }
}

// ============== 2. 本地存储服务 ==============

/// 💾 消息本地存储服务
class MessageStorageService {
  static const String _conversationsKey = 'conversations';
  static const String _messagesPrefix = 'messages_';
  static const String _userInfoPrefix = 'user_info_';
  static const String _messageStatsKey = 'message_stats';

  // 模拟本地存储
  static final Map<String, String> _localStorage = {};

  /// 保存对话列表
  static Future<void> saveConversations(List<Conversation> conversations) async {
    try {
      final json = jsonEncode(conversations.map((c) => c.toJson()).toList());
      _localStorage[_conversationsKey] = json;
      developer.log('MessageStorageService: 保存对话列表成功，数量: ${conversations.length}');
    } catch (e) {
      developer.log('MessageStorageService: 保存对话列表失败: $e');
      rethrow;
    }
  }

  /// 获取对话列表
  static Future<List<Conversation>> getConversations() async {
    try {
      final json = _localStorage[_conversationsKey];
      if (json == null) return [];

      final List<dynamic> data = jsonDecode(json);
      final conversations = data.map((item) => Conversation.fromJson(item)).toList();
      developer.log('MessageStorageService: 获取对话列表成功，数量: ${conversations.length}');
      return conversations;
    } catch (e) {
      developer.log('MessageStorageService: 获取对话列表失败: $e');
      return [];
    }
  }

  /// 保存对话消息
  static Future<void> saveMessages(String conversationId, List<Message> messages) async {
    try {
      final key = '$_messagesPrefix$conversationId';
      final json = jsonEncode(messages.map((m) => m.toJson()).toList());
      _localStorage[key] = json;
      developer.log('MessageStorageService: 保存对话消息成功，对话ID: $conversationId，消息数量: ${messages.length}');
    } catch (e) {
      developer.log('MessageStorageService: 保存对话消息失败: $e');
      rethrow;
    }
  }

  /// 获取对话消息
  static Future<List<Message>> getMessages(String conversationId) async {
    try {
      final key = '$_messagesPrefix$conversationId';
      final json = _localStorage[key];
      if (json == null) return [];

      final List<dynamic> data = jsonDecode(json);
      final messages = data.map((item) => Message.fromJson(item)).toList();
      developer.log('MessageStorageService: 获取对话消息成功，对话ID: $conversationId，消息数量: ${messages.length}');
      return messages;
    } catch (e) {
      developer.log('MessageStorageService: 获取对话消息失败: $e');
      return [];
    }
  }

  /// 添加新消息
  static Future<void> addMessage(Message message) async {
    try {
      final existingMessages = await getMessages(message.conversationId);
      existingMessages.add(message);
      await saveMessages(message.conversationId, existingMessages);
      developer.log('MessageStorageService: 添加消息成功: ${message.id}');
    } catch (e) {
      developer.log('MessageStorageService: 添加消息失败: $e');
      rethrow;
    }
  }

  /// 更新消息状态
  static Future<void> updateMessageStatus(String conversationId, String messageId, MessageStatus status) async {
    try {
      final messages = await getMessages(conversationId);
      final messageIndex = messages.indexWhere((m) => m.id == messageId);
      
      if (messageIndex != -1) {
        messages[messageIndex] = messages[messageIndex].updateStatus(status);
        await saveMessages(conversationId, messages);
        developer.log('MessageStorageService: 更新消息状态成功: $messageId -> ${status.value}');
      }
    } catch (e) {
      developer.log('MessageStorageService: 更新消息状态失败: $e');
      rethrow;
    }
  }

  /// 保存用户信息
  static Future<void> saveUserInfo(MessageUser user) async {
    try {
      final key = '$_userInfoPrefix${user.id}';
      final json = jsonEncode(user.toJson());
      _localStorage[key] = json;
      developer.log('MessageStorageService: 保存用户信息成功: ${user.nickname}');
    } catch (e) {
      developer.log('MessageStorageService: 保存用户信息失败: $e');
      rethrow;
    }
  }

  /// 获取用户信息
  static Future<MessageUser?> getUserInfo(String userId) async {
    try {
      final key = '$_userInfoPrefix$userId';
      final json = _localStorage[key];
      if (json == null) return null;

      final user = MessageUser.fromJson(jsonDecode(json));
      developer.log('MessageStorageService: 获取用户信息成功: ${user.nickname}');
      return user;
    } catch (e) {
      developer.log('MessageStorageService: 获取用户信息失败: $e');
      return null;
    }
  }

  /// 保存消息统计
  static Future<void> saveMessageStats(MessageStats stats) async {
    try {
      final json = jsonEncode(stats.toJson());
      _localStorage[_messageStatsKey] = json;
      developer.log('MessageStorageService: 保存消息统计成功');
    } catch (e) {
      developer.log('MessageStorageService: 保存消息统计失败: $e');
      rethrow;
    }
  }

  /// 获取消息统计
  static Future<MessageStats?> getMessageStats() async {
    try {
      final json = _localStorage[_messageStatsKey];
      if (json == null) return null;

      final stats = MessageStats.fromJson(jsonDecode(json));
      developer.log('MessageStorageService: 获取消息统计成功');
      return stats;
    } catch (e) {
      developer.log('MessageStorageService: 获取消息统计失败: $e');
      return null;
    }
  }

  /// 清空所有数据
  static Future<void> clearAll() async {
    try {
      _localStorage.clear();
      developer.log('MessageStorageService: 清空所有数据成功');
    } catch (e) {
      developer.log('MessageStorageService: 清空所有数据失败: $e');
      rethrow;
    }
  }
}

// ============== 3. 消息推送服务 ==============

/// 📱 消息推送服务
class MessagePushService {
  static MessagePushService? _instance;
  static MessagePushService get instance => _instance ??= MessagePushService._();
  MessagePushService._();

  final StreamController<Message> _messageStreamController = StreamController<Message>.broadcast();
  final StreamController<MessageStats> _statsStreamController = StreamController<MessageStats>.broadcast();
  
  Timer? _heartbeatTimer;
  bool _isConnected = false;

  /// 消息流
  Stream<Message> get messageStream => _messageStreamController.stream;

  /// 统计流
  Stream<MessageStats> get statsStream => _statsStreamController.stream;

  /// 是否已连接
  bool get isConnected => _isConnected;

  /// 初始化推送服务
  Future<void> initialize() async {
    try {
      await _connectToServer();
      _startHeartbeat();
      developer.log('MessagePushService: 初始化成功');
    } catch (e) {
      developer.log('MessagePushService: 初始化失败: $e');
      rethrow;
    }
  }

  /// 连接到服务器
  Future<void> _connectToServer() async {
    // 模拟WebSocket连接
    await Future.delayed(const Duration(milliseconds: 500));
    _isConnected = true;
    developer.log('MessagePushService: 连接服务器成功');
  }

  /// 开始心跳
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        developer.log('MessagePushService: 心跳检测');
      }
    });
  }

  /// 模拟接收新消息
  void simulateNewMessage(Message message) {
    if (_isConnected) {
      _messageStreamController.add(message);
      developer.log('MessagePushService: 收到新消息: ${message.id}');
    }
  }

  /// 模拟统计更新
  void simulateStatsUpdate(MessageStats stats) {
    if (_isConnected) {
      _statsStreamController.add(stats);
      developer.log('MessagePushService: 统计更新: ${stats.totalUnreadCount} 条未读');
    }
  }

  /// 发送消息状态更新
  Future<void> sendMessageStatusUpdate(String messageId, MessageStatus status) async {
    if (!_isConnected) return;
    
    try {
      // 模拟发送状态更新到服务器
      await Future.delayed(const Duration(milliseconds: 100));
      developer.log('MessagePushService: 发送消息状态更新: $messageId -> ${status.value}');
    } catch (e) {
      developer.log('MessagePushService: 发送消息状态更新失败: $e');
      rethrow;
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    try {
      _heartbeatTimer?.cancel();
      _isConnected = false;
      developer.log('MessagePushService: 断开连接');
    } catch (e) {
      developer.log('MessagePushService: 断开连接失败: $e');
    }
  }

  /// 销毁服务
  void dispose() {
    _heartbeatTimer?.cancel();
    _messageStreamController.close();
    _statsStreamController.close();
    _isConnected = false;
    developer.log('MessagePushService: 服务已销毁');
  }
}

// ============== 4. 综合消息服务 ==============

/// 🔧 综合消息服务
class MessageService {
  static MessageService? _instance;
  static MessageService get instance => _instance ??= MessageService._();
  MessageService._();

  final MessagePushService _pushService = MessagePushService.instance;
  bool _isInitialized = false;

  /// 是否已初始化
  bool get isInitialized => _isInitialized;

  /// 消息流
  Stream<Message> get messageStream => _pushService.messageStream;

  /// 统计流
  Stream<MessageStats> get statsStream => _pushService.statsStream;

  /// 初始化消息服务
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _pushService.initialize();
      _isInitialized = true;
      developer.log('MessageService: 初始化成功');
    } catch (e) {
      developer.log('MessageService: 初始化失败: $e');
      rethrow;
    }
  }

  /// 获取对话列表（优先从缓存，然后网络）
  Future<List<Conversation>> getConversations({bool forceRefresh = false}) async {
    try {
      List<Conversation> conversations = [];
      
      // 如果不强制刷新，先尝试从缓存获取
      if (!forceRefresh) {
        conversations = await MessageStorageService.getConversations();
      }
      
      // 如果缓存为空或强制刷新，从网络获取
      if (conversations.isEmpty || forceRefresh) {
        conversations = await MessageApiService.getConversations();
        // 保存到缓存
        await MessageStorageService.saveConversations(conversations);
      }
      
      // 按排序权重排序
      conversations.sort((a, b) => b.getSortWeight().compareTo(a.getSortWeight()));
      
      developer.log('MessageService: 获取对话列表成功，数量: ${conversations.length}');
      return conversations;
    } catch (e) {
      developer.log('MessageService: 获取对话列表失败: $e');
      // 发生错误时尝试从缓存获取
      return await MessageStorageService.getConversations();
    }
  }

  /// 获取对话消息
  Future<List<Message>> getConversationMessages(String conversationId, {bool forceRefresh = false}) async {
    try {
      List<Message> messages = [];
      
      // 如果不强制刷新，先尝试从缓存获取
      if (!forceRefresh) {
        messages = await MessageStorageService.getMessages(conversationId);
      }
      
      // 如果缓存为空或强制刷新，从网络获取
      if (messages.isEmpty || forceRefresh) {
        messages = await MessageApiService.getConversationMessages(conversationId: conversationId);
        // 保存到缓存
        await MessageStorageService.saveMessages(conversationId, messages);
      }
      
      // 按时间排序
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      developer.log('MessageService: 获取对话消息成功，对话ID: $conversationId，消息数量: ${messages.length}');
      return messages;
    } catch (e) {
      developer.log('MessageService: 获取对话消息失败: $e');
      // 发生错误时尝试从缓存获取
      return await MessageStorageService.getMessages(conversationId);
    }
  }

  /// 发送消息
  Future<Message> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // 先创建本地消息
      final localMessage = Message.text(
        id: MessageModelUtils.generateMessageId(),
        conversationId: conversationId,
        senderId: 'current_user_id',
        content: content,
      );
      
      // 保存到本地缓存
      await MessageStorageService.addMessage(localMessage);
      
      // 发送到服务器
      final serverMessage = await MessageApiService.sendMessage(
        conversationId: conversationId,
        content: content,
        type: type,
        metadata: metadata,
      );
      
      // 更新本地消息状态
      await MessageStorageService.updateMessageStatus(
        conversationId,
        localMessage.id,
        serverMessage.status,
      );
      
      developer.log('MessageService: 发送消息成功: ${serverMessage.id}');
      return serverMessage;
    } catch (e) {
      developer.log('MessageService: 发送消息失败: $e');
      rethrow;
    }
  }

  /// 获取分类消息
  Future<List<Message>> getCategoryMessages(MessageCategory category, {bool forceRefresh = false}) async {
    try {
      final messages = await MessageApiService.getCategoryMessages(category: category);
      developer.log('MessageService: 获取分类消息成功，类型: ${category.value}，数量: ${messages.length}');
      return messages;
    } catch (e) {
      developer.log('MessageService: 获取分类消息失败: $e');
      return [];
    }
  }

  /// 获取系统通知
  Future<List<NotificationMessage>> getSystemNotifications({bool forceRefresh = false}) async {
    try {
      final notifications = await MessageApiService.getSystemNotifications();
      developer.log('MessageService: 获取系统通知成功，数量: ${notifications.length}');
      return notifications;
    } catch (e) {
      developer.log('MessageService: 获取系统通知失败: $e');
      return [];
    }
  }

  /// 获取消息统计
  Future<MessageStats> getMessageStats({bool forceRefresh = false}) async {
    try {
      MessageStats? stats;
      
      // 如果不强制刷新，先尝试从缓存获取
      if (!forceRefresh) {
        stats = await MessageStorageService.getMessageStats();
      }
      
      // 如果缓存为空或强制刷新，从网络获取
      if (stats == null || forceRefresh) {
        stats = await MessageApiService.getMessageStats();
        // 保存到缓存
        await MessageStorageService.saveMessageStats(stats);
      }
      
      developer.log('MessageService: 获取消息统计成功: ${stats.totalUnreadCount} 条未读');
      return stats;
    } catch (e) {
      developer.log('MessageService: 获取消息统计失败: $e');
      // 发生错误时返回默认统计
      return MessageStats(lastUpdatedAt: DateTime.now());
    }
  }

  /// 获取用户信息
  Future<MessageUser> getUserInfo(String userId) async {
    try {
      // 先从缓存获取
      MessageUser? user = await MessageStorageService.getUserInfo(userId);
      
      // 如果缓存没有，从网络获取
      if (user == null) {
        user = await MessageApiService.getUserInfo(userId);
        // 保存到缓存
        await MessageStorageService.saveUserInfo(user);
      }
      
      developer.log('MessageService: 获取用户信息成功: ${user.nickname}');
      return user;
    } catch (e) {
      developer.log('MessageService: 获取用户信息失败: $e');
      // 返回默认用户信息
      return MessageUser(
        id: userId,
        nickname: '用户$userId',
      );
    }
  }

  /// 标记消息为已读
  Future<void> markMessagesAsRead(String conversationId, List<String> messageIds) async {
    try {
      // 更新本地状态
      for (final messageId in messageIds) {
        await MessageStorageService.updateMessageStatus(conversationId, messageId, MessageStatus.read);
      }
      
      // 发送到服务器
      await MessageApiService.markMessagesAsRead(
        conversationId: conversationId,
        messageIds: messageIds,
      );
      
      developer.log('MessageService: 标记消息已读成功，数量: ${messageIds.length}');
    } catch (e) {
      developer.log('MessageService: 标记消息已读失败: $e');
      rethrow;
    }
  }

  /// 清空所有数据
  Future<void> clearAllData() async {
    try {
      await MessageStorageService.clearAll();
      developer.log('MessageService: 清空所有数据成功');
    } catch (e) {
      developer.log('MessageService: 清空所有数据失败: $e');
      rethrow;
    }
  }

  /// 销毁服务
  void dispose() {
    _pushService.dispose();
    _isInitialized = false;
    developer.log('MessageService: 服务已销毁');
  }
}
