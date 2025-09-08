// 🧠 消息系统状态管理
// 基于ChangeNotifier的消息状态管理，支持实时更新和本地缓存

import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

import '../models/message_models.dart';
import '../services/message_services.dart';

// ============== 1. 主消息Provider ==============

/// 💬 主消息Provider - 管理整个消息系统的状态
class MessageProvider extends ChangeNotifier {
  final MessageService _messageService = MessageService.instance;
  
  // 状态变量
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;
  MessageStats _messageStats = MessageStats(lastUpdatedAt: DateTime.now());
  
  // 流订阅
  StreamSubscription<Message>? _messageStreamSubscription;
  StreamSubscription<MessageStats>? _statsStreamSubscription;

  // Getter方法
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MessageStats get messageStats => _messageStats;
  
  /// 总未读消息数
  int get totalUnreadCount => _messageStats.totalUnreadCount;
  
  /// 各分类未读数
  int get chatUnreadCount => _messageStats.chatUnreadCount;
  int get likeUnreadCount => _messageStats.likeUnreadCount;
  int get commentUnreadCount => _messageStats.commentUnreadCount;
  int get followUnreadCount => _messageStats.followUnreadCount;
  int get systemUnreadCount => _messageStats.systemUnreadCount;

  /// 初始化消息系统
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      // 初始化消息服务
      await _messageService.initialize();
      
      // 加载消息统计
      await _loadMessageStats();
      
      // 订阅实时更新
      _subscribeToUpdates();
      
      _isInitialized = true;
      developer.log('MessageProvider: 初始化成功');
    } catch (e) {
      _setError('初始化消息系统失败: $e');
      developer.log('MessageProvider: 初始化失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 加载消息统计
  Future<void> _loadMessageStats({bool forceRefresh = false}) async {
    try {
      final stats = await _messageService.getMessageStats(forceRefresh: forceRefresh);
      _messageStats = stats;
      notifyListeners();
      developer.log('MessageProvider: 加载消息统计成功: ${stats.totalUnreadCount} 条未读');
    } catch (e) {
      developer.log('MessageProvider: 加载消息统计失败: $e');
    }
  }

  /// 刷新消息统计
  Future<void> refreshMessageStats() async {
    await _loadMessageStats(forceRefresh: true);
  }

  /// 订阅实时更新
  void _subscribeToUpdates() {
    // 订阅新消息
    _messageStreamSubscription = _messageService.messageStream.listen(
      (message) {
        developer.log('MessageProvider: 收到新消息: ${message.id}');
        // 更新统计（简化处理，实际项目中应该更精确）
        _updateStatsForNewMessage(message);
      },
      onError: (error) {
        developer.log('MessageProvider: 消息流错误: $error');
      },
    );

    // 订阅统计更新
    _statsStreamSubscription = _messageService.statsStream.listen(
      (stats) {
        _messageStats = stats;
        notifyListeners();
        developer.log('MessageProvider: 统计更新: ${stats.totalUnreadCount} 条未读');
      },
      onError: (error) {
        developer.log('MessageProvider: 统计流错误: $error');
      },
    );
  }

  /// 更新新消息的统计
  void _updateStatsForNewMessage(Message message) {
    if (message.isUnread) {
      final newStats = _messageStats.copyWith(
        totalUnreadCount: _messageStats.totalUnreadCount + 1,
        chatUnreadCount: message.category == MessageCategory.chat 
            ? _messageStats.chatUnreadCount + 1 
            : _messageStats.chatUnreadCount,
        likeUnreadCount: message.category == MessageCategory.like 
            ? _messageStats.likeUnreadCount + 1 
            : _messageStats.likeUnreadCount,
        commentUnreadCount: message.category == MessageCategory.comment 
            ? _messageStats.commentUnreadCount + 1 
            : _messageStats.commentUnreadCount,
        followUnreadCount: message.category == MessageCategory.follow 
            ? _messageStats.followUnreadCount + 1 
            : _messageStats.followUnreadCount,
        systemUnreadCount: message.category == MessageCategory.system 
            ? _messageStats.systemUnreadCount + 1 
            : _messageStats.systemUnreadCount,
        lastUpdatedAt: DateTime.now(),
      );
      
      _messageStats = newStats;
      notifyListeners();
    }
  }

  /// 获取分类的未读数量
  int getUnreadCountByCategory(MessageCategory category) {
    return _messageStats.getUnreadCountByCategory(category);
  }

  /// 模拟接收新消息（用于测试）
  void simulateNewMessage({
    MessageCategory category = MessageCategory.chat,
    String content = '新消息内容',
  }) {
    final message = Message.text(
      id: MessageModelUtils.generateMessageId(),
      conversationId: 'test_conversation',
      senderId: 'test_user',
      content: content,
      category: category,
    );
    
    MessagePushService.instance.simulateNewMessage(message);
  }

  /// 设置加载状态
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// 设置错误信息
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// 清除错误信息
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _messageStreamSubscription?.cancel();
    _statsStreamSubscription?.cancel();
    super.dispose();
    developer.log('MessageProvider: 已销毁');
  }
}

