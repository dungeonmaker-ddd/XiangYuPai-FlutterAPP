// 📋 分类消息页面
// 赞和收藏、评论、粉丝、系统通知等分类消息的列表页面

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

import '../models/message_models.dart';
import '../providers/message_providers.dart';
import '../widgets/message_widgets.dart';

/// 📋 分类消息页面
class CategoryMessagePage extends StatefulWidget {
  final MessageCategory category;

  const CategoryMessagePage({
    super.key,
    required this.category,
  });

  @override
  State<CategoryMessagePage> createState() => _CategoryMessagePageState();
}

class _CategoryMessagePageState extends State<CategoryMessagePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategoryMessages();
    });
  }

  /// 加载分类消息
  Future<void> _loadCategoryMessages() async {
    try {
      final categoryProvider = context.read<CategoryMessageProvider>();
      
      if (widget.category == MessageCategory.system) {
        await categoryProvider.loadSystemNotifications();
      } else {
        await categoryProvider.loadCategoryMessages(widget.category);
      }
      
      developer.log('CategoryMessagePage: 加载分类消息完成: ${widget.category.value}');
    } catch (e) {
      developer.log('CategoryMessagePage: 加载分类消息失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: widget.category == MessageCategory.system
          ? _buildSystemNotificationList()
          : _buildCategoryMessageList(),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        widget.category.displayName,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Colors.black87,
          size: 20,
        ),
      ),
      actions: [
        // 清空按钮
        TextButton(
          onPressed: _onClearMessages,
          child: const Text(
            '清空',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建分类消息列表
  Widget _buildCategoryMessageList() {
    return Consumer<CategoryMessageProvider>(
      builder: (context, categoryProvider, child) {
        final isLoading = categoryProvider.isCategoryLoading(widget.category);
        final errorMessage = categoryProvider.getCategoryError(widget.category);
        final messages = categoryProvider.getCategoryMessages(widget.category);

        if (isLoading && messages.isEmpty) {
          return _buildLoadingState();
        }

        if (errorMessage != null) {
          return _buildErrorState(errorMessage);
        }

        if (messages.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => _onRefresh(),
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return Consumer<ConversationProvider>(
                builder: (context, conversationProvider, child) {
                  final senderUser = conversationProvider.getUserInfo(message.senderId);
                  
                  return CategoryMessageItem(
                    message: message,
                    senderUser: senderUser,
                    onTap: () => _onMessageTap(message),
                    onUserTap: () => _onUserTap(message.senderId),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  /// 构建系统通知列表
  Widget _buildSystemNotificationList() {
    return Consumer<CategoryMessageProvider>(
      builder: (context, categoryProvider, child) {
        final isLoading = categoryProvider.isLoadingNotifications;
        final errorMessage = categoryProvider.notificationsError;
        final notifications = categoryProvider.systemNotifications;

        if (isLoading && notifications.isEmpty) {
          return _buildLoadingState();
        }

        if (errorMessage != null) {
          return _buildErrorState(errorMessage);
        }

        if (notifications.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => _onRefresh(),
          child: ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              
              return SystemNotificationItem(
                notification: notification,
                onTap: () => _onNotificationTap(notification),
                onAction: () => _onNotificationAction(notification),
                onDismiss: () => _onNotificationDismiss(notification),
              );
            },
          ),
        );
      },
    );
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
      ),
    );
  }

  /// 构建错误状态
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              '加载失败',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadCategoryMessages,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyStateIcon(),
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              _getEmptyStateTitle(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyStateSubtitle(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 获取空状态图标
  IconData _getEmptyStateIcon() {
    switch (widget.category) {
      case MessageCategory.like:
        return Icons.favorite_outline;
      case MessageCategory.comment:
        return Icons.chat_bubble_outline;
      case MessageCategory.follow:
        return Icons.group_outlined;
      case MessageCategory.system:
        return Icons.notifications_outlined;
      case MessageCategory.chat:
        return Icons.message_outlined;
    }
  }

  /// 获取空状态标题
  String _getEmptyStateTitle() {
    switch (widget.category) {
      case MessageCategory.like:
        return '暂无赞和收藏';
      case MessageCategory.comment:
        return '暂无评论消息';
      case MessageCategory.follow:
        return '暂无粉丝消息';
      case MessageCategory.system:
        return '暂无系统通知';
      case MessageCategory.chat:
        return '暂无聊天消息';
    }
  }

  /// 获取空状态副标题
  String _getEmptyStateSubtitle() {
    switch (widget.category) {
      case MessageCategory.like:
        return '当有人点赞或收藏你的内容时\n会在这里显示';
      case MessageCategory.comment:
        return '当有人评论你的内容时\n会在这里显示';
      case MessageCategory.follow:
        return '当有新粉丝关注你时\n会在这里显示';
      case MessageCategory.system:
        return '系统重要通知和提醒\n会在这里显示';
      case MessageCategory.chat:
        return '开始你的第一次对话吧';
    }
  }

  /// 处理消息点击
  void _onMessageTap(Message message) {
    developer.log('CategoryMessagePage: 点击消息: ${message.id}');
    
    // 根据消息类型跳转到相应页面
    switch (message.category) {
      case MessageCategory.like:
        _handleLikeMessageTap(message);
        break;
      case MessageCategory.comment:
        _handleCommentMessageTap(message);
        break;
      case MessageCategory.follow:
        _handleFollowMessageTap(message);
        break;
      default:
        break;
    }
  }

  /// 处理赞和收藏消息点击
  void _handleLikeMessageTap(Message message) {
    final targetId = message.metadata?['target_id'] as String?;
    final targetType = message.metadata?['target_type'] as String?;
    
    if (targetId != null && targetType != null) {
      developer.log('CategoryMessagePage: 跳转到内容详情: $targetType -> $targetId');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('跳转到${targetType == 'post' ? '作品' : '评论'}详情'),
          backgroundColor: const Color(0xFF8B5CF6),
        ),
      );
    }
  }

  /// 处理评论消息点击
  void _handleCommentMessageTap(Message message) {
    final targetId = message.metadata?['target_id'] as String?;
    
    if (targetId != null) {
      developer.log('CategoryMessagePage: 跳转到评论详情: $targetId');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('跳转到评论详情'),
          backgroundColor: Color(0xFF8B5CF6),
        ),
      );
    }
  }

  /// 处理粉丝消息点击
  void _handleFollowMessageTap(Message message) {
    final userId = message.senderId;
    
    developer.log('CategoryMessagePage: 跳转到用户详情: $userId');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('跳转到用户详情'),
        backgroundColor: Color(0xFF8B5CF6),
      ),
    );
  }

  /// 处理用户点击
  void _onUserTap(String userId) {
    developer.log('CategoryMessagePage: 点击用户: $userId');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('查看用户详情'),
        backgroundColor: Color(0xFF8B5CF6),
      ),
    );
  }

  /// 处理系统通知点击
  void _onNotificationTap(NotificationMessage notification) {
    developer.log('CategoryMessagePage: 点击系统通知: ${notification.id}');
    
    // 标记为已读
    context.read<CategoryMessageProvider>().markNotificationAsRead(notification.id);
    
    // 如果有跳转链接，执行跳转
    if (notification.actionUrl != null) {
      _handleNotificationAction(notification);
    }
  }

  /// 处理系统通知操作
  void _onNotificationAction(NotificationMessage notification) {
    developer.log('CategoryMessagePage: 系统通知操作: ${notification.id}');
    
    // 标记为已读
    context.read<CategoryMessageProvider>().markNotificationAsRead(notification.id);
    
    // 执行相应操作
    _handleNotificationAction(notification);
  }

  /// 处理系统通知忽略
  void _onNotificationDismiss(NotificationMessage notification) {
    developer.log('CategoryMessagePage: 忽略系统通知: ${notification.id}');
    
    // 标记为已读并删除
    context.read<CategoryMessageProvider>().deleteNotification(notification.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已忽略通知'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  /// 处理通知操作
  void _handleNotificationAction(NotificationMessage notification) {
    final actionType = notification.metadata?['action_type'] as String?;
    
    switch (actionType) {
      case 'profile_completion':
        developer.log('CategoryMessagePage: 跳转到个人资料完善页面');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('跳转到个人资料页面'),
            backgroundColor: Color(0xFF8B5CF6),
          ),
        );
        break;
      case 'booking_approved':
        developer.log('CategoryMessagePage: 跳转到预订详情页面');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('跳转到预订详情页面'),
            backgroundColor: Color(0xFF8B5CF6),
          ),
        );
        break;
      default:
        developer.log('CategoryMessagePage: 未知通知操作类型: $actionType');
        break;
    }
  }

  /// 处理清空消息
  void _onClearMessages() {
    developer.log('CategoryMessagePage: 点击清空消息: ${widget.category.value}');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('清空${widget.category.displayName}'),
        content: Text('确定要清空所有${widget.category.displayName}消息吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearMessages();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }

  /// 清空消息
  Future<void> _clearMessages() async {
    try {
      final categoryProvider = context.read<CategoryMessageProvider>();
      
      if (widget.category == MessageCategory.system) {
        await categoryProvider.clearSystemNotifications();
      } else {
        await categoryProvider.clearCategoryMessages(widget.category);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.category.displayName}消息已清空'),
          backgroundColor: const Color(0xFF8B5CF6),
        ),
      );
      
      developer.log('CategoryMessagePage: 清空消息完成: ${widget.category.value}');
    } catch (e) {
      developer.log('CategoryMessagePage: 清空消息失败: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('清空失败，请重试'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 处理下拉刷新
  Future<void> _onRefresh() async {
    try {
      final categoryProvider = context.read<CategoryMessageProvider>();
      
      if (widget.category == MessageCategory.system) {
        await categoryProvider.refreshSystemNotifications();
      } else {
        await categoryProvider.refreshCategoryMessages(widget.category);
      }
      
      developer.log('CategoryMessagePage: 刷新完成: ${widget.category.value}');
    } catch (e) {
      developer.log('CategoryMessagePage: 刷新失败: $e');
    }
  }
}
