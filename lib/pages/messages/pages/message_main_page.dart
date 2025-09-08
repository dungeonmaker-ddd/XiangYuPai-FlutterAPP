// 💬 消息系统主页面
// 基于设计文档的消息中心首页，包含分类功能区和最近对话列表

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

import '../models/message_models.dart';
import '../providers/message_providers.dart';
import '../widgets/message_widgets.dart';
import 'category_message_page.dart';
import 'chat_page.dart';

/// 💬 消息主页面
class MessageMainPage extends StatefulWidget {
  const MessageMainPage({super.key});

  @override
  State<MessageMainPage> createState() => _MessageMainPageState();
}

class _MessageMainPageState extends State<MessageMainPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMessageSystem();
    });
  }

  /// 初始化消息系统
  Future<void> _initializeMessageSystem() async {
    try {
      final messageProvider = context.read<MessageProvider>();
      final conversationProvider = context.read<ConversationProvider>();
      
      // 初始化消息系统
      await messageProvider.initialize();
      
      // 加载对话列表
      await conversationProvider.loadConversations();
      
      developer.log('MessageMainPage: 消息系统初始化完成');
    } catch (e) {
      developer.log('MessageMainPage: 消息系统初始化失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            // 消息分类功能区
            SliverToBoxAdapter(
              child: _buildCategorySection(),
            ),
            
            // 最近对话列表
            _buildConversationList(),
          ],
        ),
      ),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        '消息',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        // 消息设置按钮
        IconButton(
          onPressed: _onMessageSettings,
          icon: const Icon(
            Icons.notifications_outlined,
            color: Colors.grey,
            size: 24,
          ),
          tooltip: '消息设置',
        ),
      ],
    );
  }

  /// 构建消息分类功能区
  Widget _buildCategorySection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 区域标题
          const Text(
            '消息分类',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 4宫格布局
          Consumer<MessageProvider>(
            builder: (context, messageProvider, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 赞和收藏卡片
                  MessageCategoryCard(
                    category: MessageCategory.like,
                    unreadCount: messageProvider.likeUnreadCount,
                    onTap: () => _onCategoryTap(MessageCategory.like),
                  ),
                  
                  // 评论卡片
                  MessageCategoryCard(
                    category: MessageCategory.comment,
                    unreadCount: messageProvider.commentUnreadCount,
                    onTap: () => _onCategoryTap(MessageCategory.comment),
                  ),
                  
                  // 粉丝卡片
                  MessageCategoryCard(
                    category: MessageCategory.follow,
                    unreadCount: messageProvider.followUnreadCount,
                    onTap: () => _onCategoryTap(MessageCategory.follow),
                  ),
                  
                  // 系统通知卡片
                  MessageCategoryCard(
                    category: MessageCategory.system,
                    unreadCount: messageProvider.systemUnreadCount,
                    onTap: () => _onCategoryTap(MessageCategory.system),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// 构建对话列表
  Widget _buildConversationList() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // 区域标题
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '最近对话',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  
                  // 清空按钮
                  GestureDetector(
                    onTap: _onClearAllConversations,
                    child: const Text(
                      '清空',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 对话列表
            Consumer<ConversationProvider>(
              builder: (context, conversationProvider, child) {
                if (conversationProvider.isLoading && !conversationProvider.hasConversations) {
                  return _buildLoadingState();
                }
                
                if (conversationProvider.errorMessage != null) {
                  return _buildErrorState(conversationProvider.errorMessage!);
                }
                
                if (!conversationProvider.hasConversations) {
                  return _buildEmptyState();
                }
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: conversationProvider.conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = conversationProvider.conversations[index];
                    final otherUser = conversationProvider.getOtherUser(
                      conversation,
                      'current_user_id', // 实际项目中从用户状态获取
                    );
                    
                    return ConversationListItem(
                      conversation: conversation,
                      otherUser: otherUser,
                      currentUserId: 'current_user_id',
                      onTap: () => _onConversationTap(conversation, otherUser),
                      onLongPress: () => _onConversationLongPress(conversation),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    return Container(
      height: 200,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
        ),
      ),
    );
  }

  /// 构建错误状态
  Widget _buildErrorState(String error) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: const TextStyle(
              fontSize: 16,
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ConversationProvider>().loadConversations(forceRefresh: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无对话',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '开始你的第一次对话吧',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// 处理分类点击
  void _onCategoryTap(MessageCategory category) {
    developer.log('MessageMainPage: 点击分类卡片: ${category.value}');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryMessagePage(category: category),
      ),
    );
  }

  /// 处理对话点击
  void _onConversationTap(Conversation conversation, MessageUser? otherUser) {
    developer.log('MessageMainPage: 点击对话: ${conversation.id}');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          conversationId: conversation.id,
          otherUser: otherUser,
        ),
      ),
    ).then((_) {
      // 从聊天页面返回时，刷新对话列表
      context.read<ConversationProvider>().loadConversations();
    });
  }

  /// 处理对话长按
  void _onConversationLongPress(Conversation conversation) {
    developer.log('MessageMainPage: 长按对话: ${conversation.id}');
    
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildConversationActionSheet(conversation),
    );
  }

  /// 构建对话操作面板
  Widget _buildConversationActionSheet(Conversation conversation) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              '对话操作',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          
          // 操作选项
          ListTile(
            leading: Icon(
              conversation.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: const Color(0xFF8B5CF6),
            ),
            title: Text(conversation.isPinned ? '取消置顶' : '置顶对话'),
            onTap: () {
              Navigator.pop(context);
              context.read<ConversationProvider>().toggleConversationPin(conversation.id);
            },
          ),
          
          ListTile(
            leading: Icon(
              conversation.isMuted ? Icons.notifications : Icons.notifications_off,
              color: Colors.orange,
            ),
            title: Text(conversation.isMuted ? '取消静音' : '静音对话'),
            onTap: () {
              Navigator.pop(context);
              context.read<ConversationProvider>().toggleConversationMute(conversation.id);
            },
          ),
          
          ListTile(
            leading: const Icon(
              Icons.mark_email_read,
              color: Colors.green,
            ),
            title: const Text('标记已读'),
            onTap: () {
              Navigator.pop(context);
              context.read<ConversationProvider>().markConversationAsRead(conversation.id);
            },
          ),
          
          ListTile(
            leading: const Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),
            title: const Text('删除对话'),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmDialog(conversation);
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

  /// 显示删除确认对话框
  void _showDeleteConfirmDialog(Conversation conversation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除对话'),
        content: const Text('确定要删除这个对话吗？删除后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ConversationProvider>().deleteConversation(conversation.id);
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

  /// 处理消息设置
  void _onMessageSettings() {
    developer.log('MessageMainPage: 点击消息设置');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('消息设置功能开发中...'),
        backgroundColor: Color(0xFF8B5CF6),
      ),
    );
  }

  /// 处理清空所有对话
  void _onClearAllConversations() {
    developer.log('MessageMainPage: 点击清空所有对话');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空对话'),
        content: const Text('确定要清空所有对话记录吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ConversationProvider>().clearAllConversations();
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

  /// 处理下拉刷新
  Future<void> _onRefresh() async {
    try {
      final messageProvider = context.read<MessageProvider>();
      final conversationProvider = context.read<ConversationProvider>();
      
      // 并行刷新数据
      await Future.wait([
        messageProvider.refreshMessageStats(),
        conversationProvider.refreshConversations(),
      ]);
      
      developer.log('MessageMainPage: 刷新完成');
    } catch (e) {
      developer.log('MessageMainPage: 刷新失败: $e');
    }
  }
}
