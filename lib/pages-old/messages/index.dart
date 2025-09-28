// 💬 消息系统模块入口文件
// 统一导出消息系统的所有组件和服务

// ============== 数据模型 ==============
export 'models/message_models.dart';

// ============== 服务层 ==============
export 'services/message_services.dart';

// ============== 状态管理 ==============
export 'providers/message_providers.dart';

// ============== UI组件 ==============
export 'widgets/message_widgets.dart';

// ============== 页面组件 ==============
export 'pages/message_main_page.dart';
export 'pages/category_message_page.dart';
export 'pages/chat_page.dart';

// ============== 消息系统配置和工具 ==============

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/message_models.dart';
import 'providers/message_providers.dart';
import 'services/message_services.dart';

/// 💬 消息系统Provider配置
/// 
/// 提供消息系统所需的所有Provider
class MessageSystemProviders extends StatelessWidget {
  final Widget child;

  const MessageSystemProviders({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 主消息Provider
        ChangeNotifierProvider<MessageProvider>(
          create: (context) => MessageProvider(),
        ),
        
        // 对话列表Provider
        ChangeNotifierProvider<ConversationProvider>(
          create: (context) => ConversationProvider(),
        ),
        
        // 聊天Provider
        ChangeNotifierProvider<ChatProvider>(
          create: (context) => ChatProvider(),
        ),
        
        // 分类消息Provider
        ChangeNotifierProvider<CategoryMessageProvider>(
          create: (context) => CategoryMessageProvider(),
        ),
      ],
      child: child,
    );
  }
}

/// 💬 消息系统初始化工具
class MessageSystemInitializer {
  static bool _isInitialized = false;

  /// 初始化消息系统
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 初始化消息服务
      await MessageService.instance.initialize();
      
      _isInitialized = true;
      print('MessageSystemInitializer: 消息系统初始化完成');
    } catch (e) {
      print('MessageSystemInitializer: 消息系统初始化失败: $e');
      rethrow;
    }
  }

  /// 销毁消息系统
  static void dispose() {
    if (!_isInitialized) return;

    try {
      // 销毁消息服务
      MessageService.instance.dispose();
      
      _isInitialized = false;
      print('MessageSystemInitializer: 消息系统已销毁');
    } catch (e) {
      print('MessageSystemInitializer: 消息系统销毁失败: $e');
    }
  }

  /// 是否已初始化
  static bool get isInitialized => _isInitialized;
}

/// 💬 消息系统常量
class MessageSystemConstants {
  // 消息相关常量
  static const int maxMessageLength = 1000;
  static const int messagePageSize = 50;
  static const int conversationPageSize = 20;
  static const int categoryMessagePageSize = 20;
  static const int systemNotificationPageSize = 20;

  // 时间相关常量
  static const Duration messageTimeout = Duration(seconds: 30);
  static const Duration typingIndicatorTimeout = Duration(seconds: 3);
  static const Duration onlineStatusTimeout = Duration(minutes: 5);

  // UI相关常量
  static const double messageBubbleMaxWidth = 0.7;
  static const double avatarSize = 48.0;
  static const double categoryCardSize = 80.0;
  static const double inputBoxMinHeight = 40.0;
  static const double inputBoxMaxHeight = 120.0;

  // 颜色常量
  static const Color primaryColor = Color(0xFF8B5CF6);
  static const Color sentMessageColor = Color(0xFF8B5CF6);
  static const Color receivedMessageColor = Color(0xFFF5F5F5);
  static const Color onlineStatusColor = Color(0xFF4CAF50);
  static const Color offlineStatusColor = Color(0xFF9E9E9E);

  // 动画常量
  static const Duration cardAnimationDuration = Duration(milliseconds: 200);
  static const Duration messageAnimationDuration = Duration(milliseconds: 300);
  static const Duration typingAnimationDuration = Duration(milliseconds: 1000);
}

