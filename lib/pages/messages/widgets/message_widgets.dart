// 🎨 消息系统UI组件
// 基于设计文档的消息卡片、气泡、输入框等UI组件

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

import '../models/message_models.dart';

// ============== 1. 消息分类功能卡片 ==============

/// 💖 消息分类功能卡片
class MessageCategoryCard extends StatefulWidget {
  final MessageCategory category;
  final int unreadCount;
  final VoidCallback? onTap;
  final bool showUnreadBadge;

  const MessageCategoryCard({
    super.key,
    required this.category,
    this.unreadCount = 0,
    this.onTap,
    this.showUnreadBadge = true,
  });

  @override
  State<MessageCategoryCard> createState() => _MessageCategoryCardState();
}

class _MessageCategoryCardState extends State<MessageCategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // 主要内容
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 功能图标
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: _getCategoryGradient(),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getCategoryIcon(),
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // 功能标题
                      Text(
                        widget.category.displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  
                  // 未读角标
                  if (widget.showUnreadBadge && widget.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: _buildUnreadBadge(),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建未读角标
  Widget _buildUnreadBadge() {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        MessageModelUtils.formatUnreadCount(widget.unreadCount),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 获取分类图标
  IconData _getCategoryIcon() {
    switch (widget.category) {
      case MessageCategory.like:
        return Icons.favorite;
      case MessageCategory.comment:
        return Icons.chat_bubble;
      case MessageCategory.follow:
        return Icons.group;
      case MessageCategory.system:
        return Icons.notifications;
      case MessageCategory.chat:
        return Icons.message;
    }
  }

  /// 获取分类渐变色
  Gradient _getCategoryGradient() {
    switch (widget.category) {
      case MessageCategory.like:
        return const LinearGradient(
          colors: [Color(0xFFFF6B9D), Color(0xFFFF8E8E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case MessageCategory.comment:
        return const LinearGradient(
          colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case MessageCategory.follow:
        return const LinearGradient(
          colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case MessageCategory.system:
        return const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF9C27B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case MessageCategory.chat:
        return const LinearGradient(
          colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}

// ============== 2. 对话列表项 ==============

/// 💬 对话列表项
class ConversationListItem extends StatelessWidget {
  final Conversation conversation;
  final MessageUser? otherUser;
  final String currentUserId;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ConversationListItem({
    super.key,
    required this.conversation,
    this.otherUser,
    required this.currentUserId,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
          ),
        ),
        child: Row(
          children: [
            // 左侧头像区域
            _buildAvatarSection(),
            
            const SizedBox(width: 12),
            
            // 中央消息信息区域
            Expanded(
              child: _buildMessageInfoSection(),
            ),
            
            // 右侧状态区域
            _buildStatusSection(),
          ],
        ),
      ),
    );
  }

  /// 构建头像区域
  Widget _buildAvatarSection() {
    return Stack(
      children: [
        // 用户头像
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: otherUser?.hasAvatar == true
                ? Image.network(
                    otherUser!.avatar!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultAvatar();
                    },
                  )
                : _buildDefaultAvatar(),
          ),
        ),
        
        // 在线状态指示器
        if (otherUser?.isOnline == true)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        
        // 未读消息角标
        if (conversation.hasUnreadMessages)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                MessageModelUtils.formatUnreadCount(conversation.unreadCount),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  /// 构建默认头像
  Widget _buildDefaultAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Text(
          otherUser?.initials ?? '?',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B5CF6),
          ),
        ),
      ),
    );
  }

  /// 构建消息信息区域
  Widget _buildMessageInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 用户昵称和时间行
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 用户昵称
            Expanded(
              child: Text(
                conversation.getDisplayTitle(currentUserId, otherUserName: otherUser?.displayName),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            const SizedBox(width: 8),
            
            // 消息时间
            Text(
              conversation.lastMessage?.displayTime ?? '',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 4),
        
        // 最后消息预览行
        Row(
          children: [
            Expanded(
              child: Text(
                conversation.lastMessage?.previewText ?? '暂无消息',
                style: TextStyle(
                  fontSize: 14,
                  color: conversation.hasUnreadMessages ? Colors.black87 : Colors.grey,
                  fontWeight: conversation.hasUnreadMessages ? FontWeight.w500 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建状态区域
  Widget _buildStatusSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 免打扰图标
        if (conversation.isMuted)
          const Icon(
            Icons.notifications_off,
            size: 16,
            color: Colors.grey,
          ),
        
        // 置顶图标
        if (conversation.isPinned)
          const Icon(
            Icons.push_pin,
            size: 16,
            color: Color(0xFF8B5CF6),
          ),
      ],
    );
  }
}

// ============== 3. 消息气泡 ==============

/// 💬 消息气泡
class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isSentByMe;
  final MessageUser? senderUser;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onResend;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSentByMe,
    this.senderUser,
    this.onTap,
    this.onLongPress,
    this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Row(
          mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isSentByMe) ...[
              // 对方头像
              _buildAvatar(),
              const SizedBox(width: 8),
            ],
            
            // 消息气泡
            Flexible(
              child: Column(
                crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // 消息内容气泡
                  _buildMessageBubble(context),
                  
                  const SizedBox(height: 2),
                  
                  // 消息时间和状态
                  _buildMessageMeta(),
                ],
              ),
            ),
            
            if (isSentByMe) ...[
              const SizedBox(width: 8),
              // 自己头像
              _buildAvatar(),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建头像
  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: senderUser?.hasAvatar == true
            ? Image.network(
                senderUser!.avatar!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAvatar();
                },
              )
            : _buildDefaultAvatar(),
      ),
    );
  }

  /// 构建默认头像
  Widget _buildDefaultAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Text(
          senderUser?.initials ?? (isSentByMe ? '我' : '?'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B5CF6),
          ),
        ),
      ),
    );
  }

  /// 构建消息气泡
  Widget _buildMessageBubble(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSentByMe ? const Color(0xFF8B5CF6) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12).copyWith(
          bottomLeft: Radius.circular(isSentByMe ? 12 : 4),
          bottomRight: Radius.circular(isSentByMe ? 4 : 12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: _buildMessageContent(),
    );
  }

  /// 构建消息内容
  Widget _buildMessageContent() {
    switch (message.type) {
      case MessageType.text:
        return _buildTextContent();
      case MessageType.image:
        return _buildImageContent();
      case MessageType.voice:
        return _buildVoiceContent();
      case MessageType.video:
        return _buildVideoContent();
      case MessageType.system:
        return _buildSystemContent();
    }
  }

  /// 构建文字内容
  Widget _buildTextContent() {
    return Text(
      message.content,
      style: TextStyle(
        fontSize: 16,
        color: isSentByMe ? Colors.white : Colors.black87,
        height: 1.3,
      ),
    );
  }

  /// 构建图片内容
  Widget _buildImageContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 图片
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            message.content,
            fit: BoxFit.cover,
            width: 200,
            height: 200,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: Colors.grey,
                ),
              );
            },
          ),
        ),
        
        // 图片描述
        if (message.metadata?['caption'] != null) ...[
          const SizedBox(height: 8),
          Text(
            message.metadata!['caption'] as String,
            style: TextStyle(
              fontSize: 14,
              color: isSentByMe ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ],
    );
  }

  /// 构建语音内容
  Widget _buildVoiceContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.mic,
          size: 20,
          color: isSentByMe ? Colors.white : Colors.black87,
        ),
        const SizedBox(width: 8),
        Text(
          '[语音消息]',
          style: TextStyle(
            fontSize: 16,
            color: isSentByMe ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  /// 构建视频内容
  Widget _buildVideoContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.videocam,
          size: 20,
          color: isSentByMe ? Colors.white : Colors.black87,
        ),
        const SizedBox(width: 8),
        Text(
          '[视频消息]',
          style: TextStyle(
            fontSize: 16,
            color: isSentByMe ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  /// 构建系统内容
  Widget _buildSystemContent() {
    return Text(
      message.content,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.orange,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  /// 构建消息元信息
  Widget _buildMessageMeta() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 消息时间
        Text(
          message.displayTime,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
        
        if (isSentByMe) ...[
          const SizedBox(width: 4),
          // 消息状态图标
          _buildStatusIcon(),
        ],
      ],
    );
  }

  /// 构建状态图标
  Widget _buildStatusIcon() {
    switch (message.status) {
      case MessageStatus.sending:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        );
      case MessageStatus.sent:
        return const Icon(
          Icons.check,
          size: 12,
          color: Colors.grey,
        );
      case MessageStatus.delivered:
        return const Icon(
          Icons.done_all,
          size: 12,
          color: Colors.grey,
        );
      case MessageStatus.read:
        return const Icon(
          Icons.done_all,
          size: 12,
          color: Colors.blue,
        );
      case MessageStatus.failed:
        return GestureDetector(
          onTap: onResend,
          child: const Icon(
            Icons.error_outline,
            size: 12,
            color: Colors.red,
          ),
        );
    }
  }
}

// ============== 4. 消息输入框 ==============

/// 📝 消息输入框
class MessageInputBox extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(String)? onSendImage;
  final VoidCallback? onTakePhoto;
  final VoidCallback? onPickImage;
  final bool isEnabled;
  final bool isSending;
  final String hintText;

  const MessageInputBox({
    super.key,
    required this.onSendMessage,
    this.onSendImage,
    this.onTakePhoto,
    this.onPickImage,
    this.isEnabled = true,
    this.isSending = false,
    this.hintText = '请输入内容...',
  });

  @override
  State<MessageInputBox> createState() => _MessageInputBoxState();
}

