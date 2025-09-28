// 🎨 个人信息模块UI组件
// 提供头像、功能卡片、状态指示器等通用UI组件

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:developer' as developer;

import '../models/index.dart';
import '../providers/index.dart';

// ============== 1. 头像组件 ==============

/// 👤 用户头像组件
/// 支持圆形头像显示、编辑、上传进度等功能
class UserAvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final double size;
  final bool showEditButton;
  final bool showOnlineStatus;
  final UserStatus? userStatus;
  final VoidCallback? onTap;
  final VoidCallback? onEditTap;

  const UserAvatarWidget({
    super.key,
    this.avatarUrl,
    this.size = 80,
    this.showEditButton = false,
    this.showOnlineStatus = false,
    this.userStatus,
    this.onTap,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // 头像主体
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: _buildAvatarImage(),
            ),
          ),
          
          // 上传进度指示器
          Consumer<UserProfileProvider>(
            builder: (context, provider, child) {
              if (!provider.isUploadingAvatar) return const SizedBox.shrink();
              
              return Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          value: provider.uploadProgress,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(provider.uploadProgress * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          // 编辑按钮
          if (showEditButton)
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: onEditTap,
                child: Container(
                  width: size * 0.3,
                  height: size * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: size * 0.15,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          
          // 在线状态指示器
          if (showOnlineStatus && userStatus != null)
            Positioned(
              right: size * 0.05,
              top: size * 0.05,
              child: UserStatusIndicator(
                status: userStatus!,
                size: size * 0.15,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage() {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return Image.network(
        avatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    }
    
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: const Color(0xFF8B5CF6).withOpacity(0.1),
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: const Color(0xFF8B5CF6),
      ),
    );
  }
}

// ============== 2. 用户状态指示器 ==============

/// 🔘 用户状态指示器
/// 显示用户在线状态的圆点指示器
class UserStatusIndicator extends StatelessWidget {
  final UserStatus status;
  final double size;
  final bool showLabel;

  const UserStatusIndicator({
    super.key,
    required this.status,
    this.size = 12,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);
    
    Widget indicator = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: statusColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: size * 0.1,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );

    // 在线状态移除动画，使用静态绿色圆点
    // 注释：为了避免内存泄漏和性能问题，暂时移除脉搏动画

    if (showLabel) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          const SizedBox(width: 4),
          Text(
            _getStatusLabel(status),
            style: TextStyle(
              color: statusColor,
              fontSize: size * 0.8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return indicator;
  }

  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.online:
        return Colors.green;
      case UserStatus.away:
        return Colors.orange;
      case UserStatus.busy:
        return Colors.red;
      case UserStatus.offline:
        return Colors.grey;
    }
  }

  String _getStatusLabel(UserStatus status) {
    switch (status) {
      case UserStatus.online:
        return '在线';
      case UserStatus.away:
        return '离开';
      case UserStatus.busy:
        return '忙碌';
      case UserStatus.offline:
        return '离线';
    }
  }
}


// ============== 3. 功能卡片组件 ==============

/// 🎯 功能卡片组件
/// 用于显示各种功能入口，支持图标、标题、角标等
class FunctionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final int? badge;
  final String? badgeText;
  final double size;
  final double iconSize;

  const FunctionCard({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
    this.badge,
    this.badgeText,
    this.size = 64,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标容器
            Stack(
              children: [
                Container(
                  width: size * 0.625, // 40px when size is 64px
                  height: size * 0.625,
                  decoration: BoxDecoration(
                    color: backgroundColor ?? const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(size * 0.3125), // 20px when size is 64px
                    boxShadow: [
                      BoxShadow(
                        color: (backgroundColor ?? const Color(0xFF8B5CF6)).withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: iconSize,
                    color: iconColor ?? Colors.white,
                  ),
                ),
                
                // 角标
                if (badge != null && badge! > 0 || badgeText != null)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badgeText ?? (badge! > 99 ? '99+' : badge.toString()),
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
            
            SizedBox(height: size * 0.0625), // 4px when size is 64px
            
            // 标题
            Text(
              title,
              style: TextStyle(
                fontSize: size * 0.1875, // 12px when size is 64px
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
}

// ============== 4. 交易统计卡片 ==============

/// 📊 交易统计卡片
/// 显示我的发布、订单、购买、报名等统计数据
class TransactionStatsCard extends StatelessWidget {
  final TransactionStats? stats;
  final bool isLoading;
  final VoidCallback? onPublishTap;
  final VoidCallback? onOrderTap;
  final VoidCallback? onPurchaseTap;
  final VoidCallback? onEnrollmentTap;

  const TransactionStatsCard({
    super.key,
    this.stats,
    this.isLoading = false,
    this.onPublishTap,
    this.onOrderTap,
    this.onPurchaseTap,
    this.onEnrollmentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // 标题
          const Text(
            '交易',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // 统计网格
          if (isLoading)
            _buildLoadingGrid()
          else
            _buildStatsGrid(),
        ],
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(4, (index) {
        return Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 50,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatsGrid() {
    final items = [
      _TransactionItem(
        title: '我的发布',
        icon: Icons.edit_note,
        color: const Color(0xFF8B5CF6),
        count: stats?.publishCount ?? 0,
        onTap: onPublishTap,
      ),
      _TransactionItem(
        title: '我的订单',
        icon: Icons.receipt_long,
        color: const Color(0xFF3B82F6),
        count: stats?.orderCount ?? 0,
        onTap: onOrderTap,
      ),
      _TransactionItem(
        title: '我的购买',
        icon: Icons.shopping_bag,
        color: const Color(0xFF10B981),
        count: stats?.purchaseCount ?? 0,
        onTap: onPurchaseTap,
      ),
      _TransactionItem(
        title: '我的报名',
        icon: Icons.how_to_reg,
        color: const Color(0xFFF59E0B),
        count: stats?.enrollmentCount ?? 0,
        onTap: onEnrollmentTap,
      ),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items.map((item) => _buildTransactionItem(item)).toList(),
    );
  }

  Widget _buildTransactionItem(_TransactionItem item) {
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  item.icon,
                  color: Colors.white,
                  size: 20,
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
    );
  }
}

class _TransactionItem {
  final String title;
  final IconData icon;
  final Color color;
  final int count;
  final VoidCallback? onTap;

  const _TransactionItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.count,
    this.onTap,
  });
}

// ============== 5. 钱包信息卡片 ==============

/// 💰 钱包信息卡片
/// 显示余额、金币等钱包信息
class WalletInfoCard extends StatelessWidget {
  final Wallet? wallet;
  final bool isLoading;
  final VoidCallback? onWalletTap;
  final VoidCallback? onCoinTap;

  const WalletInfoCard({
    super.key,
    this.wallet,
    this.isLoading = false,
    this.onWalletTap,
    this.onCoinTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 钱包
          Expanded(
            child: _buildWalletItem(
              title: '钱包',
              icon: Icons.account_balance_wallet,
              color: const Color(0xFF3B82F6),
              value: isLoading ? '...' : (wallet?.balanceDisplay ?? '¥0.00'),
              onTap: onWalletTap,
            ),
          ),
          const SizedBox(width: 12),
          
          // 金币
          Expanded(
            child: _buildWalletItem(
              title: '金币',
              icon: Icons.monetization_on,
              color: const Color(0xFFFFC107),
              value: isLoading ? '...' : (wallet?.coinDisplay ?? '0'),
              onTap: onCoinTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletItem({
    required String title,
    required IconData icon,
    required Color color,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ============== 6. 加载状态组件 ==============

/// ⏳ 加载状态组件
/// 用于显示页面加载状态
class ProfileLoadingWidget extends StatelessWidget {
  const ProfileLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '加载中...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ============== 7. 错误状态组件 ==============

/// ❌ 错误状态组件
/// 用于显示加载错误状态
class ProfileErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const ProfileErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '加载失败',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
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
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('重试'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