// ============== 2. 对话列表Provider ==============

/// 💬 对话列表Provider
class ConversationProvider extends ChangeNotifier {
  final MessageService _messageService = MessageService.instance;
  
  // 状态变量
  List<Conversation> _conversations = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  
  // 用户信息缓存
  final Map<String, MessageUser> _userCache = {};

  // Getter方法
  List<Conversation> get conversations => List.unmodifiable(_conversations);
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  bool get hasConversations => _conversations.isNotEmpty;
  int get conversationCount => _conversations.length;

  /// 加载对话列表
  Future<void> loadConversations({bool forceRefresh = false}) async {
    if (_isLoading) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      final conversations = await _messageService.getConversations(forceRefresh: forceRefresh);
      _conversations = conversations;
      
      // 预加载用户信息
      await _preloadUserInfo();
      
      notifyListeners();
      developer.log('ConversationProvider: 加载对话列表成功，数量: ${conversations.length}');
    } catch (e) {
      _setError('加载对话列表失败: $e');
      developer.log('ConversationProvider: 加载对话列表失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 刷新对话列表
  Future<void> refreshConversations() async {
    if (_isRefreshing) return;
    
    _setRefreshing(true);
    _clearError();
    
    try {
      final conversations = await _messageService.getConversations(forceRefresh: true);
      _conversations = conversations;
      
      // 预加载用户信息
      await _preloadUserInfo();
      
      notifyListeners();
      developer.log('ConversationProvider: 刷新对话列表成功，数量: ${conversations.length}');
    } catch (e) {
      _setError('刷新对话列表失败: $e');
      developer.log('ConversationProvider: 刷新对话列表失败: $e');
    } finally {
      _setRefreshing(false);
    }
  }

  /// 预加载用户信息
  Future<void> _preloadUserInfo() async {
    final userIds = <String>{};
    
    // 收集所有需要加载的用户ID
    for (final conversation in _conversations) {
      userIds.addAll(conversation.participantIds);
      if (conversation.lastMessage?.senderId != null) {
        userIds.add(conversation.lastMessage!.senderId);
      }
    }
    
    // 并行加载用户信息
    final futures = userIds.map((userId) => _loadUserInfo(userId));
    await Future.wait(futures);
  }

  /// 加载用户信息
  Future<void> _loadUserInfo(String userId) async {
    if (_userCache.containsKey(userId)) return;
    
    try {
      final user = await _messageService.getUserInfo(userId);
      _userCache[userId] = user;
    } catch (e) {
      developer.log('ConversationProvider: 加载用户信息失败: $userId -> $e');
    }
  }

  /// 获取用户信息
  MessageUser? getUserInfo(String userId) {
    return _userCache[userId];
  }

  /// 获取对话显示标题
  String getConversationTitle(Conversation conversation, String currentUserId) {
    final otherUserId = conversation.getOtherParticipantId(currentUserId);
    final otherUser = otherUserId != null ? _userCache[otherUserId] : null;
    return conversation.getDisplayTitle(currentUserId, otherUserName: otherUser?.displayName);
  }

  /// 获取对话中对方用户
  MessageUser? getOtherUser(Conversation conversation, String currentUserId) {
    final otherUserId = conversation.getOtherParticipantId(currentUserId);
    return otherUserId != null ? _userCache[otherUserId] : null;
  }

  /// 更新对话（新消息到达时）
  void updateConversationWithMessage(Message message) {
    final conversationIndex = _conversations.indexWhere((c) => c.id == message.conversationId);
    
    if (conversationIndex != -1) {
      // 更新现有对话
      _conversations[conversationIndex] = _conversations[conversationIndex].updateLastMessage(message);
      
      // 重新排序
      _conversations.sort((a, b) => b.getSortWeight().compareTo(a.getSortWeight()));
      
      notifyListeners();
      developer.log('ConversationProvider: 更新对话: ${message.conversationId}');
    }
  }

  /// 标记对话为已读
  Future<void> markConversationAsRead(String conversationId) async {
    try {
      final conversationIndex = _conversations.indexWhere((c) => c.id == conversationId);
      
      if (conversationIndex != -1) {
        _conversations[conversationIndex] = _conversations[conversationIndex].markAllAsRead();
        notifyListeners();
        
        developer.log('ConversationProvider: 标记对话已读: $conversationId');
      }
    } catch (e) {
      developer.log('ConversationProvider: 标记对话已读失败: $e');
    }
  }

  /// 切换对话静音状态
  Future<void> toggleConversationMute(String conversationId) async {
    try {
      final conversationIndex = _conversations.indexWhere((c) => c.id == conversationId);
      
      if (conversationIndex != -1) {
        _conversations[conversationIndex] = _conversations[conversationIndex].toggleMute();
        notifyListeners();
        
        developer.log('ConversationProvider: 切换对话静音: $conversationId');
      }
    } catch (e) {
      developer.log('ConversationProvider: 切换对话静音失败: $e');
    }
  }

  /// 切换对话置顶状态
  Future<void> toggleConversationPin(String conversationId) async {
    try {
      final conversationIndex = _conversations.indexWhere((c) => c.id == conversationId);
      
      if (conversationIndex != -1) {
        _conversations[conversationIndex] = _conversations[conversationIndex].togglePin();
        
        // 重新排序
        _conversations.sort((a, b) => b.getSortWeight().compareTo(a.getSortWeight()));
        
        notifyListeners();
        
        developer.log('ConversationProvider: 切换对话置顶: $conversationId');
      }
    } catch (e) {
      developer.log('ConversationProvider: 切换对话置顶失败: $e');
    }
  }

  /// 删除对话
  Future<void> deleteConversation(String conversationId) async {
    try {
      _conversations.removeWhere((c) => c.id == conversationId);
      notifyListeners();
      
      developer.log('ConversationProvider: 删除对话: $conversationId');
    } catch (e) {
      developer.log('ConversationProvider: 删除对话失败: $e');
    }
  }

  /// 清空所有对话
  Future<void> clearAllConversations() async {
    try {
      _conversations.clear();
      notifyListeners();
      
      developer.log('ConversationProvider: 清空所有对话');
    } catch (e) {
      developer.log('ConversationProvider: 清空所有对话失败: $e');
    }
  }

  /// 设置加载状态
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// 设置刷新状态
  void _setRefreshing(bool refreshing) {
    if (_isRefreshing != refreshing) {
      _isRefreshing = refreshing;
      notifyListeners();
    }
  }

  /// 设置错误信息
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// 清除错误信息
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
    developer.log('ConversationProvider: 已销毁');
  }
}

// ============== 3. 聊天Provider ==============

/// 💬 聊天Provider - 管理单个对话的消息
class ChatProvider extends ChangeNotifier {
  final MessageService _messageService = MessageService.instance;
  
