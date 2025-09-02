import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/home_routes.dart';

/// 👤 用户资料卡片组件
/// 显示用户信息，用于附近推荐等列表页面
class UserProfileCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final bool showDistance;

  const UserProfileCard({
    super.key,
    required this.user,
    this.onTap,
    this.showDistance = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => HomeRoutes.toUserProfilePage(context, user.userId),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildUserAvatar(),
            const SizedBox(width: 12),
            Expanded(child: _buildUserInfo()),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  /// 构建用户头像
  Widget _buildUserAvatar() {
    return Stack(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF9C27B0),
                Color(0xFF673AB7),
              ],
            ),
          ),
          child: const Icon(
            Icons.person,
            color: Colors.white,
            size: 30,
          ),
        ),
        
        // 在线状态指示器
        if (user.isOnline)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 构建用户信息
  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 用户名和认证标识
        Row(
          children: [
            Flexible(
              child: Text(
                user.nickname,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            if (user.isVerified)
              const Icon(
                Icons.verified,
                color: Colors.blue,
                size: 16,
              ),
            const SizedBox(width: 8),
            // 年龄显示
            if (user.age != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: user.gender == 1 ? Colors.blue[100] : Colors.pink[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: user.gender == 1 ? Colors.blue[300]! : Colors.pink[300]!,
                    width: 1,
                  ),
                ),
                child: Text(
                  '${user.age}',
                  style: TextStyle(
                    fontSize: 12,
                    color: user.gender == 1 ? Colors.blue[700] : Colors.pink[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 4),
        
        // 个人简介
        if (user.bio != null && user.bio!.isNotEmpty)
          Text(
            user.bio!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        
        const SizedBox(height: 6),
        
        // 位置和距离信息
        Row(
          children: [
            if (user.city != null) ...[
              Icon(
                Icons.location_on,
                size: 14,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 2),
              Text(
                user.city!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
            if (showDistance && user.distance != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  user.distanceText,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            const Spacer(),
            // 最后活跃时间
            Text(
              user.lastActiveText,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        
        // 标签显示
        if (user.tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Wrap(
              spacing: 4,
              runSpacing: 2,
              children: user.tags.take(3).map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.purple[200]!,
                    width: 1,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.purple[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
          ),
      ],
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // 在线状态文本
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: user.isOnline ? Colors.green[50] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: user.isOnline ? Colors.green[200]! : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Text(
            user.isOnline ? '在线' : '离线',
            style: TextStyle(
              fontSize: 11,
              color: user.isOnline ? Colors.green[700] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // 操作按钮
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              icon: Icons.chat_bubble_outline,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('聊天功能即将上线'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.favorite_border,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('关注功能即将上线'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  /// 构建小操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