class _MessageInputBoxState extends State<MessageInputBox> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showExtensions = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty && widget.isEnabled && !widget.isSending) {
      widget.onSendMessage(text);
      _textController.clear();
      setState(() {
        _hasText = false;
      });
    }
  }

  void _toggleExtensions() {
    setState(() {
      _showExtensions = !_showExtensions;
    });
    if (_showExtensions) {
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 主输入区域
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // 扩展功能按钮
                  GestureDetector(
                    onTap: _toggleExtensions,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _showExtensions ? Icons.keyboard : Icons.add,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // 输入框
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: 40,
                        maxHeight: 120,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        enabled: widget.isEnabled,
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              // 切换语音输入模式
                              developer.log('MessageInputBox: 切换语音输入');
                            },
                            child: Icon(
                              Icons.mic,
                              size: 20,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                        onTap: () {
                          if (_showExtensions) {
                            setState(() {
                              _showExtensions = false;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // 发送按钮
                  GestureDetector(
                    onTap: _sendMessage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _hasText && widget.isEnabled && !widget.isSending
                            ? const Color(0xFF8B5CF6)
                            : Colors.grey[400],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: widget.isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              size: 20,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 扩展功能区域
            if (_showExtensions) _buildExtensionsPanel(),
          ],
        ),
      ),
    );
  }

  /// 构建扩展功能面板
  Widget _buildExtensionsPanel() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
        ),
      ),
      child: GridView.count(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          // 拍照按钮
          _buildExtensionButton(
            icon: Icons.camera_alt,
            label: '拍照',
            color: Colors.green,
            onTap: widget.onTakePhoto,
          ),
          
          // 相册按钮
          _buildExtensionButton(
            icon: Icons.photo_library,
            label: '相册',
            color: Colors.blue,
            onTap: widget.onPickImage,
          ),
          
          // 语音按钮
          _buildExtensionButton(
            icon: Icons.mic,
            label: '语音',
            color: Colors.orange,
            onTap: () {
              developer.log('MessageInputBox: 点击语音按钮');
            },
          ),
          
          // 位置按钮
          _buildExtensionButton(
            icon: Icons.location_on,
            label: '位置',
            color: Colors.red,
            onTap: () {
              developer.log('MessageInputBox: 点击位置按钮');
            },
          ),
        ],
      ),
    );
  }

  /// 构建扩展功能按钮
  Widget _buildExtensionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              size: 24,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ============== 5. 分类消息项 ==============