  // 状态变量
  String? _conversationId;
  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isSending = false;
  String? _errorMessage;
  
  // 对话信息
  Conversation? _conversation;
  MessageUser? _otherUser;
  
  // 分页信息
  bool _hasMore = true;
  int _currentPage = 1;

  // Getter方法
  String? get conversationId => _conversationId;
  List<Message> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  Conversation? get conversation => _conversation;
  MessageUser? get otherUser => _otherUser;
  bool get hasMessages => _messages.isNotEmpty;
  bool get hasMore => _hasMore;

  /// 初始化聊天（加载对话和消息）
  Future<void> initializeChat(String conversationId, {String? otherUserId}) async {
    if (_conversationId == conversationId && _messages.isNotEmpty) return;
    
    _conversationId = conversationId;
    _setLoading(true);
    _clearError();
    
    try {
      // 加载消息
      await _loadMessages(forceRefresh: true);
      
      // 加载对方用户信息
      if (otherUserId != null) {
        _otherUser = await _messageService.getUserInfo(otherUserId);
      }
      
      // 标记消息为已读
      await _markMessagesAsRead();
      
      notifyListeners();
      developer.log('ChatProvider: 初始化聊天成功: $conversationId');
    } catch (e) {
      _setError('初始化聊天失败: $e');
      developer.log('ChatProvider: 初始化聊天失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 加载消息
  Future<void> _loadMessages({bool forceRefresh = false}) async {
    if (_conversationId == null) return;
    
    try {
      final messages = await _messageService.getConversationMessages(
        _conversationId!,
        forceRefresh: forceRefresh,
      );
      
      _messages = messages;
      _currentPage = 1;
      _hasMore = messages.length >= 50; // 假设每页50条
      
      developer.log('ChatProvider: 加载消息成功，数量: ${messages.length}');
    } catch (e) {
      developer.log('ChatProvider: 加载消息失败: $e');
      rethrow;
    }
  }

  /// 加载更多历史消息
  Future<void> loadMoreMessages() async {
    if (_conversationId == null || _isLoadingMore || !_hasMore) return;
    
    _setLoadingMore(true);
    
    try {
      // 模拟加载更多消息（实际项目中应该调用分页API）
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 这里应该是真实的分页加载逻辑
      final moreMessages = <Message>[]; // 空列表表示没有更多消息
      
      if (moreMessages.isEmpty) {
        _hasMore = false;
      } else {
        _messages.insertAll(0, moreMessages);
        _currentPage++;
      }
      
      notifyListeners();
      developer.log('ChatProvider: 加载更多消息，新增: ${moreMessages.length}');
    } catch (e) {
      _setError('加载更多消息失败: $e');
      developer.log('ChatProvider: 加载更多消息失败: $e');
    } finally {
      _setLoadingMore(false);
    }
  }

  /// 发送文字消息
  Future<void> sendTextMessage(String content) async {
    if (_conversationId == null || content.trim().isEmpty || _isSending) return;
    
    _setSending(true);
    _clearError();
    
    try {
      final message = await _messageService.sendMessage(
        conversationId: _conversationId!,
        content: content.trim(),
        type: MessageType.text,
      );
      
      // 添加到消息列表
      _messages.add(message);
      notifyListeners();
      
      developer.log('ChatProvider: 发送文字消息成功: ${message.id}');
    } catch (e) {
      _setError('发送消息失败: $e');
      developer.log('ChatProvider: 发送文字消息失败: $e');
    } finally {
      _setSending(false);
    }
  }

  /// 发送图片消息
  Future<void> sendImageMessage(String imageUrl, {String? caption}) async {
    if (_conversationId == null || imageUrl.isEmpty || _isSending) return;
    
    _setSending(true);
    _clearError();
    
    try {
      final message = await _messageService.sendMessage(
        conversationId: _conversationId!,
        content: imageUrl,
        type: MessageType.image,
        metadata: {
          'caption': caption,
          'image_url': imageUrl,
        },
      );
      
      // 添加到消息列表
      _messages.add(message);
      notifyListeners();
      
      developer.log('ChatProvider: 发送图片消息成功: ${message.id}');
    } catch (e) {
      _setError('发送图片消息失败: $e');
      developer.log('ChatProvider: 发送图片消息失败: $e');
    } finally {
      _setSending(false);
    }
  }

  /// 标记消息为已读
  Future<void> _markMessagesAsRead() async {
    if (_conversationId == null || _messages.isEmpty) return;
    
    try {
      final unreadMessageIds = _messages
          .where((m) => m.isUnread && !m.isSentByMe('current_user_id'))
          .map((m) => m.id)
          .toList();
      
      if (unreadMessageIds.isNotEmpty) {
        await _messageService.markMessagesAsRead(_conversationId!, unreadMessageIds);
        
        // 更新本地消息状态
        for (int i = 0; i < _messages.length; i++) {
          if (unreadMessageIds.contains(_messages[i].id)) {
            _messages[i] = _messages[i].markAsRead();
          }
        }
        
        notifyListeners();
        developer.log('ChatProvider: 标记消息已读，数量: ${unreadMessageIds.length}');
      }
    } catch (e) {
      developer.log('ChatProvider: 标记消息已读失败: $e');
    }
  }

  /// 重新发送消息
  Future<void> resendMessage(String messageId) async {
    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1) return;
    
    final message = _messages[messageIndex];
    if (message.status != MessageStatus.failed) return;
    
    try {
      // 更新消息状态为发送中
      _messages[messageIndex] = message.updateStatus(MessageStatus.sending);
      notifyListeners();
      
      // 重新发送
      final newMessage = await _messageService.sendMessage(
        conversationId: message.conversationId,
        content: message.content,
        type: message.type,
        metadata: message.metadata,
      );
      
      // 替换消息
      _messages[messageIndex] = newMessage;
      notifyListeners();
      
      developer.log('ChatProvider: 重新发送消息成功: ${newMessage.id}');
    } catch (e) {
      // 标记为发送失败
      _messages[messageIndex] = message.updateStatus(MessageStatus.failed);
      notifyListeners();
      
      developer.log('ChatProvider: 重新发送消息失败: $e');
    }
  }

  /// 删除消息
  Future<void> deleteMessage(String messageId) async {
    try {
      _messages.removeWhere((m) => m.id == messageId);
      notifyListeners();
      
      developer.log('ChatProvider: 删除消息: $messageId');
    } catch (e) {
      developer.log('ChatProvider: 删除消息失败: $e');
    }
  }

  /// 接收新消息
  void receiveMessage(Message message) {
    if (message.conversationId == _conversationId) {
      _messages.add(message);
      notifyListeners();
      
      // 自动标记为已读（如果聊天页面是活跃的）
      Future.delayed(const Duration(milliseconds: 500), () {
        _markMessagesAsRead();
      });
      
      developer.log('ChatProvider: 接收新消息: ${message.id}');
    }
  }

  /// 清空聊天
  void clearChat() {
    _conversationId = null;
    _messages.clear();
    _conversation = null;
    _otherUser = null;
    _currentPage = 1;
    _hasMore = true;
    _clearError();
    notifyListeners();
    
    developer.log('ChatProvider: 清空聊天');
  }

  /// 设置加载状态
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// 设置加载更多状态
  void _setLoadingMore(bool loadingMore) {
    if (_isLoadingMore != loadingMore) {
      _isLoadingMore = loadingMore;
      notifyListeners();
    }
  }

  /// 设置发送状态
  void _setSending(bool sending) {
    if (_isSending != sending) {
      _isSending = sending;
      notifyListeners();
    }
  }

  /// 设置错误信息
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// 清除错误信息
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
    developer.log('ChatProvider: 已销毁');
  }
}

// ============== 4. 分类消息Provider ==============

/// 📋 分类消息Provider - 管理赞和收藏、评论、粉丝等分类消息
class CategoryMessageProvider extends ChangeNotifier {
  final MessageService _messageService = MessageService.instance;
  
