// 👤 个人信息主页面
// 展示用户信息、交易统计、钱包信息和功能网格

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

import '../models/index.dart';
import '../providers/index.dart';
import '../widgets/index.dart';

// ============== 数据类定义 ==============

/// 交易网格项数据类
class _TransactionGridItem {
  final String title;
  final IconData icon;
  final Color color;
  final int count;
  final VoidCallback? onTap;

  const _TransactionGridItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.count,
    this.onTap,
  });
}

// ============== 1. 主页面组件 ==============

/// 🏠 个人信息主页面
/// 整合用户信息、交易统计、钱包信息等模块
class ProfileMainPage extends StatefulWidget {
  const ProfileMainPage({super.key});

  @override
  State<ProfileMainPage> createState() => _ProfileMainPageState();
}

class _ProfileMainPageState extends State<ProfileMainPage> {
  static const String _logTag = 'ProfileMainPage';

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  /// 初始化用户数据
  void _initializeUserData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        const mockUserId = 'user_123456'; // 模拟用户ID
        
        // 分别初始化各个Provider
        context.read<UserProfileProvider>().initializeUser(mockUserId);
        context.read<TransactionStatsProvider>().loadTransactionStats(mockUserId);
        context.read<WalletProvider>().loadWallet(mockUserId);
        
