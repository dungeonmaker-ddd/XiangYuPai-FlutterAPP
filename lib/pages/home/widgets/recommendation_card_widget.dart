import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/home_routes.dart';
import '../config/home_config.dart';

/// 💫 推荐卡片组件
/// 显示用户推荐信息，支持横向滑动
class RecommendationCardWidget extends StatelessWidget {
  final List<UserModel> users;
  final String title;
  final ValueChanged<UserModel>? onUserTap;

  const RecommendationCardWidget({
    super.key,
    required this.users,
    this.title = '限时专享',
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color(HomeConfig.cardBackgroundColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context),
          _buildUserCards(context),
          const SizedBox(height: 16), // 底部间距
        ],
      ),
    );
  }

  /// 构建区域标题
  Widget _buildSectionHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '优质好玩',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              // TODO: 跳转到更多页面
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('更多页面即将上线'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '更多',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建用户卡片列表
  Widget _buildUserCards(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < users.length - 1 ? 12 : 0,
            ),
            child: _buildUserCard(context, users[index]),
          );
        },
      ),
    );
  }

  /// 构建单个用户卡片
  Widget _buildUserCard(BuildContext context, UserModel user) {
    return GestureDetector(
      onTap: () {
        onUserTap?.call(user);
        HomeRoutes.toUserProfilePage(context, user.userId);
      },
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[100],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户头像区域
            _buildUserAvatar(user),
            
            // 用户信息区域
            _buildUserInfo(user),
          ],
        ),
      ),
    );
  }

  /// 构建用户头像区域
  Widget _buildUserAvatar(UserModel user) {
    return Container(
      height: 120,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9C27B0),
            Color(0xFF673AB7),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 用户头像
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          
          // 在线状态
          if (user.isOnline)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          
          // 认证标识
          if (user.isVerified)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建用户信息区域
  Widget _buildUserInfo(UserModel user) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 昵称和年龄
          Row(
            children: [
              Expanded(
                child: Text(
                  user.nickname,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (user.age != null)
                Text(
                  '${user.age}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          // 位置和距离
          if (user.city != null || user.distance != null)
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 12,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    '${user.city ?? ''} ${user.distanceText}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          
          const SizedBox(height: 6),
          
          // 标签
          if (user.tags.isNotEmpty)
            Wrap(
              children: user.tags.take(2).map((tag) => Container(
                margin: const EdgeInsets.only(right: 4, bottom: 2),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey[700],
                  ),
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }
}