  // 状态变量
  final Map<MessageCategory, List<Message>> _categoryMessages = {};
  final Map<MessageCategory, bool> _loadingStates = {};
  final Map<MessageCategory, String?> _errorMessages = {};
  
  // 系统通知
  List<NotificationMessage> _systemNotifications = [];
  bool _isLoadingNotifications = false;
  String? _notificationsError;

  // Getter方法
  List<Message> getCategoryMessages(MessageCategory category) {
    return List.unmodifiable(_categoryMessages[category] ?? []);
  }
  
  bool isCategoryLoading(MessageCategory category) {
    return _loadingStates[category] ?? false;
  }
  
  String? getCategoryError(MessageCategory category) {
    return _errorMessages[category];
  }
  
  List<NotificationMessage> get systemNotifications => List.unmodifiable(_systemNotifications);
  bool get isLoadingNotifications => _isLoadingNotifications;
  String? get notificationsError => _notificationsError;

  /// 加载分类消息
  Future<void> loadCategoryMessages(MessageCategory category, {bool forceRefresh = false}) async {
    if (isCategoryLoading(category)) return;
    
    _setLoadingState(category, true);
    _clearError(category);
    
    try {
      final messages = await _messageService.getCategoryMessages(category, forceRefresh: forceRefresh);
      _categoryMessages[category] = messages;
      notifyListeners();
      
      developer.log('CategoryMessageProvider: 加载分类消息成功，类型: ${category.value}，数量: ${messages.length}');
    } catch (e) {
      _setError(category, '加载${category.displayName}失败: $e');
      developer.log('CategoryMessageProvider: 加载分类消息失败: $e');
    } finally {
      _setLoadingState(category, false);
    }
  }