        developer.log('$_logTag: 开始加载用户数据 - $mockUserId');
      } catch (e) {
        developer.log('$_logTag: 初始化用户数据失败 - $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 设置页面背景色为浅灰色
      backgroundColor: const Color(0xFFF8F8F8), // #F8F8F8 浅灰色背景
      body: Consumer3<UserProfileProvider, TransactionStatsProvider, WalletProvider>(
        builder: (context, userProvider, statsProvider, walletProvider, child) {
          // 显示加载状态
          if (userProvider.isLoading) {
            return const ProfileLoadingWidget();
          }

          // 显示错误状态
          if (userProvider.hasError) {
            return ProfileErrorWidget(
              error: userProvider.profileError ?? '加载用户信息失败',
              onRetry: () => _initializeUserData(),
            );
          }

          // 获取用户信息
          final userProfile = userProvider.profile;
          if (userProfile == null) {
            return const ProfileErrorWidget(
              error: '用户信息不存在',
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              slivers: [
                // 1. 页面标题区域（简单的标题）
                _buildPageHeader(),
                
                // 2. 紫色header + 用户信息 + 嵌套交易模块的完整层叠区域
                _buildCompleteStackedSection(userProfile, statsProvider),
                
                // 4. 更多内容区域
                _buildMoreContentSection(walletProvider),
                
                // 5. 底部安全区域
                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 下拉刷新
  Future<void> _onRefresh() async {
    try {
      developer.log('$_logTag: 开始刷新数据');
      
      const mockUserId = 'user_123456';
      await Future.wait([
        context.read<UserProfileProvider>().loadUserProfile(forceRefresh: true),
        context.read<TransactionStatsProvider>().loadTransactionStats(mockUserId),
        context.read<WalletProvider>().loadWallet(mockUserId),
      ]);
      
      developer.log('$_logTag: 数据刷新完成');
    } catch (e) {
      developer.log('$_logTag: 刷新数据失败 - $e');
    }
  }

  /// 处理编辑个人资料
  void _handleEditProfile() {
    developer.log('$_logTag: 点击编辑个人资料');
    // TODO: 跳转到编辑个人资料页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('编辑个人资料功能开发中...')),
    );
  }

  /// 构建页面标题区域
  Widget _buildPageHeader() {
    return SliverToBoxAdapter(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '我的',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建用户信息区域（白色背景）
  Widget _buildUserInfoSection(UserProfile userProfile) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // 用户头像
            _buildUserAvatar(userProfile),
            
            const SizedBox(width: 16),
            
            // 用户信息文字
            Expanded(
              child: _buildUserInfoText(userProfile),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建紫色渐变header区域（在下方）
  Widget _buildPurpleGradientHeader() {
    return SliverToBoxAdapter(
      child: Container(
        height: 120, // 紫色header的高度
        margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8A2BE2), // 紫色开始
              Color(0xFFB19CD9), // 浅紫色结束
            ],
          ),
        ),
      ),
    );
  }

  /// 构建完整的层叠区域 - 紫色header + 用户信息 + 嵌套交易模块
  Widget _buildCompleteStackedSection(UserProfile userProfile, TransactionStatsProvider statsProvider) {
    return SliverToBoxAdapter(
      child: Container(
        height: 280, // 增加高度以容纳用户信息
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Stack(
          children: [
            // 底层：紫色渐变header（较高以容纳用户信息）
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 200, // 增加紫色header高度
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      // 背景图片
                      Positioned.fill(
                        child: Image.asset(
                          'pages/profile/背景.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      // 渐变遮罩，增强可读性并与下方过渡
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.6, 1.0],
                              colors: [
                                Colors.black.withOpacity(0.10),
                                Colors.black.withOpacity(0.05),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // 内容
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20), // 留出顶部空间
                            
                            // 用户信息区域（在紫色背景上）
                            Row(
                              children: [
                                // 用户头像（白色边框在紫色背景上更醒目）
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                                  ),
                                  child: _buildUserAvatar(userProfile),
                                ),
                                
                                const SizedBox(width: 16),
                                
                                // 用户信息文字（白色文字）
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userProfile.username,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        userProfile.bio?.isEmpty != false ? 
                                          '这个家伙很懒惰，没有填写简介' : userProfile.bio!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // 编辑按钮（白色图标）
                                GestureDetector(
                                  onTap: () => _handleEditProfile(),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.edit_outlined,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // 上层：交易模块 - 嵌套在紫色header的下半部分
            Positioned(
              top: 140, // 调整位置，在用户信息下方
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0x80FFFFFF), // rgba(255, 255, 255, 0.5) 半透明白色
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 交易区域标题
                    const Text(
                      '交易',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 交易功能网格 (4个功能按钮)
                    _buildTransactionGrid(statsProvider),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建旧的层叠效果区域（保留备用）
  Widget _buildStackedHeaderWithTransaction_OLD(TransactionStatsProvider statsProvider) {
    return SliverToBoxAdapter(
      child: Container(
        height: 200, // 总高度：紫色header(120) + 交易模块底部(80)
        margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        child: Stack(
          children: [
            // 底层：紫色渐变header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120, // 紫色header高度
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF8A2BE2), // 紫色开始
                      Color(0xFFB19CD9), // 浅紫色结束
                    ],
                  ),
                ),
              ),
            ),
            
            // 上层：交易模块 - 嵌套在紫色header的下半部分
            Positioned(
              top: 60, // 从紫色header的中间位置开始
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0x80FFFFFF), // rgba(255, 255, 255, 0.5) 半透明白色
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 交易区域标题
                    const Text(
                      '交易',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 交易功能网格 (4个功能按钮)
                    _buildTransactionGrid(statsProvider),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建旧的"我的"卡片区域（保留原方法以防需要）
  Widget _buildGradientHeaderWithSystemBar_OLD(UserProfile userProfile) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.97],
            colors: [
              Color(0x00F8F8F8), // 透明的F8F8F8开始
              Color(0xFFF8F8F8), // 97%处完全的F8F8F8
            ],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF8A2BE2), // 紫色开始
                Color(0xFFB19CD9), // 浅紫色结束
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 页面标题
                const Text(
                  '我的',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 用户信息区域
                Row(
                  children: [
                    // 用户头像
                    _buildUserAvatar(userProfile),
                    
                    const SizedBox(width: 16),
                    
                    // 用户信息文字
                    Expanded(
                      child: _buildUserInfoText(userProfile),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  /// 构建用户头像
  Widget _buildUserAvatar(UserProfile userProfile) {
    return GestureDetector(
      onTap: () => _editAvatar(),
      child: Stack(
        children: [
          // 头像主体
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
            ),
            child: ClipOval(
              child: userProfile.avatar?.isNotEmpty == true
                  ? Image.network(
                      userProfile.avatar!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar();
                      },
                    )
                  : _buildDefaultAvatar(),
            ),
          ),
          
          // 在线状态指示器
          Positioned(
            right: 4,
            bottom: 4,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getStatusColor(userProfile.status),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
          
          // 编辑图标
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Icon(
                Icons.camera_alt,
                size: 10,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建默认头像
  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.white.withOpacity(0.2),
      child: const Icon(
        Icons.person,
        size: 30,
        color: Colors.white,
      ),
    );
  }

  /// 获取状态颜色
  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.online:
        return Colors.green;
      case UserStatus.busy:
        return Colors.orange;
      case UserStatus.away:
        return Colors.yellow;
      case UserStatus.offline:
        return Colors.grey;
    }
  }

  /// 构建用户信息文字
  Widget _buildUserInfoText(UserProfile userProfile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 用户昵称
        Row(
          children: [
            Expanded(
              child: Text(
                userProfile.nickname,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 编辑按钮
            GestureDetector(
              onTap: () => _editProfile(),
              child: Icon(
                Icons.edit,
                size: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // 用户简介
        GestureDetector(
          onTap: () => _editProfile(),
          child: Text(
            userProfile.bio?.isEmpty != false
                ? '这个家伙很神秘，没有填写简介'
                : userProfile.bio!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// 构建嵌套的交易功能区域 - 嵌套在紫色header的上半部分
  Widget _buildNestedTransactionSection(TransactionStatsProvider statsProvider) {
    return SliverToBoxAdapter(
      child: Transform.translate(
        offset: const Offset(0, -60), // 向上偏移，嵌套到紫色header的上半部分
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0x80FFFFFF), // rgba(255, 255, 255, 0.5) 半透明白色
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 交易区域标题
              const Text(
                '交易',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 交易功能网格 (4个功能按钮)
              _buildTransactionGrid(statsProvider),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建原始交易功能区域(保留备用)
  Widget _buildTransactionSection_OLD(TransactionStatsProvider statsProvider) {
    return SliverToBoxAdapter(
      child: Transform.translate(
        offset: const Offset(0, -24), // 浮动在渐变背景上层
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0x80FFFFFF), // rgba(255, 255, 255, 0.5) 半透明白色
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 交易区域标题
            const Text(
              '交易',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 4宫格交易功能
            Consumer<TransactionStatsProvider>(
              builder: (context, provider, child) {
                return _buildTransactionGrid(provider);
              },
            ),
          ],
        ),
        ),
      ),
    );
  }

  /// 构建4宫格交易功能网格
  Widget _buildTransactionGrid(TransactionStatsProvider provider) {
    final stats = provider.stats;
    
    final transactionItems = [
      _TransactionGridItem(
        title: '我的发布',
        icon: Icons.edit_note_outlined,
        color: const Color(0xFF666666), // 灰色线框风格
        count: stats?.publishCount ?? 0,
        onTap: () => _showTransactionDetail('publish'),
      ),
      _TransactionGridItem(
        title: '我的订单',
        icon: Icons.receipt_long_outlined,
        color: const Color(0xFF666666), // 灰色线框风格
        count: stats?.orderCount ?? 0,
        onTap: () => _showTransactionDetail('order'),
      ),
      _TransactionGridItem(
        title: '我的购买',
        icon: Icons.shopping_bag_outlined,
        color: const Color(0xFF666666), // 灰色线框风格
        count: stats?.purchaseCount ?? 0,
        onTap: () => _showTransactionDetail('purchase'),
      ),
      _TransactionGridItem(
        title: '我的报名',
        icon: Icons.mail_outline,
        color: const Color(0xFF666666), // 灰色线框风格
        count: stats?.enrollmentCount ?? 0,
        onTap: () => _showTransactionDetail('enrollment'),
      ),
    ];

    return Row(
      children: transactionItems.map((item) {
        return Expanded(
          child: _buildTransactionGridItem(item),
        );
      }).toList(),
    );
  }

  /// 构建单个交易功能项
  Widget _buildTransactionGridItem(_TransactionGridItem item) {
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            // 功能图标
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.color,
                    size: 24,
                  ),
                ),
                
                // 数量角标
                if (item.count > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        item.count > 99 ? '99+' : item.count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // 功能标题
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建更多内容区域
  Widget _buildMoreContentSection(WalletProvider walletProvider) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 32, 16, 0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF), // #FFFFFF 白色背景
          borderRadius: BorderRadius.circular(12), // 12px 圆角
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 更多内容标题
            const Text(
              '更多内容',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 第一行功能组 (4个核心工具功能)
            _buildFeatureRow([
              _buildFeatureItem(
                title: '个人中心',
                icon: Icons.person,
                color: const Color(0xFFFF9500), // 橙色
                onTap: () => _handleFeatureTap('personal_center'),
              ),
              _buildFeatureItem(
                title: '状态',
                icon: Icons.circle,
                color: const Color(0xFFFF3B30), // 红色
                onTap: () => _handleFeatureTap('user_status'),
              ),
              _buildFeatureItem(
                title: '钱包',
                icon: Icons.account_balance_wallet,
                color: const Color(0xFF007AFF), // 蓝色
                onTap: () => _showWalletDetail(),
                badge: _getWalletBadge(walletProvider),
              ),
              _buildFeatureItem(
                title: '金币',
                icon: Icons.monetization_on,
                color: const Color(0xFFFFD700), // 金色
                onTap: () => _showCoinsDetail(),
                badge: _getCoinsBadge(walletProvider),
              ),
            ]),
            
            const SizedBox(height: 24),
            
            // 第二行功能组 (3个系统功能)
            _buildFeatureRow([
              _buildFeatureItem(
                title: '设置',
                icon: Icons.settings,
                color: const Color(0xFF8A2BE2), // 紫色
                onTap: () => _showSettings(),
              ),
              _buildFeatureItem(
                title: '客服',
                icon: Icons.support_agent,
                color: const Color(0xFF34C759), // 绿色
                onTap: () => _handleFeatureTap('customer_service'),
              ),
              _buildFeatureItem(
                title: '达人认证',
                icon: Icons.verified,
                color: const Color(0xFFFF3B30), // 粉红色
                onTap: () => _handleFeatureTap('verification'),
              ),
              // 第四个位置留空
              const SizedBox(width: 64),
            ]),
          ],
        ),
      ),
    );
  }

  /// 构建功能行
  Widget _buildFeatureRow(List<Widget> children) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children,
    );
  }

  /// 构建功能项
  Widget _buildFeatureItem({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 64,
        child: Column(
          children: [
            // 功能图标
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                
                // 角标显示
                if (badge != null)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // 功能标题
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 获取钱包角标
  String? _getWalletBadge(WalletProvider walletProvider) {
    final wallet = walletProvider.wallet;
    if (wallet != null && wallet.balance > 0) {
      return wallet.balance.toInt().toString();
    }
    return null;
  }

  /// 获取金币角标
  String? _getCoinsBadge(WalletProvider walletProvider) {
    final wallet = walletProvider.wallet;
    if (wallet != null && wallet.coinBalance > 0) {
      return wallet.coinBalance > 99 ? '99+' : wallet.coinBalance.toString();
    }
    return null;
  }


  // ============== 交互方法 ==============

  void _showSettings() {
    developer.log('$_logTag: 显示设置页面');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('设置功能开发中...')),
    );
  }

  void _editAvatar() {
    developer.log('$_logTag: 编辑头像');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('头像编辑功能开发中...')),
    );
  }

  void _editProfile() {
    developer.log('$_logTag: 编辑个人信息');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('个人信息编辑功能开发中...')),
    );
  }

  void _showTransactionDetail(String type) {
    developer.log('$_logTag: 显示交易详情 - $type');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$type 详情功能开发中...')),
    );
  }

  void _showWalletDetail() {
    developer.log('$_logTag: 显示钱包详情');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('钱包详情功能开发中...')),
    );
  }

  void _showCoinsDetail() {
    developer.log('$_logTag: 显示金币详情');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('金币详情功能开发中...')),
    );
  }


  void _handleFeatureTap(String featureId) {
    developer.log('$_logTag: 点击功能 - $featureId');
    
    switch (featureId) {
      case 'personal_center':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('个人中心功能开发中...')),
        );
        break;
      case 'user_status':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('用户状态功能开发中...')),
        );
        break;
      case 'customer_service':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('客服功能开发中...')),
        );
        break;
      case 'verification':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('达人认证功能开发中...')),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('功能 $featureId 开发中...')),
        );
    }
  }
}