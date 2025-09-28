// 💬 聊天页面
// 一对一私聊界面，支持文字、图片等多种消息类型

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

import '../models/message_models.dart';
import '../providers/message_providers.dart';
import '../widgets/message_widgets.dart';

/// 💬 聊天页面
class ChatPage extends StatefulWidget {
  final String conversationId;
  final MessageUser? otherUser;

  const ChatPage({
    super.key,
    required this.conversationId,
    this.otherUser,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final String _currentUserId = 'current_user_id'; // 实际项目中从用户状态获取
  
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScrollListener);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_onScrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    
    // 检测键盘弹起/收起
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final isKeyboardVisible = bottomInset > 0;
    
    if (_isKeyboardVisible != isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = isKeyboardVisible;
      });
      
      // 键盘弹起时滚动到底部
      if (isKeyboardVisible) {
        _scrollToBottom();
      }
    }
  }

  /// 初始化聊天
  Future<void> _initializeChat() async {
    try {
      final chatProvider = context.read<ChatProvider>();
      
      await chatProvider.initializeChat(
        widget.conversationId,
        otherUserId: widget.otherUser?.id,
      );
      
      // 滚动到底部
      _scrollToBottom();
      
      developer.log('ChatPage: 聊天初始化完成: ${widget.conversationId}');
    } catch (e) {
      developer.log('ChatPage: 聊天初始化失败: $e');
    }
  }

  /// 滚动监听器
  void _onScrollListener() {
    // 滚动到顶部时加载更多历史消息
    if (_scrollController.position.pixels <= 100) {
      final chatProvider = context.read<ChatProvider>();
      if (chatProvider.hasMore && !chatProvider.isLoadingMore) {
        chatProvider.loadMoreMessages();
      }
    }
  }

  /// 滚动到底部
  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    
    if (animated) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // 聊天消息区域
          Expanded(
            child: _buildMessageList(),
          ),
          
          // 消息输入区域
          _buildMessageInput(),
        ],
      ),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Colors.black87,
          size: 20,
        ),
      ),
      title: Column(
        children: [
          // 用户昵称
          Text(
            widget.otherUser?.displayName ?? '未知用户',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          
          // 在线状态
          if (widget.otherUser != null)
            Text(
              widget.otherUser!.onlineStatusText,
              style: TextStyle(
                fontSize: 12,
                color: widget.otherUser!.isOnline ? Colors.green : Colors.grey,
              ),
            ),
        ],
      ),
      centerTitle: true,
      actions: [
        // 语音通话按钮
        IconButton(
          onPressed: _onVoiceCall,
          icon: const Icon(
            Icons.phone,
            color: Colors.grey,
            size: 22,
          ),
          tooltip: '语音通话',
        ),
        
        // 视频通话按钮
        IconButton(
          onPressed: _onVideoCall,
          icon: const Icon(
            Icons.videocam,
            color: Colors.grey,
            size: 24,
          ),
          tooltip: '视频通话',
        ),
      ],
    );
  }

  /// 构建消息列表
  Widget _buildMessageList() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.isLoading && !chatProvider.hasMessages) {
          return _buildLoadingState();
        }

        if (chatProvider.errorMessage != null) {
          return _buildErrorState(chatProvider.errorMessage!);
        }

        if (!chatProvider.hasMessages) {
          return _buildEmptyState();
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: chatProvider.messages.length + (chatProvider.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            // 加载更多指示器
            if (index == 0 && chatProvider.isLoadingMore) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                  ),
                ),
              );
            }

            final messageIndex = chatProvider.isLoadingMore ? index - 1 : index;
            final message = chatProvider.messages[messageIndex];
            final isSentByMe = message.isSentByMe(_currentUserId);
            
            // 显示时间分隔线
            Widget messageWidget = MessageBubble(
              message: message,
              isSentByMe: isSentByMe,
              senderUser: isSentByMe ? null : widget.otherUser,
              onTap: () => _onMessageTap(message),
              onLongPress: () => _onMessageLongPress(message),
              onResend: () => _onMessageResend(message),
            );

            // 添加时间分隔线
            if (_shouldShowTimeDivider(messageIndex, chatProvider.messages)) {
              return Column(
                children: [
                  _buildTimeDivider(message.createdAt),
                  messageWidget,
                ],
              );
            }

            return messageWidget;
          },
        );
      },
    );
  }

  /// 构建时间分隔线
  Widget _buildTimeDivider(DateTime time) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _formatTimeDivider(time),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  /// 格式化时间分隔线文本
  String _formatTimeDivider(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return '今天 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return '昨天 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return '${weekdays[time.weekday - 1]} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.month}-${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  /// 是否应该显示时间分隔线
  bool _shouldShowTimeDivider(int index, List<Message> messages) {
    if (index == 0) return true;
    
    final currentMessage = messages[index];
    final previousMessage = messages[index - 1];
    
    // 如果两条消息间隔超过5分钟，显示时间分隔线
    final difference = currentMessage.createdAt.difference(previousMessage.createdAt);
    return difference.inMinutes >= 5;
  }

  /// 构建消息输入区域
  Widget _buildMessageInput() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return MessageInputBox(
          onSendMessage: _onSendMessage,
          onSendImage: _onSendImage,
          onTakePhoto: _onTakePhoto,
          onPickImage: _onPickImage,
          isEnabled: !chatProvider.isLoading,
          isSending: chatProvider.isSending,
          hintText: '请输入消息...',
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
              '加载聊天失败',
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
              onPressed: _initializeChat,
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
              Icons.chat_bubble_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              '开始对话',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '发送第一条消息开始聊天吧',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 处理发送消息
  void _onSendMessage(String content) {
    developer.log('ChatPage: 发送消息: $content');
    
    final chatProvider = context.read<ChatProvider>();
    chatProvider.sendTextMessage(content).then((_) {
      // 滚动到底部
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom();
      });
    });
  }

  /// 处理发送图片
  void _onSendImage(String imageUrl) {
    developer.log('ChatPage: 发送图片: $imageUrl');
    
    final chatProvider = context.read<ChatProvider>();
    chatProvider.sendImageMessage(imageUrl).then((_) {
      // 滚动到底部
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom();
      });
    });
  }

  /// 处理拍照
  void _onTakePhoto() {
    developer.log('ChatPage: 拍照');
    
    // 模拟拍照并发送图片
    final imageUrl = 'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}';
    _onSendImage(imageUrl);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📷 拍照功能模拟'),
        backgroundColor: Color(0xFF8B5CF6),
      ),
    );
  }

  /// 处理选择图片
  void _onPickImage() {
    developer.log('ChatPage: 选择图片');
    
    // 模拟选择图片并发送
    final imageUrl = 'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}';
    _onSendImage(imageUrl);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🖼️ 图片选择功能模拟'),
        backgroundColor: Color(0xFF8B5CF6),
      ),
    );
  }

  /// 处理消息点击
  void _onMessageTap(Message message) {
    developer.log('ChatPage: 点击消息: ${message.id}');
    
    // 如果是图片消息，显示大图
    if (message.type == MessageType.image) {
      _showImagePreview(message.content);
    }
  }

  /// 处理消息长按
  void _onMessageLongPress(Message message) {
    developer.log('ChatPage: 长按消息: ${message.id}');
    
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildMessageActionSheet(message),
    );
  }

  /// 构建消息操作面板
  Widget _buildMessageActionSheet(Message message) {
    final isSentByMe = message.isSentByMe(_currentUserId);
    
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              '消息操作',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          
          // 复制消息（仅文字消息）
          if (message.type == MessageType.text)
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.blue),
              title: const Text('复制'),
              onTap: () {
                Navigator.pop(context);
                _copyMessage(message);
              },
            ),
          
          // 转发消息
          ListTile(
            leading: const Icon(Icons.forward, color: Colors.green),
            title: const Text('转发'),
            onTap: () {
              Navigator.pop(context);
              _forwardMessage(message);
            },
          ),
          
          // 删除消息（仅自己发送的消息）
          if (isSentByMe)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('删除'),
              onTap: () {
                Navigator.pop(context);
                _deleteMessage(message);
              },
            ),
          
          // 举报消息（仅对方发送的消息）
          if (!isSentByMe)
            ListTile(
              leading: const Icon(Icons.report_outlined, color: Colors.orange),
              title: const Text('举报'),
              onTap: () {
                Navigator.pop(context);
                _reportMessage(message);
              },
            ),
          
          // 取消按钮
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black87,
                elevation: 0,
              ),
              child: const Text('取消'),
            ),
          ),
        ],
      ),
    );
  }

  /// 处理消息重发
  void _onMessageResend(Message message) {
    developer.log('ChatPage: 重发消息: ${message.id}');
    
    final chatProvider = context.read<ChatProvider>();
    chatProvider.resendMessage(message.id);
  }

  /// 复制消息
  void _copyMessage(Message message) {
    developer.log('ChatPage: 复制消息: ${message.content}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('消息已复制到剪贴板'),
        backgroundColor: Color(0xFF8B5CF6),
      ),
    );
  }

  /// 转发消息
  void _forwardMessage(Message message) {
    developer.log('ChatPage: 转发消息: ${message.id}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('转发功能开发中...'),
        backgroundColor: Color(0xFF8B5CF6),
      ),
    );
  }

  /// 删除消息
  void _deleteMessage(Message message) {
    developer.log('ChatPage: 删除消息: ${message.id}');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除消息'),
        content: const Text('确定要删除这条消息吗？删除后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ChatProvider>().deleteMessage(message.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 举报消息
  void _reportMessage(Message message) {
    developer.log('ChatPage: 举报消息: ${message.id}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('举报功能开发中...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  /// 显示图片预览
  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 处理语音通话
  void _onVoiceCall() {
    developer.log('ChatPage: 语音通话');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📞 语音通话功能开发中...'),
        backgroundColor: Color(0xFF8B5CF6),
      ),
    );
  }

  /// 处理视频通话
  void _onVideoCall() {
    developer.log('ChatPage: 视频通话');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📹 视频通话功能开发中...'),
        backgroundColor: Color(0xFF8B5CF6),
      ),
    );
  }
}