/// 💬 消息系统工具类
class MessageSystemUtils {
  /// 格式化消息时间
  static String formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${time.month}-${time.day.toString().padLeft(2, '0')}';
    }
  }

  /// 格式化未读数量
  static String formatUnreadCount(int count) {
    if (count <= 0) return '';
    if (count <= 99) return count.toString();
    return '99+';
  }

  /// 生成消息ID
  static String generateMessageId() {
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000).toString().padLeft(3, '0')}';
  }

  /// 生成对话ID
  static String generateConversationId(List<String> participantIds) {
    final sortedIds = List<String>.from(participantIds)..sort();
    return 'conv_${sortedIds.join('_')}';
  }

  /// 检查消息内容是否有效
  static bool isValidMessageContent(String content) {
    final trimmedContent = content.trim();
    return trimmedContent.isNotEmpty && trimmedContent.length <= MessageSystemConstants.maxMessageLength;
  }

  /// 获取消息预览文本
  static String getMessagePreview(String content, {int maxLength = 50}) {
    if (content.length <= maxLength) {
      return content;
    }
    return '${content.substring(0, maxLength)}...';
  }

  /// 检测消息中的URL
  static List<String> extractUrls(String content) {
    final urlRegex = RegExp(
      r'https?://[^\s]+',
      caseSensitive: false,
    );
    return urlRegex.allMatches(content).map((m) => m.group(0)!).toList();
  }

  /// 检测消息中的@提及
  static List<String> extractMentions(String content) {
    final mentionRegex = RegExp(r'@(\w+)');
    return mentionRegex.allMatches(content).map((m) => m.group(1)!).toList();
  }

  /// 检测消息中的话题标签
  static List<String> extractHashtags(String content) {
    final hashtagRegex = RegExp(r'#(\w+)');
    return hashtagRegex.allMatches(content).map((m) => m.group(1)!).toList();
  }

  /// 计算两个时间是否在同一天
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// 获取消息发送状态的颜色
  static Color getMessageStatusColor(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Colors.grey;
      case MessageStatus.sent:
        return Colors.grey;
      case MessageStatus.delivered:
        return Colors.grey;
      case MessageStatus.read:
        return Colors.blue;
      case MessageStatus.failed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// 获取用户在线状态的颜色
  static Color getUserOnlineStatusColor(UserOnlineStatus status) {
    switch (status) {
      case UserOnlineStatus.online:
        return MessageSystemConstants.onlineStatusColor;
      case UserOnlineStatus.away:
        return Colors.orange;
      case UserOnlineStatus.busy:
        return Colors.red;
      case UserOnlineStatus.offline:
        return MessageSystemConstants.offlineStatusColor;
      default:
        return MessageSystemConstants.offlineStatusColor;
    }
  }

  /// 获取消息分类的图标
  static IconData getCategoryIcon(MessageCategory category) {
    switch (category) {
      case MessageCategory.chat:
        return Icons.message;
      case MessageCategory.like:
        return Icons.favorite;
      case MessageCategory.comment:
        return Icons.chat_bubble;
      case MessageCategory.follow:
        return Icons.group;
      case MessageCategory.system:
        return Icons.notifications;
      default:
        return Icons.message;
    }
  }

  /// 获取消息分类的颜色
  static Color getCategoryColor(MessageCategory category) {
    switch (category) {
      case MessageCategory.chat:
        return Colors.green;
      case MessageCategory.like:
        return Colors.pink;
      case MessageCategory.comment:
        return Colors.blue;
      case MessageCategory.follow:
        return Colors.orange;
      case MessageCategory.system:
        return MessageSystemConstants.primaryColor;
      default:
        return MessageSystemConstants.primaryColor;
    }
  }

  /// 验证手机号格式
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    return phoneRegex.hasMatch(phone);
  }

  /// 验证邮箱格式
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// 生成随机头像URL
  static String generateAvatarUrl(String userId) {
    return 'https://picsum.photos/100/100?random=$userId';
  }

  /// 生成随机图片URL
  static String generateImageUrl({int width = 400, int height = 300}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'https://picsum.photos/$width/$height?random=$timestamp';
  }
}