  /// 加载系统通知
  Future<void> loadSystemNotifications({bool forceRefresh = false}) async {
    if (_isLoadingNotifications) return;
    
    _setNotificationsLoading(true);
    _clearNotificationsError();
    
    try {
      final notifications = await _messageService.getSystemNotifications(forceRefresh: forceRefresh);
      _systemNotifications = notifications;
      notifyListeners();
      
      developer.log('CategoryMessageProvider: 加载系统通知成功，数量: ${notifications.length}');
    } catch (e) {
      _setNotificationsError('加载系统通知失败: $e');
      developer.log('CategoryMessageProvider: 加载系统通知失败: $e');
    } finally {
      _setNotificationsLoading(false);
    }
  }

  /// 刷新分类消息
  Future<void> refreshCategoryMessages(MessageCategory category) async {
    await loadCategoryMessages(category, forceRefresh: true);
  }

  /// 刷新系统通知
  Future<void> refreshSystemNotifications() async {
    await loadSystemNotifications(forceRefresh: true);
  }

  /// 清空分类消息
  Future<void> clearCategoryMessages(MessageCategory category) async {
    try {
      _categoryMessages[category] = [];
      notifyListeners();
      
      developer.log('CategoryMessageProvider: 清空分类消息: ${category.value}');
    } catch (e) {
      developer.log('CategoryMessageProvider: 清空分类消息失败: $e');
    }
  }