/// 📋 分类消息项（赞和收藏、评论、粉丝）
class CategoryMessageItem extends StatelessWidget {
  final Message message;
  final MessageUser? senderUser;
  final VoidCallback? onTap;
  final VoidCallback? onUserTap;

  const CategoryMessageItem({
    super.key,
    required this.message,
    this.senderUser,
    this.onTap,
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
          ),
        ),
        child: Row(
          children: [
            // 左侧头像区域
            _buildAvatarSection(),
            
            const SizedBox(width: 12),
            
            // 中央消息信息区域
            Expanded(
              child: _buildMessageInfoSection(),
            ),
            
            // 右侧内容缩略图
            _buildThumbnailSection(),
          ],
        ),
      ),
    );
  }

  /// 构建头像区域
  Widget _buildAvatarSection() {
    return Stack(
      children: [
        // 用户头像
        GestureDetector(
          onTap: onUserTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: senderUser?.hasAvatar == true
                  ? Image.network(
                      senderUser!.avatar!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar();
                      },
                    )
                  : _buildDefaultAvatar(),
            ),
          ),
        ),
        
        // 操作类型图标
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _getActionColor(),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              _getActionIcon(),
              size: 12,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建默认头像
  Widget _buildDefaultAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Text(
          senderUser?.initials ?? '?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B5CF6),
          ),
        ),
      ),
    );
  }

  /// 构建消息信息区域
  Widget _buildMessageInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 用户操作信息行
        Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: senderUser?.displayName ?? '未知用户',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    TextSpan(
                      text: ' ${message.content}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              message.displayTime,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 6),
        
        // 相关内容预览行
        if (message.metadata?['target_content'] != null)
          Text(
            message.metadata!['target_content'] as String,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  /// 构建缩略图区域
  Widget _buildThumbnailSection() {
    final imageUrl = message.metadata?['target_image'] as String?;
    
    if (imageUrl == null) return const SizedBox.shrink();
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: const Icon(
                Icons.image_not_supported,
                size: 24,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }

  /// 获取操作图标
  IconData _getActionIcon() {
    switch (message.category) {
      case MessageCategory.like:
        final actionType = message.metadata?['action_type'] as String?;
        if (actionType == 'favorite') {
          return Icons.star;
        }
        return Icons.favorite;
      case MessageCategory.comment:
        return Icons.chat_bubble;
      case MessageCategory.follow:
        return Icons.person_add;
      default:
        return Icons.notifications;
    }
  }

  /// 获取操作颜色
  Color _getActionColor() {
    switch (message.category) {
      case MessageCategory.like:
        return Colors.red;
      case MessageCategory.comment:
        return Colors.blue;
      case MessageCategory.follow:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

// ============== 6. 系统通知项 ==============

/// 🔔 系统通知项
class SystemNotificationItem extends StatelessWidget {
  final NotificationMessage notification;
  final VoidCallback? onTap;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  const SystemNotificationItem({
    super.key,
    required this.notification,
    this.onTap,
    this.onAction,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧系统图标
            _buildSystemIcon(),
            
            const SizedBox(width: 12),
            
            // 中央通知信息区域
            Expanded(
              child: _buildNotificationInfo(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建系统图标
  Widget _buildSystemIcon() {
    return Stack(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF9C27B0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.notifications,
            size: 24,
            color: Colors.white,
          ),
        ),
        
        // 优先级标识
        if (notification.priority == 'high')
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.priority_high,
                size: 8,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  /// 构建通知信息
  Widget _buildNotificationInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 通知标题和时间行
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              notification.displayTime,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 6),
        
        // 通知内容
        Text(
          notification.content,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            height: 1.4,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        
        // 操作按钮区域
        if (notification.actionUrl != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              // 主要操作按钮
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: const Size(100, 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '立即完善',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // 次要操作按钮
              OutlinedButton(
                onPressed: onDismiss,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey,
                  side: const BorderSide(color: Colors.grey),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: const Size(60, 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '忽略',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