  /// 标记系统通知为已读
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final index = _systemNotifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _systemNotifications[index] = _systemNotifications[index].markAsRead();
        notifyListeners();
        
        developer.log('CategoryMessageProvider: 标记通知已读: $notificationId');
      }
    } catch (e) {
      developer.log('CategoryMessageProvider: 标记通知已读失败: $e');
    }
  }

  /// 删除系统通知
  Future<void> deleteNotification(String notificationId) async {
    try {
      _systemNotifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
      
      developer.log('CategoryMessageProvider: 删除通知: $notificationId');
    } catch (e) {
      developer.log('CategoryMessageProvider: 删除通知失败: $e');
    }
  }

  /// 清空系统通知
  Future<void> clearSystemNotifications() async {
    try {
      _systemNotifications.clear();
      notifyListeners();
      
      developer.log('CategoryMessageProvider: 清空系统通知');
    } catch (e) {
      developer.log('CategoryMessageProvider: 清空系统通知失败: $e');
    }
  }

  /// 设置分类加载状态
  void _setLoadingState(MessageCategory category, bool loading) {
    if (_loadingStates[category] != loading) {
      _loadingStates[category] = loading;
      notifyListeners();
    }
  }

  /// 设置分类错误信息
  void _setError(MessageCategory category, String error) {
    _errorMessages[category] = error;
    notifyListeners();
  }

  /// 清除分类错误信息
  void _clearError(MessageCategory category) {
    if (_errorMessages[category] != null) {
      _errorMessages[category] = null;
      notifyListeners();
    }
  }

  /// 设置通知加载状态
  void _setNotificationsLoading(bool loading) {
    if (_isLoadingNotifications != loading) {
      _isLoadingNotifications = loading;
      notifyListeners();
    }
  }

  /// 设置通知错误信息
  void _setNotificationsError(String error) {
    _notificationsError = error;
    notifyListeners();
  }

  /// 清除通知错误信息
  void _clearNotificationsError() {
    if (_notificationsError != null) {
      _notificationsError = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
    developer.log('CategoryMessageProvider: 已销毁');
  }
}
